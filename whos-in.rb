require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'haml'
require 'sass'
require 'sinatra/subdomain'
require 'random-word'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/whos-in.db")

class Attending
  include DataMapper::Resource
  property :id,     Serial
  property :subdomain, Text
  property :name,   Text
  property :timestamp, DateTime
end

DataMapper.auto_upgrade!

class WhosIn < Sinatra::Application
  enable :sessions
  register Sinatra::Subdomain
  
  subdomain do
    get '/' do

      if subdomain == "www"
        info_page
        exit
      end

      t = Date.today
      stale = Attending.all(:timestamp.lt => DateTime.new(t.year, t.month, t.day))
      stale.each { |a| a.destroy }

      @attending = Attending.all :subdomain => subdomain, :order => :timestamp.desc
      @added_id = session.delete :added_id

      haml :index
    end
    
    post '/add' do
      name = params[:name]
      name = 'Lazy Mystery Guest' if name.length == 0
      time = DateTime.now

      attendee = Attending.create(:name => name, :subdomain => subdomain, 
                                  :timestamp => time)

      session[:added_id] = attendee.id

      redirect '/', 303
    end

    post '/delete' do
      id = params[:id]

      victim = Attending.get(id)
      victim.destroy

      redirect '/', 303
    end
  end

  get '/' do
    info_page
  end

  def info_page
    haml :info, :locals => {:rando => unoccupied_word}
  end

  def unoccupied_word
    begin
      rando = RandomWord.nouns.first.gsub('_','-')
      count = Attending.count(:subdomain => rando)
    end while count != 0
    rando
  end
end
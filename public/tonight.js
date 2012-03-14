(function(){
  var
    offset = (new Date()).getTimezoneOffset() * -60000,
    timestamps = document.getElementsByClassName("timestamp"),
    i,
    timestamp,
    date,
    label,
    selectOutField
  
  for (i = 0; i < timestamps.length; i++) {
    timestamp = timestamps[i]
    date = new Date(parseInt(timestamp.attributes["data-unixtime"].value, 10) * 1000 + offset)
    label = (date.getHours() > 12 ? date.getHours() - 12 : date.getHours())
    label += ":" + date.getMinutes()
    label += (date.getHours() >= 12 ? "PM" : "AM")
    timestamp.innerHTML = label
  }
  
  selectOutField = function() {
    document.querySelector(".out form.add input").select()
  }
  
  if (location.hash === "#out") selectOutField()
  
  document.querySelector("h2 a.out").onclick = selectOutField
})()

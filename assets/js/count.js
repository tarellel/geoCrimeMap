function setCrimeCounts(crimes){
  // Replace 0 count with current crime counts
  $.each(crimes, function(crime_key, val){
    $(('.' + crime_key + "_count")).text(val);
  });
}

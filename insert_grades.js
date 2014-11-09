$.each($('div.restaurant-name'), function(index, inspection) {
  var $restaurantLink = $(this).find('a');

  var restaurantName = $restaurantLink.text().trim();
  var linkHref = $restaurantLink.attr('href');
  var vendorId = linkHref.split('.')[1];

  // Send address to server, wait for letter grade response
  var letterGrade // based on response from server
  $(this).append("<a href='http://www.google.com' target='_blank'><img src='" + letterGrade + "' style='height:35px'/></a>");
});
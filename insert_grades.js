gradeA = "http://parmenides.wnyc.org/media/photologue/photos/Grade%20Card_C_v2.jpg"
gradeB = "http://parmenides.wnyc.org/media/photologue/photos/Grade%20Card_B_v2.jpg"
gradeC = "http://parmenides.wnyc.org/media/photologue/photos/Grade%20Card_C_v2.jpg"
gradePending = "http://parmenides.wnyc.org/media/photologue/photos/Grade%20Card_GradePending_v2.jpg"

$.each($('div.restaurant-name'), function(index, inspection) {
  var $restaurantLink = $(this).find('a');

  var restaurantName = $restaurantLink.text().trim();
  var linkHref = $restaurantLink.attr('href');
  var vendorId = linkHref.split('.')[1];

  // Send address to server, wait for letter grade response
  var letterGrade = gradeB
  $(this).append("<a href='http://www.google.com' target='_blank'><img src='" + letterGrade + "' style='height:35px'/></a>");
});
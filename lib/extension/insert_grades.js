$.each($('div.restaurant-name'), function(index, inspection) {
  var restaurantElement = $(this);
  var $restaurantLink = restaurantElement.find('a');
  var linkHref = $restaurantLink.attr('href');
  var vendorId = linkHref.split('.')[1];

  $.ajax({
    url: 'http://localhost:3000/health_inspections',
    data: {
      'vendorId': vendorId,
      'restaurantHref': linkHref
    },
    type: 'GET',
    success: function(response) {
      var letterGrade = response['letter_grade'];

      $(restaurantElement).append(
        "<a href='http://www.google.com' target='_blank'>" +
        "<img src='chrome-extension://jaomghcnjgmcadjgahcagkhllfaimagl/Grade" + letterGrade + ".jpg' style='height:35px'/></a>"
        );
    },
    error: function(response) {
      // Should we do anything?
      console.log(response);
    }
  })
});

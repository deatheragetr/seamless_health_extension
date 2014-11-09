$.each($('div.restaurant-name'), function(index, inspection) {
  var $restaurantLink = $(this).find('a');
  var linkHref = $restaurantLink.attr('href');
  var vendorId = linkHref.split('.')[1];

  $.ajax({
    url: 'server.com',
    data: {
      'vendorId': vendorId,
      'restaurantHref': linkHref
    },
    type: 'GET',
    success: function(response) {
      var letterGrade = response['letterGrade']; // based on response from server
      $(this).append(
        "<a href='http://www.google.com' target='_blank'>" +
        "<img src='" + letterGrade + "' style='height:35px'/></a>"
        );
    },
    error: function(response) {
      // Should we do anything?
    }
  })
});
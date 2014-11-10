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
      var letterGrade = response.letter_grade;
      if (letterGrade === 'Z') { letterGrade = 'Pending' }

      if (letterGrade != 'Not Yet Graded') {
        $(restaurantElement).append(
          "<a href='http://www.google.com' target='_blank'>" +
            "<img src='chrome-extension://jaomghcnjgmcadjgahcagkhllfaimagl/Grade" + letterGrade + ".jpg'/>" +
          "</a>"
        );
      } else {
        $(restaurantElement).append("<a href='http://www.google.com' target='_blank'>(Not Yet Graded)</a>");
      }
    },
    error: function(response) {
      $(restaurantElement).append("<a href='http://www.google.com' target='_blank'>(NYC Grade not found)</a>");
    }
  })
});

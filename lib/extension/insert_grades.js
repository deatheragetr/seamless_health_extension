var containerSize;

$(document).ajaxComplete(function(e) {
  console.log('HELLOOOOOO');

  var currentContainerSize = $('.v-container.list .v-block').size();

  if (currentContainerSize !== containerSize) {
    containerSize = currentContainerSize;

    $.each($('div.restaurant-name:not(.grade-searching):not(.grade-added)'), function(index, inspection) {
      var restaurantElement = $(this);
      var $restaurantLink = restaurantElement.find('a');
      var linkHref = $restaurantLink.attr('href');
      var vendorId = linkHref.split('.')[1];

      $(restaurantElement).addClass('grade-searching');

      $.ajax({
        url: 'http://seamless-health-grades.herokuapp.com/health_inspections',
        data: {
          'vendorId': vendorId,
          'restaurantHref': linkHref
        },
        type: 'GET',
        success: function(response) {
          var letterGrade = response.letter_grade;
          var show_page   = response.show_violations_url;
          if (letterGrade === 'Z') { letterGrade = 'Pending' }

          if (letterGrade != 'Not Yet Graded') {
            $(restaurantElement).removeClass('grade-searching').addClass('grade-added').append(
              "<a href='" + show_page + "' target='_blank'>" +
                "<img src='chrome-extension://" + chrome.runtime.id + "/Grade" + letterGrade + ".jpg'/>" +
              "</a>"
            );
          } else {
            $(restaurantElement).append("<a href='"+ show_page + "' target='_blank'>(Not Yet Graded)</a>");
          }
        },
        error: function(response) {
          $(restaurantElement).append("<a href='#' target='_blank'>(Not Yet Graded)</a>");
        }
      })
    });
  }
});

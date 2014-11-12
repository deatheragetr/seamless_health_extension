$(document).ready(function() {
  var containerSize;

  $('#HeaderContainer').bind('DOMSubtreeModified', function() {
    var json = {};
    var currentContainerSize = $('.v-container.list .v-block').size();

    if (currentContainerSize !== containerSize) {
      containerSize = currentContainerSize;

      $.each($('div.restaurant-name:not(.grade-searching):not(.grade-added)'), function(index, element) {
        var $restaurantElement = $(element);
        var $restaurantLink = $restaurantElement.find('a');
        var linkHref = $restaurantLink.attr('href');
        var vendorId = linkHref.split('.')[1];

        $restaurantElement.addClass('grade-searching');
        json[vendorId] = linkHref;
      });

      $.ajax({
        url: 'http://seamless-health-grades.herokuapp.com/health_inspections',
        data: { 'json': json },
        type: 'GET',
        success: function(response) {
          var restaurantGrades = response.serverResponse;

          $.each(restaurantGrades, function(key) {
            var $restaurantElement = $('a[rel="VendorName_" + key + ""]').parent();
            var letterGrade = restaurantGrades[key].letterGrade;
            var show_page   = restaurantGrades[key].showPage;
            if (letterGrade === 'Z') { letterGrade = 'Pending'; }

            if (letterGrade != 'Not Yet Graded') {
              $restaurantElement.removeClass('grade-searching').addClass('grade-added').append(
                      "<a href='" + show_page + "' target='_blank'>" +
                      "<img src='chrome-extension://" + chrome.runtime.id + "/Grade" + letterGrade + ".jpg'/>" +
                      "</a>"
              );
            } else {
              $restaurantElement.append("<a href='" + show_page + "' target='_blank'>(Not Yet Graded)</a>");
            }
          });
        },
        error: function() {
          $restaurantElement.append("(Grade Not Listed)");
        }
      });
    }
  });
});

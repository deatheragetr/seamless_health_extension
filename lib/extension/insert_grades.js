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

        $restaurantElement
          .addClass('grade-searching')
          .append(
            "<img src='chrome-extension://" + chrome.runtime.id +
            "/images/loading_spinner.gif' class='doh_spinner' style='float:right'/>"
          );
        json[vendorId] = linkHref;
      });

      $.ajax({
        url: 'http://localhost:3000/health_inspections',
        data: { 'json': json },
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));},
        type: 'POST',
        success: function(response) {
          var gradesFound = response.grades_found;
          var gradesNotFound = response.grades_not_found;

          $.each(gradesFound, function(key, val) {
            var $restaurantElement = $('a[rel="VendorName_' + key + '"]').parent();
            var letterGrade = val.grade;
            var show_page   = val.url;

            if (letterGrade === 'Z' || letterGrade === 'P') { letterGrade = 'Pending'; }

            if (!$restaurantElement.hasClass('grade-added')) {
              if (letterGrade === 'Not Yet Graded') {
                $restaurantElement.find('.doh_spinner').remove();

                $restaurantElement
                    .removeClass('grade-searching')
                    .addClass('grade-added')
                    .append(
                    "<a href='" + show_page + "' target='_blank' style='font-size:12px;float:right'>" +
                    "(See Violations) " +
                    "<img src='chrome-extension://" + chrome.runtime.id + "/images/GradeNotYetGraded_2.jpg'" +
                    "alt='Letter Grade: " + letterGrade + "' />" +
                    "</a>"
                );
              } else {
                $restaurantElement.find('.doh_spinner').remove();

                $restaurantElement
                    .removeClass('grade-searching')
                    .addClass('grade-added')
                    .append(
                    "<a href='" + show_page + "' target='_blank' style='font-size:12px;float:right'>" +
                    "(See Violations) " +
                    "<img src='chrome-extension://" + chrome.runtime.id + "/images/Grade" + letterGrade + "_2.jpg'" +
                    "alt='Letter Grade: " + letterGrade + "' />" +
                    "</a>"
                );
              }
            }
          });

          $.each(gradesNotFound, function(i, key) {
            var $restaurantElement = $('a[rel="VendorName_' + key + '"]').parent();

            if (!$restaurantElement.hasClass('grade-added')) {
              $restaurantElement.find('.doh_spinner').remove();

              $restaurantElement
                  .removeClass('grade-searching')
                  .addClass('grade-added')
                  .append(
                  "<a href='http://seamless-health-grades.herokuapp.com/health_inspections/' target='_blank' style='font-size:12px;float:right'>" +
                  "(Grade not available)" +
                  "</a>"
              );
            }
          });
        },
        error: function(response) {
          //console.log("Ajax error: " + response);
        }
      });
    }
  });
});

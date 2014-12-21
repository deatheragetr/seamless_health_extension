$(document).ready(function() {
  var containerSize;
  var gradeNotAvailableLink = "<a href='http://www.cleaneats.nyc/health_inspections/'" +
                            " target='_blank' style='font-size:12px;float:right'>" +
                            "(Grade not available)</a>";

  if (document.URL.match(/food-delivery\/home/)) {
    $('#HeaderContainer').bind('DOMSubtreeModified', function() {
      var requestJson = {},
          currentContainerSize = $('h4.restaurant-name').size();

      if (currentContainerSize !== containerSize && currentContainerSize > 0) {
        containerSize = currentContainerSize;

        $.each($('h4.restaurant-name'), function(index, element) {
          var $restaurantElement = $(element),
              $restaurantLink = $restaurantElement.find('a');

          $restaurantElement.addClass('grade-searching');
          addSpinner($restaurantElement);

          if ($restaurantLink.length > 0) {
            var onClickFunction = $restaurantLink.attr('onclick'),
                restaurantLink = onClickFunction.toString().split("startNewOrder('/food-delivery")[1].split(");")[0].split("',")[0],
                vendorId = restaurantLink.split('.')[1];

            requestJson[vendorId] = {'onClickFunction': onClickFunction, 'restaurantLink': restaurantLink};
          }
        });

        setTimeout(function() {
          $.ajax({
            // url: 'http://seamless-health-grades.herokuapp.com/recently_ordered',
            url: 'http://localhost:3000/recently_ordered',
            data: { 'requestJson': requestJson },
            beforeSend: function(xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
            type: 'POST',
            success: function(response) {
              $.each(response.grades_found, function(key, val) {
                var $restaurantElements = $('a[onclick="' + val.onclick_function + '"]').parent(),
                    letterGrade = standardizeLetterGrade(val.grade);
                    showPage   = val.url;
                $.each($restaurantElements, function(index, restaurantElement) {
                  var $restaurantElement = $(restaurantElement);

                  if (!$restaurantElement.hasClass('grade-added')) {
                    insertGrade($restaurantElement, showPage, letterGrade, true, true, 'font-size:12px;float:right');
                  }
                });
              });

              $.each(response.grades_not_found, function(key, val) {
                var $restaurantElements = $('a[onclick="' + val + '"]').parent();
                var letterGrade = standardizeLetterGrade(val.grade);

                $.each($restaurantElements, function(index, restaurantElement) {
                  insertGrade(restaurantElement, 'http://www.cleaneats.nyc', 'NotYetGraded', true, true, 'font-size:12px;float:right');
                });
              });
            }
          });
        }, 1875);
      }
    });
  } else if (document.URL.match(/food-delivery\/vendors/)) {
    $('#HeaderContainer').bind('DOMSubtreeModified', function() {
      var requestJson = {},
          currentContainerSize = $('.v-container.list .v-block').size();

      if (currentContainerSize !== containerSize && currentContainerSize > 0) {
        containerSize = currentContainerSize;

        $.each($('div.restaurant-name:not(.grade-searching):not(.grade-added)'), function(index, element) {
          var $restaurantElement = $(element),
              $restaurantLink = $restaurantElement.find('a');

          var linkHref = $restaurantLink.attr('href'),
              vendorId = linkHref.split('.')[1];

          $restaurantElement.addClass('grade-searching');
          addSpinner($restaurantElement);

          requestJson[vendorId] = linkHref;
        });

        $.ajax({
          url: 'http://seamless-health-grades.herokuapp.com/health_inspections',
          // url: 'http://localhost:3000/health_inspections',
          data: { 'json': requestJson },
          beforeSend: function(xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
          type: 'POST',
          success: function(response) {
            $.each(response.grades_found, function(key, val) {
              var $restaurantElement = $('a[rel="VendorName_' + key + '"]').parent();

              var letterGrade = standardizeLetterGrade(val.grade),
                  showPage   = val.url;

              if (!$restaurantElement.hasClass('grade-added')) {
                if (letterGrade === 'Not Yet Graded') {
                  insertGrade($restaurantElement, showPage, 'NotYetGraded', false, true, 'font-size:12px;float:right');
                } else {
                  insertGrade($restaurantElement, showPage, letterGrade, false, true, 'font-size:12px;float:right');
                }
              }
            });

            $.each(response.grades_not_found, function(i, key) {
              var $restaurantElement = $('a[rel="VendorName_' + key + '"]').parent();

              if (!$restaurantElement.hasClass('grade-added')) {
                removeSpinner($restaurantElement);

                $restaurantElement.removeClass('grade-searching')
                    .addClass('grade-added')
                    .append(gradeNotAvailableLink);
              }
            });
          }
        });
      }
    });
  } else {
    var url = document.URL,
        vendorId = url.split('food-delivery/')[1].match(/\.\d+\.r/)[0].replace('.', '').replace('.', '').replace('r', ''),
        phoneNumber = $('span[itemprop="telephone"]').text();

    var requestJson = {
      'vendorId': vendorId,
      'url': url,
      'phoneNumber': phoneNumber
    }

    $.ajax({
      url: 'http://seamless-health-grades.herokuapp.com/seamless_show',
      // url: 'http://localhost:3000/seamless_show',
      data: { 'requestJson': requestJson },
      beforeSend: function(xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
      type: 'POST',
      success: function(response) {
        var $restaurantElement = $('#VendorName').parent();

        var letterGrade,
            showPage,
            style;

        if (response['response'] === 'Grade not found') {
          letterGrade = 'NotYetGraded';
          showPage    = 'http://www.cleaneats.nyc/health_inspections/';
        } else {
          letterGrade = standardizeLetterGrade(response.grade);
          showPage    = response.url;
        }

        insertGrade($restaurantElement, showPage, letterGrade, true, false, 'float:left;margin-right:1%');
        $restaurantElement.find('img').css('float', 'left');
      }
    });
  }
});

function standardizeLetterGrade(letterGrade) {
  if (letterGrade === 'Z' || letterGrade === 'P') {
    return 'Pending';
  } else {
    return letterGrade;
  }
}

function insertGrade(restaurantElement, showPage, letterGrade, showViolationsLink, append, style) {
  var letterGradeImage;

  if (showViolationsLink) {
    letterGradeImage = "<a href='" + showPage + "' target='_blank' style='" + style + "'>" +
                       "<img src='chrome-extension://" + chrome.runtime.id + "/images/Grade" + letterGrade + ".jpg'" +
                       "alt='Letter Grade: " + letterGrade + "' />" +
                       "</a>";

  } else {
    letterGradeImage = "<a href='" + showPage + "' target='_blank' style='" + style + "'>" +
                       "(See Violations) " +
                       "<img src='chrome-extension://" + chrome.runtime.id + "/images/Grade" + letterGrade + ".jpg'" +
                       "alt='Letter Grade: " + letterGrade + "' />" +
                       "</a>";
  }

  removeSpinner(restaurantElement);
  $(restaurantElement).removeClass('grade-searching')
      .addClass('grade-added');

  if (append) {
    $(restaurantElement).append(letterGradeImage);
  } else {
    $(restaurantElement).prepend(letterGradeImage);
  }
}

function addSpinner(restaurantElement) {
  $(restaurantElement).append(
    "<img src='chrome-extension://" + chrome.runtime.id +
    "/images/loading_spinner.gif' class='doh_spinner' style='float:right'/>"
  );
}

function removeSpinner(restaurantElement) {
  $(restaurantElement).find('.doh_spinner').remove();
}

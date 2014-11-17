class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :image_name

  def image_name(letter_grade)
    {
      "A" => "GradeA_2.jpg",
      "B" => "GradeB_2.jpg",
      "C" => "GradeC_2.jpg",
      "P" => "GradePending_2.jpg",
      "Z" => "GradePending_2.jpg",
      "Not Yet Graded" => "GradeNotYetGraded_2.jpg"
    }[letter_grade]
  end
end

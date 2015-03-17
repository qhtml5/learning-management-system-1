#coding: utf-8

class WhoShouldAttendWidget < ApplicationWidget

  after_initialize :setup!
  
  def display(args)
    # return render :nothing => true if !Flip.course_who_attend? 
    course = args[:course]
    if course.who_should_attend?
      @who_should_attend = course.who_should_attend
      render :layout => "widget_course"
    else
      return render :nothing => true
    end
  end

  private
    def setup!(*)
      @title = t('widgets.who_should_attend.title')
    end
end

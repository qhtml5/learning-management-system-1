#coding: utf-8

class CourseInstructorWidget < ApplicationWidget
  
  after_initialize :setup!
  
  def display(args)    
    @course = args[:course]

    if @course.instructor_bio.present?
      render :layout => "widget_course"
    else
      render :nothing => true
    end
  end
  
  private
    def setup!(*)
      @title = "O Instrutor"
    end
end

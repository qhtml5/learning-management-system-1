#coding: utf-8

class CourseSchoolWidget < ApplicationWidget
  
  after_initialize :setup!
  
  def display(args)
    # return render :nothing => true if !Flip.teacher_bio? 
    
    course = args[:course]
    @school = course.school
    @school_layout = @school.layout_configuration

    render :layout => "widget_course"
  end
  
  private
    def setup!(*)
      @title = "A Escola"
    end
end

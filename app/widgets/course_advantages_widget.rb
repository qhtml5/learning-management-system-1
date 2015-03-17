#coding: utf-8

class CourseAdvantagesWidget < ApplicationWidget
  
  after_initialize :setup!
  
  def display(args)
    return render :nothing => true if !args[:course].advantages.present?
    
    @course = args[:course]
    @school = @course.school
    @school_layout = @school.layout_configuration

    render :layout => "widget_course"
  end
  
  private
  def setup!(*)
    @title = "Vantagens ao comprar o curso"
  end
end

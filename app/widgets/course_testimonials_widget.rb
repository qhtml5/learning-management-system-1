#coding: utf-8

class CourseTestimonialsWidget < ApplicationWidget

  after_initialize :setup!
  
  def display(args)
    # return render :nothing => true if !Flip.course_testimonials? 
    
    course = args[:course] 
    if course.testimonials?
      @testimonials = course.testimonials
      render :layout => "widget_course"
    else
      return render :nothing => true
    end
      
  end
  
  private
    def setup!(*)
      @title = t('widgets.testimonials.title')
    end
end

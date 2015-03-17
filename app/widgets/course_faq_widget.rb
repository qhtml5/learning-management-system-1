#coding: utf-8

class CourseFaqWidget < ApplicationWidget

  after_initialize :setup!
  
  def display params
    # return render :nothing => true if !Flip.course_faq? 
    @course = params[:course]
    render :layout => "widget_course"
  end

  private
    def setup!(*)
      @title = t('widgets.course_faq.title')
    end
end

#coding: utf-8

class HowItWorksWidget < ApplicationWidget

  after_initialize :setup!
  
  def display
    return render :nothing => true if !Flip.how_course_works? 
    render :layout => "widget_course"
  end
  
  private
    def setup!(*)
      @title = t('widgets.how_it_works.title')
    end
end

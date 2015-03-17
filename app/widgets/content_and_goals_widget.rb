#coding: utf-8

class ContentAndGoalsWidget < ApplicationWidget

  after_initialize :setup!
  
  def display(args)
    # return render :nothing => true if !Flip.content_and_goals? 
    
    course = args[:course]
    if course.content_and_goals?
      @content_and_goals = course.content_and_goals
      render :layout => "widget_course"
    else
      return render :nothing => true
    end
  end
  
  private
    def setup!(*)
      @title = t('widgets.content_and_goals.title')
    end
end

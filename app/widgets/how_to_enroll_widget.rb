#coding: utf-8

class HowToEnrollWidget < ApplicationWidget

  after_initialize :setup!

  def display
    # return render :nothing => true if !Flip.how_easy_enroll_is? 
    render :layout => "widget_course"
  end
  
  private
    def setup!(*)
      @title = t('widgets.how_to_enroll.title')
    end
end

#coding: utf-8

class DownloadsWidget < ApplicationWidget

  after_initialize :setup!
  
  responds_to_event :show_downloads, :with => :display
  
  def display args
    # return render :nothing => true if !Flip.course_downloads? 
    
    course = args[:course]
    if course.downloads?
      @downloads = course.downloads
      render :layout => "widget_course"
    else
      return render :nothing => true
    end
  end
  
  private
    def setup!(*)
      @title = t('widgets.downloads.title')
      @icon = "fa-icon-paper-clip"
    end
end

#coding: utf-8

class CurriculumWidget < ApplicationWidget

  after_initialize :setup!

  responds_to_event :refresh_media, with: :refresh_media
  responds_to_event :back, with: :back
  
  def display params
    # return render :nothing => true if !Flip.course_curriculum? 
    @course = params[:course]
    @lessons = @course.lessons.available.order(:sequence).includes(:medias)
    @title = t('widgets.curriculum.title') 
    render :layout => "widget_course"
  end
  
  def sales_page params
    # return render :nothing => true if !Flip.course_curriculum? 
    @course = params[:course]
    @lessons = @course.lessons.available.order(:sequence).includes(:medias)
    @title = t('widgets.curriculum.title') 
    render :layout => "widget_course"
  end

  def crm_page params
    # return render :nothing => true if !Flip.course_curriculum? 
    @course = Course.find params[:course]
    @lessons = @course.lessons.available.order(:sequence).includes(:medias)
    @student = User.find params[:user]
    @title = "Progresso detalhado" 
    render :layout => "widget_course"
  end

  def back
    @course = Course.find(params[:course])
    replace :view => :display, :layout => "widget_course"
  end
  
  private
    def setup!(*)
      @icon = "icon-list-alt"
    end
end

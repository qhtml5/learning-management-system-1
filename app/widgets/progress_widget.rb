#coding: utf-8

class ProgressWidget < ApplicationWidget

  after_initialize :setup!
  
  def display params
    # return render :nothing => true if !Flip.course_progress? 
    @course = params[:course]
    @user = params[:user]
    @title = "Progresso"
    @icon = "icon-check"
    render :layout => "widget_course"
  end

  def crm_page params
    # return render :nothing => true if !Flip.course_progress? 
    @course = Course.find params[:course]
    @user = User.find params[:user]
    @title = "Progresso geral"
    render :layout => "widget_course"
  end

  private  

  def setup!(*)
    # @title = t('widgets.your_progress.title') 
  end
end

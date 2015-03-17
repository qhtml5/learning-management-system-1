#coding: utf-8

class Dashboard::MediasController < Dashboard::BaseController  
  def rename
    @course = current_user.courses.find(params[:course_id])
    @media = Media.find(params[:id])
    @media.update_attribute(:title, params[:media][:title]) if params[:media][:title].present?

    render :nothing => true
    authorize! :dashboard_medias_rename, @course
  end

  def sort
    @course = current_user.courses.find(params[:course_id])
    @lesson_media = LessonMedia.find(params[:id])
    @lesson_media.update_attribute :sequence_position, params[:position]
    
    render nothing: true
    authorize! :dashboard_medias_sort, @course
  end
end
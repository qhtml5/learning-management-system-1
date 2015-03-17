#coding: utf-8

class Dashboard::LessonsController < Dashboard::BaseController
  layout :layout_course

  include Apotomo::Rails::ControllerMethods 
  has_widgets do |root|
    root << widget(:edit_curriculum)
  end

  def index
    @course = Course.find(params[:course_id])
    authorize! :dashboard_lessons_index, @course
  end

  def rename
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:id])
    @lesson.update_attribute(:title, params[:lesson][:title]) if !params[:lesson][:title].blank?
    render :nothing => true

    authorize! :dashboard_lessons_rename, @course
  end

  def sort
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:id])
    @lesson.update_attribute :sequence_position, params[:position]
    render nothing: true

    authorize! :dashboard_lessons_sort, @course
  end

  private
	def layout_course
		"dashboard/course_edit"
	end

end
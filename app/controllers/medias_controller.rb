#coding: utf-8

class MediasController < ApplicationController
	before_filter :authenticate_user!

	include Apotomo::Rails::ControllerMethods	
	has_widgets do |root|
    root << widget(:curriculum)
    root << widget(:media)
  end

	def show
		@course = Course.find params[:course_id]
		@media = Media.find params[:id]
		@sequence = params[:counter]

		begin
			@content = Wistia::Media.find(@media.wistia_hashed_id) if @media.embed?
		rescue
			flash[:alert] = "Ocorreu um erro ao o renderizar conteúdo. Tente novamente mais tarde."
			redirect_to content_course_path(@course)
		end

		authorize! :show_media, @course
	end

	def ended
		@course = Course.find params[:course_id]
		@media = Media.find params[:id]

		Notification.create(
      sender: current_user,
      code: Notification::USER_ENDED_MEDIA,
      notifiable: @media,
      message: @course.title,
      personal: true
    )

    @started_notification = Notification.started_media.find_by_sender_id_and_notifiable_id(current_user.id, @media.id)
    @started_notification.destroy if @started_notification

    render nothing: true

    authorize! :ended, @course
	end
end
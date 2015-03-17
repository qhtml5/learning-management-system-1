#coding: utf-8

class Dashboard::LayoutConfigurationsController < Dashboard::BaseController	
	load_and_authorize_resource

	def index
		@user = current_user
		@school = @user.school
		@layout = @school.layout_configuration 
	end

	def update
		@layout = LayoutConfiguration.find(params[:id])

		if @layout.update_attributes(params[:layout_configuration])
			flash[:notice] = t('messages.layout.update.success')
			redirect_to dashboard_layout_configurations_path
		else
			flash[:alert] = t('messages.layout.update.failure')
			render :index
		end	
	end

end
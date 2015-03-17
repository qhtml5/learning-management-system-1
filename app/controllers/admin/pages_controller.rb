#coding: utf-8

class Admin::PagesController < ApplicationController
	layout :layout_admin
	authorize_resource :class => false

	include Apotomo::Rails::ControllerMethods	
  has_widgets do |root|
    root << widget(:admin_show_schools)
  end  
  
	def index
	end

	def courses
		@courses = Course.all.sort_by { |s| s.students.length }.reverse
	end

  def switch_to_school
    @school = School.find(params[:school_id])

    current_user.update_attribute :school_id, @school.id

    redirect_to root_path(subdomain: @school.subdomain, code: current_user.encrypted_password)
  end

	private
	def layout_admin
		"admin/admin"
	end
end
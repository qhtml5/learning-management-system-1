#coding: utf-8

class SchoolsController < ApplicationController
	# estava dando o erro: Firefox has detected that the server is redirecting the request for this address in a way that will never complete.
	#load_and_authorize_resource
  include Apotomo::Rails::ControllerMethods	
  has_widgets do |root|
    root << widget(:school_phone_email)
  end
  
  def home
	  @school = School.unscoped.find_by_subdomain(request.subdomain)	    
	  @school_layout = @school.layout_configuration
	  @course_categories = CourseCategory.includes(:courses).select { |cc| cc.courses.published.not_private.present? }
	  @courses = @school.courses.published.not_private.no_category.order("created_at DESC")
	end

end

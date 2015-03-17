#coding: utf-8

class Users::SessionsController < Devise::SessionsController
  include Apotomo::Rails::ControllerMethods 
  has_widgets do |root|
    root << widget(:secure_info)
    root << widget(:school_phone_email)
  end

  def create
    if params[:invitation]
      params["user"]["email"] = Invitation.find(params[:invitation]).email
    end
    
    self.resource = warden.authenticate!(auth_options)

    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    
    Notification.create(
      sender: resource,
      code: Notification::USER_SIGN_IN,
      notifiable: resource,
      personal: true
    )

    if params[:course] && params[:restrict] && Course.find(params[:course]).paid?
      redirect_to add_to_cart_course_path(params[:course])
    elsif params[:course] || (params[:course] && params[:restrict] && Course.find(params[:course]).free?)
      course = Course.find(params[:course])
      resource.courses_invited << course unless resource.courses_invited.include?(course)
      Invitation.find(params[:invitation]).destroy if params[:invitation]
      flash[:notice] = "Parabéns! Você está logado e já pode consumir o conteúdo do curso."
      redirect_to content_course_path(course)
    else
      respond_with resource, :location => after_sign_in_path_for(resource)
    end
  end
  
  private
  def use_https?
    unless current_school.try(:use_custom_domain) || request.host.include?("lvh.me") || Rails.env.staging?
      (request.ssl? || params[:action] == "new")
    end
  end
end
#coding: utf-8

class Users::PasswordsController < Devise::PasswordsController
  def create
  	resource_params.merge!({subdomain: current_subdomain})
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  private
  def use_https?
  	unless current_school.try(:use_custom_domain) || request.host.include?("lvh.me") || Rails.env.staging?
	    !["edit","update"].include?(params[:action])
	  end
  end
end
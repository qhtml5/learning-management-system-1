#coding: utf-8

class AuthenticationsController < ApplicationController

  # def create  
  #   auth = request.env["omniauth.auth"]
  #   authentication = Authentication.find_by_provider_and_uid(auth['provider'], auth['uid'])   

  #   if authentication
  #     authentication.user.apply_omniauth(auth)
  #     sign_in(:user, authentication.user)
  #     custom_redirect
  #   else      
  #     user = User.find_by_email(auth['extra']['raw_info']['email']) || User.new
  #     user.apply_omniauth(auth)

  #     if user.save(:validate => false)
  #       flash[:notice] = I18n.t("messages.authentication.signup")
  #       sign_in(:user, user)
  #       if !current_school
  #         redirect_to wizard_basic_info_dashboard_schools_path
  #       else
  #         custom_redirect
  #       end
  #     else
  #       flash[:alert] = I18n.t("messages.authentication.signup_failure")
  #       redirect_to root_url
  #     end
  #   end
  # end

  # def failure
  #   flash[:alert] = I18n.t("messages.authentication.login_failure")
  #   redirect_to root_url(subdomain: current_subdomain)
  # end

  # private
  # def custom_redirect(options = {})
  #   if request.referer == social_checkouts_url
  #     redirect_to register_checkouts_path(subdomain: current_subdomain)
  #   else
  #     redirect_to dashboard_courses_path(subdomain: current_subdomain)
  #   end
  # end
  
end
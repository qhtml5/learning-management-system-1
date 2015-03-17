#coding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  include UrlHelper
  
  rescue_from CanCan::AccessDenied, with: :cancan_redirect
  helper_method :current_cart
  helper_method :current_school
  helper_method :module_configuration
  before_filter :authenticate
  before_filter :check_notification
  before_filter :https_redirect
  before_filter :redirect_to_domain
  before_filter :get_cross_domain_params
  before_filter :invalidate_simultaneous_user_session, :unless => Proc.new {|c| c.controller_name == 'sessions' and c.action_name == 'create' }
  around_filter :scope_current_school_and_user

  def cancan_redirect exception = nil
    if user_signed_in?
      flash[:alert] = "Acesso não autorizado"
      session[:user_return_to] = nil
      redirect_to root_url(subdomain: current_school.try(:subdomain))
    else              
      flash[:alert] = "Você precisa estar logado para ver esta página"
      session[:user_return_to] = request.url
      redirect_to "/usuarios/sign_in"
    end 
  end

  def current_cart
    @current_cart ||= Cart.find_by_id(session[:cart_id])
  end

  def current_school
    @current_school ||= School.find_by_subdomain request.subdomain
  end

  def module_configuration
    @module_configuration ||= @current_school.try(:module_configuration)
  end

  def current_subdomain
    current_school ? current_school.subdomain : "www"
  end

  def scope_current_school_and_user
    School.current_id = current_school.id if current_school
    yield
  ensure
    School.current_id = nil
    User.current_status = nil
  end

  def check_notification
    if params[:notification] && params[:notification][:click]
      notification = Notification.find(params[:notification][:id])
      notification.update_attribute(:read, true)
    end
  end

  def after_sign_in_path_for(resource)
    if request.referer == social_checkouts_url
      register_checkouts_path(subdomain: current_subdomain)
    elsif Subdomain.matches?(request) && !current_user.admin?
      dashboard_courses_path(subdomain: current_subdomain)
    else
      root_path(subdomain: current_subdomain)
    end
  end

  def after_sign_out_path_for(resource)
    root_path(subdomain: current_subdomain)
  end

  protected
  def authenticate
    if (Rails.env == 'staging') && (params["controller"] != "purchases") && (params["action"] != "notification")
      authenticate_or_request_with_http_basic do |username, password|
        username == "bizstart" && password == "bizstart2013"
      end
    end
  end

  def get_cross_domain_params
    if params[:code]
      user = User.find_by_encrypted_password(params[:code])
      sign_in(user, unique_session_id: user.unique_session_id) if user && !user_signed_in?
    end

    if params[:cid]
      session[:cart_id] = params[:cid]
    end
  end

  def redirect_to_domain
    if current_school && current_school.domain.present? && current_school.use_custom_domain
      domain = current_school.domain.split(".")
      subdomain = if domain.length == 4
        [domain[0],domain[1]].join(".")
      else
        domain.first
      end

      if request.protocol == "http://" && request.env["HTTP_HOST"] == "#{current_school.subdomain}.#{AppSettings.host}"
        redirect_to params.merge!({ subdomain: subdomain, host: (domain - [domain.first]).join("."), code: current_user.try(:encrypted_password), cid: session[:cart_id] })
      elsif request.protocol == "https://" && request.env["HTTP_HOST"] == current_school.domain
        redirect_to params.merge!({ subdomain: current_school.subdomain, host: AppSettings.host, code: current_user.try(:encrypted_password), cid: session[:cart_id] })
      end
    end
  end 

  def invalidate_simultaneous_user_session
    sign_out_and_redirect(current_user) if current_user && session[:unique_session_id] != current_user.unique_session_id
  end

  def sign_in(resource_or_scope, *args)
    super
    unique_session_id = args.last.kind_of?(Hash) ? args.last[:unique_session_id] : nil
    token = unique_session_id || Devise.friendly_token
    current_user.update_attribute :unique_session_id, token
    session[:unique_session_id] = token
  end

  private
  def https_redirect    
    if request.ssl? && !use_https? || !request.ssl? && use_https?
      protocol = request.ssl? ? "http" : "https"
      flash.keep
      redirect_to params.merge!({ protocol: "#{protocol}://", status: :moved_permanently, cid: session[:cart_id], code: current_user.try(:encrypted_password) })
    end
  end

  def use_https?
    false # Override in other controllers
  end
end

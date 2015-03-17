#coding: utf-8

class Users::RegistrationsController < Devise::RegistrationsController
  require "uri"
  require "net/http"

  include Apotomo::Rails::ControllerMethods 
  has_widgets do |root|
    root << widget(:secure_info)
    root << widget(:school_phone_email)
  end

  def create
    if params[:invitation]
      params["user"]["email"] = Invitation.find(params[:invitation]).email
    end

    build_resource

    User.current_status = :purchasing_free if params[:free]
        
    if resource.save
      resource.destroy_lead

      set_flash_message :notice, :signed_up if is_navigational_format?
      sign_up(resource_name, resource)

      if current_school        
        resource.register_on_rdstation current_school.name.parameterize

        Notification.create_list(
          sender: resource,
          receivers: current_school.team,
          code: Notification::USER_NEW_REGISTRATION,
          notifiable: resource
        )
        
        if params[:checkout_registration]
          redirect_to register_checkouts_path(subdomain: current_subdomain)
        elsif params[:course] && params[:restrict] && Course.find(params[:course]).paid?
          redirect_to add_to_cart_course_path(params[:course])
        elsif params[:course] || (params[:course] && params[:restrict] && Course.find(params[:course]).free?)
          course = Course.find(params[:course])
          resource.courses_invited << course unless resource.courses_invited.include?(course)
          resource.register_on_rdstation "confirmado_#{course.slug}"
          Invitation.find(params[:invitation]).destroy if params[:invitation]
          flash[:notice] = "Parabéns! Você foi cadastrado e já pode consumir o conteúdo deste curso!"
          redirect_to content_course_path(course)
        else
          redirect_to root_path(subdomain: current_subdomain)
        end
      else
        redirect_to wizard_basic_info_dashboard_schools_path
      end
    else
      @user = resource
      if params[:checkout_registration]
        render template: "checkouts/social"
      elsif params[:course] && params[:invitation]
        @invitation = Invitation.find(params[:invitation])
        @course = Course.find(params[:course])
        render template: "courses/checkout_invitation"
      elsif params[:course] && params[:restrict]
        @course = Course.find(params[:course])
        render template: "courses/checkout_restrict"
      elsif params[:course]
        @course = Course.find(params[:course])
        render template: "courses/checkout_free"
      else
        clean_up_passwords resource
        respond_with resource
      end
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if current_cart && params[:commit] != "Salvar"
      User.current_status = :purchasing

      if resource.update_without_password(params[:user])
        current_user.reload

        if current_cart.total_greater_than_zero?
          checkout
        else
          create_completed_purchase
          redirect_to finish_coupon_checkouts_path(subdomain: current_subdomain)
        end
      else
        render :template => "checkouts/register"
      end
    else
      User.current_status = :editing

      update = if params[:user][:password].present?
        resource.update_with_password(params[:user])
      else
        resource.update_without_password(params[:user])
      end

      if update
        sign_in(resource, :bypass => true)
        flash[:notice] = t("messages.user.profile.update.success")
        redirect_to edit_profile_user_path(subdomain: current_subdomain)
      else
        render :template => "users/edit_profile"  
      end
    end
  end

  private

  def checkout
    begin
      current_cart.identificator =  "#{Time.now.strftime("%Y%m%d%H%M%s")}#{rand(100)}"

      build_instruction
      transparent_request = MyMoip::TransparentRequest.new("bizstart")
      transparent_request.api_call(@instruction)


      unless transparent_request.token.present? 
        SupportMailer.checkout_failure(current_cart, current_user, transparent_request.response).deliver
        redirect_to exception_checkouts_path(subdomain: current_subdomain) and return
      end

      current_cart.token = transparent_request.token
      current_cart.save!

      flash[:notice] = "Cadastro completo com sucesso, efetue o pagamento"
      
      if current_school.domain.present? && current_school.use_custom_domain && request.env["HTTP_HOST"] == current_school.domain
        current_user_id = current_user.try(:encrypted_password)
        redirect_to payment_checkouts_path(protocol: "https://", subdomain: current_subdomain, host: AppSettings.host, code: current_user_id, cid: session[:cart_id])
      else
        redirect_to payment_checkouts_path(subdomain: current_subdomain)
      end
    rescue Exception => e
      SupportMailer.checkout_exception(current_cart, current_user, e).deliver
      redirect_to exception_checkouts_path(subdomain: current_subdomain)
    end
  end

  def build_instruction
    build_payer
    commissions = []
    courses_titles = current_cart.courses.map(&:title).join(", ")

    # commissions << MyMoip::Commission.new(
    #   reason: "Venda de curso na escola #{current_school.name}",
    #   receiver_login: current_school.moip_login,
    #   percentage_value: 1.0
    # )

    @instruction = MyMoip::Instruction.new(
      :values => [current_cart.total_em_real],
      :id => current_cart.identificator,
      :payer => @payer,
      :payment_reason => "Venda do(s) curso(s): #{courses_titles}",
      :fee_payer_login => current_school.moip_login,
      :payment_receiver_login => current_school.moip_login
      # :commissions => commissions
    )

    if current_cart.available_to_pay_in_installments?
      @instruction.installments = [{ min: 1, max: current_cart.maximum_installments, forward_taxes: true, fee: 2.99 }]
    end
  end

  def build_payer
    @current_user_address = current_user.address
    @payer = MyMoip::Payer.new(
      :id => current_user.id,
      :name => current_user.full_name,
      :email => current_user.email,
      :address_street => @current_user_address.street,
      :address_street_number => @current_user_address.number,
      :address_street_extra => @current_user_address.complement,
      :address_neighbourhood => @current_user_address.district,
      :address_city => @current_user_address.city,
      :address_state => @current_user_address.state,
      :address_country => "BRA",
      :address_cep => @current_user_address.zip_code,
      :address_phone => current_user.phone_number
    )    
  end 

  def create_completed_purchase
    @purchase = current_user.purchases.create(
      :cart_items => current_cart.cart_items,
      :payment_status => "Concluido",
      :identificator => "#{Time.now.strftime("%Y%m%d%H%M%s")}#{rand(100)}"
    )
  end

  def use_https?
    unless current_school.try(:use_custom_domain) || request.host.include?("lvh.me") || Rails.env.staging?
      (request.ssl? || params[:action] == "new")
    end
  end

end
#coding: utf-8

class CoursesController < ApplicationController			
	require 'securerandom'

	load_and_authorize_resource
	skip_authorize_resource :only => :render_event_response # To work with apotomo

	include Apotomo::Rails::ControllerMethods	
	has_widgets do |root|
		root << widget(:school_phone_email)
		root << widget(:course_alumni)
		root << widget(:course_school)
    root << widget(:downloads)
    root << widget(:progress)
    root << widget(:questions)
    root << widget(:curriculum)
    root << widget(:course_testimonials)
    root << widget(:about)
    root << widget(:course_faq)
    root << widget(:how_it_works)
    root << widget(:how_to_enroll)
    root << widget(:who_should_attend)
    root << widget(:content_and_goals)
    root << widget(:course_evaluation)
    root << widget(:course_advantages)
    root << widget(:school_payment_forms)
    root << widget(:course_instructor)
    root << widget(:course_cart_recovery)
  end
	
	def show  
	  @course = Course.find(params[:id])
	  @school = @course.school
		@title = @course.title
		@coupon = @course.coupons.find_by_name(params[:coupon]) if params[:coupon]
		@path = if @course.restrict?
			checkout_restrict_course_path(@course)
		elsif @course.free?
			checkout_free_course_path(@course)
		elsif @coupon
			add_to_cart_course_path(@course, coupon: @coupon.name)
		elsif current_school.try(:cart_recovery) && !user_signed_in?
			"#newLead"
		else
			add_to_cart_course_path(@course)
		end

		Notification.create(
			code: Notification::COURSE_VIEW_PAGE, 
			notifiable: @course,
			personal: true
		)
	end

	def content
		@course = Course.find(params[:id])
		@medias = @course.medias.order(:sequence)
		@messages = @course.questions.order("created_at DESC").page(params[:page]).per(6)

    Notification.create(
      sender: current_user,
      code: Notification::USER_VIEW_COURSE_CONTENT,
      notifiable: @course,
      personal: true
    )
	end

	def checkout_free
		@course = Course.find(params[:id])
		@school = @course.school

		unless @course.free?
			redirect_to root_path(subdomain: @school.subdomain), alert: "Esse curso não é gratuito." and return
		end

		if user_signed_in?
			@course.students_invited << current_user
			redirect_to content_course_path(@course)
		end

		@user = User.new
	end

	def checkout_invitation
		@course = Course.find(params[:id])
		@school = @course.school

		@invitation = @course.invitations.find_by_email(params[:user_email])

		unless @invitation
			redirect_to root_path(subdomain: @school.subdomain), alert: "Convite inválido." and return
		end

		if user_signed_in? && current_user.email == @invitation.email
			current_user.courses_invited << @course unless current_user.courses_invited.include?(@course)
			@invitation.destroy
			redirect_to content_course_path(@course)
		elsif user_signed_in?
			flash[:alert] = "Você não pode usar esse convite."
			redirect_to request.referer || root_path(subdomain: @school.subdomain) and return
		end

		@user = User.new
	end

	def checkout_restrict
		@course = Course.find(params[:id])
		@school = @course.school

		if user_signed_in?
			redirect_to add_to_cart_course_path(@course)
		else
			@user = User.new
		end
	end

	def add_to_cart
		@course = Course.find(params[:id])
		@cart = Cart.find_by_id(session[:cart_id]) || Cart.create
		
		if @cart.courses.include? @course
			flash[:alert] = t("messages.course.add_to_cart.already_in_cart")
			redirect_to cart_checkouts_path(subdomain: current_subdomain) and return
		end
		
		if @course.draft?
			flash[:alert] = t("messages.course.add_to_cart.invalid")
			redirect_to root_path(subdomain: current_subdomain) and return
		end

		if user_signed_in? && @course.restrict? && !@course.array_of_allowed_emails.include?(current_user.email)
			flash[:alert] = t("messages.course.add_to_cart.restrict")
			redirect_to root_path(subdomain: current_subdomain) and return
		end

		if params[:coupon]
			@coupon = @course.coupons.active.find_by_name(params[:coupon])
			flash[:alert] = t("messages.course.add_to_cart.invalid_coupon") unless @coupon
		end

		@cart.cart_items.build course: @course, coupon: @coupon

		if @cart.save
	    Notification.create_list(
	    	sender: current_user, 
				receivers: current_school.team, 
				code: Notification::COURSE_ADD_TO_CART, 
				notifiable: @course
			) if current_school && current_user
			session[:cart_id] = @cart.id
			redirect_to cart_checkouts_path(subdomain: current_subdomain)
		end
	end

	def remove_from_cart
		@course = Course.find(params[:id])

		if @course && current_cart
			cart_item = CartItem.find_by_cart_id_and_course_id(current_cart.id, @course.id)
			cart_item.destroy if cart_item
			redirect_to cart_checkouts_path
		else
			redirect_to root_url, :alert => I18n.t("messages.course.remove_from_cart.failure")
		end
	end

	def add_coupon
		@course = Course.find(params[:id])
		@cart_item = CartItem.find(params[:cart_item_id])
		@coupon = @course.coupons.active.find_by_name(params[:coupon])

		if @coupon
			if @cart_item.update_attributes(coupon: @coupon)
				flash[:notice] = t("messages.course.add_coupon.success")
			else
				flash[:alert] = t("messages.course.add_coupon.failure")
			end
		else
			flash["invalid_coupon_#{@cart_item.id}"] = t("coupon.invalid")
		end

		redirect_to cart_checkouts_path
	end

	def remove_coupon
		@course = Course.find(params[:id])
		@cart_item = CartItem.find(params[:cart_item_id])
		@cart_item.update_attribute(:coupon_id, nil)
		flash[:notice] = t("messages.course.remove_coupon.success")
		redirect_to cart_checkouts_path		
	end	

	def request_certificate
		@course = Course.find(params[:id])

		begin
			Notification.create_list(
				sender: current_user, 
				receivers: @course.school.admins + @course.teachers, 
				notifiable: @course, 
				code: Notification::COURSE_NEW_CERTIFICATE_REQUEST
			)
			flash[:notice] = "Solicitação de certificado enviada com sucesso"
		rescue
			flash[:alert] = "Ocorreu um erro ao solicitar seu certificado"
		end

		redirect_to content_course_path(@course)
	end

	def affiliate
		@course = Course.find(params[:id])
		@coupon = @course.coupons.find_by_name(params[:coupon])

		unless @coupon
			flash[:alert] = "Cupom não encontrado."
			redirect_to root_path(subdomain: current_school.subdomain) and return
		end

		@cart_items = CartItem.with_purchase.with_price.where(coupon_id: @coupon.id).includes(:purchase).order("cart_items.created_at DESC")
		@cart_items_confirmed = @cart_items.payment_confirmed
		
		@billing_last_month = @cart_items_confirmed.between((Date.today - 1.month).beginning_of_month, (Date.today - 1.month).end_of_month).sum(&:price_with_discount)
    @billing_this_month = @cart_items_confirmed.between(Date.today.beginning_of_month, Date.today).sum(&:price_with_discount)

    @total_of_cart_items_confirmed = @cart_items_confirmed.length
    @total_of_cart_items_pending = @cart_items.pending.length
    @total_of_cart_items_canceled = @cart_items.canceled.length
    @total_of_cart_items_paid_with_billet = @cart_items_confirmed.paid_with_billet.length
    @total_of_cart_items_paid_with_online_debit = @cart_items_confirmed.paid_with_online_debit.length
    @total_of_cart_items_paid_with_credit_card = @cart_items_confirmed.paid_with_credit_card.length

		@cart_items = @cart_items.page(params[:page]).per(20)
	end

	private
	def use_https?
		unless current_school.try(:use_custom_domain) || request.host.include?("lvh.me") || Rails.env.staging?
			["add_coupon", "remove_coupon", "remove_from_cart", "checkout_free"].include?(params[:action])
		end
  end

end
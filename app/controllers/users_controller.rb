#coding: utf-8

class UsersController < ApplicationController
	before_filter :authenticate_user!, except: [:register]
  load_and_authorize_resource :only => [:purchases, :edit_profile, :notifications, :mark_all_notifications_as_read,
  	:messages] 

  has_widgets do |root|
    root << widget("school_student_profile/messages", :messages)
  end

	def purchases
		@purchases = current_user.purchases.order("created_at DESC")
	end

	def edit_profile
		@user = current_user
		@user.build_address if @user.address.nil?
	end

	def notifications
		@user = current_user
		@notifications = @user.notifications_received.not_personal.order("created_at DESC").page(params[:page]).per(10)
		render layout: "dashboard/dashboard"
	end

	def mark_all_notifications_as_read
		@user = current_user
		@user.notifications_received.find_each do |notification|
			notification.update_attribute :read, true
		end
		flash[:notice] = "Todas as notificações foram marcadas como lidas"
		redirect_to notifications_user_path
	end

	def messages
		@messages = current_user.messages_received.order("created_at DESC")
		render layout: "dashboard/dashboard"
	end

end

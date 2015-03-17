#coding: utf-8

class PagesController < ApplicationController	
	def index	
		authorize! :index, :pages
	end
	
	def teach
	end
	
	def learn
	end
	
	def pricing
  end

	def new_feedback
		@feedback = Feedback.new(params[:feedback])
		if @feedback.save
			flash[:notice] = t("messages.feedback.success")
		else
			flash[:alert] = t("messages.feedback.failure")
		end
		redirect_to request.referer || root_path
	end
	
end
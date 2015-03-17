#coding: utf-8

class Admin::FeedbacksController < ApplicationController
	layout :layout_admin
	authorize_resource :class => false
	
	def index
		@feedbacks = Feedback.all
		@feedbacks_like_count = Feedback.where(:like => true).length
		@feedbacks_dislike_count = Feedback.where(:like => false).length
	end

	private
	def layout_admin
		"admin/admin"
	end
end
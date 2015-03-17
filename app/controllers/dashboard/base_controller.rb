class Dashboard::BaseController < ApplicationController
	before_filter :authenticate_user!
	layout :layout_dashboard

	private
	def layout_dashboard
		"dashboard/dashboard"
	end
end
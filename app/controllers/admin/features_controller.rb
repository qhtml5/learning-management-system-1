#coding: utf-8

class Admin::FeaturesController < Flip::FeaturesController
  layout :layout_admin
  authorize_resource :class => false
  
  private
	def layout_admin
		"admin/admin"
	end
end
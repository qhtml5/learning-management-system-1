#coding: utf-8

class Dashboard::CouponsController < Dashboard::BaseController
  load_and_authorize_resource
  before_filter :set_course
  
  # def update
  #   @coupon = @course.coupons.find(params[:id])
  #   if @coupon.update_attributes(params[:coupon])
  #     flash[:notice] = t("messages.coupon.update.success")
  #     redirect_to dashboard_coupons_path
  #   else
  #     flash[:alert] = @coupon.errors.full_messages
  #     render :edit
  #   end
  # end

  def create
    @coupon = @course.coupons.new(params[:coupon])
    if @coupon.save
      flash[:notice] = t("messages.coupon.create.success")
      redirect_to edit_price_and_coupon_dashboard_course_path(@course)
    else
      render template: "dashboard/courses/edit_price_and_coupon", layout: "dashboard/course_edit"
    end
  end

  def destroy
    @coupon = @course.coupons.find(params[:id])
    @coupon.destroy
    flash[:notice] = t("messages.coupon.destroy.success")
    redirect_to edit_price_and_coupon_dashboard_course_path(@course.id)
  end

  private
  def set_course
    @course = Course.find(params[:course_id])
  end

end
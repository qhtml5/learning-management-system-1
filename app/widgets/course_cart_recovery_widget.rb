#coding: utf-8

class CourseCartRecoveryWidget < ApplicationWidget
  
  responds_to_event :create_lead, :with => :create_lead
  
  def display args
    @course = args[:course]
    @lead = Lead.new
    render :layout => "clean"
  end

  def create_lead params
    @course = Course.find(params[:course])
    @lead = @course.leads.build(params[:lead])
    @coupon = @course.coupons.build(
      name: SecureRandom.uuid,
      discount: 5,
      expiration_date: Time.now + 7.days,
      quantity: 1,
      automatic: true
    )

    if @lead.save && @coupon.save
      CourseMailer.send_coupon(@lead, @coupon).deliver
      replace :view => :coupon_sent, :layout => "clean"
    else
      replace :view => :display, :layout => "clean"
    end
  end

end

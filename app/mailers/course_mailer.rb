#coding: utf-8
class CourseMailer < ActionMailer::Base
  default :from => "Notificações - Edools <contato@edools.com>"
  layout 'school_mail'
  helper :mailer

  def send_coupon lead, coupon
    @lead = lead
    @coupon = coupon
    @course = coupon.course
    @school = @course.school
    @school_admin = @school.admins.first

    mail(from: default_from, :to => @lead.email, :subject => "Aqui está o seu cupom! Continue com a compra do curso #{@course.title}!")
  end  

  private
  def default_from
    if @school.email.present?
      @school.email
    elsif @school_admin.present?
      @school_admin.email
    else
      "Notificações - Edools <contato@edools.com>"
    end
  end

end
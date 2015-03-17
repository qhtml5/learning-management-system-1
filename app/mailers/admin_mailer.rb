#coding: utf-8

class AdminMailer < ActionMailer::Base
  default :from => "Notificações - Edools <contato@edools.com>"
  # layout 'simple_mail', only: [:day_one_help, :contact]
  layout 'edools_mail'
  helper :mailer

  def school_plan_change school, school_admin, old_plan
    @school = school
    @school_admin = school_admin
    @old_plan = School::PLANS.key(old_plan)
    @new_plan = School::PLANS.key(@school.plan)
    @admin_emails = User.admins.map(&:email)

    if @admin_emails.present?
      mail(to: @admin_emails, subject: "A Escola #{@school.name} mudou de plano")
    end
  end
end
#coding: utf-8

class SchoolMailer < ActionMailer::Base
  default :from => "Notificações - Edools <contato@edools.com>"
  layout 'edools_mail', only: [:two_days_to_end_trial, :end_trial, :new_school]
  helper :mailer

  def new_school school, user
    @school = school
    @user = user

    mail(to: @user.email, subject: "Seja bem vindo ao Edools.com")
  end

  def day_one_help school
    @school = school
    @school_admin = @school.owner

    mail(from: "Rafael - Edools.com <rafael@edools.com>", bcc: "contato@edools.com", to: @school_admin.email, subject: "Precisa de alguma ajuda com o Edools.com?")
  end

  def two_days_to_end_trial school
    @school = school
    @school_admin = @school.owner

    mail(to: @school_admin.email, bcc: "contato@edools.com", subject: "Seu período de teste do Edools.com está chegando ao fim")
  end

  def end_trial school
    @school = school
    @school_admin = @school.owner

    mail(to: @school_admin.email, bcc: "contato@edools.com", subject: "Seu período de teste do Edools.com acabou")
  end

  def contact school, subject, message
    @school = school
    @school_admin = @school.owner
    @message = message

    if @school_admin
      mail(from: "Rafael - Edools.com <rafael@edools.com>", to: @school_admin.email, subject: subject)
    end
  end
end
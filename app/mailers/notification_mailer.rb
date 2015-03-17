#coding: utf-8
class NotificationMailer < ActionMailer::Base
  default :from => "Notificações - Edools <contato@edools.com>"
  layout 'school_mail'
  helper :mailer

  def user_new_registration(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @school = @receiver.school

    mail(:to => @receiver.email, :subject => "Você tem uma nova inscrição na sua escola!")
  end

  def user_new_course_invitation(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @invitation = notification.notifiable
    @course = @invitation.course
    @school = @course.school
    @school_admin = @school.admins.first
    
    receiver_email = if @receiver
      @receiver.email
    else
      notification.email
    end

    mail(from: default_from, :to => receiver_email, :subject => "Você foi convidado para assistir ao curso #{@course.title}")
  end

  def course_new_certificate_request(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @course = notification.notifiable
    @school = @receiver.school

    mail(:to => @receiver.email, :subject => "#{@sender.full_name} solicitou o certificado do curso #{@course.title}")
  end

  def course_new_question(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @school = @receiver.school
    @message = notification.notifiable
    @course = @message.course

    mail(:to => @receiver.email, :subject => "#{@sender.full_name} enviou uma nova pergunta no curso #{@course.title}")
  end

  def course_new_answer(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @message = notification.notifiable
    @course = @message.course
    @school = @sender.school
    @school_admin = @school.admins.first

    mail(from: default_from, :to => @receiver.email, :subject => "#{@sender.full_name} respondeu à sua pergunta no curso #{@course.title}")
  end

  def course_add_to_cart(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @course = notification.notifiable
    @school = @receiver.school

    mail(:to => @receiver.email, :subject => "#{@sender.full_name} adicionou seu curso #{@course.title} ao carrinho.")
  end

  def course_new_evaluation(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @course_evaluation = notification.notifiable
    @course = @course_evaluation.course
    @school = @receiver.school

    mail(:to => @receiver.email, :subject => "O aluno #{@sender.full_name} avaliou seu curso #{@course.title} com #{@course_evaluation.score} estrelas.")
  end

  def purchase_pending(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @purchase = notification.notifiable
    @courses_titles = @purchase.courses.map(&:title).join(", ")
    @school = @receiver.school

    if @purchase.courses.length > 1
      subject = "#{@sender.full_name} comprou os cursos #{@courses_titles}. (pagamento pendente)"
    else
      subject = "#{@sender.full_name} comprou o curso #{@courses_titles}. (pagamento pendente)"
    end

    mail(:to => @receiver.email, :subject => subject)
  end

  def purchase_liberated(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @purchase = notification.notifiable
    @courses_titles = @purchase.courses.map(&:title).join(", ")
    @school = @receiver.school

    if @purchase.courses.length > 1
      subject = "#{@sender.full_name} teve o acesso liberado nos cursos #{@courses_titles}."
    else
      subject = "#{@sender.full_name} teve o acesso liberado no curso #{@courses_titles}."
    end

    mail(:to => @receiver.email, :subject => subject)
  end  

  def purchase_confirmed(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @purchase = notification.notifiable
    @courses_titles = @purchase.courses.map(&:title).join(", ")
    @school = @receiver.school

    if @purchase.courses.length > 1
      subject = "#{@sender.full_name} teve o pagamento confirmado na compra dos cursos #{@courses_titles}."
    else
      subject = "#{@sender.full_name} teve o pagamento confirmado na compra do curso #{@courses_titles}."
    end

    mail(:to => @receiver.email, :subject => subject)
  end

  def purchase_user_pending(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @purchase = notification.notifiable
    @courses_titles = @purchase.courses.map(&:title).join(", ")
    @school = @purchase.school
    @school_admin = @school.admins.first

    if @purchase.courses.length > 1
      subject = "Sua compra dos cursos #{@courses_titles} está com o pagamento pendente. Status: #{@purchase.payment_status}"
    else
      subject = "Sua compra do curso #{@courses_titles} está com o pagamento pendente. Status: #{@purchase.payment_status}"
    end

    mail(from: default_from, :to => @receiver.email, :subject => subject)
  end

  def purchase_user_confirmed(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @purchase = notification.notifiable
    @courses_titles = @purchase.courses.map(&:title).join(", ")
    @school = @purchase.school
    @school_admin = @school.admins.first

    if @purchase.courses.length > 1
      subject = "Parabéns! O seu pagamento na compra dos cursos #{@courses_titles} foi confirmado."
    else
      subject = "Parabéns! O seu pagamento na compra do curso #{@courses_titles} foi confirmado."
    end    

    mail(from: default_from, :to => @receiver.email, :subject => subject)
  end

  def purchase_user_liberated(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @purchase = notification.notifiable
    @courses_titles = @purchase.courses.map(&:title).join(", ")
    @school = @purchase.school
    @school_admin = @school.admins.first

    if @purchase.courses.length > 1
      subject = "Parabéns! O seu acesso aos cursos #{@courses_titles} já está liberado."
    else
      subject = "Parabéns! O seu ao curso #{@courses_titles} já está liberado."
    end    

    mail(from: default_from, :to => @receiver.email, :subject => subject)
  end  

  # def user_new_invitation(notification)
  #   if notification.receiver
  #     @receiver = notification.receiver 
  #   elsif notification.email
  #     @email = notification.email
  #   end
  #   @sender = notification.sender
  #   @school = @sender.school
  #   @invitation = notification.notifiable
  #   @role = User::SCHOOL_ROLES.key(@invitation.role).capitalize

  #   mail(:to => @invitation.email, :subject => "#{@sender.full_name} te convidou para ser #{@role} na escola #{@school.name}")
  # end

  def school_plan_choose(notification)
    @receiver = notification.receiver
    @school = notification.notifiable

    mail(:to => @receiver.email, :subject => "Contato para confirmar escolha do plano de pagamento no Edools")
  end

  def user_new_contact(notification)
    @receiver = notification.receiver
    @sender = notification.sender
    @message = notification.notifiable
    @school = @sender.school

    mail(:to => @receiver.email, :subject => "O aluno #{@sender.full_name} enviou um novo contato")
  end

  def user_school_new_contact(notification)
    if notification.receiver.present?
      @to = notification.receiver.email
      @receiver_name = notification.receiver.first_name
    else
      @to = notification.email
      @receiver_name = @to
    end

    @sender = notification.sender
    @message = notification.notifiable
    @school = @sender.school
    @school_admin = @school.admins.first

    mail(from: default_from, :to => @to, :subject => "#{@school.name} - Novo contato")
  end

  private
  def default_from
    if @school.email.present?
      "#{@school.name} <#{@school.email}>"
    elsif @school_admin.present?
      "#{@school_admin.full_name} <#{@school_admin.email}>"
    else
      "Notificações - Edools <contato@edools.com>"
    end
  end

end
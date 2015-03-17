#coding: utf-8

module NotificationsHelper

  def notification_picture notification
    if notification.sender
      if notification.sender.image_url
        image_tag(notification.sender.image_url, size: "30x30", class: "img-circle")
      else
        image_tag(notification.sender.image(:thumb), size: "30x30", class: "img-circle")
      end
    else
      image_tag("ic_avatar_homem.jpg", size: "30x30", class: "img-circle")
    end
  end

  def notification_path notification
    begin
      case notification.code
      when Notification::COURSE_NEW_QUESTION
        content_course_path(notification.notifiable.course, notification: { click: true, id: notification.id })
      when Notification::COURSE_NEW_ANSWER
        content_course_path(notification.notifiable.course, notification: { click: true, id: notification.id })
      when Notification::COURSE_NEW_EVALUATION
        course_evaluations_dashboard_schools_path(notification.notifiable.course, notification: { click: true, id: notification.id })
      when Notification::PURCHASE_PENDING
        dashboard_students_path(notification: { click: true, id: notification.id })
      when Notification::PURCHASE_CONFIRMED
        dashboard_students_path(notification: { click: true, id: notification.id })
      when Notification::PURCHASE_LIBERATED
        dashboard_students_path(notification: { click: true, id: notification.id })
      when Notification::PURCHASE_USER_PENDING
        dashboard_courses_path
      when Notification::PURCHASE_USER_CONFIRMED
        dashboard_courses_path
      when Notification::COURSE_NEW_CERTIFICATE_REQUEST
        dashboard_students_path(notification: { click: true, id: notification.id })
      when Notification::SCHOOL_PLAN_CHOOSE
        edit_basic_info_dashboard_schools_path
      when Notification::USER_NEW_COURSE_INVITATION
        checkout_invitation_course_path(notification.notifiable.course, user_email: notification.email, notification: { click: true, id: notification.id })
      when Notification::USER_SCHOOL_NEW_CONTACT
        messages_user_path(notification: { click: true, id: notification.id })
      else
        notifications_user_path(notification: { click: true, id: notification.id })
      end
    rescue
    end
  end

  def notification_text notification
    sender_name = notification.sender.full_name if notification.sender
    begin
      case notification.code
      when Notification::COURSE_NEW_QUESTION
        "<strong>#{sender_name}</strong> fez uma nova pergunta no curso <strong>#{notification.notifiable.course.title}</strong>".html_safe
      when Notification::COURSE_NEW_ANSWER
        "<strong>#{sender_name}</strong> respondeu sua pergunta no curso <strong>#{notification.notifiable.course.title}</strong>".html_safe
      when Notification::COURSE_NEW_EVALUATION
        "<strong>#{sender_name}</strong> avaliou em <strong>#{notification.notifiable.score}</strong> estrelas o curso <strong>#{notification.notifiable.course.title}</strong>".html_safe
      when Notification::PURCHASE_PENDING
        courses_titles = notification.notifiable.courses.map(&:title).join(", ")
        if notification.notifiable.courses.length == 1
          "<strong>#{sender_name}</strong> comprou o curso <strong>#{courses_titles}</strong>. (pagamento pendente)".html_safe
        else
          "<strong>#{sender_name}</strong> comprou os cursos <strong>#{courses_titles}</strong>. (pagamento pendente)".html_safe
        end
      when Notification::PURCHASE_CONFIRMED
        courses_titles = notification.notifiable.courses.map(&:title).join(", ")
        if notification.notifiable.courses.length == 1
          "<strong>#{sender_name}</strong> teve o pagamento confirmado na compra do curso <strong>#{courses_titles}</strong>.".html_safe
        else
          "<strong>#{sender_name}</strong> teve o pagamento confirmado na compra dos cursos <strong>#{courses_titles}</strong>.".html_safe
        end
      when Notification::PURCHASE_LIBERATED
        courses_titles = notification.notifiable.courses.map(&:title).join(", ")
        if notification.notifiable.courses.length == 1
          "<strong>#{sender_name}</strong> teve o acesso liberado nos cursos <strong>#{courses_titles}</strong>.".html_safe
        else
          "<strong>#{sender_name}</strong> teve o acesso liberado no curso <strong>#{courses_titles}</strong>.".html_safe
        end
      when Notification::PURCHASE_USER_PENDING
        purchase = notification.notifiable
        courses_titles = purchase.courses.map(&:title).join(", ")

        if purchase.courses.length > 1
          "Sua compra dos cursos <strong>#{courses_titles}</strong> está com o pagamento pendente. Status: #{purchase.payment_status}".html_safe
        else
          "Sua compra do curso <strong>#{courses_titles}</strong> está com o pagamento pendente. Status: #{purchase.payment_status}".html_safe
        end
      when Notification::PURCHASE_USER_CONFIRMED
        purchase = notification.notifiable
        courses_titles = purchase.courses.map(&:title).join(", ")

        if purchase.courses.length > 1
          "O seu pagamento na compra dos cursos <strong>#{courses_titles}</strong> foi confirmado.".html_safe
        else
          "O seu pagamento na compra do curso <strong>#{courses_titles}</strong> foi confirmado.".html_safe
        end
      when Notification::COURSE_ADD_TO_CART
        course = notification.notifiable
        "<strong>#{notification.sender.full_name}</strong> adicionou o curso <strong>#{course.title}</strong> ao carrinho.".html_safe
      when Notification::USER_NEW_REGISTRATION
        user = notification.notifiable
        "<strong>#{sender_name}</strong> entrou na escola.".html_safe
      when Notification::USER_NEW_COURSE_INVITATION
        course = notification.notifiable
        "Você foi convidado para assistir ao curso <strong>#{course.title}</strong>".html_safe
      when Notification::COURSE_NEW_CERTIFICATE_REQUEST
        "<strong>#{sender_name}</strong> solicitou o certificado do curso <strong>#{notification.notifiable.title}</strong>".html_safe
      when Notification::SCHOOL_PLAN_CHOOSE
        "Parabéns, <strong>#{notification.receiver.first_name}</strong>! Você criou a sua escola!".html_safe
      when Notification::USER_SCHOOL_NEW_CONTACT
        "Você recebeu um novo contato".html_safe
      end
    rescue
    end
  end

  def notification_text_passive notification
    sender_name = notification.sender.full_name if notification.sender
    begin
      case notification.code
      when Notification::COURSE_NEW_QUESTION
        "Fez uma pergunta no curso <strong>#{notification.notifiable.course.title}</strong>".html_safe
      when Notification::COURSE_NEW_ANSWER
        "Respondeu uma pergunta no curso <strong>#{notification.notifiable.course.title}</strong>".html_safe
      when Notification::COURSE_NEW_EVALUATION
        "Avaliou em <strong>#{notification.notifiable.score}</strong> estrelas o curso <strong>#{notification.notifiable.course.title}</strong>".html_safe
      when Notification::PURCHASE_PENDING
        courses_titles = notification.notifiable.courses.map(&:title).join(", ")
        if notification.notifiable.courses.length == 1
          "Comprou o curso <strong>#{courses_titles}</strong>. (pagamento pendente)".html_safe
        else
          "Comprou os cursos <strong>#{courses_titles}</strong>. (pagamento pendente)".html_safe
        end
      when Notification::PURCHASE_CONFIRMED
        courses_titles = notification.notifiable.courses.map(&:title).join(", ")
        if notification.notifiable.courses.length == 1
          "Teve o pagamento confirmado na compra do curso <strong>#{courses_titles}</strong>.".html_safe
        else
          "Teve o pagamento confirmado na compra dos cursos <strong>#{courses_titles}</strong>.".html_safe
        end
      when Notification::PURCHASE_LIBERATED
        courses_titles = notification.notifiable.courses.map(&:title).join(", ")
        if notification.notifiable.courses.length == 1
          "Teve o acesso liberado no curso <strong>#{courses_titles}</strong>.".html_safe
        else
          "Teve o acesso liberado nos cursos <strong>#{courses_titles}</strong>.".html_safe
        end
      when Notification::COURSE_ADD_TO_CART
        course = notification.notifiable
        "Adicionou o curso <strong>#{course.title}</strong> ao carrinho.".html_safe
      when Notification::USER_NEW_REGISTRATION
        user = notification.notifiable
        "Entrou na escola.".html_safe
      when Notification::COURSE_NEW_CERTIFICATE_REQUEST
        "Solicitou o certificado do curso <strong>#{notification.notifiable.title}</strong>".html_safe
      when Notification::USER_SIGN_IN
        "Logou na escola".html_safe
      when Notification::USER_STARTED_MEDIA
        "Começou a assistir a aula <strong>#{notification.notifiable.title}</strong> do curso 
          <strong>#{notification.message}</strong>".html_safe
      when Notification::USER_ENDED_MEDIA
        "Terminou de assistir a aula <strong>#{notification.notifiable.title}</strong> do curso 
          <strong>#{notification.message}</strong>".html_safe          
      when Notification::USER_VIEW_COURSE_CONTENT
        "Acessou o ambiente de conteúdo do curso <strong>#{notification.notifiable.title}</strong>".html_safe
      when Notification::USER_NEW_CONTACT
        "Enviou um novo contato".html_safe
      end
    rescue
    end
  end

  def notification_icon notification
    case notification.code
    when Notification::COURSE_NEW_QUESTION
      "<i class='icon-question-sign'></i>".html_safe
    when Notification::COURSE_NEW_ANSWER
      "<i class='icon-exclamation-sign'></i>".html_safe
    when Notification::COURSE_NEW_EVALUATION
      "<i class='icon-check'></i>".html_safe
    when Notification::PURCHASE_PENDING
      "<i class='icon-shopping-cart'></i>".html_safe
    when Notification::PURCHASE_CONFIRMED
      "<i class='icon-shopping-cart'></i>".html_safe
    when Notification::PURCHASE_LIBERATED
      "<i class='icon-shopping-cart'></i>".html_safe
    when Notification::PURCHASE_USER_PENDING
      "<i class='icon-shopping-cart'></i>".html_safe
    when Notification::PURCHASE_USER_CONFIRMED
      "<i class='icon-shopping-cart'></i>".html_safe
    when Notification::COURSE_ADD_TO_CART
      "<i class='icon-shopping-cart'></i>".html_safe
    when Notification::COURSE_NEW_CERTIFICATE_REQUEST
      "<i class='icon-certificate'></i>".html_safe
    when Notification::SCHOOL_PLAN_CHOOSE
      "<i class='icon-map-marker'></i>".html_safe
    when Notification::USER_NEW_COURSE_INVITATION
      "<i class='icon-gift'></i>".html_safe
    when Notification::USER_SIGN_IN
      "<i class='icon-user'></i>".html_safe
    when Notification::USER_STARTED_MEDIA
      "<i class='icon-play-circle'></i>".html_safe
    when Notification::USER_ENDED_MEDIA
      "<i class='icon-ok'></i>".html_safe
    when Notification::USER_VIEW_COURSE_CONTENT
      "<i class='icon-align-justify'></i>".html_safe
    when Notification::USER_NEW_CONTACT
      "<i class='fa-icon-comment'></i>".html_safe
    end
  end

end

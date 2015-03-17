#coding: utf-8

class SchoolStudentsWidget < ApplicationWidget  
  responds_to_event :search, :with => :search
  responds_to_event :send_message_to_students, with: :send_message_to_students
  responds_to_event :filter, with: :filter

  def display
    widget_attributes
    render :layout => "clean"
  end

  def search params
    @users = current_user.school.students.order(:first_name)
    
    if params[:user] && params[:user][:search].present?
      @users = @users.find_all_by_full_name(params[:user][:search])
    end

    @search = params[:user][:search] if params[:user]
    @users_length = @users.length
    @users = Kaminari.paginate_array(@users).page(params[:page]).per(20)
    @school = current_user.school
    replace :view => :display, :layout => "clean"
  end

  def send_message_to_students params
    checked_students = params[:students_leads].select { |k,v| k.split("_").first == "student" && v == "1" }.keys.map { |k| k.split("_").last.to_i }
    checked_leads = params[:students_leads].select { |k,v| k.split("_").first == "lead" && v == "1" }.keys.map { |k| k.split("_").last.to_i }

    # begin
      if params[:students_leads][:message].present?   
        User.find(checked_students).each do |user|
          message = Message.new(
            user: current_user,
            receiver: user,
            text: params[:students_leads][:message],
            kind: Message::CONTACT
          )
          if message.save
            Notification.create(
              sender: message.user, 
              receiver: message.receiver, 
              code: Notification::USER_SCHOOL_NEW_CONTACT, 
              notifiable: message
            )
          end
        end

        Lead.find(checked_leads).each do |lead|
          message = Message.new(
            user: current_user,
            text: params[:students_leads][:message],
            kind: Message::CONTACT
          )
          if message.save
            Notification.create(
              sender: message.user, 
              email: lead.email, 
              code: Notification::USER_SCHOOL_NEW_CONTACT, 
              notifiable: message
            )
          end
        end
      end
      @notice = "Mensagem enviada com sucesso para os emails selecionados."
    # rescue
    #   @alert = "Ocorreu um erro ao enviar mensagem, favor tentar novamente."
    # end

    widget_attributes
    replace :view => :display, :layout => "clean"
  end

  def filter params
    @school = current_school
    @course = Course.find_by_slug params[:course]
    search = @course.present? ? @course : @school

    @users = case params[:status] 
              when "confirmed"
                @users_title = "Alunos ativos"
                search.active_users
              when "expired"
                @users_title = "Alunos expirados"
                search.expired_users
              when "pending"
                @users_title = "Alunos pendentes"
                search.pending_users_from_purchases
              when "canceled"
                @users_title = "Alunos cancelados"
                search.canceled_users_from_purchases  
              when "leads"
                @users_title = "Leads"
                search.leads
              when "school_admins"
                @users_title = "Administradores"
                search.admins
              else
                search.students
              end

    @status_filter = params[:status]
    @users_length = @users.length
    @users = Kaminari.paginate_array(@users).page(params[:page]).per(40)
    replace :view => :display, :layout => "clean"
  end

  private
  def widget_attributes
    @school = current_school
    @users_length = @school.users_and_leads.length
    @users = @school.users_and_leads
    @users = Kaminari.paginate_array(@users).page(params[:page]).per(40)
  end

end

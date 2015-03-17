#coding: utf-8

class SchoolStudentProfile::MessagesWidget < ApplicationWidget
  responds_to_event :send_message, with: :send_message
  responds_to_event :destroy_message, with: :destroy_message

  helper NotificationsHelper

  def display params
  	widget_attributes params
    render :layout => "clean"
  end

  def send_message params
    message = Message.new(
      text: params[:message_to_send][:text],
      receiver: User.find(params[:student]),
      user: current_user,
      kind: Message::CONTACT
    )
    if message.save
      if message.user == message.receiver
        Notification.create_list(
          sender: message.user, 
          receivers: current_school.team, 
          code: Notification::USER_NEW_CONTACT, 
          notifiable: message
        )
      else
        Notification.create(
          sender: message.user, 
          receiver: message.receiver, 
          code: Notification::USER_SCHOOL_NEW_CONTACT, 
          notifiable: message
        )
      end
      @notice = "Mensagem enviada com sucesso"
    else
      @alert = "Ocorreu um erro ao enviar sua mensagem"
    end

    widget_attributes params
    trigger :reloadTabs, active: "messages", student: params[:student]
    replace view: :display, layout: "clean"
  end

  def destroy_message params
    @message = Message.find(params[:message])
    @message.destroy
    @notice = "Mensagem apagada com sucesso"

    widget_attributes params
    trigger :reloadTabs, active: "messages", student: params[:student]
    replace view: :display, layout: "clean"
  end  

  private
  def widget_attributes params
    @student = User.find params[:student]
    @messages = @student.messages_received
    @school = current_school
  end
end

#coding: utf-8

class SchoolStudentProfile::AnnotationsWidget < ApplicationWidget
  responds_to_event :create, with: :create
  responds_to_event :destroy, with: :destroy

  helper NotificationsHelper

  def display params
    widget_attributes params
    render :layout => "clean"
  end

  def create params
    message = Message.new(
      text: params[:annotation_to_create][:text],
      receiver: User.find(params[:student]),
      user: current_user,
      kind: Message::ANNOTATION
    )
    if message.save
      @notice = "Anotação criada com sucesso"
    else
      @alert = "Ocorreu um erro ao enviar sua anotação"
    end

    widget_attributes params
    trigger :reloadTabs, active: "annotations", student: params[:student]
    replace view: :display, layout: "clean"
  end

  def destroy params
    @annotation = Message.find(params[:annotation])
    @annotation.destroy
    @notice = "Anotação apagada com sucesso"

    widget_attributes params
    trigger :reloadTabs, active: "annotations", student: params[:student]
    replace view: :display, layout: "clean"
  end  

  private
  def widget_attributes params
    @student = User.find params[:student]
    @annotations = @student.annotations.order("created_at DESC")
    @school = current_school
  end
end

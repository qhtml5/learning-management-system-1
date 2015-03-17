#coding: utf-8

class CourseInviteStudentsWidget < ApplicationWidget

  after_initialize :setup!

	responds_to_event :invite, with: :invite
  responds_to_event :destroy_invitation, with: :destroy_invitation

  def display params
    # return render :nothing => true if !Flip.course_invite_students? 
    
    @course = if params[:course].is_a?(Course)
      params[:course]
    else
      Course.find(params[:course])
    end

    render :layout => "widget_course"
  end

  def invite params
    emails = params[:users][:emails].split(",")
    @course = Course.find(params[:course])

    invitations = Invitation.create_list(emails: emails, course: @course)

    if invitations[:success].present?
      @notice = "Convites enviados com sucesso para o(s) email(s): <strong>#{invitations[:success].map(&:email).join(', ')}</strong>".html_safe
    end
    if invitations[:failure].present?
      @alert = "Falha ao enviar os convites para o(s) email(s): <strong>#{invitations[:failure].map(&:email).join(', ')}</strong>".html_safe
    end

    replace :view => :display, :layout => "widget_course"
  end

  def destroy_invitation params
    @course = Course.find(params[:course])
    @invitation = Invitation.find(params[:invitation])
    @invitation.destroy
    @notice = "Convite removido com sucesso"

    replace :view => :display, :layout => "widget_course"
  end  

  private
  def setup!(*)
    @title = "Convidar alunos"
  end

end

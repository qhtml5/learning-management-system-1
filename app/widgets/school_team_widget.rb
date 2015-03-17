#coding: utf-8

class SchoolTeamWidget < ApplicationWidget

  after_initialize :setup!
  
	responds_to_event :invite, with: :invite

  def display args
  	@school = args[:school]
    @users = @school.admins + @school.teachers 
    @invitations = @school.invitations
    render :layout => "clean"
  end

  # def invite
  #   @school = School.find(params[:school])
  #   @invitation = @school.invitations.build(params[:invitation])
  #   @users = @school.admins + @school.teachers 
    
  #   if @invitation.save
  #     user = User.find_by_email(invitation.email)
  #     if user
  #       Notification.create(sender: current_user,
  #                           receiver: user,
  #                           code: Notification::USER_NEW_INVITATION,
  #                           notifiable: @course_evaluation)
  #     else
  #       Notification.create(sender: current_user,
  #                           email: invitation.email,
  #                           code: Notification::USER_NEW_INVITATION,
  #                           notifiable: @course_evaluation)
  #     end
  #     @invitations = @school.invitations
  #     @notice = t("messages.invitation.create.success")
  #   else
  #     @invitations = @school.invitations
  # 		@alert = @invitation.errors.full_messages.join(", ")
  # 	end
  # 	replace view: :display, :layout => "widget_course"
  # end
  
  private
  def setup!(*)
    @title = "Equipe"
    @icon = "fa-icon-group"
    @soon = true
  end
  

end
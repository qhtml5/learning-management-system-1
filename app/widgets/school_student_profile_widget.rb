#coding: utf-8

class SchoolStudentProfileWidget < ApplicationWidget
  responds_to_event :activities, with: :activities
  responds_to_event :messages, with: :messages
  responds_to_event :progress, with: :progress
  responds_to_event :reloadTabs, with: :reload_tabs

  helper NotificationsHelper

  has_widgets do |root|
    root << widget(:progress)
    root << widget(:curriculum)
    root << widget("school_student_profile/messages", :messages)
    root << widget("school_student_profile/annotations", :annotations)
  end

  def display params
    widget_attributes params

    @active_tab = "activities"
    render :layout => "clean"
  end

  def reload_tabs params
    widget_attributes params
    
    @active_tab = params[:active]
    replace :view => :display, :layout => "clean"
  end

  private
  def widget_attributes params
    @student = if params[:student].is_a?(User)
      params[:student]
    else
      current_user.school.students.find(params[:student])
    end
    @courses_within_validity = @student.courses_invited_within_validity + @student.courses_as_student_within_validity.payment_confirmed
    @courses_pending = @student.courses_as_student.payment_pending - @courses_within_validity
    @courses_out_of_date = @student.courses_invited_out_of_date + @student.courses_as_student_out_of_date.payment_confirmed
    @address = @student.address
    notifications = @student.notifications_sent.sent_by_students.order("created_at DESC").uniq_by { |n| n.created_at.strftime("%d%m%Y%H%M") }
    @notifications_length = notifications.length
    @notifications = Kaminari.paginate_array(notifications).page(params[:page]).per(10)
    @messages = @student.messages_received.order("created_at DESC")
    @courses = @student.courses
    @average_progress = (@student.courses.inject(0.0) { |sum, course| sum + @student.completed_progress(course).to_f }.to_f / @student.courses.length).to_i if @courses.present?
    @active_tab = {}
    @annotations = @student.annotations
  end
end

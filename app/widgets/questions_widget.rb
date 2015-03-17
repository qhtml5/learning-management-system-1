#coding: utf-8

class QuestionsWidget < ApplicationWidget

  after_initialize :setup!

  responds_to_event :submit_message, :with => :submit_message
  responds_to_event :destroy_message, with: :destroy_message
  responds_to_event :submit_answer, with: :submit_answer
  
  def display params
    # return render :nothing => true if !Flip.course_questions? 
    @messages = params[:messages]
    @course = params[:course]
    @user = params[:user]
    render :layout => "widget_course"
  end

  def submit_message params
    @course = Course.find(params[:course])
    @messages = @course.messages.questions.order("created_at DESC").page(params[:page]).per(6)

    message = @course.messages.build params[:message].merge({user: current_user, kind: Message::COURSE_QUESTION})

    if @course.save
      Notification.create_list(
        sender: current_user, 
        receivers: @course.school.team, 
        code: Notification::COURSE_NEW_QUESTION, 
        notifiable: message
      )
      @notice = t("messages.course.submit_message.success")
    else
      @alert = t("messages.course.submit_message.failure")
    end

    replace :view => :display, :layout => "widget_course"
  end

  def submit_answer params
    @course = Course.find(params[:course])
    @messages = @course.messages.questions.order("created_at DESC").page(params[:page]).per(6)

    @message = Message.find params[:question]
    answer = @message.answers.build params[:message].merge({user: current_user, 
                                                            kind: Message::COURSE_ANSWER,
                                                            course: @course})

    if @message.save
      Notification.create(
        sender: answer.user,
        receiver: @message.user, 
        code: Notification::COURSE_NEW_ANSWER, 
        notifiable: answer
      )
      Notification.create_list(
        sender: current_user, 
        receivers: @course.school.team, 
        code: Notification::COURSE_NEW_QUESTION, 
        notifiable: answer
      )
      @notice = t("messages.course.submit_answer.success")
    else
      @alert = t("messages.course.submit_answer.failure")
    end

    replace :view => :display, :layout => "widget_course"
  end

  def destroy_message
    @course = Course.find(params[:course])
    @messages = @course.messages.questions.order("created_at DESC").page(params[:page]).per(6)

    @message = Message.find(params[:message])
    @message.destroy
    @notice = t("messages.message.destroy.success")

    replace :view => :display, :layout => "widget_course"
  end

  private
  
  def setup!(*)
    @title = t('widgets.questions.title') 
    @icon = "icon-question-sign"
  end
end

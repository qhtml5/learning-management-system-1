#coding: utf-8

class CourseEvaluationWidget < ApplicationWidget
  
  after_initialize :setup!
  responds_to_event :submit, :with => :process_course_evaluation
  
  def display args
    # return render :nothing => true if !Flip.course_evaluation?
    @user = current_user 
    @course = args[:course]
    @course_evaluation = @course.course_evaluations.find_by_user_id(@user.id)
    @course_evaluation = @course.course_evaluations.build unless @course_evaluation
    render :layout => "widget_course"
  end

  def show args
    @course = args[:course]
    @title = "Avaliação média do curso"
    render view: :show, :layout => "widget_course"
  end
  
  def process_course_evaluation params
    params[:course_evaluation][:score] = params[:score]

    @course = Course.find(params[:course_evaluation].delete(:course_id))
    @course_evaluation = @course.course_evaluations.find_by_user_id(current_user.id)
    @course_evaluation = @course.course_evaluations.build unless @course_evaluation
    @course_evaluation.user = current_user
    
    if @course_evaluation.update_attributes(params[:course_evaluation])
      Notification.create_list(
        sender: @course_evaluation.user,
        receivers: @course.school.team,
        code: Notification::COURSE_NEW_EVALUATION,
        notifiable: @course_evaluation
      )
      @notice = "Avaliação enviada com sucesso!"
      replace :view => :process_course_evaluation, :layout => "widget_course"
    else
      @alert = "Dê uma nota para o curso."
      replace :view => :display, :layout => "widget_course"
    end
    
  end

  private
    def setup!(*)
      @title = t('widgets.course_evaluation.title')
      @icon = "icon-star"
    end
end

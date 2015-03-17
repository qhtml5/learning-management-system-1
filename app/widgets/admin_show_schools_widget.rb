#coding: utf-8
class AdminShowSchoolsWidget < ApplicationWidget

  after_initialize :setup!
  responds_to_event :send_email_to_schools, with: :send_email_to_schools
  responds_to_event :order_schools, with: :order_schools
  
  def display
    # return render :nothing => true if !Flip.admin_show_schools?
    
    @schools = School.all.sort_by { |s| s.students.length }.reverse
    render :layout => "widget_course"
  end

  def send_email_to_schools params    
    schools_to_email = School.includes(:users).find(params[:schools_to_email].select { |k,v| v == "1" }.keys)
    subject = params[:schools_to_email][:subject]
    message = params[:schools_to_email][:message]

    schools_to_email.each do |school|
      SchoolMailer.contact(school, subject, message).deliver
    end

    emails = schools_to_email.map { |s| s.owner.try(:email) }.join(", ")

    @notice = "Email enviado com sucesso para: #{emails}"  
    @schools = School.all.sort_by { |s| s.students.length }.reverse
    replace :view => :display, :layout => "widget_course"
  end

  def order_schools params
    order = params[:order]

    @schools = case order
    when "name"
      School.order(:name)
    when "plan"
      School.order(:plan)
    when "students"
      School.all.sort_by { |s| s.students.length }.reverse
    when "school_admin"
      School.all.sort_by { |s| s.owner.first_name }.reverse
    when "courses"
      School.all.sort_by { |s| s.courses.length }
    when "created_at"
      School.order("created_at DESC")
    when "updated_at"
      School.order("updated_at DESC")
    end

    @schools = @schools.reverse if params[:reverse] == "true"
    @order = params[:order]
    replace :view => :display, :layout => "widget_course"
  end

  private
    def setup!(*)
      @title = t('widgets.admin_show_schools.title')
    end
end

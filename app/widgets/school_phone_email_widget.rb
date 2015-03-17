#coding: utf-8

class SchoolPhoneEmailWidget < ApplicationWidget  

  after_initialize :setup!
  
  def home_school args
    @school = args[:school]    
    @phone = @school.phone
    @email = @school.email
    render :view => :home_school, :layout => "clean"
  end
  
  def course args
    @title = 'Alguma dúvida?'
    @school = args[:school]
    return render :nothing => true if @school.phone.blank? and @school.email.blank?
    
    @phone = @school.phone
    @email = @school.email
    render :view => :course, :layout => "widget_course"
  end
  
  def checkout args
    @title = 'Alguma dúvida?'
    @school = args[:school]
    return render :nothing => true if @school.phone.blank? and @school.email.blank?
    
    @phone = @school.phone
    @email = @school.email
    render
  end
  
  private
    def setup!(*)
      @title = 'Contatos'
    end
end

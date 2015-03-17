#coding: utf-8

class AboutWidget < ApplicationWidget
  
  after_initialize :setup!
  
  # def display(args)
  #   return render :nothing => true if !Flip.teacher_bio? 
    
  #   course = args[:course]
  #   school = course.school
  #   if school.owner.try(:biography)
  #     @bio = school.owner.try(:biography)
  #     render :layout => "widget_course"
  #   else
  #     return render :nothing => true
  #   end
  # end
  
  private
    def setup!(*)
      @title = t('widgets.about_teacher.title')
    end
end

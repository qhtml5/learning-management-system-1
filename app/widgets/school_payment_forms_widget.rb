#coding: utf-8

class SchoolPaymentFormsWidget < ApplicationWidget
  
  after_initialize :setup!
  
  def display
    # return render :nothing => true if !Flip.teacher_bio?
    
    @school = current_school
    @school_layout = @school.layout_configuration

    render :layout => "widget_course"
  end
  
  private
    def setup!(*)
      @title = "Formas de Pagamento"
    end
end

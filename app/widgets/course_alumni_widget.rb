#coding: utf-8

class CourseAlumniWidget < ApplicationWidget
  
  def display params
    # return render :nothing => true if !Flip.teacher_bio? 
    
    @course = params[:course]
    @students = @course.active_users + @course.expired_users

    if @students.any?
	    students = @students.length != 1 ? "alunos já fizeram" : "aluno fez"
	    if @course.slug == "workshop-online-sua-ideia-ainda-nao-vale-nada"
		    @title = "#{@students.length+40} #{students} esse curso"
		  else
		  	@title = "#{@students.length} #{students} esse curso"
		  end
	    render :layout => "widget_course"
	  else
	  	render :nothing => true
	  end
  end

end

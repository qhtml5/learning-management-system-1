#coding: utf-8

class Dashboard::UsersController < Dashboard::BaseController  
  include Apotomo::Rails::ControllerMethods 
  has_widgets do |root|
    root << widget(:school_student_profile)
    root << widget(:school_students)
    root << widget(:progress)
  end

	def show
		@school = current_user.school
		@student = @school.students.find_by_id(params[:id])
    @page = params[:page]

    unless @student
      flash[:alert] = "Aluno não existe"
      redirect_to action: :index
    end
		
		authorize! :show, :dashboard_user
	end

	def index
		@school = current_user.school
    @students = @school.students.order(:first_name)

    authorize! :index, :dashboard_user

    respond_to do |format|
    	format.html
    	format.xls { send_data @students.to_csv(col_sep: "\t") }
    end
	end

end

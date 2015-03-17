class CourseCategoriesWidget < ApplicationWidget
  responds_to_event :create, :with => :create
  responds_to_event :destroy, :with => :destroy
  
  def display
    # return render :nothing => true if !Flip.course_evaluation?

    widget_attributes
    render :layout => "clean"
  end

  def create params
  	course_category = CourseCategory.new(params[:course_category])

  	if course_category.save
  		@notice = "Categoria criada com sucesso"
  	else
  		@alert = "Ocorreu um erro ao criar categoria"
  	end

  	widget_attributes
  	replace :view => :display, :layout => "clean"
  end

  def destroy params
    course_category = CourseCategory.find(params[:course_category])
    course_category.destroy
    widget_attributes
    @notice = "Categoria apagada com sucesso"
    replace :view => :display, :layout => "clean"
  end

  private

  def widget_attributes
    @course_categories = CourseCategory.order(:sequence)
  end

end

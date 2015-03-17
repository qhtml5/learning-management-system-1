#coding: utf-8

class Dashboard::CoursesController < Dashboard::BaseController
  include Apotomo::Rails::ControllerMethods 
  has_widgets do |root|
    root << widget(:school_library)
    root << widget(:course_invite_students)
    root << widget(:course_categories)
  end

  def index
    if current_user.student?
      @course_items = current_user.cart_items.published + current_user.courses_users.published
    else
      @courses = current_school.courses
    end

    authorize! :dashboard_index, Course
  end  

  def show
    @user = current_user

    @course = Course.find(params[:id])

    render :layout => "dashboard/course_edit"

    authorize! :dashboard_show, @course
  end

  def create
    @user = current_user
    @school = @user.school

    @course = @school.courses.build(params[:course])

    if @course.save
      begin
        unless @school.wistia_public_project_id
          wistia_project = Wistia::Project.create(:name => @school.subdomain, :public => true, :anonymousCanUpload => true)
          @school.update_attribute(:wistia_public_project_id, wistia_project.try(:publicId))
        end
      rescue
      end

      flash[:notice] = t("messages.course.create.success")
      redirect_to dashboard_course_path(@course)
    else
      flash[:alert] = @course.errors.full_messages.join(", ")
      @user = current_user
      @courses = @user.courses - [@course]
      render :index
    end

    authorize! :dashboard_create, @course
  end   

  def update
    params[:course] = {} if params[:course].nil?
    params[:course][:price].gsub!(/\D+/, "") if params[:course][:price]
    params[:course][:price] = 0 if params[:course][:price] == ""
    params[:course][:privacy] = params.delete(:course_privacy) if params[:course_privacy]
    params[:course][:available_time] = 0 if params[:availability] == Course::ILIMITED
    params[:course][:video_url] = nil if params[:course][:video_url] == ""

    @user = current_user
    @course = Course.find(params[:id])

    if @course.update_attributes(params[:course])
      flash[:notice] = t("messages.course.update.success")
      redirect_to action: params[:edit_action] || dashboard_course_path(@course), id: @course.slug
    else
      flash[:alert] = @course.errors.full_messages.join(", ") if params[:edit_action] == "edit_image"
      render action: params[:edit_action], :layout => "dashboard/course_edit"
    end

    authorize! :dashboard_update, @course
  end

  def publish
    @user = current_user
    @course = Course.find(params[:id])
    @course.status = Course::PUBLISHED

    if @course.save
      flash[:notice] = t('messages.course.publish.success')
    else
      flash[:alert] = @course.errors.full_messages.join(', ')
    end

    redirect_to request.referer || dashboard_course_path(@course)

    authorize! :dashboard_publish, @course
  end  

  def unpublish
    @user = current_user
    @course = Course.find(params[:id])
    @course.status = Course::DRAFT

    if @course.save
      flash[:notice] = t('messages.course.unpublish.success')
    else
      flash[:alert] = t('messages.course.unpublish.failure')
    end

    redirect_to request.referer || dashboard_course_path(@course)

    authorize! :dashboard_unpublish, @course
  end

  def edit_links_downloads
    @user = current_user
    @course = Course.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_links_downloads, @course
  end

  def edit_available_time
    @user = current_user
    @course = Course.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_available_time, @course
  end
  
  def edit_basic_info
    @user = current_user
    @course = Course.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_basic_info, @course
  end

  def edit_detailed_info
    @user = current_user
    @course = Course.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_detailed_info, @course
  end

  def edit_image
    @user = current_user
    @course = Course.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_image, @course
  end

  def edit_promo_video
    @user = current_user
    @course = Course.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_promo_video, @course
  end

  def edit_price_and_coupon
    @user = current_user
    @course = Course.find(params[:id])
    @course.price = @course.price.em_real if @course.price
    @coupon = Coupon.new
    @coupons = @course.coupons
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_price_and_coupon, @course
  end

  def edit_privacy
    @user = current_user
    @course = Course.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_privacy, @course
  end

  def edit_certificate
    @user = current_user
    @course = Course.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_certificate, @course
  end

  def edit_instructor
    @user = current_user
    @course = Course.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_edit_instructor, @course
  end  

  # def edit_teachers
  #   @user = current_user
  #   @course = Course.find(params[:id])
  #   render :layout => "dashboard/course_edit"

  #   authorize! :dashboard_edit_teachers, @course
  # end

  # def update_promo_video
  #   @user = current_user
  #   @course = Course_as_teacher.find(params["id"])
  #   Wistia::Media.find(@course.wistia_promo_video_id).destroy if @course.wistia_promo_video_id
  #   @course.update_attribute(:wistia_promo_video_id, params["hashed_id"])
  #   redirect_to edit_promo_video_dashboard_course_path(@course)

  #   authorize! :dashboard_update_promo_video, @course
  # end

  # def medias
  #   @user = current_user
  #   @course = Course.find(params[:id])
  #   begin
  #     @wistia_project = Wistia::Project.find(@course.wistia_project_id)
  #   rescue ActiveResource::ResourceNotFound => e
  #     @wistia_project = Wistia::Project.create(:name => @course.title, :public => true, :anonymousCanUpload => true)
  #     @wistia_project.reload
  #     @course.update_attribute(:wistia_project_id, @wistia_project.try(:id))
  #     @course.update_attribute(:wistia_public_project_id, @wistia_project.try(:publicId))
  #   end
  #   @medias = @wistia_project.medias

  #   authorize! :dashboard_medias, @course
  # end
  
  def library
    @user = current_user
    @course = Course.find(params[:id])
    @school = @user.school
    render :layout => "dashboard/course_edit"
    
    authorize! :library, @school
  end

  def invite_students
    @course = current_user.courses.find(params[:id])
    render :layout => "dashboard/course_edit"

    authorize! :dashboard_students, @course
  end

  def course_categories
    authorize! :dashboard_course_categories, Course
  end

  def sort_course_categories
    @course_category = CourseCategory.find(params[:id])
    @course_category.update_attribute :sequence_position, params[:position]
    render nothing: true

    authorize! :dashboard_sort_course_categories, Course
  end

  def rename_course_category
    @course_category = CourseCategory.find(params[:course_category_id])
    @course_category.update_attribute(:name, params[:course_category][:name]) if !params[:course_category][:name].blank?
    render :nothing => true
  end

  def conversion_graphic
    @start_date = unless params[:start_date].empty?
      Date.strptime(params[:start_date], "%d/%m/%Y").to_datetime
    else
      Time.now
    end

    @end_date = if params[:end_date].chars.any?
      Date.strptime(params[:end_date], "%d/%m/%Y").to_datetime.change(:hour => 23, :min => 59, :sec => 59)
    else
      Time.now.change(:hour => 23, :min => 59, :sec => 59)
    end

    @courses = Course.find(params[:course_ids].split(","))
    @data = []

    @courses.each_with_index do |course, i|
      @data[i] = {}
      @data[i][:title] = course.title
      @data[i][:data] = [{
        name: course.title,
        data: [
          ["Acessaram a página", course.notifications.between(@start_date, @end_date).course_view_page.length],
          ["Adicionaram no carrinho", course.notifications.between(@start_date, @end_date).course_add_to_cart.uniq_by { |n| n.created_at.strftime("%d%m%Y%H%M") }.length],
          ["Compraram", course.purchases.payment_confirmed.between(@start_date, @end_date).length]
        ]
      }]
    end

    render :json => @data
  end

  # def destroy
  #   @user = current_user
  #   @course = Course.find(params[:id])
  #   @course.destroy
  #   redirect_to dashboard_courses_path
  # end

end
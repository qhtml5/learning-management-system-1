#coding: utf-8

class EditCurriculumWidget < ApplicationWidget

  after_initialize :setup!

  responds_to_event :new_lesson, :with => :new_lesson
  responds_to_event :create_lesson, :with => :create_lesson
  responds_to_event :destroy_lesson, :with => :destroy_lesson
  responds_to_event :new_media, with: :new_media
  responds_to_event :create_media, with: :create_media
  responds_to_event :destroy_media, with: :destroy_media
  responds_to_event :add_content, with: :add_content
  responds_to_event :create_content, with: :create_content
  responds_to_event :view_content, with: :view_content
  responds_to_event :load_content, with: :load_content
  responds_to_event :cancel_action, :with => :cancel_action
  responds_to_event :choose_library_or_upload, :with => :choose_library_or_upload
  responds_to_event :add_from_library, :with => :add_from_library
  responds_to_event :update_media_from_library, :with => :update_media_from_library
  
  def display params
    widget_attributes params
    render :layout => "widget_course"
  end

  def new_lesson
    @course = Course.find(params[:course])
    replace :view => :new_lesson, :layout => "widget_course"
  end

  def create_lesson
    widget_attributes params

    @lesson = @course.lessons.build(params[:lesson])
    @lesson.course = @course

    if @lesson.save
      @notice = t("messages.module.create.success")
      replace :view => :display, :layout => "widget_course"
    else
      @alert = @lesson.errors.full_messages.join(", ")
      replace :view => :new_lesson, :layout => "widget_course"
    end

  end

  def destroy_lesson
    widget_attributes params    
    @lesson = Lesson.find(params[:lesson])
    @lesson.destroy
    @notice = t("messages.module.destroy.success")
    replace :view => :display, :layout => "widget_course"
  end

  def new_media
    widget_attributes params
    @lesson = Lesson.find(params[:lesson])
    replace :view => :new_media, :layout => "widget_course"
  end

  def create_media
    widget_attributes params
    @media = Media.new(params[:media])
    @lesson = Lesson.find(params[:lesson])

    if @lesson.lessons_medias.any?
      @media.lessons_medias.build(:lesson => @lesson, 
        :sequence => @lesson.lessons_medias.order(:sequence).last.sequence + 1 )
    else
      @media.lessons_medias.build(:lesson => @lesson, :sequence => 1 )
    end

    if @media.save
      @notice = t("messages.lesson.create.success")
      replace :view => :choose_library_or_upload, :layout => "widget_course"
    else
      @alert  = @media.errors.full_messages.join(", ")
      replace :view => :new_media, :layout => "widget_course"
    end
  end

  def destroy_media
    widget_attributes params
    @media = Media.find(params[:media])
    @media.destroy
    @notice = t("messages.lesson.destroy.success")
    replace :view => :display, :layout => "widget_course"
  end

  def choose_library_or_upload params
    widget_attributes params
    @media = Media.find(params[:media])
    replace :view => :choose_library_or_upload, :layout => "widget_course"
  end

  def add_from_library params
    widget_attributes params
    @media = Media.find(params[:media])
    @wistia_project = Wistia::Project.find(current_school.wistia_public_project_id)
    @medias = @wistia_project.medias
    replace :view => :add_from_library, :layout => "widget_course"
  end

  def update_media_from_library params
    widget_attributes params

    @media = Media.find(params[:media])
    
    @media.wistia_hashed_id = params[:library_media_hashed_id]
    @media.kind = params[:library_media][:kind]

    if @media.save
      @notice = t("messages.media.update.success")
      replace :view => :display, :layout => "widget_course"
    else
      @alert = @media.errors.full_messages.join(", ")
      replace :view => :add_from_library, :layout => "widget_course"
    end
  end

  def add_content params
    @course = Course.find(params[:course])
    @media = Media.find(params[:media])
    replace :view => :add_content, :layout => "widget_course"
  end

  def create_content params
    @course = Course.find(params[:course])
    @media = Media.find(params[:media_id])

    if @media.update_attributes(params[:media])
      @lessons = @course.lessons.order(:sequence) 
      @notice = t("messages.media.update.success")
      replace :view => :display, :layout => "widget_course"
    else
      @alert = @media.errors.full_messages.join(", ")
      replace :view => :add_content, :layout => "widget_course"
    end
  end

  def view_content params
    @course = Course.find(params[:course])
    @media = Media.find(params[:media])

    if @media.embed?
      begin
        @content = Wistia::Media.find(@media.wistia_hashed_id)
        @content.embedCode.gsub!('width="1280"', 'width="100%"') if @content.embedCode
        @content.embedCode.gsub!('height="800"', 'height="580"') if @content.embedCode
        replace :view => :view_content, :layout => "widget_course"
      rescue
        @alert = "Ocorreu um erro ao o renderizar conteúdo."
        @lessons = @course.lessons.order(:sequence)
        replace :view => :display, :layout => "widget_course"
      end
    else
      replace :view => :view_content, :layout => "widget_course"
    end
  end

  def load_content params
    @course = Course.find(params[:course])
    @media = Media.find(params[:media])
    @media.kind = params[:kind]
    @show_form = true
    replace :view => :add_content, :layout => "widget_course"
  end

  def cancel_action params
    widget_attributes params

    replace :view => :display, :layout => "widget_course"
  end
  
  private
  def widget_attributes params
    @course = Course.find(params[:course])
    @lessons = @course.lessons.order(:sequence) 
  end

  def setup!(*)
    @title = t('widgets.edit_curriculum.title')
  end
end

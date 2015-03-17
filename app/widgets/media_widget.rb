#coding: utf-8

class MediaWidget < ApplicationWidget

  responds_to_event :display, with: :display

  def display args
    @course = if args[:course]
      args[:course].is_a?(Course) ? args[:course] : Course.find(args[:course])
    else
      Course.find(params[:course]) 
    end
    @media = if args[:media]
      args[:media].is_a?(Media) ? args[:media] : Media.find(args[:media])
    else
      Media.find(params[:media]) 
    end

    begin
      if @media.embed?
        @content = Wistia::Media.find(@media.wistia_hashed_id) 
        @content.embedCode.gsub!('width="1280"', 'width="100%"') if @content.embedCode
        @content.embedCode.gsub!('height="800"', 'height="580"') if @content.embedCode
      end

      if @media.kind == "Video"
        Notification.create(
          sender: current_user,
          code: Notification::USER_STARTED_MEDIA,
          notifiable: @media,
          message: @course.title,
          personal: true
        )
      else
        Notification.create(
          sender: current_user,
          code: Notification::USER_ENDED_MEDIA,
          notifiable: @media,
          message: @course.title,
          personal: true
        )
      end
    rescue
      @alert = "Ocorreu um erro ao o renderizar conteúdo. Tente novamente mais tarde."
      replace :view => :display, :layout => "widget_course"
    end
    
    @title = Media::TYPES.key(@media.kind)

    if args[:media].is_a? Media
      render :view => :display, :layout => "clean"
    else
      replace :view => :display, :layout => "clean"
    end
  end

end
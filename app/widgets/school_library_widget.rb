#coding: utf-8

class SchoolLibraryWidget < ApplicationWidget

  after_initialize :setup!
  
  responds_to_event :show_media, :with => :show_media
  responds_to_event :delete_media, :with => :delete_media
  responds_to_event :cancel, :with => :cancel

  has_widgets do |root|
    root << widget(:school_bandwidth)
  end
  
  def display args
    @school = args[:school]
    begin
      #3fmkwa3jeb
      if @school.wistia_public_project_id.present?
        @wistia_project = Wistia::Project.find(@school.wistia_public_project_id)
        @medias = @wistia_project.medias
      end
    rescue 
      @alert = t("messages.wistia.connect_failure")
    end
    render :layout => "clean"
  end
  
  def show_media params
    @school = School.find(params[:school])
    begin
      @content = Wistia::Media.find(params[:media_hash])
      if @content.respond_to?(:embedCode) && @content.embedCode.present?
        @embed = @content.embedCode
        @embed.gsub!('width="1280"', 'width="100%"') 
        @embed.gsub!('height="800"', 'height="580"')
      end
    rescue
      begin
        @wistia_project = Wistia::Project.find(@school.wistia_public_project_id) #3fmkwa3jeb
        @medias = @wistia_project.medias
        @alert = "Ocorreu um erro ao o renderizar conteúdo. Tente novamente mais tarde."
      rescue
        @alert = t("messages.wistia.connect_failure")
      end
      replace :view => :display, :layout => "clean"
    end
    replace :view => :show_media, :layout => "clean"
  end
  
  def delete_media
    @school = School.find(params[:school])
    begin
      Wistia::Media.find(params[:media_hash]).destroy
      @notice = 'Mídia apagada com sucesso'
    rescue
      @alert = t("messages.wistia.connect_failure")
    end
    replace :view => :delete_media, :layout => "clean"
  end
  
  def cancel params
    @school = School.find(params[:school])
    begin
      @wistia_project = Wistia::Project.find(@school.wistia_public_project_id) #3fmkwa3jeb
      @medias = @wistia_project.medias
    rescue 
      @alert = t("messages.wistia.connect_failure")
    end
    replace :view => :display, :layout => "clean"
  end

  private
  def setup!(*)
    @title = "Biblioteca de mídias"
    @icon = "fa-icon-book"
  end
  
end

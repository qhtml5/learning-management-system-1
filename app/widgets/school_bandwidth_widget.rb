#coding: utf-8

class SchoolBandwidthWidget < ApplicationWidget

  after_initialize :setup!
  
  def display args
    # return render :nothing => true if !Flip.school_bandwidth? 
    
    @school = args[:school]
    # begin
    #       #3fmkwa3jeb
    #       #@school.wistia_public_project_id
    #       @project_stats = Wistia::Stats::Project.get(@school.wistia_public_project_id + '/by_date', :start_date => '2013-06-01')
    #     rescue 
    #       @alert = t("messages.wistia.connect_failure")
    #       return render :layout => "widget_course"
    #     end
    
    # @total_gb = '40'
    #     @percent_gb = '80'
    render :layout => "widget_course"
  end

  private
  def setup!(*)
    @title = "Tráfego de dados do mês"
    @icon = "fa-icon-download"
    @soon = true
  end
  
end

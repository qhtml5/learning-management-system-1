class LayoutConfiguration < ActiveRecord::Base
  attr_accessible :background, :box_header, :menu_bar, :main_color, :home_logo, 
      :title, :home_title, :home_subtitle, :menu_link_color, :menu_link_color,
      :site_logo, :menu_link_hover_color, :box_header_color, :box_content,
      :box_content_color, :title_home_color, :home_title_subtitle_shadow,
      :video_url

  has_attached_file :site_logo, :styles => { medium: "300x75" },
    :default_url => '/images/:attachment/missing_:style.png'
    
  has_attached_file :home_logo, :styles => { medium: "480x270>", small: "313x176>" },
    :default_url => '/images/:attachment/missing_:style.png'

  belongs_to :school
end

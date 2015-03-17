#coding: utf-8

module LayoutHelper

  def box(options = {}, &block)
    result = "".html_safe
    result << "<div class='box #{options[:class]}' id='#{options[:id]}' style='#{options[:style]}'>".html_safe
    if options[:title]
      result << '<div class="head"><h4>'.html_safe
      if options[:icon]
        result << "<i class=\"#{options[:icon]}\" style='opacity: 0.8;'></i>".html_safe
        result << "<span class='head-divider'></span>".html_safe
      end
      result << "#{options[:title]}".html_safe
      if options[:soon]
        result << " - <span class=\"soon hint hint--right\" data-hint=\"Ainda estamos finalizando essa funcionalidade, mas você já pode dar uma espiadinha ;-)\">Em breve! (?)</span>".html_safe
      end
      result << "</h4></div>".html_safe
    end
    result << "<div class='content' style='#{options[:content_style]}'>".html_safe
    result << capture(&block)
    result << '	</div></div>'.html_safe
  end

  def new_box(options = {}, &block)
    result = "".html_safe
    result << "<div class='new_box #{options[:class]}' id='#{options[:id]}'>".html_safe
    if options[:title]
      result << '<div class="new_head"><h2>'.html_safe
      if options[:icon]
        result << "<i class=\"#{options[:icon]}\"></i>".html_safe
      end
      result << "#{options[:title]}".html_safe
      if options[:soon]
        result << " - <span class=\"soon hint hint--right\" data-hint=\"Ainda estamos finalizando essa funcionalidade, mas você já pode dar uma espiadinha ;-)\">Em breve! (?)</span>".html_safe
      end
      result << "</h2></div>".html_safe
    end
    result << '<div class="new_content">'.html_safe
    result << capture(&block)
    result << ' </div></div>'.html_safe
  end  

end
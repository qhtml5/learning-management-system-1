module MailerHelper

	def p_tag content, options = ""
	  style = "padding:7px 0px 3px;font-weight:200;font-size:20px;text-align:left;line-height:28px;color:#434343;" + options

    return "<p style=\"#{style}\">#{content}</p>".html_safe
	end

	def p2_tag content
	  style = "padding:4px 0px 1px;font-weight:200;font-size:16px;text-align:left;line-height:22px;color:#434343;"

    return "<p style=\"#{style}\">#{content}</p>".html_safe
	end	

	def header_tag content
		style = "padding:10px 20px 5px;font-weight:200;font-size:20px;text-align:center;line-height:28px;color:#434343;"

    return "<p style=\"#{style}\">#{content}</p>".html_safe
	end

	def text_tag content
		style = "font-family: Helvetica, Arial, sans-serif;font-size: 12px;text-align:left;line-height:16px;"

		return "<p style=\"#{style}\">#{content}</p>".html_safe
	end

	def message_tag content
		style = "padding:10px 20px 5px;font-weight:200;font-size:20px;text-align:left;line-height:28px;color:#434343;background-color:#fafafa"

		return "<div style=\"#{style}\">#{content}</div>".html_safe
	end

	def a_tag content, link
	  style = 'color:#e9490f;'

	  return link_to content, link, style: style
	end

	def title_tag content
	  style = "padding:7px 0px 3px;font-weight:200;font-size:22px;text-align:left;line-height:28px;color:#434343;"

	  return "<h1 style=\"#{style}\">#{content}</h1>".html_safe
	end

	def button_tag content, link
		style = "color:white;padding:18px;border-radius:5px;background:#8fc25d;border: 1px solid #f0f0f0;text-decoration:none;"

		return p_tag link_to(content, link, style: style), "margin: 10px 0;"
	end

	def footer_tag content
		style = "padding-top:15px;margin:0;clear:both;text-align:center;line-height:24px;font-size:12px;color:#aaa"

		return "<p style=\"#{style}\">#{content}</p>".html_safe
	end

end

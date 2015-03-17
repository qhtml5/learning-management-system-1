#coding: utf-8

module ApplicationHelper

  def title
    default = "Edools"
    @title.present? ? "#{@title} | #{default}" : default
  end

	def em_real value
    value = value.to_s
    if value.include? "."
      value = value.split(".").first
    else
      value = value.gsub(/\D+/, "")
    end
    if value == "0"
      "Grátis"
    elsif value.length == 1
      "R$ 0,0" + value
    elsif value.length == 2
      "R$ 0," + value
    elsif value.length > 2
      "R$ " + value.insert(-3, ',')
    end
  end

  def em_real_with_zero value
    result = em_real(value)
    result.gsub("Grátis", "R$ 0,00")
  end  

  def states
    ["AC", "AL", "AM", "AP", "BA", "CE", "DF", 
      "ES", "GO", "MA", "MT", "MS", "MG", "PA", 
      "PB", "PR", "PE", "PI", "RJ", "RN", "RO", 
      "RS", "RR", "SC", "SE", "SP", "TO"]
  end

  # def link_login_facebook(options = {})
  #   image = if options[:watch]
  #     'facebook_bt_assistir.png'
  #   else
  #     'facebook_bt_home.png'
  #   end

  #   link_to image_tag(image, :size => "255x49"), '/auth/facebook/', :id => (options[:id] || "facebook-login"), :class => "popup", "data-width" => 800, "data-height" => 600
  # end

  def thumbs_up_or_down bool
    if bool
      '<i class="icon-thumbs-up"></i>'.html_safe
    else
      '<i class="icon-thumbs-down"></i>'.html_safe
    end
  end

  def nav_link(link_path, options = {}, &block)
    if link_path.include? "courses"
      class_name = request.fullpath.include?("courses") ? 'active' : ''
      class_name = request.fullpath.include?("avaliacoes") ? 'active' : '' unless class_name.present?
      class_name = request.fullpath.include?("biblioteca") ? 'active' : '' unless class_name.present?
    elsif link_path.include? "aluno"
      class_name = request.fullpath.include?("aluno") ? 'active' : ''
    elsif link_path.include? "conversoes"
      class_name = request.fullpath.include?("conversoes") ? 'active' : ''
      class_name = request.fullpath.include?("cupons") ? 'active' : '' unless class_name.present?
    elsif link_path.include? "configuracoes"
      class_name = request.fullpath.include?("configuracoes/gerais") ? 'active' : ''
      class_name = request.fullpath.include?("configuracoes/integracoes") ? 'active' : '' unless class_name.present?
      class_name = request.fullpath.include?("configuracoes/moip") ? 'active' : '' unless class_name.present?
      class_name = request.fullpath.include?("configuracoes/dominio") ? 'active' : '' unless class_name.present?
      class_name = request.fullpath.include?("configuracoes/plano") ? 'active' : '' unless class_name.present?
      class_name = request.fullpath.include?("configuracoes/notificacoes") ? 'active' : '' unless class_name.present?
    elsif current_page?(link_path)
      class_name = 'active'
    else
      class_name = ''
    end

    content_tag(:li, :class => "#{class_name} #{options[:class]}") do
      link_to link_path, block.call
    end
  end

  def sub_nav_link(link_path, options = {}, &block)
    if current_page?(link_path)
      class_name = 'active'
    else
      class_name = ''
    end

    content_tag(:li, :class => "#{class_name} #{options[:class]}") do
      link_to link_path, block.call
    end
  end
  
  def media_icon type, options={}
    case type
    when "Video"
      "<i class=\"glyphicons-icon facetime_video\" style=\"#{options[:style]}\"\"></i>".html_safe
    when "Document"
      "<i class=\"glyphicons-icon file\" style=\"#{options[:style]}\"\"></i>".html_safe
    when "Slide"
      "<i class=\"glyphicons-icon keynote\" style=\"#{options[:style]}\"\"></i>".html_safe
    when "Audio"
      "<i class=\"glyphicons-icon bullhorn\" style=\"#{options[:style]}\"\"></i>".html_safe
    when "Text"
      "<i class=\"glyphicons-icon notes\" style=\"#{options[:style]}\"\"></i>".html_safe
    end
  end

  def pluralize_sentence amount, sentence
    result = []
    # result << amount
    sentence.split(" ").each do |word|
      if amount > 1
        result << word.pluralize
      else
        result << word
      end
    end
    result.join(" ")
  end

  def crm_showing_message students_length, course, status_filter
    status = if status_filter
      case status_filter
      when "confirmed"
        "confirmados"
      when "pending"
        "pendentes"
      end
    end
    result = "Exibindo #{students_length} alunos #{status}"
    if course
      result << " do curso #{course.title}"
    end
    result << "."
    result
  end

end
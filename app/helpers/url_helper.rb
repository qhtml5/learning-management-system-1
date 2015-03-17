module UrlHelper  
  def url_for(options = nil)
    if options.kind_of?(Hash) && current_school && current_school.domain.present? && current_school.use_custom_domain
      domain = current_school.domain.split(".")
      subdomain = if domain.length == 4
        [domain[0],domain[1]].join(".")
      else
        domain.first
      end

      if domain && request.protocol == "http://"
        unless params["action"] == "update" && params["controller"] == "users/registrations"
          options[:subdomain] = subdomain
          options[:host] = (domain - [domain.first]).join(".")
        end
      end
    end
    super
  end
end
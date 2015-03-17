class Subdomain
  def self.matches?(request)
    request.subdomain.present? && !["www", ""].include?(request.subdomain) &&
    	School.find_by_subdomain(request.subdomain).present?
  end
end
class NotSubdomain
  def self.matches?(request)
    request.subdomain.present? && ["www", ""].include?(request.subdomain)
  end
end
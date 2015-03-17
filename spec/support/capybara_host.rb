require 'capybara'
module Capybara

  # Adding a flag you can set to make Capybara always give `app_host` the port
  #  it chose for the rack server.
  def self.use_own_port?
    @use_own_port
  end

  def self.use_own_port=(use_own_port)
    @use_own_port = use_own_port
  end


  class Server
    # re-write this method to obey the `Capybara.use_own_port?` flag
    def url(path)
      if path =~ /^http/
        path
      else
        url = Capybara.app_host ? Capybara.app_host.dup : "http://#{host}:#{port}"
        url << ":#{port}" if !Capybara.app_host || Capybara.use_own_port?
        url + path.to_s
      end
    end
  end
end
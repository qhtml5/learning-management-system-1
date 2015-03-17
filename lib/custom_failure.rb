class CustomFailure < Devise::FailureApp
  def redirect_url
    if request.referer == social_checkouts_url
      social_checkouts_path
    elsif request.referer
      request.referer
    else
      new_user_session_path
    end
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
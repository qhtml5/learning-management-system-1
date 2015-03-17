#coding: utf-8

class SecureInfoWidget < ApplicationWidget

  def display
    # return render :nothing => true if !Flip.secure_info? 
    render
  end

end

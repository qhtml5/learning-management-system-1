class Feedback < ActiveRecord::Base
  attr_accessible :like, :text, :email

  validates :like, :inclusion => {:in => [true, false] }
  validates :text, :length => { :maximum => 5000 }, :allow_blank => true
  validates :email, :length => { :maximum => 100 }, :format => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
end

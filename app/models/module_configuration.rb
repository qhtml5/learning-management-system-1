class ModuleConfiguration < ActiveRecord::Base
  attr_accessible :remove_edools_logo

  belongs_to :school

  def active? attribute
  	self.send(attribute)
  end

  def inactive? attribute
  	!self.send(attribute)
  end
end

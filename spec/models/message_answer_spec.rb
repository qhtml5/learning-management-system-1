require 'spec_helper'

describe MessageAnswer do
  describe :associations do
  	it { should have_many(:notifications).dependent(:delete_all) }
  	
  	[:answer, :message].each do |model|
			it { should belong_to(model) }
		end
  end	
end

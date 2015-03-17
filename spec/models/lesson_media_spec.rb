require 'spec_helper'

describe LessonMedia do
  describe :validations do
    context :presence do
      it { should validate_presence_of(:sequence) }
    end
  end

  describe :associations do
    it { should have_many(:notifications).dependent(:delete_all) }
    
  	[:lesson, :media].each do |attribute|
  		it { should belong_to(attribute) }
  	end
  end
end

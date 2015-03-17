require 'spec_helper'

describe Lesson do
  describe :validations do
  	context :presence do
      it { should validate_presence_of(:course) }
  	end

    context :length do
      it { should ensure_length_of(:title).is_at_least(5).is_at_most(100) }
    end
  end

  describe :associations do
    it { should have_many(:notifications).dependent(:delete_all) }
    
		it { should belong_to(:course) }

		[:medias, :teachers].each do |model|
			it { should have_many(model) }
		end

		it { should have_many(:lessons_medias).dependent(:destroy) }
  end	
end

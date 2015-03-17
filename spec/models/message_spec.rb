require 'spec_helper'

describe Message do
  describe :validations do
    context :length do
      it { should ensure_length_of(:text).is_at_least(10).is_at_most(5000) }
    end
  end

  describe :associations do
  	[:course, :user].each do |model|
			it { should belong_to(model) }
		end

		[:messages_answers, :answers].each do |model|
			it { should have_many(model) }
		end

    it { should have_many(:notifications).dependent(:delete_all) }
  end	
end

require 'spec_helper'

describe CourseEvaluation do
  
  describe :associations do
    [:user, :course].each do |model|
      it { should belong_to(model) }
    end

    it { should have_many(:notifications).dependent(:delete_all) }
  end
  
end

require 'spec_helper'

describe LayoutConfiguration do
  
  describe :associations do
  	it { should belong_to(:school) }
  end
end

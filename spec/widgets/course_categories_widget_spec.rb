require 'spec_helper'

describe CourseCategoriesWidget do
  has_widgets do |root|
    root << widget('course_categories')
  end
  
end

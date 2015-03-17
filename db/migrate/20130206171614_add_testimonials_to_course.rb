class AddTestimonialsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :testimonials, :text
  end
end

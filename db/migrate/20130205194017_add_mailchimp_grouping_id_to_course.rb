class AddMailchimpGroupingIdToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :staging_mailchimp_grouping, :string
    add_column :courses, :production_mailchimp_grouping, :string
  end
end

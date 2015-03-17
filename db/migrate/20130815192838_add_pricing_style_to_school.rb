class AddPricingStyleToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :pricing_style, :integer, default: 1
  end
end

class AddWistiaPromoVideoIdToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :wistia_promo_video_id, :string
  end
end

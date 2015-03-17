class RenameColumnOrderToSequenceInCourseMedia < ActiveRecord::Migration
	def up
		rename_column :courses_medias, :order, :sequence
	end

	def down
		rename_column :courses_medias, :sequence, :order
	end
end

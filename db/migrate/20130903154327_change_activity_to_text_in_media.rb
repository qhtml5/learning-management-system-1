class ChangeActivityToTextInMedia < ActiveRecord::Migration
  def up
  	Media.where(kind: "Activity").update_all(kind: "Text")
  end

  def down
  	Media.where(kind: "Text").update_all(kind: "Activity")
  end
end

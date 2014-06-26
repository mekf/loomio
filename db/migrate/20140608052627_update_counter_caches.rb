class UpdateCounterCaches < ActiveRecord::Migration
  def up
    remove_column :groups, :motions_count
    add_column :discussions, :motions_count, :integer, default: 0

    Group.update_all discussions_count: 0
    Discussion.update_all motions_count: 0
  	Group.find_each do |group| 
      discussion_ids = Discussion.where(group_id: group.id).pluck(:id)
  	  Group.update_counters group.id, discussions_count: discussion_ids.size if discussion_ids.size > 0
      discussion_ids.each do |discussion_id| 
        motion_ids = Motion.where(discussion_id: discussion_id).pluck(:id)
        Discussion.update_counters discussion_id, motions_count: motion_ids.size if motion_ids.size > 0 
      end
  	end
  end

  def down
    remove_column :discussions, :motions_count
    add_column :groups, :motions_count, :integer, default: 0
  end
end

class AddFieldsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :birthday, :string
    add_column :users, :remote_avatar, :text
  end
end

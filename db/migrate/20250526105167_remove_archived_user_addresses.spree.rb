# frozen_string_literal: true

# This migration comes from spree (originally 20220419170826)
class RemoveArchivedUserAddresses < ActiveRecord::Migration[5.2]
  def up
    Spree::UserAddress.where(archived: true).delete_all
    remove_column :spree_user_addresses, :archived, :boolean, default: false
  end

  def down
    add_column :spree_user_addresses, :archived, :boolean, default: false
  end
end

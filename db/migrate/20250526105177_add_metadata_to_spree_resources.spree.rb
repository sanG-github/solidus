# frozen_string_literal: true

# This migration comes from spree (originally 20250129061658)
class AddMetadataToSpreeResources < ActiveRecord::Migration[7.2]
  def change
    # List of Resources to add metadata columns to
    %i[
      spree_orders
      spree_line_items
      spree_shipments
      spree_payments
      spree_refunds
      spree_customer_returns
      spree_store_credit_events
      spree_return_authorizations
    ].each do |table_name|
      change_table table_name do |t|
        # Check if the database supports jsonb for efficient querying
        if t.respond_to?(:jsonb)
          t.jsonb(:customer_metadata, default: {}) unless t.column_exists?(:customer_metadata)
          t.jsonb(:admin_metadata, default: {}) unless t.column_exists?(:admin_metadata)
        else
          t.json(:customer_metadata) unless t.column_exists?(:customer_metadata)
          t.json(:admin_metadata) unless t.column_exists?(:admin_metadata)
        end
      end
    end
  end
end

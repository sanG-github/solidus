# This migration converts JSON columns to JSONB for better performance in PostgreSQL.
#
# Benefits of JSONB over JSON in PostgreSQL:
# - Binary storage format (more efficient)
# - Supports indexing with GIN indexes
# - Faster query operations
# - Automatic deduplication of keys
# - More efficient comparison and sorting
#
# For other databases:
# - SQLite: JSON is stored as text, no performance difference
# - MySQL: JSON type is already optimized
#
class ConvertJsonToJsonbColumns < ActiveRecord::Migration[8.0]
  def up
    # List of tables and their JSON columns to convert
    tables_with_json_columns = [
      { table: :spree_customer_returns, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_line_items, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_orders, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_payments, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_refunds, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_return_authorizations, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_shipments, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_store_credit_events, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_users, columns: [:customer_metadata, :admin_metadata] }
    ]

    case connection.adapter_name
    when 'PostgreSQL'
      # Convert each JSON column to JSONB for PostgreSQL
      tables_with_json_columns.each do |table_info|
        table_name = table_info[:table]
        
        table_info[:columns].each do |column_name|
          say "Converting #{table_name}.#{column_name} from JSON to JSONB"
          # Change column type from json to jsonb
          change_column table_name, column_name, :jsonb, using: "#{column_name}::jsonb"
        end
      end
      say "Successfully converted all JSON columns to JSONB for PostgreSQL"
    when 'SQLite'
      say "SQLite detected - JSON columns are already optimized (SQLite stores JSON as text)", true
      # SQLite doesn't distinguish between JSON and JSONB - it stores JSON as text
      # No conversion needed, but we'll add a comment for documentation
      tables_with_json_columns.each do |table_info|
        table_name = table_info[:table]
        table_info[:columns].each do |column_name|
          say "#{table_name}.#{column_name} - SQLite JSON handling is already optimal"
        end
      end
    else
      say "Database adapter #{connection.adapter_name} detected - no JSON to JSONB conversion available", true
      say "This migration is primarily intended for PostgreSQL databases", true
    end
  end

  def down
    # List of tables and their JSONB columns to convert back to JSON
    tables_with_jsonb_columns = [
      { table: :spree_customer_returns, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_line_items, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_orders, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_payments, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_refunds, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_return_authorizations, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_shipments, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_store_credit_events, columns: [:customer_metadata, :admin_metadata] },
      { table: :spree_users, columns: [:customer_metadata, :admin_metadata] }
    ]

    case connection.adapter_name
    when 'PostgreSQL'
      # Convert each JSONB column back to JSON for PostgreSQL
      tables_with_jsonb_columns.each do |table_info|
        table_name = table_info[:table]
        
        table_info[:columns].each do |column_name|
          say "Converting #{table_name}.#{column_name} from JSONB back to JSON"
          # Change column type from jsonb to json
          change_column table_name, column_name, :json, using: "#{column_name}::json"
        end
      end
      say "Successfully reverted all JSONB columns to JSON for PostgreSQL"
    when 'SQLite'
      say "SQLite detected - no reversion needed (JSON columns unchanged)", true
    else
      say "Database adapter #{connection.adapter_name} detected - no reversion needed", true
    end
  end
end

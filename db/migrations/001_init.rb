Sequel.migration do
  change do
    create_table :channels do
      primary_key :id

      TrueClass :enabled, null: false, default: true
      String :title,     size: 255, null: false
      String :feed_link, size: 255, null: false
      String :html_link, size: 255, null: false
      String :status,    size: 255
      Integer :items_count,        null: false, default: 0
      Integer :unread_items_count, null: false, default: 0

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :feed_link, unique: true
      index :enabled
    end

    create_table :items do
      primary_key :id
      foreign_key :channel_id, :channels, null: false, on_delete: :cascade

      FalseClass :read, null: false, default: false
      String :title, size: 255, null: false
      String :link, text: true, null: false
      String :description, text: true, null: true
      String :author, size: 255, null: true
      String :guid, size: 255, null: false
      DateTime :pub_date, null: true

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :channel_id
      index [:channel_id, :guid], unique: true
      index :read
    end

    def pgt_unread_counter_cache(main_table, main_table_id_column, counter_column, counted_table, counted_table_id_column, counted_table_bool_column, opts={})
      trigger_name = opts[:trigger_name] || "pgt_ucc_#{main_table}__#{main_table_id_column}__#{counter_column}__#{counted_table_id_column}"
      function_name = opts[:function_name] || "pgt_ucc_#{main_table}__#{main_table_id_column}__#{counter_column}__#{counted_table}__#{counted_table_id_column}"

      table = quote_schema_table(main_table)
      id_column = quote_identifier(counted_table_id_column)
      main_column = quote_identifier(main_table_id_column)
      count_column = quote_identifier(counter_column)
      bool_column = quote_identifier(counted_table_bool_column)

      pgt_trigger(counted_table, trigger_name, function_name, [:insert, :update, :delete], <<-SQL)
      BEGIN
        IF (TG_OP = 'UPDATE' AND ((OLD.#{id_column} IS NULL AND NEW.#{id_column} IS NULL) OR (NEW.#{id_column} = OLD.#{id_column} AND NEW.#{bool_column} = true AND OLD.#{bool_column} = true))) THEN
          RETURN NEW;
        ELSE
          IF ((TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.#{id_column} IS NOT NULL AND NEW.#{bool_column} = false) THEN
            UPDATE #{table} SET #{count_column} = #{count_column} + 1 WHERE #{main_column} = NEW.#{id_column};
          END IF;
          IF ((TG_OP = 'DELETE' OR TG_OP = 'UPDATE') AND OLD.#{id_column} IS NOT NULL AND OLD.#{bool_column} = false) THEN
            UPDATE #{table} SET #{count_column} = #{count_column} - 1 WHERE #{main_column} = OLD.#{id_column};
          END IF;
        END IF;

        IF (TG_OP = 'DELETE') THEN
          RETURN OLD;
        END IF;
        RETURN NEW;
      END;
      SQL
    end

    extension :pg_triggers
    pgt_counter_cache :channels, :id, :items_count, :items, :channel_id
    pgt_unread_counter_cache :channels, :id, :unread_items_count, :items, :channel_id, :read
  end
end

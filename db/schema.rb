Sequel.migration do
  change do
    create_table(:channels) do
      primary_key :id
      column :enabled, 'boolean', default: true, null: false
      column :title, 'character varying(255)', null: false
      column :feed_link, 'character varying(255)', null: false
      column :html_link, 'character varying(255)', null: false
      column :status, 'character varying(255)'
      column :items_count, 'integer', default: 0, null: false
      column :unread_items_count, 'integer', default: 0, null: false
      column :created_at, 'timestamp without time zone', null: false
      column :updated_at, 'timestamp without time zone', null: false

      index [:enabled]
      index [:feed_link], unique: true
    end

    create_table(:schema_info) do
      column :version, 'integer', default: 0, null: false
    end

    create_table(:items) do
      primary_key :id
      foreign_key :channel_id, :channels, null: false, key: [:id], on_delete: :cascade
      column :read, 'boolean', default: false, null: false
      column :title, 'character varying(255)', null: false
      column :link, 'text', null: false
      column :description, 'text'
      column :author, 'character varying(255)'
      column :guid, 'character varying(255)', null: false
      column :pub_date, 'timestamp without time zone'
      column :created_at, 'timestamp without time zone', null: false
      column :updated_at, 'timestamp without time zone', null: false

      index %i[channel_id guid], unique: true
      index [:channel_id]
      index [:read]
    end
  end
end

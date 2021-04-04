class CreateConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :configs do |t|
      t.text :name
      t.integer :record_id
      t.text :record_type
      t.text :data
      t.datetime :created_at
      t.datetime :updated_at
      t.index [:record_id, :record_type], name: :index_configs_on_record_id_and_record_type
    end
  end
end

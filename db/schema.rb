# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_04_090914) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ad_groups", force: :cascade do |t|
    t.text "campaign_id"
    t.text "adwords_id"
    t.text "name"
    t.text "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["adwords_id", "name"], name: "index_ad_groups_on_adwords_id_and_name", unique: true
    t.index ["campaign_id"], name: "index_ad_groups_on_campaign_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.text "adwords_id"
    t.text "name"
    t.text "status"
    t.text "serving_status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["adwords_id", "name"], name: "index_campaigns_on_adwords_id_and_name", unique: true
  end

  create_table "configs", force: :cascade do |t|
    t.text "name"
    t.integer "record_id"
    t.text "record_type"
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["record_id", "record_type"], name: "index_configs_on_record_id_and_record_type"
  end

end

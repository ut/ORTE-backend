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

ActiveRecord::Schema[7.2].define(version: 2025_03_26_143647) do
  create_table "active_storage_attachments", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "annotations", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.bigint "place_id"
    t.bigint "person_id"
    t.boolean "published", default: false
    t.integer "sorting"
    t.text "source"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["person_id"], name: "fk_rails_adeffa1c70"
    t.index ["place_id"], name: "fk_rails_51dbcfe977"
  end

  create_table "build_logs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "map_id"
    t.bigint "layer_id"
    t.string "output"
    t.string "size"
    t.string "version"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["layer_id"], name: "index_build_logs_on_layer_id"
    t.index ["map_id"], name: "index_build_logs_on_map_id"
  end

  create_table "friendly_id_slugs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, length: { slug: 70, scope: 70 }
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", length: { slug: 140 }
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "groups", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: true
    t.text "message"
  end

  create_table "icons", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.bigint "iconset_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["iconset_id"], name: "index_icons_on_iconset_id"
  end

  create_table "iconsets", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "icon_anchor"
    t.string "icon_size"
    t.string "popup_anchor"
    t.string "class_name"
  end

  create_table "images", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.string "licence"
    t.text "source"
    t.string "creator"
    t.bigint "place_id"
    t.string "alt"
    t.string "caption"
    t.integer "sorting"
    t.boolean "preview"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "itype", default: "image"
    t.index ["place_id"], name: "index_images_on_place_id"
  end

  create_table "import_mappings", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.text "mapping", size: :long, collation: "utf8mb4_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "json_valid(`mapping`)", name: "mapping"
  end

  create_table "layers", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.boolean "published", default: false
    t.bigint "map_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "color"
    t.text "text"
    t.boolean "public_submission", default: false
    t.string "slug"
    t.text "credits"
    t.string "mapcenter_lat"
    t.string "mapcenter_lon"
    t.integer "zoom", default: 12
    t.text "teaser"
    t.text "style"
    t.text "basemap_url"
    t.text "basemap_attribution"
    t.string "tooltip_display_mode", default: "none"
    t.string "places_sort_order"
    t.string "background_color", default: ""
    t.boolean "exif_remove", default: true
    t.boolean "rasterize_images", default: false
    t.integer "relations_bending", default: 1
    t.string "relations_coloring", default: "colored"
    t.boolean "use_mapcenter_from_parent_map", default: true
    t.text "image_alt"
    t.string "image_licence"
    t.text "image_source"
    t.string "image_creator"
    t.string "image_caption"
    t.boolean "use_background_from_parent_map", default: true
    t.string "ltype", default: "standard"
    t.text "geojson", size: :long, collation: "utf8mb4_bin"
    t.index ["map_id"], name: "index_layers_on_map_id"
    t.index ["slug"], name: "index_layers_on_slug", unique: true
    t.check_constraint "json_valid(`geojson`)", name: "geojson"
  end

  create_table "maps", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.boolean "published", default: false
    t.bigint "group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "script"
    t.string "northeast_corner"
    t.string "southwest_corner"
    t.text "text"
    t.integer "iconset_id"
    t.string "basemap_url"
    t.string "basemap_attribution"
    t.string "slug"
    t.string "popup_display_mode", default: "click"
    t.boolean "show_annotations_on_map", default: false
    t.text "credits"
    t.text "teaser"
    t.text "style"
    t.string "color"
    t.string "mapcenter_lat"
    t.string "mapcenter_lon"
    t.integer "zoom", default: 12
    t.string "tooltip_display_mode", default: "none"
    t.string "places_sort_order"
    t.string "background_color", default: "#454545"
    t.string "preview_url"
    t.boolean "enable_map_to_go", default: false
    t.boolean "enable_privacy_features", default: true
    t.string "marker_display_mode", default: "cluster"
    t.boolean "enable_historical_maps", default: false
    t.boolean "enable_time_slider", default: false
    t.index ["group_id"], name: "index_maps_on_group_id"
    t.index ["slug"], name: "index_maps_on_slug", unique: true
  end

  create_table "mobility_string_translations", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.string "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_string_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_string_translations_on_keys", unique: true
    t.index ["translatable_type", "key", "value", "locale"], name: "index_mobility_string_translations_on_query_keys"
  end

  create_table "mobility_text_translations", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.text "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_text_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_text_translations_on_keys", unique: true
  end

  create_table "pages", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.boolean "is_published", default: false
    t.boolean "in_menu", default: false
    t.string "ptype"
    t.string "title"
    t.text "teasertext"
    t.text "fulltext"
    t.text "footertext"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "people", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.text "info"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "map_id"
    t.index ["map_id"], name: "index_people_on_map_id"
  end

  create_table "places", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.text "teaser"
    t.text "text"
    t.string "link"
    t.datetime "startdate", precision: nil
    t.datetime "enddate", precision: nil
    t.string "lat"
    t.string "lon"
    t.string "location"
    t.string "address"
    t.string "zip"
    t.string "city"
    t.string "country"
    t.boolean "published", default: false
    t.bigint "layer_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "imagelink"
    t.integer "icon_id"
    t.boolean "featured", default: false
    t.string "ptype", default: "info"
    t.boolean "shy", default: false
    t.boolean "sensitive", default: false
    t.integer "sensitive_radius", default: 100
    t.string "subtitle"
    t.string "direction"
    t.string "uid"
    t.string "startdate_qualifier"
    t.string "enddate_qualifier"
    t.string "state"
    t.text "sources"
    t.index ["layer_id"], name: "index_places_on_layer_id"
  end

  create_table "relations", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "relation_from_id"
    t.integer "relation_to_id"
    t.string "rtype"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "sessions", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data", size: :long
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "submission_configs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title_intro"
    t.string "subtitle_intro"
    t.text "intro"
    t.string "title_outro"
    t.text "outro"
    t.datetime "start_time", precision: nil
    t.datetime "end_time", precision: nil
    t.boolean "use_city_only"
    t.bigint "layer_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "locales"
    t.index ["layer_id"], name: "index_submission_configs_on_layer_id"
  end

  create_table "submissions", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.boolean "rights"
    t.boolean "privacy"
    t.string "locale"
    t.bigint "place_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", default: 0, null: false
    t.index ["place_id"], name: "index_submissions_on_place_id"
  end

  create_table "taggings", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", collation: "utf8mb3_bin"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "role", default: "user"
    t.bigint "group_id"
    t.datetime "created_at", precision: nil, default: "2021-09-03 18:29:24", null: false
    t.datetime "updated_at", precision: nil, default: "2021-09-03 18:29:24", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["group_id"], name: "index_users_on_group_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "videos", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.string "licence"
    t.text "source"
    t.string "creator"
    t.bigint "place_id"
    t.string "alt"
    t.string "caption"
    t.integer "sorting"
    t.boolean "preview"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["place_id"], name: "index_videos_on_place_id"
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "annotations", "people"
  add_foreign_key "annotations", "places"
  add_foreign_key "build_logs", "layers"
  add_foreign_key "build_logs", "maps"
  add_foreign_key "icons", "iconsets"
  add_foreign_key "images", "places"
  add_foreign_key "layers", "maps"
  add_foreign_key "maps", "groups"
  add_foreign_key "people", "maps"
  add_foreign_key "places", "layers"
  add_foreign_key "submission_configs", "layers"
  add_foreign_key "submissions", "places"
  add_foreign_key "taggings", "tags"
  add_foreign_key "users", "groups"
  add_foreign_key "videos", "places"
end

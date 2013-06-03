# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130531191255) do

  create_table "addresses", :force => true do |t|
    t.integer  "user_id"
    t.string   "street"
    t.string   "build"
    t.integer  "porch"
    t.integer  "nos"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "primary",    :default => false
    t.string   "room",                          :null => false
  end

  create_table "admin_departments", :force => true do |t|
    t.integer  "admin_id"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_departments", ["admin_id", "department_id"], :name => "index_admin_departments_on_admin_id_and_department_id", :unique => true

  create_table "admin_settings", :force => true do |t|
    t.integer  "admin_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_settings", ["admin_id", "key", "value"], :name => "index_admin_settings_on_admin_id_and_key_and_value", :unique => true

  create_table "admins", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",                              :default => false, :null => false
    t.boolean  "super_user",                            :default => false, :null => false
    t.datetime "reset_password_sent_at"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.boolean  "displayed"
    t.boolean  "reported"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order", :default => 0, :null => false
  end

  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "cell1"
    t.string   "cell2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cell3"
    t.string   "home_phone"
    t.string   "jabber",     :limit => 50
  end

  create_table "department_categories", :force => true do |t|
    t.integer  "department_id"
    t.integer  "category_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "department_categories", ["department_id", "category_id"], :name => "index_department_categories_on_department_id_and_category_id", :unique => true

  create_table "department_permissions", :force => true do |t|
    t.integer  "department_id"
    t.integer  "permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "department_permissions", ["department_id", "permission_id"], :name => "index_department_permissions_on_department_id_and_permission_id", :unique => true

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.boolean  "has_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_t_shirt",    :default => false
    t.boolean  "has_levels",     :default => false
    t.boolean  "show_address",   :default => true
    t.boolean  "has_events",     :default => true
    t.boolean  "has_schedule",   :default => true
    t.boolean  "self_scored",    :default => false
  end

  create_table "events", :force => true do |t|
    t.integer  "shift_id"
    t.integer  "user_id"
    t.integer  "category_id"
    t.datetime "eventtime"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ip_address",  :limit => 8
  end

  add_index "events", ["category_id"], :name => "index_events_on_category_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "late_comings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "shift_id"
    t.integer  "late_minutes"
    t.integer  "late_type",    :default => 7, :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "late_comings", ["shift_id"], :name => "index_late_comings_on_shift_id"
  add_index "late_comings", ["user_id"], :name => "index_late_comings_on_user_id"

  create_table "logs", :force => true do |t|
    t.text     "body"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logs", ["author_id", "author_type"], :name => "index_logs_on_author_id_and_author_type"
  add_index "logs", ["subject_id", "subject_type"], :name => "index_logs_on_subject_id_and_subject_type"

  create_table "norms", :force => true do |t|
    t.integer "user_id"
    t.integer "year"
    t.integer "month"
    t.integer "workdays"
    t.integer "weekend"
  end

  create_table "permissions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "last_name"
    t.string   "first_name"
    t.date     "birthdate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "t_shirt_size", :null => false
    t.string   "level",        :null => false
  end

  create_table "schedule_cells", :force => true do |t|
    t.integer "schedule_shift_id"
    t.integer "line"
    t.integer "day"
    t.integer "user_id"
    t.integer "additional_attributes"
    t.integer "responsible"
    t.boolean "is_modified"
    t.boolean "exclude",               :default => false
  end

  add_index "schedule_cells", ["schedule_shift_id", "line", "day"], :name => "by_shift_line_day", :unique => true
  add_index "schedule_cells", ["schedule_shift_id"], :name => "index_schedule_cells_on_shift_id"

  create_table "schedule_shifts", :force => true do |t|
    t.integer "schedule_template_id"
    t.integer "lines"
    t.integer "number"
    t.integer "start"
    t.integer "end"
  end

  add_index "schedule_shifts", ["schedule_template_id", "number"], :name => "index_schedule_shifts_on_schedule_template_id_and_number", :unique => true
  add_index "schedule_shifts", ["schedule_template_id"], :name => "index_schedule_shifts_on_template_id"

  create_table "schedule_statuses", :force => true do |t|
    t.string "name",  :null => false
    t.string "color", :null => false
  end

  add_index "schedule_statuses", ["name"], :name => "index_schedule_statuses_on_name", :unique => true

  create_table "schedule_templates", :force => true do |t|
    t.integer "department_id"
    t.integer "year"
    t.integer "month"
    t.integer "visible",       :default => 0, :null => false
  end

  add_index "schedule_templates", ["department_id", "year", "month"], :name => "index_schedule_templates_on_department_id_and_year_and_month", :unique => true

  create_table "self_scores", :force => true do |t|
    t.date     "score_date"
    t.integer  "user_id"
    t.integer  "score"
    t.string   "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "shift_leader_scores", :force => true do |t|
    t.date     "shift_date"
    t.integer  "shift_number"
    t.integer  "shift_leader_id"
    t.integer  "user_id"
    t.integer  "score"
    t.string   "comment"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "shifts", :force => true do |t|
    t.integer  "user_id"
    t.date     "shiftdate"
    t.integer  "number"
    t.integer  "start_event"
    t.integer  "end_event"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "schedule_shift_id"
  end

  add_index "shifts", ["schedule_shift_id"], :name => "index_shifts_on_schedule_shift_id"
  add_index "shifts", ["user_id"], :name => "index_shifts_on_user_id"

  create_table "taxi_routes", :force => true do |t|
    t.date     "traced"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_permissions", ["user_id", "permission_id"], :name => "index_user_permissions_on_user_id_and_permission_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.integer  "department_id"
    t.integer  "identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "active",                                :default => false, :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.date     "hired_at"
    t.date     "fired_at"
    t.boolean  "fired",                                 :default => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "can_edit_schedule",                     :default => 0,     :null => false
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean  "team_lead",                             :default => false
    t.integer  "norm",                                  :default => 8,     :null => false
    t.text     "extended_permissions"
    t.boolean  "deliverable",                           :default => false, :null => false
  end

  add_index "users", ["department_id"], :name => "index_users_on_department_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

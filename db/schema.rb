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

ActiveRecord::Schema.define(:version => 20131106170656) do

  create_table "addresses", :force => true do |t|
    t.string   "street"
    t.string   "number"
    t.string   "complement"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "district"
  end

  add_index "addresses", ["user_id"], :name => "index_addresses_on_user_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "cart_items", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "course_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "coupon_id"
    t.integer  "purchase_id"
    t.datetime "confirmed_at"
    t.integer  "price",        :default => 0
  end

  add_index "cart_items", ["cart_id"], :name => "index_cart_items_on_cart_id"
  add_index "cart_items", ["coupon_id"], :name => "index_cart_items_on_coupon_id"
  add_index "cart_items", ["course_id"], :name => "index_cart_items_on_course_id"
  add_index "cart_items", ["purchase_id"], :name => "index_cart_items_on_purchase_id"

  create_table "carts", :force => true do |t|
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "school_id"
    t.string   "identificator"
    t.string   "token"
  end

  add_index "carts", ["school_id"], :name => "index_carts_on_school_id"

  create_table "coupons", :force => true do |t|
    t.integer  "discount",        :default => 0
    t.string   "name"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "expiration_date"
    t.integer  "quantity",        :default => 0
    t.integer  "quantity_left"
    t.integer  "course_id"
    t.boolean  "automatic",       :default => false
  end

  add_index "coupons", ["course_id"], :name => "index_coupons_on_course_id"
  add_index "coupons", ["name"], :name => "index_coupons_on_name"

  create_table "course_categories", :force => true do |t|
    t.string   "name"
    t.integer  "school_id"
    t.integer  "sequence"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "course_evaluations", :force => true do |t|
    t.text     "comment"
    t.decimal  "score",      :precision => 10, :scale => 0
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "course_evaluations", ["course_id"], :name => "index_course_evaluations_on_course_id"
  add_index "course_evaluations", ["user_id"], :name => "index_course_evaluations_on_user_id"

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "price",                         :default => 0,        :null => false
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "pitch"
    t.string   "logo_url"
    t.string   "video_url"
    t.string   "video_title"
    t.string   "video_subtitle"
    t.string   "last_call_to_action"
    t.text     "content"
    t.string   "slug"
    t.boolean  "academy",                       :default => false
    t.string   "staging_mailchimp_grouping"
    t.string   "production_mailchimp_grouping"
    t.text     "testimonials"
    t.string   "small_logo_url"
    t.string   "status",                        :default => "draft"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "privacy",                       :default => "public"
    t.text     "who_should_attend"
    t.text     "content_and_goals"
    t.text     "downloads"
    t.integer  "school_id"
    t.integer  "hours"
    t.text     "allowed_emails"
    t.integer  "available_time",                :default => 0
    t.text     "advantages"
    t.boolean  "certificate_available",         :default => false
    t.text     "instructor_bio"
    t.integer  "course_category_id"
    t.boolean  "accept_download",               :default => false
  end

  add_index "courses", ["school_id"], :name => "index_courses_on_school_id"
  add_index "courses", ["slug"], :name => "index_courses_on_slug"

  create_table "courses_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "courses_users", ["course_id"], :name => "index_courses_users_on_course_id"
  add_index "courses_users", ["user_id"], :name => "index_courses_users_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "features", :force => true do |t|
    t.string   "key",                           :null => false
    t.boolean  "enabled",    :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "features", ["key"], :name => "index_features_on_key"

  create_table "feedbacks", :force => true do |t|
    t.boolean  "like"
    t.text     "text"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "email",      :limit => 100
  end

  create_table "invitations", :force => true do |t|
    t.string   "email"
    t.string   "role"
    t.integer  "school_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "course_id"
  end

  add_index "invitations", ["course_id"], :name => "index_invitations_on_course_id"
  add_index "invitations", ["school_id"], :name => "index_invitations_on_school_id"

  create_table "layout_configurations", :force => true do |t|
    t.string   "background"
    t.string   "menu_bar"
    t.string   "box_header"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "site_logo_file_name"
    t.string   "site_logo_content_type"
    t.integer  "site_logo_file_size"
    t.datetime "site_logo_updated_at"
    t.string   "main_color"
    t.string   "title"
    t.string   "home_title"
    t.string   "home_subtitle"
    t.string   "home_logo_file_name"
    t.string   "home_logo_content_type"
    t.integer  "home_logo_file_size"
    t.datetime "home_logo_updated_at"
    t.string   "menu_link_color"
    t.integer  "school_id"
    t.string   "menu_link_hover_color"
    t.string   "box_header_color"
    t.string   "box_content"
    t.string   "box_content_color"
    t.string   "title_home_color"
    t.string   "home_title_subtitle_shadow"
    t.string   "video_url"
  end

  add_index "layout_configurations", ["school_id"], :name => "index_layout_configurations_on_school_id"

  create_table "leads", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "school_id"
    t.integer  "course_id"
  end

  create_table "lessons", :force => true do |t|
    t.string   "title"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
    t.integer  "sequence"
  end

  add_index "lessons", ["course_id"], :name => "index_lessons_on_course_id"

  create_table "lessons_medias", :force => true do |t|
    t.integer  "lesson_id"
    t.integer  "media_id"
    t.integer  "sequence"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "medias", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "text"
    t.string   "kind"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "wistia_hashed_id"
  end

  create_table "messages", :force => true do |t|
    t.text     "text"
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "kind"
    t.integer  "receiver_id"
  end

  add_index "messages", ["course_id"], :name => "index_messages_on_course_id"
  add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "messages_answers", :force => true do |t|
    t.integer  "message_id"
    t.integer  "answer_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "messages_answers", ["answer_id"], :name => "index_messages_answers_on_answer_id"
  add_index "messages_answers", ["message_id"], :name => "index_messages_answers_on_message_id"

  create_table "module_configurations", :force => true do |t|
    t.boolean  "remove_edools_logo", :default => false
    t.integer  "school_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "notification_configurations", :force => true do |t|
    t.boolean  "user_new_registration",          :default => true
    t.boolean  "user_new_contact",               :default => true
    t.boolean  "course_new_question",            :default => true
    t.boolean  "course_add_to_cart",             :default => true
    t.boolean  "course_new_evaluation",          :default => true
    t.boolean  "course_new_certificate_request", :default => true
    t.boolean  "purchase_pending",               :default => true
    t.boolean  "purchase_confirmed",             :default => true
    t.integer  "school_id"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.boolean  "purchase_liberated"
  end

  add_index "notification_configurations", ["school_id"], :name => "index_notification_configurations_on_school_id"

  create_table "notifications", :force => true do |t|
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "code"
    t.boolean  "read",            :default => false
    t.string   "message"
    t.string   "email"
    t.boolean  "personal",        :default => false
  end

  add_index "notifications", ["notifiable_id"], :name => "index_notifications_on_notifiable_id"
  add_index "notifications", ["notifiable_type"], :name => "index_notifications_on_notifiable_type"
  add_index "notifications", ["receiver_id"], :name => "index_notifications_on_receiver_id"
  add_index "notifications", ["sender_id"], :name => "index_notifications_on_sender_id"

  create_table "purchases", :force => true do |t|
    t.string   "status"
    t.integer  "code"
    t.string   "return_code"
    t.float    "moip_tax",                   :default => 0.0
    t.string   "payment_status"
    t.string   "classification_description"
    t.integer  "moip_code"
    t.string   "message"
    t.integer  "amount_paid",                :default => 0
    t.integer  "user_id"
    t.string   "classification_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_type"
    t.string   "institution"
    t.string   "identificator"
    t.string   "token"
    t.boolean  "sent_new_email",             :default => false
    t.boolean  "sent_confirmation_email",    :default => false
    t.integer  "school_id"
    t.integer  "commission",                 :default => 0
    t.integer  "installments",               :default => 1
  end

  add_index "purchases", ["identificator"], :name => "index_purchases_on_identificator"
  add_index "purchases", ["school_id"], :name => "index_purchases_on_school_id"
  add_index "purchases", ["user_id"], :name => "index_purchases_on_user_id"

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.text     "about_us"
    t.string   "site"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "moip_login"
    t.string   "domain"
    t.string   "slug"
    t.string   "subdomain"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "wistia_public_project_id"
    t.string   "plan",                     :default => "trial"
    t.string   "ga_tracking_id"
    t.boolean  "can_create_free_course",   :default => false
    t.string   "token_rdstation"
    t.string   "adroll_adv_id"
    t.string   "adroll_pix_id"
    t.string   "phone"
    t.string   "email"
    t.boolean  "accept_credit_card",       :default => true
    t.boolean  "accept_online_debit",      :default => true
    t.boolean  "accept_billet",            :default => true
    t.integer  "pricing_style",            :default => 1
    t.boolean  "cart_recovery",            :default => false
    t.boolean  "automatic_confirmation",   :default => false
    t.boolean  "use_custom_domain",        :default => false
    t.text     "footer_info"
    t.text     "introduction_info"
  end

  add_index "schools", ["subdomain"], :name => "index_schools_on_subdomain"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "first_name",             :limit => 40
    t.string   "last_name",              :limit => 40
    t.string   "skype"
    t.string   "phone_number"
    t.string   "cpf"
    t.string   "image_url"
    t.text     "biography"
    t.string   "slug"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "school_id"
    t.string   "role"
    t.string   "company"
    t.string   "function"
    t.string   "unique_session_id",      :limit => 20
  end

  add_index "users", ["email", "school_id"], :name => "index_users_on_email_and_school_id", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_usuarios_on_reset_password_token", :unique => true
  add_index "users", ["school_id"], :name => "index_users_on_school_id"

end

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

ActiveRecord::Schema[8.0].define(version: 2025_09_30_000007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_activity_logs", force: :cascade do |t|
    t.string "action"
    t.json "details"
    t.bigint "admin_id", null: false
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_activity_logs_on_admin_id"
    t.index ["resource_type", "resource_id"], name: "index_admin_activity_logs_on_resource"
  end

  create_table "admin_transactions", force: :cascade do |t|
    t.integer "action"
    t.text "reason"
    t.bigint "admin_id", null: false
    t.string "approvable_type", null: false
    t.bigint "approvable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_transactions_on_admin_id"
    t.index ["approvable_type", "approvable_id"], name: "index_admin_transactions_on_approvable"
  end

  create_table "bond_transactions", force: :cascade do |t|
    t.bigint "bond_id", null: false
    t.bigint "payment_transaction_id"
    t.string "transaction_type"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bond_id"], name: "index_bond_transactions_on_bond_id"
    t.index ["payment_transaction_id"], name: "index_bond_transactions_on_payment_transaction_id"
    t.index ["transaction_type"], name: "index_bond_transactions_on_transaction_type"
  end

  create_table "bonds", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.string "status"
    t.datetime "paid_at"
    t.datetime "forfeited_at"
    t.datetime "returned_at"
    t.text "forfeiture_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_bonds_on_status"
    t.index ["user_id"], name: "index_bonds_on_user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_cart_items_on_item_id"
    t.index ["user_id", "item_id"], name: "index_cart_items_on_user_id_and_item_id", unique: true
    t.index ["user_id"], name: "index_cart_items_on_user_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.bigint "parent_id"
    t.string "fee_type", default: "default"
    t.index ["active"], name: "index_categories_on_active"
    t.index ["fee_type"], name: "index_categories_on_fee_type"
    t.index ["parent_id", "name"], name: "index_categories_on_parent_id_and_name", unique: true
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["position"], name: "index_categories_on_position"
  end

  create_table "compare_items", force: :cascade do |t|
    t.bigint "compare_list_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["compare_list_id", "product_id"], name: "index_compare_items_on_compare_list_id_and_product_id", unique: true
    t.index ["compare_list_id"], name: "index_compare_items_on_compare_list_id"
    t.index ["product_id"], name: "index_compare_items_on_product_id"
  end

  create_table "compare_lists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_compare_lists_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "sender_id"
    t.bigint "recipient_id"
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_conversations_on_order_id"
    t.index ["recipient_id"], name: "index_conversations_on_recipient_id"
    t.index ["sender_id", "recipient_id"], name: "index_conversations_on_sender_id_and_recipient_id", unique: true
    t.index ["sender_id"], name: "index_conversations_on_sender_id"
  end

  create_table "dispute_activities", force: :cascade do |t|
    t.string "action", null: false
    t.json "data", null: false
    t.bigint "dispute_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_dispute_activities_on_action"
    t.index ["dispute_id", "created_at"], name: "index_dispute_activities_on_dispute_id_and_created_at"
    t.index ["dispute_id"], name: "index_dispute_activities_on_dispute_id"
    t.index ["user_id"], name: "index_dispute_activities_on_user_id"
  end

  create_table "dispute_comments", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.bigint "dispute_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispute_id"], name: "index_dispute_comments_on_dispute_id"
    t.index ["user_id"], name: "index_dispute_comments_on_user_id"
  end

  create_table "dispute_evidences", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.bigint "dispute_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispute_id", "created_at"], name: "index_dispute_evidences_on_dispute_id_and_created_at"
    t.index ["dispute_id"], name: "index_dispute_evidences_on_dispute_id"
    t.index ["user_id"], name: "index_dispute_evidences_on_user_id"
  end

  create_table "dispute_resolutions", force: :cascade do |t|
    t.integer "resolution_type", null: false
    t.text "notes", null: false
    t.decimal "refund_amount", precision: 10, scale: 2
    t.bigint "dispute_id", null: false
    t.datetime "implemented_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispute_id"], name: "index_dispute_resolutions_on_dispute_id"
    t.index ["resolution_type"], name: "index_dispute_resolutions_on_resolution_type"
  end

  create_table "disputes", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "status"
    t.bigint "moderator_id"
    t.text "resolution_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "order_id", null: false
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "escrow_transaction_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "dispute_type", null: false
    t.datetime "moderator_assigned_at"
    t.datetime "resolved_at"
    t.index ["buyer_id", "created_at"], name: "index_disputes_on_buyer_id_and_created_at"
    t.index ["buyer_id"], name: "index_disputes_on_buyer_id"
    t.index ["dispute_type"], name: "index_disputes_on_dispute_type"
    t.index ["escrow_transaction_id"], name: "index_disputes_on_escrow_transaction_id"
    t.index ["moderator_id"], name: "index_disputes_on_moderator_id"
    t.index ["order_id"], name: "index_disputes_on_order_id"
    t.index ["resolved_at"], name: "index_disputes_on_resolved_at"
    t.index ["seller_id", "created_at"], name: "index_disputes_on_seller_id_and_created_at"
    t.index ["seller_id"], name: "index_disputes_on_seller_id"
    t.index ["status"], name: "index_disputes_on_status"
  end

  create_table "escrow_holds", force: :cascade do |t|
    t.bigint "payment_account_id", null: false
    t.bigint "order_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "reason", null: false
    t.string "status", default: "active", null: false
    t.datetime "released_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_escrow_holds_on_expires_at"
    t.index ["order_id"], name: "index_escrow_holds_on_order_id"
    t.index ["payment_account_id"], name: "index_escrow_holds_on_payment_account_id"
    t.index ["released_at"], name: "index_escrow_holds_on_released_at"
    t.index ["status"], name: "index_escrow_holds_on_status"
  end

  create_table "escrow_transactions", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "payment_transaction_id", null: false
    t.bigint "buyer_account_id", null: false
    t.bigint "seller_account_id", null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.integer "fee_cents", default: 0, null: false
    t.string "fee_currency", default: "USD", null: false
    t.datetime "release_at"
    t.string "status"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_account_id"], name: "index_escrow_transactions_on_buyer_account_id"
    t.index ["order_id"], name: "index_escrow_transactions_on_order_id"
    t.index ["payment_transaction_id"], name: "index_escrow_transactions_on_payment_transaction_id"
    t.index ["release_at"], name: "index_escrow_transactions_on_release_at"
    t.index ["seller_account_id"], name: "index_escrow_transactions_on_seller_account_id"
    t.index ["status"], name: "index_escrow_transactions_on_status"
  end

  create_table "helpful_votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "review_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["review_id"], name: "index_helpful_votes_on_review_id"
    t.index ["user_id", "review_id"], name: "index_helpful_votes_on_user_id_and_review_id", unique: true
    t.index ["user_id"], name: "index_helpful_votes_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.integer "condition", null: false
    t.integer "view_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["condition"], name: "index_items_on_condition"
    t.index ["name"], name: "index_items_on_name"
    t.index ["price"], name: "index_items_on_price"
    t.index ["status"], name: "index_items_on_status"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "cart_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_line_items_on_cart_id"
    t.index ["product_id"], name: "index_line_items_on_product_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "user_id", null: false
    t.text "body"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "actor_type", null: false
    t.bigint "actor_id", null: false
    t.string "action"
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_notifications_on_actor"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "option_types", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "product_id", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "name"], name: "index_option_types_on_product_id_and_name", unique: true
    t.index ["product_id"], name: "index_option_types_on_product_id"
  end

  create_table "option_values", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "option_type_id", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["option_type_id", "name"], name: "index_option_values_on_option_type_id_and_name", unique: true
    t.index ["option_type_id"], name: "index_option_values_on_option_type_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "item_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_order_items_on_item_id"
    t.index ["order_id", "item_id"], name: "index_order_items_on_order_id_and_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.string "tracking_number"
    t.text "shipping_address", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "delivery_confirmed_at"
    t.datetime "finalized_at"
    t.datetime "auto_finalize_at"
    t.bigint "seller_id", null: false
    t.index ["auto_finalize_at"], name: "index_orders_on_auto_finalize_at"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["delivery_confirmed_at"], name: "index_orders_on_delivery_confirmed_at"
    t.index ["finalized_at"], name: "index_orders_on_finalized_at"
    t.index ["seller_id"], name: "index_orders_on_seller_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["tracking_number"], name: "index_orders_on_tracking_number"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "held_balance", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "available_balance", precision: 10, scale: 2, default: "0.0", null: false
    t.string "status", default: "pending", null: false
    t.string "type", null: false
    t.jsonb "payment_methods", default: {}
    t.datetime "last_payout_at"
    t.string "currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "square_account_id"
    t.string "business_email"
    t.string "merchant_name"
    t.index ["square_account_id"], name: "index_payment_accounts_on_square_account_id", unique: true
    t.index ["status"], name: "index_payment_accounts_on_status"
    t.index ["type"], name: "index_payment_accounts_on_type"
    t.index ["user_id"], name: "index_payment_accounts_on_user_id"
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.bigint "source_account_id", null: false
    t.bigint "target_account_id"
    t.bigint "order_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "transaction_type", null: false
    t.string "status", default: "pending", null: false
    t.text "description"
    t.jsonb "metadata", default: {}
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "square_payment_id"
    t.string "square_refund_id"
    t.string "square_transfer_id"
    t.index ["order_id"], name: "index_payment_transactions_on_order_id"
    t.index ["processed_at"], name: "index_payment_transactions_on_processed_at"
    t.index ["source_account_id"], name: "index_payment_transactions_on_source_account_id"
    t.index ["square_payment_id"], name: "index_payment_transactions_on_square_payment_id", unique: true
    t.index ["square_refund_id"], name: "index_payment_transactions_on_square_refund_id", unique: true
    t.index ["square_transfer_id"], name: "index_payment_transactions_on_square_transfer_id", unique: true
    t.index ["status"], name: "index_payment_transactions_on_status"
    t.index ["target_account_id"], name: "index_payment_transactions_on_target_account_id"
    t.index ["transaction_type"], name: "index_payment_transactions_on_transaction_type"
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id"], name: "index_product_categories_on_product_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "position", null: false
    t.boolean "is_primary", default: false
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "is_primary"], name: "index_product_images_on_product_id_and_is_primary"
    t.index ["product_id", "position"], name: "index_product_images_on_product_id_and_position"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_tags", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "tag_id"], name: "index_product_tags_on_product_id_and_tag_id", unique: true
    t.index ["product_id"], name: "index_product_tags_on_product_id"
    t.index ["tag_id"], name: "index_product_tags_on_tag_id"
  end

  create_table "product_views", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.integer "view_count", default: 1
    t.datetime "last_viewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_viewed_at"], name: "index_product_views_on_last_viewed_at"
    t.index ["product_id"], name: "index_product_views_on_product_id"
    t.index ["user_id", "product_id"], name: "index_product_views_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_product_views_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "review_invitations", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "completed_at"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_review_invitations_on_buyer_id"
    t.index ["expires_at"], name: "index_review_invitations_on_expires_at"
    t.index ["order_id"], name: "index_review_invitations_on_order_id"
    t.index ["seller_id"], name: "index_review_invitations_on_seller_id"
    t.index ["token"], name: "index_review_invitations_on_token", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "rating"
    t.text "content"
    t.bigint "reviewer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reviewable_type", null: false
    t.bigint "reviewable_id", null: false
    t.integer "helpful_count", default: 0, null: false
    t.bigint "review_invitation_id"
    t.bigint "order_id"
    t.text "pros"
    t.text "cons"
    t.index ["order_id"], name: "index_reviews_on_order_id"
    t.index ["review_invitation_id"], name: "index_reviews_on_review_invitation_id"
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable"
    t.index ["reviewer_id", "reviewable_type", "reviewable_id"], name: "idx_reviews_on_reviewer_and_reviewable", unique: true
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "saved_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.bigint "variant_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_saved_items_on_product_id"
    t.index ["user_id", "product_id", "variant_id"], name: "index_saved_items_on_user_id_and_product_id_and_variant_id", unique: true
    t.index ["user_id"], name: "index_saved_items_on_user_id"
    t.index ["variant_id"], name: "index_saved_items_on_variant_id"
  end

  create_table "seller_applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status"
    t.text "note"
    t.text "rejection_reason"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewed_by_id"], name: "index_seller_applications_on_reviewed_by_id"
    t.index ["user_id"], name: "index_seller_applications_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug"
    t.integer "products_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "user_reputation_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "points"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_reputation_events_on_user_id"
  end

  create_table "user_warnings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "moderator_id", null: false
    t.text "reason"
    t.integer "level"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["moderator_id"], name: "index_user_warnings_on_moderator_id"
    t.index ["user_id"], name: "index_user_warnings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.string "user_type", default: "seeker"
    t.string "seller_status"
    t.datetime "seller_approved_at"
    t.datetime "seller_bond_paid_at"
    t.decimal "seller_bond_amount", precision: 10, scale: 2
    t.datetime "seller_application_date"
    t.text "seller_application_note"
    t.text "seller_rejection_reason"
    t.datetime "seller_bond_refunded_at"
    t.integer "level", default: 1, null: false
    t.integer "points", default: 0, null: false
    t.string "seller_tier", default: "standard"
    t.bigint "total_sales_cents", default: 0
    t.bigint "monthly_sales_cents", default: 0
    t.datetime "last_sales_update"
    t.string "bond_status", default: "none"
    t.index ["bond_status"], name: "index_users_on_bond_status"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["monthly_sales_cents"], name: "index_users_on_monthly_sales_cents"
    t.index ["seller_status"], name: "index_users_on_seller_status"
    t.index ["seller_tier"], name: "index_users_on_seller_tier"
    t.index ["user_type"], name: "index_users_on_user_type"
  end

  create_table "variant_option_values", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.bigint "option_value_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["option_value_id"], name: "index_variant_option_values_on_option_value_id"
    t.index ["variant_id", "option_value_id"], name: "index_variant_option_values_on_variant_id_and_option_value_id", unique: true
    t.index ["variant_id"], name: "index_variant_option_values_on_variant_id"
  end

  create_table "variants", force: :cascade do |t|
    t.string "sku", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "stock_quantity", default: 0, null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_variants_on_product_id"
    t.index ["sku"], name: "index_variants_on_sku", unique: true
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.bigint "wishlist_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_wishlist_items_on_product_id"
    t.index ["wishlist_id", "product_id"], name: "index_wishlist_items_on_wishlist_id_and_product_id", unique: true
    t.index ["wishlist_id"], name: "index_wishlist_items_on_wishlist_id"
  end

  create_table "wishlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "wishlist_items_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wishlists_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_activity_logs", "users", column: "admin_id"
  add_foreign_key "admin_transactions", "users", column: "admin_id"
  add_foreign_key "bond_transactions", "bonds"
  add_foreign_key "bond_transactions", "payment_transactions"
  add_foreign_key "bonds", "users"
  add_foreign_key "cart_items", "items"
  add_foreign_key "cart_items", "users"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "compare_items", "compare_lists"
  add_foreign_key "compare_items", "products"
  add_foreign_key "compare_lists", "users"
  add_foreign_key "conversations", "orders"
  add_foreign_key "conversations", "users", column: "recipient_id"
  add_foreign_key "conversations", "users", column: "sender_id"
  add_foreign_key "dispute_activities", "disputes"
  add_foreign_key "dispute_activities", "users"
  add_foreign_key "dispute_comments", "disputes"
  add_foreign_key "dispute_comments", "users"
  add_foreign_key "dispute_evidences", "disputes"
  add_foreign_key "dispute_evidences", "users"
  add_foreign_key "dispute_resolutions", "disputes"
  add_foreign_key "disputes", "escrow_transactions"
  add_foreign_key "disputes", "orders"
  add_foreign_key "disputes", "users", column: "buyer_id"
  add_foreign_key "disputes", "users", column: "moderator_id"
  add_foreign_key "disputes", "users", column: "seller_id"
  add_foreign_key "escrow_holds", "orders"
  add_foreign_key "escrow_holds", "payment_accounts"
  add_foreign_key "escrow_transactions", "orders"
  add_foreign_key "escrow_transactions", "payment_accounts", column: "buyer_account_id"
  add_foreign_key "escrow_transactions", "payment_accounts", column: "seller_account_id"
  add_foreign_key "escrow_transactions", "payment_transactions"
  add_foreign_key "helpful_votes", "reviews"
  add_foreign_key "helpful_votes", "users"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "users"
  add_foreign_key "line_items", "carts"
  add_foreign_key "line_items", "products"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "option_types", "products"
  add_foreign_key "option_values", "option_types"
  add_foreign_key "order_items", "items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "seller_id"
  add_foreign_key "payment_accounts", "users"
  add_foreign_key "payment_transactions", "orders"
  add_foreign_key "payment_transactions", "payment_accounts", column: "source_account_id"
  add_foreign_key "payment_transactions", "payment_accounts", column: "target_account_id"
  add_foreign_key "product_categories", "categories"
  add_foreign_key "product_categories", "products"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_tags", "products"
  add_foreign_key "product_tags", "tags"
  add_foreign_key "product_views", "products"
  add_foreign_key "product_views", "users"
  add_foreign_key "products", "users"
  add_foreign_key "review_invitations", "orders"
  add_foreign_key "review_invitations", "users", column: "buyer_id"
  add_foreign_key "review_invitations", "users", column: "seller_id"
  add_foreign_key "reviews", "orders"
  add_foreign_key "reviews", "review_invitations"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "saved_items", "products"
  add_foreign_key "saved_items", "users"
  add_foreign_key "saved_items", "variants"
  add_foreign_key "seller_applications", "users"
  add_foreign_key "seller_applications", "users", column: "reviewed_by_id"
  add_foreign_key "user_reputation_events", "users"
  add_foreign_key "user_warnings", "users"
  add_foreign_key "user_warnings", "users", column: "moderator_id"
  add_foreign_key "variant_option_values", "option_values"
  add_foreign_key "variant_option_values", "variants"
  add_foreign_key "variants", "products"
  add_foreign_key "wishlist_items", "products"
  add_foreign_key "wishlist_items", "wishlists"
  add_foreign_key "wishlists", "users"
end

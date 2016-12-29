class InitialMigration < ActiveRecord::Migration[5.0]
  def change
    enable_extension "plpgsql"
    enable_extension "uuid-ossp"

    create_table :auth_events, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.inet    :ip_address
      t.boolean :success
      t.uuid    :user_id

      t.timestamps null: false

      t.index :user_id
    end

    create_table :fcm_tokens, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :token
      t.uuid   :user_id

      t.timestamps null: false
    end

    create_table :users, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string   :fname
      t.string   :lname
      t.string   :token
      t.string   :email, default: '', null: false
      t.string   :password_digest, default: '', null: false
      t.date     :dob
      t.string   :phone
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.string   :confirmation_token
      t.datetime :confirmation_sent_at
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at

      t.timestamps null: false

      t.index :email, unique: true
    end
  end
end

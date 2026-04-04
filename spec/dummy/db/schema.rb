# frozen_string_literal: true

ActiveRecord::Schema.define(version: 0) do
  create_table :users, force: true do |t|
    t.string :first_name, null: false
    t.string :last_name, null: false
  end

  create_table :posts, force: true do |t|
    t.string :title, null: false
    t.text :body, null: false
    t.references :user, foreign_key: true
    t.datetime :published_at
  end

  create_table :comments, force: true do |t|
    t.text :body, null: false
    t.references :user, foreign_key: true
  end

  create_table :products, force: true do |t|
    t.string :name, null: false
    t.string :description
    t.integer :price_subunit, null: false
    t.string :price_currency, null: false
  end
end

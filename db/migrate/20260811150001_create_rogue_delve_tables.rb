class CreateRogueDelveTables < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.string :player_name, null: false, default: "Adventurer"
      t.integer :depth, null: false, default: 1
      t.integer :hp, null: false, default: 30
      t.integer :max_hp, null: false, default: 30
      t.integer :attack, null: false, default: 5
      t.integer :defense, null: false, default: 0
      t.integer :kills, null: false, default: 0
      t.integer :score, null: false, default: 0
      t.integer :px, null: false, default: 1
      t.integer :py, null: false, default: 1
      t.string :inventory, null: false, default: ""
      t.string :status, null: false, default: "active"
      t.integer :goal_depth, null: false, default: 5
      t.timestamps
    end

    create_table :levels do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :depth, null: false
      t.text :grid, null: false
      t.timestamps
    end

    create_table :monsters do |t|
      t.references :level, null: false, foreign_key: true
      t.string :kind, null: false
      t.boolean :special, null: false, default: false
      t.integer :hp, null: false
      t.integer :attack, null: false
      t.integer :defense, null: false, default: 0
      t.integer :score_value, null: false, default: 10
      t.integer :heal_drop, null: false, default: 0
      t.integer :x, null: false
      t.integer :y, null: false
      t.timestamps
    end

    create_table :items do |t|
      t.references :level, null: false, foreign_key: true
      t.string :kind, null: false
      t.integer :x, null: false
      t.integer :y, null: false
      t.timestamps
    end

    create_table :score_entries do |t|
      t.string :player_name, null: false
      t.integer :kills, null: false, default: 0
      t.integer :score, null: false, default: 0
      t.integer :depth, null: false, default: 1
      t.string :result, null: false, default: "dead"
      t.timestamps
    end
  end
end

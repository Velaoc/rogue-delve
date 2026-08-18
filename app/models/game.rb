class Game < ApplicationRecord
  has_many :levels, dependent: :destroy
  has_many :monsters, through: :levels
  has_many :items, through: :levels
  has_one :level, -> { order(depth: :desc) }, class_name: "Level", inverse_of: :game

  STATUSES = %w[active won dead].freeze

  validates :player_name, presence: true
  validates :status, inclusion: { in: STATUSES }

  after_create :generate_level

  def current_level
    level || levels.create!(depth: depth, grid: DungeonGenerator.generate)
  end

  def generate_level
    lvl = levels.create!(depth: depth, grid: DungeonGenerator.generate.to_json)
    sx, sy = DungeonGenerator.spawn_point(lvl.grid_rows)
    self.px = sx
    self.py = sy
    save!
    lvl.place_entities(self)
  end

  # Human-readable tile grid for rendering; monsters/items/player overlaid.
  def view_grid
    lvl = current_level
    g = lvl.grid_rows
    lvl.monsters.each { |m| g[m.y][m.x] = m.special ? "M" : "m" }
    lvl.items.each { |i| g[i.y][i.x] = item_glyph(i.kind) }
    g[py][px] = "@"
    g
  end

  def item_glyph(kind)
    { "potion" => "!", "tome" => "+", "shield" => "=", "key" => "K" }[kind] || "?"
  end

  def move(dx, dy)
    return unless status == "active"

    lvl = current_level
    nx = px + dx
    ny = py + dy
    return if lvl.wall?(nx, ny)

    descended = false
    monster = lvl.monsters.find_by(x: nx, y: ny)
    if monster
      attack_monster(monster)
    else
      self.px = nx
      self.py = ny
      pickup_item
      descended = descend_if_stairs
    end
    monsters_turn unless status != "active" || descended
    save!
  end

  def attack_monster(monster)
    dmg = [attack - monster.defense, 1].max
    monster.hp -= dmg
    if monster.hp <= 0
      self.kills += 1
      self.score += monster.score_value
      monster.destroy!
      self.hp = [hp + monster.heal_drop, max_hp].min if monster.heal_drop.positive?
      check_goal if monster.boss?
    else
      monster.save!
    end
  end

  def monsters_turn
    lvl = current_level
    lvl.monsters.each do |m|
      next unless m.alive?

      m.take_turn(self, lvl)
      if status == "dead"
        save!
        return
      end
    end
  end

  def pickup_item
    lvl = current_level
    item = lvl.items.find_by(x: px, y: py)
    return unless item

    case item.kind
    when "potion"
      self.hp = [hp + 8, max_hp].min
    when "tome"
      self.attack += 2
    when "shield"
      self.defense += 1
    when "key"
      self.score += 5
    end
    self.inventory = inventory.split(",").tap { |a| a << item.kind }.reject(&:blank?).join(",")
    self.score += 3
    item.destroy!
  end

  def descend_if_stairs
    return false unless current_level.stairs?(px, py)

    if depth >= goal_depth
      win!
    else
      self.depth += 1
      generate_level
    end
    true
  end

  def take_damage(amount)
    dmg = [amount - defense, 1].max
    self.hp -= dmg
    if hp <= 0
      self.hp = 0
      die!
    end
  end

  def check_goal
    win! if depth >= goal_depth
  end

  def win!
    self.status = "won"
    self.score += 200 + (kills * 10)
    record_score
  end

  def die!
    self.status = "dead"
    record_score
  end

  def record_score
    ScoreEntry.create!(
      player_name: player_name,
      kills: kills,
      score: score,
      depth: depth,
      result: status
    )
  end
end

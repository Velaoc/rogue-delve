class Monster < ApplicationRecord
  belongs_to :level

  KINDS = %w[rat bat goblin skeleton] .freeze
  SPECIAL_KINDS = %w[orc_brute shadow_wraith] .freeze
  BOSS_KINDS = %w[dungeon_lord] .freeze

  def self.build_for(depth)
    r = Random.new
    special = depth >= 3 && r.rand < [0.15 + depth * 0.05, 0.45].min
    boss = depth >= 5 && r.rand < 0.5
    kind = if boss
             "dungeon_lord"
           elsif special
             SPECIAL_KINDS.sample(random: r)
           else
             KINDS.sample(random: r)
           end
    new(kind: kind, special: special || boss, hp: hp_for(kind, depth), attack: attack_for(kind, depth), defense: defense_for(kind), score_value: score_for(kind, depth), heal_drop: heal_for(kind))
  end

  def self.hp_for(kind, depth)
    base = { "rat" => 3, "bat" => 4, "goblin" => 6, "skeleton" => 7, "orc_brute" => 14, "shadow_wraith" => 12, "dungeon_lord" => 40 }[kind]
    base + depth * 2
  end

  def self.attack_for(kind, depth)
    base = { "rat" => 2, "bat" => 3, "goblin" => 4, "skeleton" => 5, "orc_brute" => 8, "shadow_wraith" => 9, "dungeon_lord" => 12 }[kind]
    base + depth
  end

  def self.defense_for(kind)
    { "rat" => 0, "bat" => 0, "goblin" => 0, "skeleton" => 1, "orc_brute" => 2, "shadow_wraith" => 1, "dungeon_lord" => 3 }[kind]
  end

  def self.score_for(kind, depth)
    base = { "rat" => 5, "bat" => 6, "goblin" => 8, "skeleton" => 10, "orc_brute" => 25, "shadow_wraith" => 30, "dungeon_lord" => 100 }[kind]
    base + depth * 2
  end

  def self.heal_for(kind)
    { "rat" => 1, "bat" => 1, "goblin" => 2, "skeleton" => 2, "orc_brute" => 4, "shadow_wraith" => 3, "dungeon_lord" => 10 }[kind]
  end

  def boss?
    kind == "dungeon_lord"
  end

  def alive?
    hp.positive?
  end

  def take_turn(game, level)
    return unless alive?

    dx = game.px <=> x
    dy = game.py <=> y
    # Prefer the axis with the larger distance.
    if dx.abs >= dy.abs
      move_or_attack(game, level, dx, 0)
      return
    end
    move_or_attack(game, level, 0, dy)
  end

  private

  def move_or_attack(game, level, dx, dy)
    nx = x + dx
    ny = y + dy
    return if level.wall?(nx, ny)
    return if level.monsters.where(x: nx, y: ny).where.not(id: id).exists?

    if nx == game.px && ny == game.py
      game.take_damage(attack)
      return
    end

    self.x = nx
    self.y = ny
    save!
  end
end

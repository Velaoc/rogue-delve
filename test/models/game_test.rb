require "test_helper"

class GameTest < ActiveSupport::TestCase
  def new_game(attrs = {})
    Game.create!({ player_name: "Testy", hp: 30, max_hp: 30, attack: 5, defense: 0 }.merge(attrs))
  end

  def stairs_of(game)
    lvl = game.current_level
    lvl.grid_rows.each_with_index.flat_map do |row, y|
      row.each_index.select { |x| row[x] == ">" }.map { |x| [x, y] }
    end.first
  end

  test "a new game generates a level with monsters, items, and stairs" do
    game = new_game

    assert_equal 1, game.depth
    assert_equal "active", game.status
    assert game.current_level.present?
    assert game.current_level.monsters.size.positive?
    assert game.current_level.items.size.positive?
    assert stairs_of(game).present?
  end

  test "moving onto a monster fights it and awards kills on death" do
    game = new_game
    lvl = game.current_level

    # Place the player on an open floor cell adjacent to a monster so the
    # move is deterministic: step straight onto it.
    monster = lvl.monsters.first
    lvl.grid_rows.each_with_index do |row, y|
      row.each_index do |x|
        next unless row[x] == "."
        next if lvl.monsters.exists?(x: x, y: y)

        if (x == monster.x && (y - monster.y).abs == 1) || (y == monster.y && (x - monster.x).abs == 1)
          game.update!(px: x, py: y)
        end
      end
    end

    hp_before = monster.hp
    kills_before = game.kills
    game.move(monster.x - game.px, monster.y - game.py)

    monster.reload
    if monster.alive?
      assert_operator monster.hp, :<, hp_before, "monster should be damaged"
    else
      assert_equal kills_before + 1, game.kills
    end
  end

  test "walking onto an item loots it" do
    game = new_game
    lvl = game.current_level
    item = lvl.items.first
    game.update!(px: item.x, py: item.y)
    game.pickup_item

    assert_includes game.inventory.split(","), item.kind
    assert_nil lvl.items.find_by(id: item.id)
  end

  test "standing on stairs descends to a deeper generated level" do
    game = new_game
    x, y = stairs_of(game)
    game.update!(px: x, py: y)

    game.move(0, 0)

    assert_equal 2, game.reload.depth
    assert_equal 2, game.current_level.depth
    assert_not_equal [game.px, game.py], [x, y], "player should respawn on the new level"
  end

  test "standing on stairs at the goal depth wins and records a score" do
    game = new_game(depth: 5, goal_depth: 5)
    x, y = stairs_of(game)
    game.update!(px: x, py: y)

    game.move(0, 0)

    assert_equal "won", game.reload.status
    assert ScoreEntry.exists?(player_name: "Testy", result: "won")
  end

  test "dying records a score entry" do
    game = new_game(hp: 1, defense: 0)
    game.take_damage(10)

    assert_equal "dead", game.status
    assert_equal 0, game.hp
    assert_equal 1, ScoreEntry.where(player_name: "Testy", result: "dead").count
  end
end

require "test_helper"

class GameTest < ActiveSupport::TestCase
  def new_game(attrs = {})
    Game.create!({ player_name: "Testy", hp: 30, max_hp: 30, attack: 5, defense: 0 }.merge(attrs))
  end

  test "a new game generates a level with monsters, items, and stairs" do
    game = new_game

    assert_equal 1, game.depth
    assert_equal "active", game.status
    assert game.current_level.present?
    assert game.current_level.monsters.size.positive?
    assert game.current_level.items.size.positive?
    assert game.current_level.grid_rows.flatten.include?(">")
  end

  test "moving onto a monster fights it and awards kills" do
    game = new_game
    lvl = game.current_level
    monster = lvl.monsters.first
    # Park the player next to a monster.
    game.update!(px: monster.x - 1, py: monster.y)

    kills_before = game.kills
    game.move(1, 0)

    game.reload
    if monster.reload.alive?
      assert_operator monster.hp, :<, monster.hp_before_move, "monster should be damaged"
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

  test "descending stairs generates a deeper level and repositions the player" do
    game = new_game
    lvl = game.current_level
    stairs = lvl.grid_rows.each_with_index.flat_map do |row, y|
      row.each_index.select { |x| row[x] == ">" }.map { |x| [x, y] }
    end.first
    game.update!(px: stairs[0], py: stairs[1])

    game.move(0, 0) # no-op move won't descend; step onto stairs by standing on them
    game.descend_if_stairs

    assert_equal 2, game.reload.depth
    assert_equal 2, game.current_level.depth
  end

  test "reaching the goal depth on the stairs wins and records a score" do
    game = new_game(depth: 5, goal_depth: 5)
    lvl = game.current_level
    stairs = lvl.grid_rows.each_with_index.flat_map do |row, y|
      row.each_index.select { |x| row[x] == ">" }.map { |x| [x, y] }
    end.first
    game.update!(px: stairs[0], py: stairs[1])

    game.descend_if_stairs

    assert_equal "won", game.reload.status
    assert game.score_entry_exists?
  end

  test "dying records a score entry" do
    game = new_game(hp: 1, defense: 0)
    game.take_damage(10)

    assert_equal "dead", game.status
    assert_equal 0, game.hp
    assert_equal 1, ScoreEntry.where(player_name: "Testy", result: "dead").count
  end

  def score_entry_exists?
    ScoreEntry.exists?(player_name: player_name, result: "won")
  end
end

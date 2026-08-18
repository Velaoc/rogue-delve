require "test_helper"

# RogueDelve is guest-first: no account required to play.
class GamesIntegrationTest < ActionDispatch::IntegrationTest
  test "start screen shows the name form and seeded leaderboard" do
    get root_path

    assert_response :success
    assert_select "h1", text: "RogueDelve"
    assert_select "form" do
      assert_select "input[name='game[player_name]']"
    end
  end

  test "starting a run creates a game and renders the board" do
    assert_difference -> { Game.count }, 1 do
      post games_path, params: { game: { player_name: "Vex" } }
    end

    game = Game.last
    assert_redirected_to game_path(game)
    follow_redirect!

    assert_response :success
    assert_select ".rd-board"
    assert_select ".rd-cell", minimum: 100
    assert_match(/Vex/, response.body)
  end

  test "a move request is accepted for an active game" do
    game = Game.create!(player_name: "Vex")

    post move_game_path(game), params: { dx: 1, dy: 0 }

    assert_redirected_to game_path(game)
    follow_redirect!
    assert_response :success
    assert_select ".rd-board"
  end

  test "a finished game renders the game over screen" do
    game = Game.create!(player_name: "Vex", hp: 1)
    game.take_damage(10)

    get game_path(game)

    assert_response :success
    assert_select "h1", text: "RogueDelve"
    assert_match(/run is over/, response.body)
  end

  test "leaderboard lists entries ranked by kills" do
    ScoreEntry.create!(player_name: "Top", kills: 99, score: 500, depth: 5, result: "won")
    ScoreEntry.create!(player_name: "Low", kills: 1, score: 10, depth: 1, result: "dead")

    get leaderboard_path

    assert_response :success
    assert_match(/Top/, response.body)
    assert_match(/Low/, response.body)
  end
end

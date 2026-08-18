require "test_helper"

# The public root is the RogueDelve product itself: guests land on the
# start screen without any account, inside the foundation's public shell.
class HomePageTest < ActionDispatch::IntegrationTest
  test "root renders the RogueDelve start screen in the public shell" do
    get root_path

    assert_response :success
    assert_select "h1", text: "RogueDelve"
    assert_select "a.md-skip-link[href='#main-content']", text: "Skip to main content"
    assert_select "form input[name='game[player_name]']"
    assert_select "a[href='#{new_user_session_path}']", text: "Sign in"
    assert_select "footer a[href='#{legal_terms_path}']", minimum: 1
    assert_no_selector "nav.md-navigation"
  end
end

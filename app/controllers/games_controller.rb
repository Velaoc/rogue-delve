class GamesController < ApplicationController
  # Guests play without an account; no authentication required.
  def new
    @game = Game.new
    @top = ScoreEntry.order(kills: :desc, score: :desc).limit(5)
  end

  def create
    @game = Game.create!(game_params)
    redirect_to @game
  end

  def show
    @game = Game.find(params[:id])
    @board = @game.view_grid
    @top = ScoreEntry.order(kills: :desc, score: :desc).limit(5)
  end

  def move
    @game = Game.find(params[:id])
    @game.move(params[:dx].to_i, params[:dy].to_i) if @game.status == "active"
    redirect_to @game
  end

  def leaderboard
    @entries = ScoreEntry.order(kills: :desc, score: :desc).limit(25)
  end

  private

  def game_params
    params.require(:game).permit(:player_name)
  end
end

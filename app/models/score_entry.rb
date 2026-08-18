class ScoreEntry < ApplicationRecord
  validates :player_name, presence: true
  validates :kills, numericality: { greater_than_or_equal_to: 0 }
  validates :score, numericality: { greater_than_or_equal_to: 0 }
  validates :depth, numericality: { greater_than_or_equal_to: 1 }
  validates :result, inclusion: { in: %w[won dead] }

  scope :top, ->(limit = 10) { order(kills: :desc, score: :desc).limit(limit) }
end

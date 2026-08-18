class Item < ApplicationRecord
  belongs_to :level

  KINDS = %w[potion tome shield key] .freeze

  def self.random_kind
    KINDS.sample
  end
end

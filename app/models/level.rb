class Level < ApplicationRecord
  belongs_to :game
  has_many :monsters, dependent: :destroy
  has_many :items, dependent: :destroy

  def grid_rows
    @grid_rows ||= JSON.parse(grid)
  end

  def wall?(x, y)
    return true if x.negative? || y.negative? || x >= grid_rows.first.size || y >= grid_rows.size

    grid_rows[y][x] == "#"
  end

  def stairs?(x, y)
    grid_rows[y][x] == ">"
  end

  def floor_cells
    cells = []
    grid_rows.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        cells << [x, y] if cell == "."
      end
    end
    cells
  end

  # Populate monsters and items on floor tiles, avoiding the player spawn.
  def place_entities(game)
    cells = floor_cells
    cells -= [[game.px, game.py]]
    cells.shuffle!

    monster_count = [4 + game.depth, cells.size / 4].min
    monster_count.times do
      x, y = cells.pop
      break unless x

      m = Monster.build_for(game.depth)
      m.level = self
      m.x = x
      m.y = y
      m.save!
    end

    item_count = [2 + game.depth / 2, 6].min
    item_count.times do
      x, y = cells.pop
      break unless x

      Item.create!(level: self, kind: Item.random_kind, x: x, y: y)
    end
  end
end

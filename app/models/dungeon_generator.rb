class DungeonGenerator
  WIDTH = 24
  HEIGHT = 15

  class << self
    def generate(rng = Random.new)
      grid = Array.new(HEIGHT) { Array.new(WIDTH, "#") }
      rooms = []

      attempts = 0
      while rooms.size < 6 && attempts < 200
        attempts += 1
        w = rand(4..7)
        h = rand(3..5)
        x = rand(1..(WIDTH - w - 2))
        y = rand(1..(HEIGHT - h - 2))
        next if rooms.any? { |r| overlap?(r, [x, y, w, h]) }

        rooms << [x, y, w, h]
        (y..(y + h - 1)).each { |yy| (x..(x + w - 1)).each { |xx| grid[yy][xx] = "." } }
      end

      # Carve corridors connecting rooms center to center.
      rooms.each_cons(2) do |(x1, y1, w1, h1), (x2, y2, w2, h2)|
        cx1 = x1 + w1 / 2
        cy1 = y1 + h1 / 2
        cx2 = x2 + w2 / 2
        cy2 = y2 + h2 / 2
        carve(grid, cx1, cy1, cx2, cy2)
      end

      # Stairs in the last room (farthest from spawn).
      lx, ly, lw, lh = rooms.last
      grid[ly + lh / 2][lx + lw / 2] = ">"

      grid
    end

    def spawn_point(grid)
      grid.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          return [x, y] if cell == "."
        end
      end
      [1, 1]
    end

    private

    def overlap?(a, b)
      ax, ay, aw, ah = a
      bx, by, bw, bh = b
      ax < bx + bw && bx < ax + aw && ay < by + bh && by < ay + ah
    end

    def carve(grid, x1, y1, x2, y2)
      x = x1
      y = y1
      until x == x2
        grid[y][x] = "."
        x += x2 > x ? 1 : -1
      end
      until y == y2
        grid[y][x] = "."
        y += y2 > y ? 1 : -1
      end
      grid[y][x] = "."
    end
  end
end

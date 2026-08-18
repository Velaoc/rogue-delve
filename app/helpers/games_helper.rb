module GamesHelper
  # Map a board glyph to a CSS class for the dungeon grid.
  def cell_class(cell)
    case cell
    when "#" then "rd-wall"
    when ">" then "rd-stairs"
    when "@" then "rd-player"
    when "m" then "rd-monster"
    when "M" then "rd-boss"
    when "!", "+", "=", "K" then "rd-item"
    else "rd-floor"
    end
  end

  def cell_label(cell, x, y)
    return "Wall" if cell == "#"
    return "Stairs down" if cell == ">"
    return "You" if cell == "@"
    return "Elite or boss monster" if cell == "M"
    return "Monster" if cell == "m"
    return "Item" if cell == "!" || cell == "+" || cell == "=" || cell == "K"
    return "Empty floor at #{x},#{y}" if cell == "."

    "Empty floor"
  end
end

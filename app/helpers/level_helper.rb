module LevelHelper
  def level_name(level)
    case level
    when 1 then "Garnet"
    when 2 then "Topaz"
    when 3 then "Emerald"
    when 4 then "Sapphire"
    when 5 then "Ruby"
    when 6 then "Diamond"
    else "Unknown"
    end
  end

  def level_color(level)
    case level
    when 1 then "#933" # Garnet - dark red
    when 2 then "#FB3" # Topaz - amber
    when 3 then "#3B7" # Emerald - green
    when 4 then "#27D" # Sapphire - blue
    when 5 then "#E33" # Ruby - bright red
    when 6 then "#DEF" # Diamond - light blue-white
    else "#999" # Unknown - gray
    end
  end

  def level_badge(user)
    return "" unless user
    
    level_text = user.admin? ? "Diamond Admin" : level_name(user.level)
    level = user.admin? ? 6 : user.level
    color = level_color(level)
    
    content_tag :div, class: "user-level-badge", style: "display: inline-block;" do
      content_tag :span, class: "badge", 
        style: "background-color: #{color}; color: white; padding: 0.2em 0.6em; border-radius: 10px; font-size: 0.8em;" do
        content_tag(:i, "", class: "bi bi-gem", style: "margin-right: 4px;") + level_text
      end
    end
  end
end
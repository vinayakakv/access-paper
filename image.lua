-- adopted from https://github.com/pandoc/lua-filters/blob/master/short-captions/short-captions.lua
if FORMAT ~= "latex" then
  return
end

local function latex(str)
  return pandoc.RawInline('latex', str)
end


function figure_image (elem)
  local image = elem.content and elem.content[1]
  return (image.t == 'Image' and image.title == 'fig:')
    and image
    or nil
end

function Para (para)
  local img = figure_image(para)
  if not img or not img.caption then
    return nil
  end
  local full_width = img.attributes["fullwidth"] == "1" and "*" or ""
  local width = img.attributes['width'] or "1"
  
  local environment_start = "\\begin{figure"..full_width.."}\n\\centering\n"
  local environment_end = "\n\\end{figure"..full_width.."}\n"
    
  local label = "\n"
  if img.identifier ~= img.title then
    label = string.format("\n\\label{%s}",img.identifier)
  end
  return pandoc.Para {
    latex(environment_start),
    latex("\\includegraphics[width="..width.."\\linewidth]{"..img.src.."}"),
    latex("\n\\caption"), pandoc.Span(img.caption),
    latex(label ..environment_end)
  }
end

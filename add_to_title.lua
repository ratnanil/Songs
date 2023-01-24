-- <--
-- Collect metadata with the key "song_meta"  
-- from the YAML header and store in table
-- with the name "my_key_values"
local my_key_values = {}

function Meta(meta)
  if not (meta.song_meta == nil) then
    for key, value in pairs(meta.song_meta) do
      my_key_values[key] = value
    end
  end
end
-- --> 

-- <--
-- Create a function to sort the metadata keys
local function by_sorted_keys(t)
  local keys = {}
  for k in pairs(t) do table.insert(keys, k) end
  table.sort(keys)
  local i = 0                -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if keys[i] == nil then return nil
    else return keys[i], t[keys[i]]
    end
  end
  return iter
end
-- -->

-- <--
-- Add the metadata to the first paragraph
-- the var "first" is used to make sure that the metadata is only added once
local first = true
function Para(element)
  -- <--
  -- count the number of lines in my_key_values
  -- so that we only insert the metadata if there 
  -- is something to insert
  local lengthNum = 0
  for k, v in pairs(my_key_values) do 
    lengthNum = lengthNum + 1
  end
  -- -->
  
  if first and lengthNum > 0 then
    first = false
    local plain = pandoc.Para({})
    
    for key, value in by_sorted_keys(my_key_values) do
      plain.content:insert(pandoc.Strong(pandoc.Str(key .. ": ")))
      plain.content:extend(value)
      plain.content:insert(pandoc.SoftBreak())
    end
    local placeholder = pandoc.Note(plain)
    element.content:insert(placeholder)
    return element
  else
    return nil
  end
end
-- -->

return {
  {Meta = Meta},
  {Para = Para}
}
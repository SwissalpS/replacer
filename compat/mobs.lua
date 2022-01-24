if not minetest.get_modpath('mobs') then return end

local rgp = replacer.group_placeholder
if not rgp['group:food_cheese'] then rgp['group:food_cheese'] = 'mobs:cheese' end
if not rgp['group:food_meat'] then rgp['group:food_meat'] = 'mobs:meat' end


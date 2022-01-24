if not minetest.get_modpath('farming') then return end

local rgp = replacer.group_placeholder
rgp['group:food_cheese'] = 'farming:cheese_vegan'
rgp['group:food_meat'] = 'farming:tofu_cooked'
rgp['group:food_saucepan'] = 'farming:saucepan'
rgp['group:food_coffee'] = 'farming:coffee_beans'
rgp['group:food_pot'] = 'farming:pot'
rgp['group:food_corn'] = 'farming:corn'
rgp['group:food_sunflower_seeds'] = 'farming:seed_sunflower'
rgp['group:food_vanilla'] = 'farming:vanilla'
rgp['group:food_peppercorn'] = 'farming:peppercorn'
rgp['group:food_soy'] = 'farming:soy_beans'
rgp['group:food_salt'] = 'farming:salt'
rgp['group:food_juicer'] = 'farming:juicer'
rgp['group:food_potato'] = 'farming:potato'


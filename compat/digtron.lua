if not minetest.get_modpath('digtron') then return end

-- prevent accidental replacement of digtron crates
-- also placing isn't a good idea either
replacer.deny_list['digtron:loaded_crate'] = true
replacer.deny_list['digtron:loaded_locked_crate'] = true


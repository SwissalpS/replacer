-- for some reason cobwebs need this [mobs_monster]
-- probably because they drop string when dug and string
-- is only a craft item.
if minetest.get_modpath('mobs_monster') then
	replacer.register_exception('mobs:cobweb', 'mobs:cobweb')
end


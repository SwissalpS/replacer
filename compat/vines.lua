if not minetest.get_modpath('vines') then return end

-- for inspection tool
replacer.group_placeholder['group:vines'] = 'vines:vines'

-- for replacer, so player can set to any part of vine and then replacer
-- uses the '_end' part to place
local vines = { 'jungle', 'root', 'side', 'vine', 'willow' }
local name_base, name_end, name_middle
for _, name in ipairs(vines) do
	name_base = 'vines:' .. name
	name_end = name_base .. '_end'
	name_middle = name_base .. '_middle'
	replacer.register_exception(name_end, name_end)
	replacer.register_non_creative_alias(name_middle, name_end)
end


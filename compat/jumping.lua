if not minetest.get_modpath('jumping') then return end

local sBaseName = 'jumping:trampoline'
local sDropName = sBaseName .. '1'
for i = 2, 6 do
	replacer.register_exception(sBaseName .. tostring(i), sDropName)
end


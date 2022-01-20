if not minetest.get_modpath('prefab') then return end

local name = 'prefab:concrete_with_grass'
replacer.register_exception(name, name)
-- not adding the inverted slabs as they can't be rotated
-- anyway, and there are the table-saw slabs too.


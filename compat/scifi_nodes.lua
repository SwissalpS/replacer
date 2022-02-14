if not minetest.get_modpath('scifi_nodes') then return end

local S = replacer.S

-- for replacer --

replacer.register_exception('scifi_nodes:laptop_open', 'scifi_nodes:laptop_closed')

-- for inspection tool --

-- These are not 100% accurate as other items could be dropped on the holders.
-- We can't be more accurate as long as scifi_nodes does't store the item's name.

local function add_recipe_itemholder(item_name, context, recipes)
    if 'scifi_nodes:itemholder' ~= item_name then return end

    if not (context and context.pos) then return end

	local objects = minetest.get_objects_inside_radius(context.pos, .5)
	if (not objects) or (0 == #objects) then return end

	local held_name, luaentity
	for _, obj in ipairs(objects) do
		if obj and obj.get_luaentity then
			luaentity = obj:get_luaentity()
			if luaentity and luaentity.itemstring
				and ('' ~= luaentity.itemstring)
				and minetest.registered_items[luaentity.itemstring]
			then
				held_name = luaentity.itemstring
				break
			end
		end
	end
	if not held_name then return end

	recipes[#recipes + 1] = {
		method = S('holding'),
		type = 'scifi_nodes:itemholder',
		items = { held_name },
		output = nil,
	}
end -- add_recipe_itemholder

replacer.register_craft_method(
	'scifi_nodes:itemholder', 'scifi_nodes:itemholder', add_recipe_itemholder)


local function add_recipe_powered_stand(item_name, context, recipes)
    if 'scifi_nodes:powered_stand' ~= item_name then return end

    if not (context and context.pos) then return end

	local objects = minetest.get_objects_inside_radius(
		vector.add(context.pos, vector.new(0, 1, 0)), .5)
	if (not objects) or (0 == #objects) then return end

	local held_name, luaentity
	for _, obj in ipairs(objects) do
		if obj and obj.get_luaentity then
			luaentity = obj:get_luaentity()
			if luaentity and luaentity.itemstring
				and ('' ~= luaentity.itemstring)
				and minetest.registered_items[luaentity.itemstring]
			then
				held_name = luaentity.itemstring
				break
			end
		end
	end
	if not held_name then return end

	recipes[#recipes + 1] = {
		method = S('holding'),
		type = 'scifi_nodes:powered_stand',
		items = { held_name },
		output = nil,
	}
end -- add_recipe_powered_stand

replacer.register_craft_method(
	'scifi_nodes:powered_stand', 'scifi_nodes:powered_stand', add_recipe_powered_stand)


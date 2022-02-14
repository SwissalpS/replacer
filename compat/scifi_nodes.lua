if not minetest.get_modpath('scifi_nodes') then return end

local S = replacer.S

-- for replacer --

replacer.register_exception('scifi_nodes:laptop_open', 'scifi_nodes:laptop_closed')

-- for inspection tool --

-- These are not 100% accurate as other items could be dropped on the holders.
-- We can't be more accurate as long as scifi_nodes does't store the item's name.
-- Like https://github.com/pandorabox-io/pandorabox_custom/blob/master/scifi_override.lua
-- does. When this override isn't installed, up to 9 objects are returned.

local function add_recipe_itemholder(item_name, context, recipes)
    if 'scifi_nodes:itemholder' ~= item_name then return end

    if not (context and context.pos) then return end

	local held_name = minetest.get_meta(context.pos):get_string('item')
	local items
	if '' ~= held_name then
		items = { held_name }
	else
		-- servers without override need to search for dropped items.
		items = {}
		local luaentity
		local objects = minetest.get_objects_inside_radius(context.pos, .5)
		if (not objects) or (0 == #objects) then return end

		for _, obj in ipairs(objects) do
			if obj and obj.get_luaentity then
				luaentity = obj:get_luaentity()
				if luaentity and luaentity.itemstring
					and ('' ~= luaentity.itemstring)
					and minetest.registered_items[ItemStack(luaentity.itemstring):get_name()]
				then
					table.insert(items, luaentity.itemstring)
				end
			end
			if 9 == #items then break end
		end
		if 0 == #items then return end
	end

	recipes[#recipes + 1] = {
		method = S('holding'),
		type = 'scifi_nodes:itemholder',
		items = items,
		output = nil,
	}
end -- add_recipe_itemholder

replacer.register_craft_method(
	'scifi_nodes:itemholder', 'scifi_nodes:itemholder', add_recipe_itemholder)


local function add_recipe_powered_stand(item_name, context, recipes)
    if 'scifi_nodes:powered_stand' ~= item_name then return end

    if not (context and context.pos) then return end

	local held_name = minetest.get_meta(context.pos):get_string('item')
	local items
	if '' ~= held_name then
		items = { held_name }
	else
		-- servers without override need to search for dropped items.
		items = {}
		local luaentity
		local objects = minetest.get_objects_inside_radius(
			vector.add(context.pos, vector.new(0, 1, 0)), .5)
		if (not objects) or (0 == #objects) then return end

		for _, obj in ipairs(objects) do
			if obj and obj.get_luaentity then
				luaentity = obj:get_luaentity()
				if luaentity and luaentity.itemstring
					and ('' ~= luaentity.itemstring)
					and minetest.registered_items[ItemStack(luaentity.itemstring):get_name()]
				then
					table.insert(items, luaentity.itemstring)
				end
			end
			if 9 == #items then break end
		end
		if 0 == #items then return end
	end

	recipes[#recipes + 1] = {
		method = S('holding'),
		type = 'scifi_nodes:powered_stand',
		items = items,
		output = nil,
	}
end -- add_recipe_powered_stand

replacer.register_craft_method(
	'scifi_nodes:powered_stand', 'scifi_nodes:powered_stand', add_recipe_powered_stand)


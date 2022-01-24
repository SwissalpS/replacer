local r = replacer
if not r.has_circular_saw then return end

local core_registered_nodes = minetest.registered_nodes
local shapes_list_sorted = nil
local confirmed_saw_items = {}

local function is_saw_output(node_name)
	if not node_name or 'moreblocks:circular_saw' == node_name then
		return nil
	end
	
	-- if we already confirmed this item, let's take the shortcut
	if confirmed_saw_items[node_name] then return confirmed_saw_items[node_name] end

	-- first time this function is called
	-- make a copy and sort so longest postfixes are used first
	if nil == shapes_list_sorted then
		shapes_list_sorted = table.copy(stairsplus.shapes_list)
		table.sort(shapes_list_sorted, function(a, b) return #a[2] > #b[2] end)
	end
	-- now iterate looking for match
	local mod_name, material, found
	for i, t in ipairs(shapes_list_sorted) do
		mod_name, material = string.match(node_name,
			'^([^:]+):' .. t[1] .. '(.*)' .. t[2] .. '$')
		if mod_name and material then
			-- double check
			if circular_saw.known_nodes[mod_name .. ':' .. material] then
				break
			elseif circular_saw.known_nodes['default:' .. material] then
				-- many are from default
				mod_name = 'default'
				break
			else
				-- need to try the long way
				found = false
				for itemstring, t in pairs(circular_saw.known_nodes) do
					if t[1] == mod_name and t[2] == material then
						mod_name = itemstring:match('^([^:]+)') or ''
						found = true
						break
					end
				end
				if found then break end
				-- make sure we don't accidently have a false-positive
				mod_name = nil
			end -- double check
		end -- match found
	end -- loop shapes_list_sorted
	if not (mod_name and material) then
		return nil
	end

	local basic_node_name = mod_name .. ':' .. material
	-- final check
	if not core_registered_nodes[basic_node_name] then
		return nil
	end

	-- cache to speed up next call
	confirmed_saw_items[node_name] = basic_node_name
	return basic_node_name
end -- is_saw_output


local function add_circular_saw_recipe(node_name, _, recipes)
	local basic_node_name = is_saw_output(node_name)
	if not basic_node_name then return end

	-- node found that fits into the saw
	recipes[#recipes + 1] = {
		method = 'saw',
		type = 'saw',
		items = { basic_node_name },
		output = node_name
	}
end -- add_circular_saw_recipe


-- for replacer
r.register_set_enabler(function(node)
	return node and is_saw_output(node.name)
end)


-- for inspection tool
r.register_craft_method('saw', 'moreblocks:circular_saw', add_circular_saw_recipe)


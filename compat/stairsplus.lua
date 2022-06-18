local r = replacer
if not r.has_stairsplus then return end

local function is_saw_output(node_name)

end -- is_saw_output

local S = replacer.S
local function add_circular_saw_recipe(node_name, _, recipes)
	local basic_node_name = stairsplus.api.get_node_of_shaped_node(node_name)
	if not basic_node_name then return end

	-- node found that fits into the saw
	recipes[#recipes + 1] = {
		method = S('sawing'),
		type = 'saw',
		items = { basic_node_name },
		output = node_name
	}
end -- add_circular_saw_recipe


-- for replacer
r.register_set_enabler(function(node)
	return node and stairsplus.api.get_node_of_shaped_node(node.name)
end)


-- for inspection tool
r.register_craft_method('saw', 'moreblocks:circular_saw', add_circular_saw_recipe)


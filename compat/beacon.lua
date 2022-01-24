if not minetest.get_modpath('beacon') then return end

local function is_beacon_beam_or_base(node_name)
	if 'string' ~= type(node_name) then return nil end
	if node_name:match('^beacon:(.*)beam$') then return true end
	if node_name:match('^beacon:(.*)base$') then return true end
	return false
end -- is_beacon_beam_or_base

replacer.register_set_enabler(function(node)
	return node and node.name and is_beacon_beam_or_base(node.name)
end)

-- for inspection tool
replacer.group_placeholder['group:beacon'] = 'beacon:white'


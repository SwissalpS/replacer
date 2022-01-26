if not minetest.get_modpath('advtrains') then return end

local function add_advtrains_aliases()
	local core_get_node_drops = minetest.get_node_drops
	local reg = replacer.register_non_creative_alias
		-- these cause crashes
	local deny_list = {
		['advtrains_interlocking:dtrack_npr_st'] = true,
		['advtrains_line_automation:dtrack_stop_st'] = true,
	}
	local drops, drop_name
	for name, _ in pairs(minetest.registered_nodes) do
		if not deny_list[name] and name:find('^advtrains') then
			drops = core_get_node_drops(name)
			drop_name = drops and drops[1] or ''
			if drop_name ~= name then
				reg(name, drop_name)
			end
		end
	end
end -- add_advtrains_aliases

minetest.after(.2, add_advtrains_aliases)


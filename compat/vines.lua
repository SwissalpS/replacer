if not minetest.get_modpath('vines') then return end

replacer.group_placeholder['group:vines'] = 'vines:vines'
local vines = { 'jungle', 'root', 'side', 'vine', 'willow' }
local node_name
for _, name in ipairs(vines) do
    node_name = 'vines:' .. name .. '_end'
	replacer.register_exception(node_name, node_name)
end


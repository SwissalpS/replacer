if not minetest.translate then
	function minetest.translate(textdomain, str, ...)
		local arg = { n = select('#', ...), ... }
		return str:gsub('@(.)', function(matched)
			local c = string.byte(matched)
			if string.byte('1') <= c and c <= string.byte('9') then
				return arg[c - string.byte('0')]
			else
				return matched
			end
		end)
	end

	function core.get_translator(textdomain)
		return function(str, ...) return core.translate(textdomain or '', str, ...) end
	end
end -- backward compatibility
replacer.S = minetest.get_translator('replacer')
local S = replacer.S

replacer.blabla = {}
replacer.blabla.inspect = {}
local rb = replacer.blabla
local rbi = replacer.blabla.inspect

rb.log_messages = '[replacer] %s: %s'
rb.choose_history = S('History')
rb.choose_mode = S('Choose mode')
rb.mode_minor1 = S('Both')
rb.mode_minor2 = S('Node')
rb.mode_minor3 = S('Rotation')
rb.mode_minor1_info = S('Replace node and apply orientation.')
rb.mode_minor2_info = S('Replace node without changing orientation.')
rb.mode_minor3_info = S('Apply orientation without changing node type.')
rb.mode_single = S('Single')
rb.mode_field = S('Field')
rb.mode_crust = S('Crust')
rb.mode_single_tooltip = S('Replace single node.')
rb.mode_field_tooltip = S('Left click: Replace field of nodes of a kind where a '
	.. 'translucent node is in front of it.@nRight click: Replace field of air '
	.. 'where no translucent node is behind the air.')
rb.mode_crust_tooltip = S('Left click: Replace nodes which touch another one of '
	.. 'its kind and a translucent node, e.g. air.@nRight click: Replace air nodes '
	.. 'which touch the crust.')
rb.wait_for_load = S('Target node not yet loaded. Please wait a moment for the '
	.. 'server to catch up.')
rb.nothing_to_replace = S('Nothing to replace.')
rb.need_more_charge = S('Not enough charge to use this mode.')
rb.too_many_nodes_detected = S('Aborted, too many nodes detected.')
rb.none_selected = S('Error: No node selected.')
rb.description_basic = S('Node replacement tool')
rb.description_technic = S('Node replacement tool (technic)')
rb.log_limit_override = '[replacer] Setting already set node-limit for "%s" was %d.'
rb.log_limit_insert = '[replacer] Setting node-limit for "%s" to %d.'
rb.log_deny_list_insert = '[replacer] Added "%s" to deny list.'
rb.timed_out = S('Time-limit reached.')
rb.tool_short_description = '(%s %s%s) %s'
rb.tool_long_description = '%s\n%s\n%s'
rb.ccm_params = '(chat|audio) (0|1)'
rb.ccm_description = S('Toggles verbosity.\nchat: When on, '
	.. 'messages are posted to chat.\naudio: When off, replacer is silent.')
rb.ccm_player_not_found = 'Player not found'
rb.ccm_player_meta_error = 'Player meta not existant'
rb.log_reg_exception_override = '[replacer] register_exception: '
	.. 'exception for "%s" already exists.'
rb.log_reg_exception = '[replacer] registered exception for "%s" to "%s"'
rb.log_reg_exception_callback = '[replacer] registered after on_place callback for "%s"'
rb.log_reg_alias_override = '[replacer] register_non_creative_alias: '
	.. ' alias for "%s" already exists.'
rb.log_reg_alias = '[replacer] registered alias for "%s" to "%s"'
rb.log_reg_set_callback_fail = '[replacer] register_set_enabler called without passing function.'
rb.formspec_error = '[replacer] formspec error, user "%s" attempting to change history. Fields: %s'
rb.formspec_hacker = '[replacer] formspec forge? By user "%s" Fields: %s'

----------------- replacer:inspect -----------------
rbi.description = S('Inspection Tool\nUse to inspect target node or entity.\n'
		.. 'Place to inspect the adjacent node.')
rbi.broken_object = S('This is a broken object. We have no further information about it. It is located')
rbi.owned_protected_locked = S('owned, protected and locked')
rbi.owned_protected = S('owned and protected')
rbi.owned_locked = S('owned and locked')
rbi.this_is_object = S('This is an object')
rbi.is_protected = S('WARNING: You can\'t dig this node. It is protected.')
rbi.you_can_dig = S('INFO: You can dig this node, others can\'t.')
rbi.no_desc = S('~ no description provided ~')
rbi.no_node_desc = S('~ no node description provided ~')
rbi.no_item_desc = S('~ no item description provided ~')
rbi.name = S('Name:')
rbi.exit = S('Exit')
rbi.this_is = S('This is:')
rbi.prev = S('prev')
rbi.next = S('next')
rbi.no_recipes = S('No recipes.')
rbi.drops_on_dig = S('Drops on dig:')
rbi.nothing = S('nothing')
rbi.may_drop_on_dig = S('May drop on dig:')
rbi.can_be_fuel = S('This can be used as a fuel.')
rbi.unkown_recipe = S('Error: Unkown recipe.')
rbi.log_reg_craft_method_wrong_arguments = '[replacer] register_craft_method invalid arguments given.'
rbi.log_reg_craft_method_overriding_method = '[replacer] register_craft_method overriding existing method '
rbi.log_reg_craft_method_added = '[replacer] register_craft_method method added: %s %s'


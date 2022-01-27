-- enable developer mode
replacer.dev_mode =
	minetest.settings:get_bool('replacer.dev_mode') or false
if not replacer.dev_mode then return end

local function pd(m) print(dump(m)) end

replacer.test = {}
local r = replacer
local rt = replacer.test
rt.spacing = 2
rt.player = nil
rt.facing = vector.new(0, 0, 0)
rt.active = false
rt.no_support = false
rt.move_player = false
rt.nodes_per_step = 444
rt.air_node = { name = 'air' }
rt.seconds_between_steps = 1.1
rt.support_node = { name = 'default:cobble' }
-- skip these patterns that return a match with string:find(pattern)
rt.skip = {
	-- these can be counter-productive and not replacer nodes
	'^air$', '^ignore$', 'corium', '^tnt:',
	'^technic:hv_nuclear_reactor_core_active$',
	'^default:lava_source$', '^default:lava_flowing$',
	'^default:.*water_source$', '^default:.*water_flowing$',
	--'^default:large_cactus_seedling$', -- depends on support_node
	'^digistuff:heatsink_onic$', -- depends on support_node
	--'^farming:seed_',  -- depends on support_node
	-- these are removed right away
	'^illumination:light_', '^morelights_extras:stairlight$',
	'^throwing:arrow', '^vacuum:vacuum$',
	-- sun matter is harmless, but not needed as not pointable
	'^planetoidgen:sun$',
	-- not pointable (can right-click with inspection tool to see them)
	'^digistuff:piston_pusher$', '^doors:hidden$', '^elevator:placeholder$',
	'^fancy_vend:display_node$',
	-- these cause crashes
	'^advtrains_interlocking:dtrack_npr_st',
	'^advtrains_line_automation:dtrack_stop_st',
	'^basic_signs:sign_',
	'^default:sign_'
}

function replacer.test.inform(message)
	if not rt.player or not rt.player.get_player_name then return end
	r.inform(rt.player:get_player_name(), message)
end -- inform
local rti = rt.inform

local function select_nodes(patterns)
	local function has_match(name, patterns_to_check)
		for _, pattern in ipairs(patterns_to_check) do
			if name:find(pattern) then return true end
		end
		return false
	end -- has_match
	rt.selected = {}
	rt.count = 0
	for name, _ in pairs(minetest.registered_nodes) do
		if not has_match(name, rt.skip)
			and has_match(name, patterns)
		then
			table.insert(rt.selected, name)
			rt.count = rt.count + 1
		end
	end
end -- select_nodes

-- This function is quite robust but it still can happen that game crashes.
-- It has worked best if area was already generated and loaded at least once.
-- Don't be too hasty to add nodes to deny-patterns.
-- It probably helps to turn off mesecons_debug and metrics in general for this
-- kind of excercise.
-- It's also advisable to have damage turned off or to wear a hazmat suit when
-- technic is involved and move_player flag is set.
function replacer.test.chatcommand_place_all(player_name, param)
	if rt.active then
		return false, 'There is an active task in progress, try again later'
	end
	param = param or ''
	local dry_run
	local params = param:split(' ')
	local patterns = {}
	rt.no_support = false
	rt.move_player = false
	for _, param2 in ipairs(params) do
		if 'dry-run' == param2 then
			dry_run = true
		elseif 'move_player' == param2 then
			rt.move_player = true
		elseif 'no_support_node' == param2 then
			rt.no_support = true
		else
			table.insert(patterns, param2)
		end
	end
	if 0 == #patterns then table.insert(patterns, '.*') end
	rt.player = minetest.get_player_by_name(player_name)
	rt.pos = rt.player:get_pos()--vector.add(rt.player:get_pos(), vector.new(1, 0, 1))--
	select_nodes(patterns)
	if 0 == rt.count then
		return true, 'Nothing to do.'
	end
	table.sort(rt.selected)
	rt.side, rt.x, rt.z = math.floor((rt.count ^ .5) + .5), 0, 0
	local full_side = rt.spacing * (rt.side + 1)
	local pos2 = vector.add(rt.pos, vector.new(full_side, 0, full_side))
	if dry_run then
		return true, 'Required space: ' .. r.nice_pos_string(rt.pos)
			.. ' to ' .. r.nice_pos_string(pos2)
	end

	minetest.emerge_area(rt.pos, vector.add(pos2, vector.new(0, -1, 0)))
	rt.i = 1
	rt.active = true
	rt.succ_count = 0
	minetest.after(.1, rt.step_place_all)
	return true, 'Started process'
end -- chatcommand_place_all


function replacer.test.step_place_all()
	-- player may have logged off already
	if not rt.active then return end

	local new_item, succ, pos_, pos__, node, name
	local function move_player()
		if not rt.move_player then return end

		rt.player:set_pos(vector.add(pos_, vector.new(-.25, 0, -1)))
		--rt.player:set_rotation(rt.facing)
		rt.player:set_look_horizontal(math.rad(0))
		rt.player:set_look_vertical(math.rad(45))
	end -- move_player

	for _ = 1, rt.nodes_per_step do
		name = rt.selected[rt.i]
		node = minetest.registered_nodes[name]
		pos_ = vector.add(rt.pos, vector.new(rt.x, 0, rt.z))
		pos__ = vector.add(pos_, vector.new(0, -1, 0))
		-- ensure area is generated and loaded
		if rt.check_mapgen(pos_) then
			rti('waiting for mapgen')
			minetest.after(5, rt.step_place_all)
			return
		end

		if minetest.find_node_near(pos_, 1, 'ignore', true) then
			rti('emerging area')
			move_player()
			minetest.emerge_area(pos_, pos__)
			minetest.after(2, rt.step_place_all)
			return
		end

		minetest.set_node(pos_, rt.air_node)
		if not rt.no_support then
			minetest.set_node(pos__, rt.support_node)
		end
		move_player()
		print(r.nice_pos_string(pos_) .. ' ' .. name)
		new_item, succ = node.on_place(ItemStack(node.name), rt.player, {
				type = 'node',
				under = vector.new(pos_),
				above = vector.add(pos_, vector.new(0, 1, 0))
		})
		if (false == succ) or (nil == new_item) then
			pd('Could not place ' .. node.name .. ' at ' .. r.nice_pos_string(pos_))
		else
			rt.succ_count = rt.succ_count + 1
		end
		rt.x = rt.x + rt.spacing if rt.spacing * rt.side < rt.x then
			rt.x = 0
			rt.z = rt.z + rt.spacing
		end
		rt.i = rt.i + 1
		if rt.count < rt.i then break end
	end
	-- keep player alive
	--rt.player:set_hp(55555, { type = 'set_hp', from = 'mod' })
	minetest.do_item_eat(55555, 'farming:bread 99', ItemStack('farming:bread 99'),
		rt.player, { type = 'nothing' })
	if rt.count <= rt.i then
		rti(tostring(rt.succ_count) .. ' of ' .. tostring(rt.count)
			.. ' nodes placed successfuly')
		rt.active = false
		return
	end

	rti('Step ' .. tostring(rt.i) .. ' of ' .. tostring(rt.count) .. ' done')

	minetest.after(rt.seconds_between_steps, rt.step_place_all)
end -- step_place_all


function replacer.test.chatcommand_test_all(player_name, param)
	if rt.active then
		return false, 'There is an active task in progress, try again later'
	end
	param = param or ''
	local dry_run
	local params = param:split(' ')
	local patterns = {}
	rt.no_support = false
	for _, param2 in ipairs(params) do
		if 'no_support_node' == param2 then
			rt.no_support = true
		else
			table.insert(patterns, param2)
		end
	end
	if 0 == #patterns then table.insert(patterns, '.*') end
	select_nodes(patterns)
	if 0 == rt.count then
		return true, 'Nothing to do.'
	end
	table.sort(rt.selected)
	rt.player = minetest.get_player_by_name(player_name)
	rt.pos = vector.add(rt.player:get_pos(), vector.new(1, 0, 0))
	rt.pos_ = vector.add(rt.pos, vector.new(0, -1, 0))
	minetest.set_node(rt.pos, rt.air_node)
	minetest.set_node(rt.pos_, rt.support_node)
	local inv = rt.player:get_inventory()
	inv:set_stack('main', 1, ItemStack('replacer:replacer'))
	inv:set_stack('main', 2, ItemStack(''))
	--inv:add_item('main', ItemStack('replacer:replacer'))
	rt.i = 1
	rt.active = true
	rt.succ_count = 0
	minetest.after(.1, rt.step_test_all)
	return true, 'Started process'
end -- chatcommand_test_all


function replacer.test.step_test_all()
	-- player may have logged off already
	if not rt.active then return end

	-- Problem I: can't change selected slot programatically
	-- Solution I: either use node_def.on_place/on_dig() directly
	--		or switch places with inv:set_stack(inv:get_stack())
	-- Problem II: can't simulate keys pressed
	-- Solution II: possibly better way to test is to use mineunit
	--		in the first place
end -- step_test_all


function replacer.test.dealloc_player(player)
	if not rt.player or not rt.player.get_player_name then return end
	if not rt.player:get_player_name() == player:get_player_name() then return end
	rt.active = false
	rt.player = nil
end -- dealloc_player


minetest.register_on_leaveplayer(rt.dealloc_player)
minetest.register_chatcommand('place_all', {
	params = '[dry-run][ move_player][ no_support_node][ [<include pattern1>] ... [ <include patternN>] ]',
	description = 'Places one of all registered nodes on a grid in +x,+z plane starting '
		.. 'at player position. You can use dry-run option to detect how much space you will need. '
		.. 'Pass patterns to only place nodes whose name matches. e.g. "^beacon:" "_tinted$" '
		.. '-> only place nodes beginning with "beacon:" i.e. beacon-mod, and all nodes ending '
		.. 'with "_tinted" i.e. paintbrush nodes. To exclude patterns, edit test.lua and add to '
		.. 'rt.skip table.',
	func = rt.chatcommand_place_all,
	privs = { privs = true }
})
minetest.register_chatcommand('replacer_test_all', {
	params = '[[<include pattern1>] ... [ <include patternN>] ]',
	description = 'Places one of all registered nodes on a support node at player position by player.'
		.. 'Attempts to set replacer to it and then digs the node. Attempts to have player place it '
		.. 'again using replacer. Checks if before and after match, then continues with next node. '
		.. 'before starting, you should ensure that the first two slots on the left are free.'
		.. 'Pass patterns to only place nodes whose name matches. e.g. "^beacon:" "_tinted$" '
		.. '-> only place nodes beginning with "beacon:" i.e. beacon-mod, and all nodes ending '
		.. 'with "_tinted" i.e. paintbrush nodes. To exclude patterns, edit test.lua and add to '
		.. 'rt.skip table.',
	func = rt.chatcommand_test_all,
	privs = { privs = true }
})


-- from jumpdrive code, mapgen tracking
local events = {} -- list of { minp, maxp, time }

-- update last mapgen event time
--luacheck: no unused args
minetest.register_on_generated(function(minp, maxp, seed)
	table.insert(events, {
		minp = minp,
		maxp = maxp,
		time = minetest.get_us_time()
	})
end)


-- true = mapgen recently active in that area
function replacer.test.check_mapgen(pos)
	for _, event in ipairs(events) do
		if 200 > vector.distance(pos, event.minp) then
			return true
		end
	end

	return false
end -- check_mapgen


-- cleanup
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if 5 > timer then return end

	timer = 0
	local time = minetest.get_us_time()
	local delay_seconds = 10

	local copied_events = events
	events = {}

	local count = 0
	for _, event in ipairs(copied_events) do
		if event.time > (time - (delay_seconds * 1000000)) then
			-- still recent
			table.insert(events, event)
			count = count + 1
		end
	end
end)


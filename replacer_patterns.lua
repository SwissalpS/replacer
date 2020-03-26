replacer.patterns = {}
local rp = replacer.patterns
local poshash = minetest.hash_node_position

-- cache results of minetest.get_node
replacer.patterns.known_nodes = {}
function replacer.patterns.get_node(pos)
	local i = poshash(pos)
	local node = rp.known_nodes[i]
	if nil ~= node then
		return node
	end
	node = minetest.get_node(pos)
	rp.known_nodes[i] = node
	return node
end

-- The cache is only valid as long as no node is changed in the world.
function replacer.patterns.reset_nodes_cache()
	replacer.patterns.known_nodes = {}
end

-- tests if there's a node at pos which should be replaced
function replacer.patterns.replaceable(pos, name, pname)
	return (rp.get_node(pos).name == name) and (not minetest.is_protected(pos, pname))
end

replacer.patterns.translucent_nodes = {}
function replacer.patterns.node_translucent(name)
	local is_translucent = rp.translucent_nodes[name]
	if nil ~= is_translucent then
		return is_translucent
	end
	local data = minetest.registered_nodes[name]
	if data and ((not data.drawtype) or ("normal" == data.drawtype)) then
		rp.translucent_nodes[name] = false
		return false
	end
	rp.translucent_nodes[name] = true
	return true
end

function replacer.patterns.field_position(pos, data)
	return rp.replaceable(pos, data.name, data.pname)
		and rp.node_translucent(
			rp.get_node(vector.add(data.above, pos)).name) ~= data.right_clicked
end

replacer.patterns.offsets_touch = {
	{ x =-1, y = 0, z = 0 },
	{ x = 1, y = 0, z = 0 },
	{ x = 0, y =-1, z = 0 },
	{ x = 0, y = 1, z = 0 },
	{ x = 0, y = 0, z =-1 },
	{ x = 0, y = 0, z = 1 },
}

-- 3x3x3 hollow cube
replacer.patterns.offsets_hollowcube = {}
local p
for x = -1, 1 do
	for y = -1, 1 do
		for z = -1, 1 do
			if (0 ~= x) or (0 ~= y) or (0 ~= z) then
				p = { x = x, y = y, z = z }
				rp.offsets_hollowcube[#rp.offsets_hollowcube + 1] = p
			end
		end
	end
end

-- To get the crust, first nodes near it need to be collected
function replacer.patterns.crust_above_position(pos, data)
	-- test if the node at pos is a translucent node and not part of the crust
	local nd = rp.get_node(pos).name
	if (nd == data.name) or (not rp.node_translucent(nd)) then
		return false
	end
	-- test if a node of the crust is near pos
	local p2
	for i = 1, 26 do
		p2 = rp.offsets_hollowcube[i]
		if rp.replaceable(vector.add(pos, p2), data.name, data.pname) then
			return true
		end
	end
	return false
end

-- used to get nodes the crust belongs to
function replacer.patterns.crust_under_position(pos, data)
	if not rp.replaceable(pos, data.name, data.pname) then
		return false
	end
	local p2
	for i = 1, 26 do
		p2 = rp.offsets_hollowcube[i]
		if data.aboves[poshash(vector.add(pos, p2))] then
			return true
		end
	end
	return false
end

-- extract the crust from the nodes the crust belongs to
function replacer.patterns.reduce_crust_ps(data)
	local newps = {}
	local n = 0
	local p, p2
	for i = 1, data.num do
		p = data.ps[i]
		for i = 1, 6 do
			p2 = rp.offsets_touch[i]
			if data.aboves[poshash(vector.add(p, p2))] then
				n = n + 1
				newps[n] = p
				break
			end
		end
	end
	data.ps = newps
	data.num = n
end

-- gets the air nodes touching the crust
function replacer.patterns.reduce_crust_above_ps(data)
	local newps = {}
	local n = 0
	local p, p2
	for i = 1, data.num do
		p = data.ps[i]
		if rp.replaceable(p, "air", data.pname) then
			for i = 1, 6 do
				p2 = rp.offsets_touch[i]
				if rp.replaceable(vector.add(p, p2), data.name, data.pname) then
					n = n + 1
					newps[n] = p
					break
				end
			end
		end
	end
	data.ps = newps
	data.num = n
end


-- Algorithm created by sofar and changed by others:
-- https://github.com/minetest/minetest/commit/d7908ee49480caaab63d05c8a53d93103579d7a9

local function search_dfs(go, p, apply_move, moves)
	local num_moves = #moves

	-- Uncomment if the starting position should be walked even if its
	-- neighbours cannot be walked
	--~ go(p)

	-- The stack contains the path to the current position;
	-- an element of it contains a position and direction (index to moves)
	local s = replacer.datastructures.create_stack()
	-- The neighbor order we will visit from our table.
	local v = 1

	while true do
		-- Push current state onto the stack.
		s:push({p = p, v = v})
		-- Go to the next position.
		p = apply_move(p, moves[v])
		-- Now we check out the node. If it is in need of an update,
		-- it will let us know in the return value (true = updated).
		local can_go, abort = go(p)
		if not can_go then
			if abort then
				return
			end
			-- If we don't need to "recurse" (walk) to it then pop
			-- our previous pos off the stack and continue from there,
			-- with the v value we were at when we last were at that
			-- node
			repeat
				local pop = s:pop()
				p = pop.p
				v = pop.v
				-- If there's nothing left on the stack, and no
				-- more sides to walk to, we're done and can exit
				if s:is_empty() and v == num_moves then
					return
				end
			until v < num_moves
			-- The next round walk the next neighbor in list.
			v = v + 1
		else
			-- If we did need to walk the neighbor/current position, then
			-- start walking from here from the walk order start (1),
			-- and not the order we just pushed up the stack.
			v = 1
		end
	end
end


function replacer.patterns.search_positions(params)
	local moves = params.moves
	local max_positions = params.max_positions
	local fdata = params.fdata
	local startpos = params.startpos
	-- visiteds has only positions where fdata.func evaluated to true
	local visiteds = {}
	local founds = {}
	local n_founds = 0
	local function go(p)
		local vi = poshash(p)
		if visiteds[vi] or not fdata.func(p, fdata) then
			return false
		end
		n_founds = n_founds+1
		founds[n_founds] = p
		visiteds[vi] = true
		if n_founds >= max_positions then
			-- Abort, too many positions
			return false, true
		end
		return true
	end
	search_dfs(go, startpos, vector.add, moves)
	if n_founds < max_positions or not params.radius_exceeded then
		return founds, n_founds, visiteds
	end

	-- Too many positions were found, so search again but only within
	-- a limited sphere around startpos
	local rr = params.radius_exceeded ^ 2
	local visiteds_old = visiteds
	visiteds = {}
	founds = {}
	n_founds = 0
	local function go(p)
		local vi = poshash(p)
		if visiteds[vi] then
			return false
		end
		local d = vector.subtract(p, startpos)
		if d.x * d.x + d.y * d.y + d.z * d.z > rr then
			-- Outside of the sphere
			return false
		end
		if not visiteds_old[vi] and not fdata.func(p, fdata) then
			return false
		end
		n_founds = n_founds+1
		founds[n_founds] = p
		visiteds[vi] = true
		return true
	end
	search_dfs(go, startpos, vector.add, moves)
	return founds, n_founds, visiteds
end

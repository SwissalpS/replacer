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

-- tests if there's a node at pos which should be replaced
function replacer.patterns.replaceable(pos, name, pname, param2)
	local node = rp.get_node(pos)
	if nil == param2 then
		-- crust mode ignores param2
		if 'air' ~= name then
			return (node.name == name) and (not minetest.is_protected(pos, pname))
		end
		-- right clicking in crust mode checks for air, but vacuum should work too
		-- TODO: add mechanism to register allowed types
		-- some servers might have other nodes like mars-lights that should be allowed too
		-- maybe dummy lights, on the other hand, it might be useful to be able to stop replacer with dummy lights
		return (('air' == node.name) or ('vacuum:vacuum' == node.name)) and (not minetest.is_protected(pos, pname))
	end
	-- in field mode we also check that param2 is the same as the initial node that was clicked on
	return (node.name == name) and (node.param2 == param2) and (not minetest.is_protected(pos, pname))
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
	return rp.replaceable(pos, data.name, data.pname, data.param2)
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

function replacer.patterns.mantle_position(pos, data)
	if not rp.replaceable(pos, data.name, data.pname) then
		return false
	end
	for i = 1, 6 do
		if rp.get_node(vector.add(pos, rp.offsets_touch[i])).name ~= data.name then
			return true
		end
	end
	return false
end

-- finds out positions using depth first search
function replacer.patterns.get_ps(pos, fdata, adps, max)
	adps = adps or rp.offsets_touch

	local tab = {}
	local num = 0

	local todo = { pos }
	local ti = 1

	local tab_avoid = {}
	local p, i

	while 0 ~= ti do
		p = todo[ti]
		ti = ti - 1

		for _, p2 in pairs(adps) do
			p2 = vector.add(p, p2)
			i = poshash(p2)
			if (not tab_avoid[i]) and fdata.func(p2, fdata) then

				num = num + 1
				tab[num] = p2

				ti = ti + 1
				todo[ti] = p2

				tab_avoid[i] = true

				if max and (num >= max) then
					return tab, num, tab_avoid
				end
			end -- if
		end -- for
	end -- while
	return tab, num, tab_avoid
end


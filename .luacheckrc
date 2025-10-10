
globals = {
	"replacer",
	core = { fields = { "translate", "get_translator" } },
}

read_globals = {
	-- Stdlib
	string = { fields = { "split", "match", "find", "lower" } },
	table = { fields = { "copy", "getn", "insert", "shuffle", "sort" } },

	-- Luanti
	"core",
	"vector", "ItemStack",
	"dump", "VoxelArea",

	-- deps
	"circular_saw",
	"colormachine",
	"creative",
	"default",
	"dye",
	"flowers",
	"moreblocks",
	"stairsplus",
	"technic",
	"unified_inventory",
	"unifieddyes",
	"xcompat",
}


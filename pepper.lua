
--[[
Copyright (C) 2018 Grizzly Adam
Copyright (C) 2015-2017 Auke Kok <sofar@foo-projects.org>

"Crops Plus" is free software based on "Crops"; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1
of the license, or (at your option) any later version.

--]]

minetest.register_node("crops:pepper_ground", {
	description = ("Ground Pepper"),
	inventory_image = "crops_pepper_ground.png",
	wield_image = "crops_pepper_ground.png",
	drawtype = "plantlike",
	tiles = {"crops_pepper_ground.png"},
	groups = {vessel = 1, pepper_ground=1, dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft( {
	output = "crops:pepper_ground",
	recipe = {
		{"", "", ""},
		{"", "crops:peppercorn", ""},
		{"", "vessels:glass_bottle", ""}
	}
})


-- Intllib
local S = crops.intllib

minetest.register_node("crops:peppercorn", {
	description = S("Peppercorn"),
	inventory_image = "crops_peppercorn.png",
	wield_image = "crops_peppercorn.png",
	tiles = { "crops_pepper_plant_1.png" },
	drawtype = "plantlike",
	paramtype2 = "meshoptions",
	waving = 1,
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	paramtype = "light",
	node_placement_prediction = "crops:pepper_plant_1",
	groups = { peppercorn = 1, vessel=1, snappy=3,flammable=3,flora=1,attached_node=1 },
	drop = {},
	sounds = default.node_sound_leaves_defaults(),

	on_place = function(itemstack, placer, pointed_thing)
		local under = minetest.get_node(pointed_thing.under)
		if minetest.get_item_group(under.name, "soil") <= 1 then
			return
		end
		crops.plant(pointed_thing.above, {name="crops:pepper_plant_1", param2 = 1})
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end
})

if  minetest.registered_items["bbq:peppercorn"] ~= nil then
minetest.override_item("bbq:peppercorn", {
    	on_place = function(itemstack, placer, pointed_thing)
		local under = minetest.get_node(pointed_thing.under)
		if minetest.get_item_group(under.name, "soil") <= 1 then
			return
		end
		crops.plant(pointed_thing.above, {name="crops:pepper_plant_1", param2 = 1})
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end
	})
end

for stage = 1, 4 do
minetest.register_node("crops:pepper_plant_" .. stage , {
	description = S("Pepper plant"),
	tiles = { "crops_pepper_plant_" .. stage .. ".png" },
	drawtype = "plantlike",
	paramtype2 = "meshoptions",
	waving = 1,
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	paramtype = "light",
	groups = { snappy=3, flammable=3, flora=1, attached_node=1, not_in_creative_inventory=1 },
	drop = {},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.45, -0.5, -0.45,  0.45, -0.6 + (((math.min(stage, 4)) + 1) / 5), 0.45}
	}
})
end

minetest.register_node("crops:pepper_plant_5" , {
	description = S("Pepper plant"),
	tiles = { "crops_pepper_plant_5.png" },
	drawtype = "plantlike",
	paramtype2 = "meshoptions",
	waving = 1,
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	paramtype = "light",
	groups = { snappy=3, flammable=3, flora=1, attached_node=1, not_in_creative_inventory=1 },
	drop = {},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.45, -0.5, -0.45,  0.45, 0.45, 0.45}
	},
	on_dig = function(pos, node, digger)
		local drops = {}
		for i = 1, math.random(1, 2) do
			table.insert(drops, "crops:pepper")
		end
		core.handle_node_drops(pos, drops, digger)

		local meta = minetest.get_meta(pos)
		local ttl = meta:get_int("crops_pepper_ttl")
		if ttl > 1 then
			minetest.swap_node(pos, { name = "crops:pepper_plant_4", param2 = 1})
			meta:set_int("crops_pepper_ttl", ttl - 1)
		else
			crops.die(pos)
		end
	end
})

minetest.register_node("crops:pepper_plant_6", {
	description = S("Pepper plant"),
	tiles = { "crops_pepper_plant_6.png" },
	drawtype = "plantlike",
	paramtype2 = "meshoptions",
	waving = 1,
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	paramtype = "light",
	groups = { snappy=3, flammable=3, flora=1, attached_node=1, not_in_creative_inventory=1 },
	drop = {},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.45, -0.5, -0.45,  0.45, 0.45, 0.45}
	},
})

minetest.register_craftitem("crops:pepper", {
	description = S("Pepper"),
	inventory_image = "crops_pepper.png",
	on_use = minetest.item_eat(2),
	groups = { pepper=1 },
})

minetest.register_craft({
	type = "shapeless",
	output = "crops:peppercorn",
	recipe = { "crops:pepper" }
})

--
-- grows a plant to mature size
--
minetest.register_abm({
	nodenames = { "crops:pepper_plant_1", "crops:pepper_plant_2", "crops:pepper_plant_3" },
	neighbors = { "group:soil" },
	interval = crops.settings.interval,
	chance = crops.settings.chance,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if not crops.can_grow(pos) then
			return
		end
		local n = string.gsub(node.name, "4", "5")
		n = string.gsub(n, "3", "4")
		n = string.gsub(n, "2", "3")
		n = string.gsub(n, "1", "2")
		minetest.swap_node(pos, { name = n, param2 = 1 })
	end
})

--
-- grows a pepper
--
minetest.register_abm({
	nodenames = { "crops:pepper_plant_4" },
	neighbors = { "group:soil" },
	interval = crops.settings.interval,
	chance = crops.settings.chance,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if not crops.can_grow(pos) then
			return
		end
		local meta = minetest.get_meta(pos)
		local ttl = meta:get_int("crops_pepper_ttl")
		local damage = meta:get_int("crops_damage")
		if ttl == 0 then
			-- damage 0   - drops 4-6
			-- damage 50  - drops 2-3
			-- damage 100 - drops 0-1
			ttl = math.random(4 - (4 * (damage / 100)), 6 - (5 * (damage / 100)))
		end
		if ttl > 1 then
			minetest.swap_node(pos, { name = "crops:pepper_plant_5", param2 = 1 })
			meta:set_int("crops_pepper_ttl", ttl)
		else
			crops.die(pos)
		end
	end
})

crops.pepper_die = function(pos)
	minetest.set_node(pos, { name = "crops:pepper_plant_6", param2 = 1 })
end

local properties = {
	die = crops.pepper_die,
	waterstart = 19,
	wateruse = 1,
	night = 5,
	soak = 80,
	soak_damage = 90,
	wither = 20,
	wither_damage = 10,
}
crops.register({ name = "crops:pepper_plant_1", properties = properties })
crops.register({ name = "crops:pepper_plant_2", properties = properties })
crops.register({ name = "crops:pepper_plant_3", properties = properties })
crops.register({ name = "crops:pepper_plant_4", properties = properties })
crops.register({ name = "crops:pepper_plant_5", properties = properties })

package levelup;

import h3d.mat.Texture;
import hxd.Res;
import hxd.res.Model;
import levelup.TerrainAssets.TerrainEffect;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TerrainAssets
{
	static public function getTerrain(id)
	{
		return terrains.filter(function (e) { return e.id == id; })[0];
	}

	static public var terrains(default, null):Array<TerrainConfig> = [];

	static public function init()
	{
		terrains = [
			{
				id: "landscapewoodchips01diffuse",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/landscapewoodchips01diffuse.jpg",
				textureUrl: "asset/texture/terrain/forest/landscapewoodchips01diffuse.jpg"
			},
			{
				id: "autumn_leaves",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/autumn_leaves.jpg",
				textureUrl: "asset/texture/terrain/forest/autumn_leaves.jpg",
				normalMapUrl: "asset/texture/terrain/forest/autumn_leaves_n.jpg"
			},
			{
				id: "t_soil_grass_basecolor",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/t_soil_grass_basecolor.jpg",
				textureUrl: "asset/texture/terrain/forest/t_soil_grass_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/forest/t_soil_grass_normal.jpg"
			},
			{
				id: "t_soil_grass_roots_a_basecolor",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/t_soil_grass_roots_a_basecolor.jpg",
				textureUrl: "asset/texture/terrain/forest/t_soil_grass_roots_a_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/forest/t_soil_grass_roots_a_normal.jpg"
			},
			{
				id: "t_soil_grass_roots_b_basecolor",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/t_soil_grass_roots_b_basecolor.jpg",
				textureUrl: "asset/texture/terrain/forest/t_soil_grass_roots_b_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/forest/t_soil_grass_roots_b_normal.jpg"
			},
			{
				id: "t_water_grass_basecolor",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/t_water_grass_basecolor.jpg",
				textureUrl: "asset/texture/terrain/forest/t_water_grass_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/forest/t_water_grass_normal.jpg"
			},
			{
				id: "bricks",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/bricks.jpg",
				textureUrl: "asset/texture/terrain/road/bricks.jpg",
				normalMapUrl: "asset/texture/terrain/road/bricks_n.jpg"
			},
			{
				id: "cracked_stone_2",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/cracked_stone_2.jpg",
				textureUrl: "asset/texture/terrain/stone/cracked_stone_2.jpg",
				normalMapUrl: "asset/texture/terrain/stone/cracked_stone_2_n.jpg"
			},
			{
				id: "desert",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/desert.jpg",
				textureUrl: "asset/texture/terrain/desert/desert.jpg",
				normalMapUrl: "asset/texture/terrain/desert/desert_n.jpg"
			},
			{
				id: "dirtground",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/dirt_ground.jpg",
				textureUrl: "asset/texture/terrain/dirt/dirt_ground.jpg",
				normalMapUrl: "asset/texture/terrain/dirt/dirt_ground_n.jpg"
			},
			{
				id: "ground_stone_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/ground_stone_basecolor.jpg",
				textureUrl: "asset/texture/terrain/dirt/ground_stone_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/dirt/ground_stone_normal.jpg"
			},
			{
				id: "t_ground_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_ground_basecolor.jpg",
				textureUrl: "asset/texture/terrain/dirt/t_ground_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/dirt/t_ground_normal.jpg"
			},
			{
				id: "t_ground_grass_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_ground_grass_basecolor.jpg",
				textureUrl: "asset/texture/terrain/dirt/t_ground_grass_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/dirt/t_ground_grass_normal.jpg"
			},
			{
				id: "t_mud_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_mud_basecolor.jpg",
				textureUrl: "asset/texture/terrain/dirt/t_mud_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/dirt/t_mud_normal.jpg"
			},
			{
				id: "t_soil_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_soil_basecolor.jpg",
				textureUrl: "asset/texture/terrain/dirt/t_soil_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/dirt/t_soil_normal.jpg"
			},
			{
				id: "t_ground_a_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_ground_a_basecolor.jpg",
				textureUrl: "asset/texture/terrain/dirt/t_ground_a_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/dirt/t_ground_a_normal.jpg"
			},
			{
				id: "t_ground_b_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_ground_b_basecolor.jpg",
				textureUrl: "asset/texture/terrain/dirt/t_ground_b_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/dirt/t_ground_b_normal.jpg"
			},
			{
				id: "dry_ground",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/dry_ground.jpg",
				textureUrl: "asset/texture/terrain/desert/dry_ground.jpg",
				normalMapUrl: "asset/texture/terrain/desert/dry_ground_n.jpg"
			},
			{
				id: "sand_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/sand_basecolor.jpg",
				textureUrl: "asset/texture/terrain/desert/sand_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/desert/sand_normal.jpg"
			},
			{
				id: "sand_stone_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/sand_stone_basecolor.jpg",
				textureUrl: "asset/texture/terrain/desert/sand_stone_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/desert/sand_stone_normal.jpg"
			},
			{
				id: "flower_field",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/flower_field.jpg",
				textureUrl: "asset/texture/terrain/grass/flower_field.jpg",
				normalMapUrl: "asset/texture/terrain/grass/flower_field_n.jpg"
			},
			{
				id: "forest_floor_green",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/forest_floor_green.jpg",
				textureUrl: "asset/texture/terrain/forest/forest_floor_green.jpg",
				normalMapUrl: "asset/texture/terrain/forest/forest_floor_green_n.jpg"
			},
			{
				id: "grass",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/grass.jpg",
				textureUrl: "asset/texture/terrain/grass/grass.jpg",
				normalMapUrl: "asset/texture/terrain/grass/grass_n.jpg"
			},
			{
				id: "ice",
				type: TerrainType.Ice,
				previewUrl: "asset/img/preview/terrain/ice/ice.jpg",
				textureUrl: "asset/texture/terrain/ice/ice.jpg",
				normalMapUrl: "asset/texture/terrain/ice/ice_n.jpg"
			},
			{
				id: "lavaground",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/lavaground.jpg",
				textureUrl: "asset/texture/terrain/lava/lavaground.jpg",
				normalMapUrl: "asset/texture/terrain/lava/lava_ground_n.jpg"
			},
			{
				id: "rock",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/rock.jpg",
				textureUrl: "asset/texture/terrain/stone/rock.jpg",
				normalMapUrl: "asset/texture/terrain/stone/rock_n.jpg"
			},
			{
				id: "sand",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/sand.jpg",
				textureUrl: "asset/texture/terrain/desert/sand.jpg"
			},
			{
				id: "sand_2",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/sand_2.jpg",
				textureUrl: "asset/texture/terrain/desert/sand_2.jpg"
			},
			{
				id: "snow",
				type: TerrainType.Ice,
				previewUrl: "asset/img/preview/terrain/ice/snow.jpg",
				textureUrl: "asset/texture/terrain/ice/snow.jpg",
				normalMapUrl: "asset/texture/terrain/ice/snow_n.jpg"
			},
			{
				id: "sticks_leaves",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/sticks_leaves.jpg",
				textureUrl: "asset/texture/terrain/forest/sticks_leaves.jpg",
				normalMapUrl: "asset/texture/terrain/forest/sticks_leaves_n.jpg"
			},
			{
				id: "stones",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/stones.jpg",
				textureUrl: "asset/texture/terrain/road/stones.jpg",
				normalMapUrl: "asset/texture/terrain/road/stones_n.jpg"
			},
			{
				id: "stylizedcliff02_basecolor",
				type: TerrainType.Cliff,
				previewUrl: "asset/img/preview/terrain/cliff/stylizedcliff02_basecolor.jpg",
				textureUrl: "asset/texture/terrain/cliff/stylizedcliff02_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/cliff/stylizedcliff02_normal.jpg"
			},
			{
				id: "rock_basecolor",
				type: TerrainType.Cliff,
				previewUrl: "asset/img/preview/terrain/cliff/rock_basecolor.jpg",
				textureUrl: "asset/texture/terrain/cliff/rock_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/cliff/rock_normal.jpg"
			},
			{
				id: "t_cliff_basecolor",
				type: TerrainType.Cliff,
				previewUrl: "asset/img/preview/terrain/cliff/t_cliff_basecolor.jpg",
				textureUrl: "asset/texture/terrain/cliff/t_cliff_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/cliff/t_cliff_normal.jpg"
			},
			{
				id: "t_cliff_basecolor_vol1",
				type: TerrainType.Cliff,
				previewUrl: "asset/img/preview/terrain/cliff/t_cliff_basecolor_vol1.jpg",
				textureUrl: "asset/texture/terrain/cliff/t_cliff_basecolor_vol1.jpg",
				normalMapUrl: "asset/texture/terrain/cliff/t_cliff_normal_vol1.jpg"
			},
			{
				id: "t_cliff_surface_basecolor",
				type: TerrainType.Cliff,
				previewUrl: "asset/img/preview/terrain/cliff/t_cliff_surface_basecolor.jpg",
				textureUrl: "asset/texture/terrain/cliff/t_cliff_surface_basecolor.jpg"
			},
			{
				id: "stylizedgrass02_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/stylizedgrass02_basecolor.jpg",
				textureUrl: "asset/texture/terrain/grass/stylizedgrass02_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/grass/stylizedgrass02_normal.jpg"
			},
			{
				id: "stylizedice01snow_basecolor",
				type: TerrainType.Ice,
				previewUrl: "asset/img/preview/terrain/ice/stylizedice01snow_basecolor.jpg",
				textureUrl: "asset/texture/terrain/ice/stylizedice01snow_basecolor.jpg"
			},
			{
				id: "stylizedstone03_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/stylizedstone03_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/stylizedstone03_basecolor.jpg"
			},
			{
				id: "stylizedroadstone01_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/stylizedroadstone01_basecolor.jpg",
				textureUrl: "asset/texture/terrain/road/stylizedroadstone01_basecolor.jpg"
			},
			{
				id: "t_ground_brick_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/t_ground_brick_basecolor.jpg",
				textureUrl: "asset/texture/terrain/road/t_ground_brick_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/road/t_ground_brick_normal.jpg"
			},
			{
				id: "t_wall_brick_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/t_wall_brick_basecolor.jpg",
				textureUrl: "asset/texture/terrain/road/t_wall_brick_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/road/t_wall_brick_normal.jpg"
			},
			{
				id: "stylizedsandrock01_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/stylizedsandrock01_basecolor.jpg",
				textureUrl: "asset/texture/terrain/desert/stylizedsandrock01_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/desert/stylizedsandrock01_normal.jpg"
			},
			{
				id: "t_sand_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/t_sand_basecolor.jpg",
				textureUrl: "asset/texture/terrain/desert/t_sand_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/desert/t_sand_normal.jpg"
			},
			{
				id: "t_sand_soil_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/t_sand_soil_basecolor.jpg",
				textureUrl: "asset/texture/terrain/desert/t_sand_soil_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/desert/t_sand_soil_normal.jpg"
			},
			{
				id: "stylizedstone02snow_basecolor",
				type: TerrainType.Ice,
				previewUrl: "asset/img/preview/terrain/ice/stylizedstone02snow_basecolor.jpg",
				textureUrl: "asset/texture/terrain/ice/stylizedstone02snow_basecolor.jpg"
			},
			{
				id: "tiles",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/tiles.jpg",
				textureUrl: "asset/texture/terrain/road/tiles.jpg",
				normalMapUrl: "asset/texture/terrain/road/tiles_n.jpg"
			},
			{
				id: "stylizedwater01_basecolor",
				type: TerrainType.Water,
				previewUrl: "asset/img/preview/terrain/water/stylizedwater01_basecolor.jpg",
				textureUrl: "asset/texture/terrain/water/stylizedwater01_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/water/stylizedwater01_normal.jpg",
				effects: [TerrainEffect.Wave, TerrainEffect.Reflection]
			},
			{
				id: "water",
				type: TerrainType.Water,
				previewUrl: "asset/img/preview/terrain/water/water.jpg",
				textureUrl: "asset/texture/terrain/water/water.jpg",
				normalMapUrl: "asset/texture/terrain/water/water_n.jpg",
				effects: [TerrainEffect.Wave, TerrainEffect.Reflection]
			},
			{
				id: "wood_floor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/wood_floor.jpg",
				textureUrl: "asset/texture/terrain/wood/wood_floor.jpg"
			},
			{
				id: "wood_basecolor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/wood_basecolor.jpg",
				textureUrl: "asset/texture/terrain/wood/wood_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/wood/wood_normal.jpg"
			},
			{
				id: "t_wood_basecolor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/t_wood_basecolor.jpg",
				textureUrl: "asset/texture/terrain/wood/t_wood_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/wood/t_wood_normal.jpg"
			},
			{
				id: "wood_wall_basecolor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/wood_wall_basecolor.jpg",
				textureUrl: "asset/texture/terrain/wood/wood_wall_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/wood/wood_wall_normal.jpg"
			},
			{
				id: "wooden__board_basecolor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/wooden__board_basecolor.jpg",
				textureUrl: "asset/texture/terrain/wood/wooden__board_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/wood/wooden__board_normal.jpg"
			},
			{
				id: "ash",
				type: TerrainType.Other,
				previewUrl: "asset/img/preview/terrain/other/ash.jpg",
				textureUrl: "asset/texture/terrain/other/ash.jpg"
			},
			{
				id: "t_bone_basecolor",
				type: TerrainType.Other,
				previewUrl: "asset/img/preview/terrain/other/t_bone_basecolor.jpg",
				textureUrl: "asset/texture/terrain/other/t_bone_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/other/t_bone_normal.jpg"
			},
			{
				id: "vol_13_2_base_color",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/vol_13_2_base_color.jpg",
				textureUrl: "asset/texture/terrain/dirt/vol_13_2_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/dirt/vol_13_2_normal.jpg"
			},
			{
				id: "vol_2_1_base_color",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/vol_2_1_base_color.jpg",
				textureUrl: "asset/texture/terrain/wood/vol_2_1_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/wood/vol_2_1_normal.jpg"
			},
			{
				id: "vol_2_2_base_color",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/vol_2_2_base_color.jpg",
				textureUrl: "asset/texture/terrain/wood/vol_2_2_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/wood/vol_2_2_normal.jpg"
			},
			{
				id: "vol_7_2_base_color",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/vol_7_2_base_color.jpg",
				textureUrl: "asset/texture/terrain/tile/vol_7_2_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/tile/vol_7_2_Normal.jpg"
			},
			{
				id: "tile_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/tile_basecolor.jpg",
				textureUrl: "asset/texture/terrain/tile/tile_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/tile/tile_normal.jpg"
			},
			{
				id: "t_tile_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/t_tile_basecolor.jpg",
				textureUrl: "asset/texture/terrain/tile/t_tile_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/tile/t_tile_normal.jpg"
			},
			{
				id: "vol_7_3_base_color",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/vol_7_3_base_color.jpg",
				textureUrl: "asset/texture/terrain/road/vol_7_3_base_color.jpg"
			},
			{
				id: "landscapestones01diffuse",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/landscapestones01diffuse.jpg",
				textureUrl: "asset/texture/terrain/road/landscapestones01diffuse.jpg"
			},
			{
				id: "sidewalk_brick_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/sidewalk_brick_basecolor.jpg",
				textureUrl: "asset/texture/terrain/road/sidewalk_brick_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/road/sidewalk_brick_normal.jpg"
			},
			{
				id: "stone_wall_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/stone_wall_basecolor.jpg",
				textureUrl: "asset/texture/terrain/road/stone_wall_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/road/stone_wall_normal.jpg"
			},
			{
				id: "vol_40_6_base_color",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/vol_40_6_base_color.jpg",
				textureUrl: "asset/texture/terrain/desert/vol_40_6_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/desert/vol_40_6_normal.jpg"
			},
			{
				id: "vol_40_4_base_color",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/vol_40_4_base_color.jpg",
				textureUrl: "asset/texture/terrain/desert/vol_40_4_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/desert/vol_40_4_normal.jpg"
			},
			{
				id: "vol_13_4_base_color",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/vol_13_4_base_color.jpg",
				textureUrl: "asset/texture/terrain/road/vol_13_4_base_color.jpg"
			},
			{
				id: "vol_17_2_base_color",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/vol_17_2_base_color.jpg",
				textureUrl: "asset/texture/terrain/grass/vol_17_2_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/grass/vol_17_2_normal.jpg"
			},
			{
				id: "vol_28_4_base_color",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/vol_28_4_base_color.jpg",
				textureUrl: "asset/texture/terrain/lava/vol_28_4_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/lava/vol_28_4_normal.jpg"
			},
			{
				id: "t_lava_cliff_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_cliff_basecolor.jpg",
				textureUrl: "asset/texture/terrain/lava/t_lava_cliff_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/lava/t_lava_cliff_normal.jpg"
			},
			{
				id: "t_lava_cliff_bone_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_cliff_bone_basecolor.jpg",
				textureUrl: "asset/texture/terrain/lava/t_lava_cliff_bone_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/lava/t_lava_cliff_bone_normal.jpg"
			},
			{
				id: "t_lava_color_b",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_color_b.jpg",
				textureUrl: "asset/texture/terrain/lava/t_lava_color_b.jpg",
				normalMapUrl: "asset/texture/terrain/lava/t_lava_normal.jpg",
				effects: [TerrainEffect.Wave, TerrainEffect.Reflection]
			},
			{
				id: "t_lava_ground_cracks_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_ground_cracks_basecolor.jpg",
				textureUrl: "asset/texture/terrain/lava/t_lava_ground_cracks_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/lava/t_lava_ground_cracks_normal.jpg"
			},
			{
				id: "t_lava_small_stone_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_small_stone_basecolor.jpg",
				textureUrl: "asset/texture/terrain/lava/t_lava_small_stone_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/lava/t_lava_small_stone_normal.jpg"
			},
			{
				id: "t_lava_stone_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_stone_basecolor.jpg",
				textureUrl: "asset/texture/terrain/lava/t_lava_stone_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/lava/t_lava_stone_normal.jpg"
			},
			{
				id: "vol_36_2_base_color",
				type: TerrainType.Water,
				previewUrl: "asset/img/preview/terrain/water/vol_36_2_base_color.jpg",
				textureUrl: "asset/texture/terrain/water/vol_36_2_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/water/vol_36_2_normal.jpg",
				effects: [TerrainEffect.Wave, TerrainEffect.Reflection]
			},
			{
				id: "vol_4_5_base_color",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/vol_4_5_base_color.jpg",
				textureUrl: "asset/texture/terrain/tile/vol_4_5_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/tile/vol_4_5_Normal.jpg"
			},
			{
				id: "vol_4_2_base_color",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/vol_4_2_base_color.jpg",
				textureUrl: "asset/texture/terrain/tile/vol_4_2_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/tile/vol_4_2_Normal.jpg"
			},
			{
				id: "vol_23_1_base_color",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/vol_23_1_base_color.jpg",
				textureUrl: "asset/texture/terrain/stone/vol_23_1_base_color.jpg",
				normalMapUrl: "asset/texture/terrain/stone/vol_23_1_normal.jpg"
			},
			{
				id: "vol_27_1_base_color",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/vol_27_1_base_color.jpg",
				textureUrl: "asset/texture/terrain/stone/vol_27_1_base_color.jpg"
			},
			{
				id: "landscaperock01diffuse",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/landscaperock01diffuse.jpg",
				textureUrl: "asset/texture/terrain/stone/landscaperock01diffuse.jpg"
			},
			{
				id: "t_rock_grass_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_rock_grass_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_rock_grass_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_rock_grass_normal.jpg"
			},
			{
				id: "t_rock_basecolor_2",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_rock_basecolor_2.jpg",
				textureUrl: "asset/texture/terrain/stone/t_rock_basecolor_2.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_rock_normal_2.jpg"
			},
			{
				id: "t_stone_ground_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stone_ground_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_stone_ground_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_stone_ground_normal.jpg"
			},
			{
				id: "t_stone_mud_a_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stone_mud_a_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_stone_mud_a_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_stone_mud_a_normal.jpg"
			},
			{
				id: "t_stone_mud_b_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stone_mud_b_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_stone_mud_b_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_stone_mud_b_normal.jpg"
			},
			{
				id: "t_ground_cracks_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_ground_cracks_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_ground_cracks_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_ground_cracks_normal.jpg"
			},
			{
				id: "t_ground_stone_bone_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_ground_stone_bone_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_ground_stone_bone_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_ground_stone_bone_normal.jpg"
			},
			{
				id: "t_rock_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_rock_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_rock_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_rock_normal.jpg"
			},
			{
				id: "t_ground_stone_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_ground_stone_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_ground_stone_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_ground_stone_normal.jpg"
			},
			{
				id: "t_stone_surface_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stone_surface_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_stone_surface_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_stone_surface_normal.jpg"
			},
			{
				id: "t_stones_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stones_basecolor.jpg",
				textureUrl: "asset/texture/terrain/stone/t_stones_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/stone/t_stones_normal.jpg"
			},
			{
				id: "landscapedirt01diffuse",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/landscapedirt01diffuse.jpg",
				textureUrl: "asset/texture/terrain/dirt/landscapedirt01diffuse.jpg"
			},
			{
				id: "landscapegrass01diffuse",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/landscapegrass01diffuse.jpg",
				textureUrl: "asset/texture/terrain/grass/landscapegrass01diffuse.jpg"
			},
			{
				id: "landscapegrass02diffuse",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/landscapegrass02diffuse.jpg",
				textureUrl: "asset/texture/terrain/grass/landscapegrass02diffuse.jpg"
			},
			{
				id: "brick_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/brick_basecolor.jpg",
				textureUrl: "asset/texture/terrain/tile/brick_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/tile/brick_normal.jpg"
			},
			{
				id: "brick_wide_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/brick_wide_basecolor.jpg",
				textureUrl: "asset/texture/terrain/tile/brick_wide_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/tile/brick_wide_normal.jpg"
			},
			{
				id: "chess_tiles_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/chess_tiles_basecolor.jpg",
				textureUrl: "asset/texture/terrain/tile/chess_tiles_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/tile/chess_tiles_normal.jpg"
			},
			{
				id: "t_grass_a_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_grass_a_basecolor.jpg",
				textureUrl: "asset/texture/terrain/grass/t_grass_a_basecolor.jpg"
			},
			{
				id: "t_grass_b_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_grass_b_basecolor.jpg",
				textureUrl: "asset/texture/terrain/grass/t_grass_b_basecolor.jpg"
			},
			{
				id: "t_grass_c_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_grass_c_basecolor.jpg",
				textureUrl: "asset/texture/terrain/grass/t_grass_c_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/grass/t_grass_c_normal.jpg"
			},
			{
				id: "t_grass_flowers_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_grass_flowers_basecolor.jpg",
				textureUrl: "asset/texture/terrain/grass/t_grass_flowers_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/grass/t_grass_flowers_normal.jpg"
			},
			{
				id: "t_stone_grass_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_stone_grass_basecolor.jpg",
				textureUrl: "asset/texture/terrain/grass/t_stone_grass_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/grass/t_stone_grass_normal.jpg"
			},
			{
				id: "grass_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/grass_basecolor.jpg",
				textureUrl: "asset/texture/terrain/grass/grass_basecolor.jpg",
				normalMapUrl: "asset/texture/terrain/grass/grass_normal.jpg"
			},
			{
				id: "other.dark",
				type: TerrainType.Other,
				previewUrl: "asset/img/preview/terrain/other/dark.jpg",
				textureUrl: "asset/texture/terrain/other/dark.jpg",
				normalMapUrl: "asset/texture/terrain/other/dark.jpg"
			},
			{
				id: "other.blueprint",
				type: TerrainType.Other,
				previewUrl: "asset/img/preview/terrain/other/blueprint.jpg",
				textureUrl: "asset/texture/terrain/other/blueprint.jpg",
				normalMapUrl: "asset/texture/terrain/other/blueprint.jpg"
			}
		];
	}
}

typedef TerrainConfig = {
	var id(default, never):String;
	var textureUrl(default, never):String;
	var type(default, never):TerrainType;
	var previewUrl(default, never):String;
	@:optional var normalMapUrl(default, never):String;
	@:optional var effects(default, never):Array<TerrainEffect>;
}

@:enum abstract TerrainType(String) from String to String
{
	var Dirt = "Dirt";
	var Grass = "Field";
	var Forest = "Forest";
	var Road = "Road";
	var Stone = "Stone";
	var Water = "Water";
	var Wood = "Wood";
	var Lava = "Lava";
	var Ice = "Ice";
	var Desert = "Desert";
	var Cliff = "Cliff";
	var Other = "Other";
	var Tile = "Tile";
	var All = "All";
}

enum TerrainEffect
{
	Wave;
	Reflection;
}
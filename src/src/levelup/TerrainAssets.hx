package levelup;

import h3d.mat.Texture;
import hxd.Res;
import hxd.res.Model;
import levelup.game.GameState.RaceId;

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

	static public var terrains(default, null):Array<TerrainConfig>;

	static public function init()
	{
		terrains = [
			{
				id: "landscapewoodchips01diffuse",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/landscapewoodchips01diffuse.jpg",
				texture: Res.texture.terrain.forest.landscapewoodchips01diffuse.toTexture()
			},
			{
				id: "autumn_leaves",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/autumn_leaves.jpg",
				texture: Res.texture.terrain.forest.autumn_leaves.toTexture()
			},
			{
				id: "t_soil_grass_basecolor",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/t_soil_grass_basecolor.jpg",
				texture: Res.texture.terrain.forest.t_soil_grass_basecolor.toTexture()
			},
			{
				id: "t_soil_grass_roots_a_basecolor",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/t_soil_grass_roots_a_basecolor.jpg",
				texture: Res.texture.terrain.forest.t_soil_grass_roots_a_basecolor.toTexture()
			},
			{
				id: "t_soil_grass_roots_b_basecolor",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/t_soil_grass_roots_b_basecolor.jpg",
				texture: Res.texture.terrain.forest.t_soil_grass_roots_b_basecolor.toTexture()
			},
			{
				id: "t_water_grass_basecolor",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/t_water_grass_basecolor.jpg",
				texture: Res.texture.terrain.forest.t_water_grass_basecolor.toTexture()
			},
			{
				id: "bricks",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/bricks.jpg",
				texture: Res.texture.terrain.road.bricks.toTexture()
			},
			{
				id: "cracked_stone_2",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/cracked_stone_2.jpg",
				texture: Res.texture.terrain.stone.cracked_stone_2.toTexture()
			},
			{
				id: "desert",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/desert.jpg",
				texture: Res.texture.terrain.desert.desert.toTexture()
			},
			{
				id: "dirtground",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/dirt_ground.jpg",
				texture: Res.texture.terrain.dirt.dirt_ground.toTexture()
			},
			{
				id: "ground_stone_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/ground_stone_basecolor.jpg",
				texture: Res.texture.terrain.dirt.ground_stone_basecolor.toTexture(),
				normalMap: Res.texture.terrain.dirt.ground_stone_normal.toTexture()
			},
			{
				id: "t_ground_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_ground_basecolor.jpg",
				texture: Res.texture.terrain.dirt.t_ground_basecolor.toTexture(),
				normalMap: Res.texture.terrain.dirt.t_ground_normal.toTexture()
			},
			{
				id: "t_ground_grass_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_ground_grass_basecolor.jpg",
				texture: Res.texture.terrain.dirt.t_ground_grass_basecolor.toTexture(),
				normalMap: Res.texture.terrain.dirt.t_ground_grass_normal.toTexture()
			},
			{
				id: "t_mud_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_mud_basecolor.jpg",
				texture: Res.texture.terrain.dirt.t_mud_basecolor.toTexture()
			},
			{
				id: "t_soil_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_soil_basecolor.jpg",
				texture: Res.texture.terrain.dirt.t_soil_basecolor.toTexture()
			},
			{
				id: "t_ground_a_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_ground_a_basecolor.jpg",
				texture: Res.texture.terrain.dirt.t_ground_a_basecolor.toTexture()
			},
			{
				id: "t_ground_b_basecolor",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/t_ground_b_basecolor.jpg",
				texture: Res.texture.terrain.dirt.t_ground_b_basecolor.toTexture()
			},
			{
				id: "dry_ground",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/dry_ground.jpg",
				texture: Res.texture.terrain.desert.dry_ground.toTexture()
			},
			{
				id: "sand_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/sand_basecolor.jpg",
				texture: Res.texture.terrain.desert.sand_basecolor.toTexture(),
				normalMap: Res.texture.terrain.desert.sand_normal.toTexture()
			},
			{
				id: "sand_stone_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/sand_stone_basecolor.jpg",
				texture: Res.texture.terrain.desert.sand_stone_basecolor.toTexture(),
				normalMap: Res.texture.terrain.desert.sand_stone_normal.toTexture()
			},
			{
				id: "flower_field",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/flower_field.jpg",
				texture: Res.texture.terrain.grass.flower_field.toTexture()
			},
			{
				id: "forest_floor_green",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/forest_floor_green.jpg",
				texture: Res.texture.terrain.forest.forest_floor_green.toTexture()
			},
			{
				id: "grass",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/grass.jpg",
				texture: Res.texture.terrain.grass.grass.toTexture()
			},
			{
				id: "ice",
				type: TerrainType.Ice,
				previewUrl: "asset/img/preview/terrain/ice/ice.jpg",
				texture: Res.texture.terrain.ice.ice.toTexture()
			},
			{
				id: "lavaground",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/lavaground.jpg",
				texture: Res.texture.terrain.lava.lavaground.toTexture()
			},
			{
				id: "rock",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/rock.jpg",
				texture: Res.texture.terrain.stone.rock.toTexture()
			},
			{
				id: "sand",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/sand.jpg",
				texture: Res.texture.terrain.desert.sand.toTexture()
			},
			{
				id: "sand_2",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/sand_2.jpg",
				texture: Res.texture.terrain.desert.sand_2.toTexture()
			},
			{
				id: "snow",
				type: TerrainType.Ice,
				previewUrl: "asset/img/preview/terrain/ice/snow.jpg",
				texture: Res.texture.terrain.ice.snow.toTexture()
			},
			{
				id: "sticks_leaves",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/sticks_leaves.jpg",
				texture: Res.texture.terrain.forest.sticks_leaves.toTexture()
			},
			{
				id: "stones",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/stones.jpg",
				texture: Res.texture.terrain.road.stones.toTexture()
			},
			{
				id: "stylizedcliff02_basecolor",
				type: TerrainType.Cliff,
				previewUrl: "asset/img/preview/terrain/cliff/stylizedcliff02_basecolor.jpg",
				texture: Res.texture.terrain.cliff.stylizedcliff02_basecolor.toTexture(),
				normalMap: Res.texture.terrain.cliff.stylizedcliff02_normal.toTexture()
			},
			{
				id: "rock_basecolor",
				type: TerrainType.Cliff,
				previewUrl: "asset/img/preview/terrain/cliff/rock_basecolor.jpg",
				texture: Res.texture.terrain.cliff.rock_basecolor.toTexture(),
				normalMap: Res.texture.terrain.cliff.rock_normal.toTexture()
			},
			{
				id: "t_cliff_basecolor",
				type: TerrainType.Cliff,
				previewUrl: "asset/img/preview/terrain/cliff/t_cliff_basecolor.jpg",
				texture: Res.texture.terrain.cliff.t_cliff_basecolor.toTexture(),
				normalMap: Res.texture.terrain.cliff.t_cliff_normal.toTexture()
			},
			{
				id: "stylizedgrass02_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/stylizedgrass02_basecolor.jpg",
				texture: Res.texture.terrain.grass.stylizedgrass02_basecolor.toTexture(),
				normalMap: Res.texture.terrain.grass.stylizedgrass02_normal.toTexture()
			},
			{
				id: "stylizedice01snow_basecolor",
				type: TerrainType.Ice,
				previewUrl: "asset/img/preview/terrain/ice/stylizedice01snow_basecolor.jpg",
				texture: Res.texture.terrain.ice.stylizedice01snow_basecolor.toTexture()
			},
			{
				id: "stylizedstone03_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/stylizedstone03_basecolor.jpg",
				texture: Res.texture.terrain.stone.stylizedstone03_basecolor.toTexture()
			},
			{
				id: "stylizedroadstone01_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/stylizedroadstone01_basecolor.jpg",
				texture: Res.texture.terrain.road.stylizedroadstone01_basecolor.toTexture(),
				normalMap: Res.texture.terrain.road.stylizedroadstone01_normal.toTexture()
			},
			{
				id: "t_ground_brick_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/t_ground_brick_basecolor.jpg",
				texture: Res.texture.terrain.road.t_ground_brick_basecolor.toTexture(),
				normalMap: Res.texture.terrain.road.t_ground_brick_normal.toTexture()
			},
			{
				id: "t_wall_brick_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/t_wall_brick_basecolor.jpg",
				texture: Res.texture.terrain.road.t_wall_brick_basecolor.toTexture(),
				normalMap: Res.texture.terrain.road.t_wall_brick_normal.toTexture()
			},
			{
				id: "stylizedsandrock01_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/stylizedsandrock01_basecolor.jpg",
				texture: Res.texture.terrain.desert.stylizedsandrock01_basecolor.toTexture(),
				normalMap: Res.texture.terrain.desert.stylizedsandrock01_normal.toTexture()
			},
			{
				id: "t_sand_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/t_sand_basecolor.jpg",
				texture: Res.texture.terrain.desert.t_sand_basecolor.toTexture(),
				normalMap: Res.texture.terrain.desert.t_sand_normal.toTexture()
			},
			{
				id: "t_sand_soil_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/t_sand_soil_basecolor.jpg",
				texture: Res.texture.terrain.desert.t_sand_soil_basecolor.toTexture()
			},
			{
				id: "stylizedstone02snow_basecolor",
				type: TerrainType.Ice,
				previewUrl: "asset/img/preview/terrain/ice/stylizedstone02snow_basecolor.jpg",
				texture: Res.texture.terrain.ice.stylizedstone02snow_basecolor.toTexture()
			},
			{
				id: "tiles",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/tiles.jpg",
				texture: Res.texture.terrain.road.tiles.toTexture()
			},
			{
				id: "stylizedwater01_basecolor",
				type: TerrainType.Water,
				previewUrl: "asset/img/preview/terrain/water/stylizedwater01_basecolor.jpg",
				texture: Res.texture.terrain.water.stylizedwater01_basecolor.toTexture(),
				normalMap: Res.texture.terrain.water.stylizedwater01_normal.toTexture()
			},
			{
				id: "water",
				type: TerrainType.Water,
				previewUrl: "asset/img/preview/terrain/water/water.jpg",
				texture: Res.texture.terrain.water.water.toTexture()
			},
			{
				id: "wood_floor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/wood_floor.jpg",
				texture: Res.texture.terrain.wood.wood_floor.toTexture()
			},
			{
				id: "wood_basecolor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/wood_basecolor.jpg",
				texture: Res.texture.terrain.wood.wood_basecolor.toTexture(),
				normalMap: Res.texture.terrain.wood.wood_normal.toTexture()
			},
			{
				id: "t_wood_basecolor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/t_wood_basecolor.jpg",
				texture: Res.texture.terrain.wood.t_wood_basecolor.toTexture(),
				normalMap: Res.texture.terrain.wood.t_wood_normal.toTexture()
			},
			{
				id: "wood_wall_basecolor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/wood_wall_basecolor.jpg",
				texture: Res.texture.terrain.wood.wood_wall_basecolor.toTexture(),
				normalMap: Res.texture.terrain.wood.wood_wall_normal.toTexture()
			},
			{
				id: "wooden__board_basecolor",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/wooden__board_basecolor.jpg",
				texture: Res.texture.terrain.wood.wooden__board_basecolor.toTexture(),
				normalMap: Res.texture.terrain.wood.wooden__board_normal.toTexture()
			},
			{
				id: "ash",
				type: TerrainType.Other,
				previewUrl: "asset/img/preview/terrain/other/ash.jpg",
				texture: Res.texture.terrain.other.ash.toTexture()
			},
			{
				id: "t_bone_basecolor",
				type: TerrainType.Other,
				previewUrl: "asset/img/preview/terrain/other/t_bone_basecolor.jpg",
				texture: Res.texture.terrain.other.t_bone_basecolor.toTexture(),
				normalMap: Res.texture.terrain.other.t_bone_normal.toTexture()
			},
			{
				id: "vol_13_2_base_color",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/vol_13_2_base_color.jpg",
				texture: Res.texture.terrain.dirt.vol_13_2_base_color.toTexture(),
				normalMap: Res.texture.terrain.dirt.vol_13_2_normal.toTexture()
			},
			{
				id: "vol_2_1_base_color",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/vol_2_1_base_color.jpg",
				texture: Res.texture.terrain.wood.vol_2_1_base_color.toTexture(),
				normalMap: Res.texture.terrain.wood.vol_2_1_normal.toTexture()
			},
			{
				id: "vol_2_2_base_color",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/vol_2_2_base_color.jpg",
				texture: Res.texture.terrain.wood.vol_2_2_base_color.toTexture(),
				normalMap: Res.texture.terrain.wood.vol_2_2_normal.toTexture()
			},
			{
				id: "vol_7_2_base_color",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/vol_7_2_base_color.jpg",
				texture: Res.texture.terrain.tile.vol_7_2_base_color.toTexture(),
				normalMap: Res.texture.terrain.tile.vol_7_2_Normal.toTexture()
			},
			{
				id: "tile_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/tile_basecolor.jpg",
				texture: Res.texture.terrain.tile.tile_basecolor.toTexture(),
				normalMap: Res.texture.terrain.tile.tile_normal.toTexture()
			},
			{
				id: "t_tile_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/t_tile_basecolor.jpg",
				texture: Res.texture.terrain.tile.t_tile_basecolor.toTexture(),
				normalMap: Res.texture.terrain.tile.t_tile_normal.toTexture()
			},
			{
				id: "vol_7_3_base_color",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/vol_7_3_base_color.jpg",
				texture: Res.texture.terrain.road.vol_7_3_base_color.toTexture()
			},
			{
				id: "landscapestones01diffuse",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/landscapestones01diffuse.jpg",
				texture: Res.texture.terrain.road.landscapestones01diffuse.toTexture()
			},
			{
				id: "sidewalk_brick_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/sidewalk_brick_basecolor.jpg",
				texture: Res.texture.terrain.road.sidewalk_brick_basecolor.toTexture(),
				normalMap: Res.texture.terrain.road.sidewalk_brick_normal.toTexture()
			},
			{
				id: "stone_wall_basecolor",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/stone_wall_basecolor.jpg",
				texture: Res.texture.terrain.road.stone_wall_basecolor.toTexture(),
				normalMap: Res.texture.terrain.road.stone_wall_normal.toTexture()
			},
			{
				id: "vol_40_6_base_color",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/vol_40_6_base_color.jpg",
				texture: Res.texture.terrain.desert.vol_40_6_base_color.toTexture(),
				normalMap: Res.texture.terrain.desert.vol_40_6_normal.toTexture()
			},
			{
				id: "vol_40_4_base_color",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/vol_40_4_base_color.jpg",
				texture: Res.texture.terrain.desert.vol_40_4_base_color.toTexture(),
				normalMap: Res.texture.terrain.desert.vol_40_4_normal.toTexture()
			},
			{
				id: "vol_13_4_base_color",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/vol_13_4_base_color.jpg",
				texture: Res.texture.terrain.road.vol_13_4_base_color.toTexture()
			},
			{
				id: "vol_17_2_base_color",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/vol_17_2_base_color.jpg",
				texture: Res.texture.terrain.grass.vol_17_2_base_color.toTexture(),
				normalMap: Res.texture.terrain.grass.vol_17_2_normal.toTexture()
			},
			{
				id: "vol_28_4_base_color",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/vol_28_4_base_color.jpg",
				texture: Res.texture.terrain.lava.vol_28_4_base_color.toTexture(),
				normalMap: Res.texture.terrain.lava.vol_28_4_normal.toTexture()
			},
			{
				id: "t_lava_cliff_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_cliff_basecolor.jpg",
				texture: Res.texture.terrain.lava.t_lava_cliff_basecolor.toTexture(),
				normalMap: Res.texture.terrain.lava.t_lava_cliff_normal.toTexture()
			},
			{
				id: "t_lava_cliff_bone_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_cliff_bone_basecolor.jpg",
				texture: Res.texture.terrain.lava.t_lava_cliff_bone_basecolor.toTexture(),
				normalMap: Res.texture.terrain.lava.t_lava_cliff_bone_normal.toTexture()
			},
			{
				id: "t_lava_color_b",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_color_b.jpg",
				texture: Res.texture.terrain.lava.t_lava_color_b.toTexture(),
				normalMap: Res.texture.terrain.lava.t_lava_normal.toTexture()
			},
			{
				id: "t_lava_ground_cracks_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_ground_cracks_basecolor.jpg",
				texture: Res.texture.terrain.lava.t_lava_ground_cracks_basecolor.toTexture(),
				normalMap: Res.texture.terrain.lava.t_lava_ground_cracks_normal.toTexture()
			},
			{
				id: "t_lava_small_stone_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_small_stone_basecolor.jpg",
				texture: Res.texture.terrain.lava.t_lava_small_stone_basecolor.toTexture(),
				normalMap: Res.texture.terrain.lava.t_lava_small_stone_normal.toTexture()
			},
			{
				id: "t_lava_stone_basecolor",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/t_lava_stone_basecolor.jpg",
				texture: Res.texture.terrain.lava.t_lava_stone_basecolor.toTexture(),
				normalMap: Res.texture.terrain.lava.t_lava_stone_normal.toTexture()
			},
			{
				id: "vol_36_2_base_color",
				type: TerrainType.Water,
				previewUrl: "asset/img/preview/terrain/water/vol_36_2_base_color.jpg",
				texture: Res.texture.terrain.water.vol_36_2_base_color.toTexture(),
				normalMap: Res.texture.terrain.water.vol_36_2_normal.toTexture()
			},
			{
				id: "vol_4_5_base_color",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/vol_4_5_base_color.jpg",
				texture: Res.texture.terrain.tile.vol_4_5_base_color.toTexture(),
				normalMap: Res.texture.terrain.tile.vol_4_5_Normal.toTexture()
			},
			{
				id: "vol_4_2_base_color",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/vol_4_2_base_color.jpg",
				texture: Res.texture.terrain.tile.vol_4_2_base_color.toTexture(),
				normalMap: Res.texture.terrain.tile.vol_4_2_Normal.toTexture()
			},
			{
				id: "vol_23_1_base_color",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/vol_23_1_base_color.jpg",
				texture: Res.texture.terrain.stone.vol_23_1_base_color.toTexture(),
				normalMap: Res.texture.terrain.stone.vol_23_1_normal.toTexture()
			},
			{
				id: "vol_27_1_base_color",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/vol_27_1_base_color.jpg",
				texture: Res.texture.terrain.stone.vol_27_1_base_color.toTexture()
			},
			{
				id: "landscaperock01diffuse",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/landscaperock01diffuse.jpg",
				texture: Res.texture.terrain.stone.landscaperock01diffuse.toTexture()
			},
			{
				id: "t_rock_grass_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_rock_grass_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_rock_grass_basecolor.toTexture()
			},
			{
				id: "t_stone_ground_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stone_ground_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_stone_ground_basecolor.toTexture()
			},
			{
				id: "t_stone_mud_a_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stone_mud_a_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_stone_mud_a_basecolor.toTexture()
			},
			{
				id: "t_stone_mud_b_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stone_mud_b_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_stone_mud_b_basecolor.toTexture()
			},
			{
				id: "t_ground_cracks_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_ground_cracks_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_ground_cracks_basecolor.toTexture(),
				normalMap: Res.texture.terrain.stone.t_ground_cracks_normal.toTexture()
			},
			{
				id: "t_ground_stone_bone_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_ground_stone_bone_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_ground_stone_bone_basecolor.toTexture(),
				normalMap: Res.texture.terrain.stone.t_ground_stone_bone_normal.toTexture()
			},
			{
				id: "t_rock_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_rock_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_rock_basecolor.toTexture(),
				normalMap: Res.texture.terrain.stone.t_rock_normal.toTexture()
			},
			{
				id: "t_ground_stone_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_ground_stone_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_ground_stone_basecolor.toTexture(),
				normalMap: Res.texture.terrain.stone.t_ground_stone_normal.toTexture()
			},
			{
				id: "t_stone_surface_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stone_surface_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_stone_surface_basecolor.toTexture()
			},
			{
				id: "t_stones_basecolor",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/t_stones_basecolor.jpg",
				texture: Res.texture.terrain.stone.t_stones_basecolor.toTexture()
			},
			{
				id: "landscapedirt01diffuse",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/landscapedirt01diffuse.jpg",
				texture: Res.texture.terrain.dirt.landscapedirt01diffuse.toTexture()
			},
			{
				id: "landscapegrass01diffuse",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/landscapegrass01diffuse.jpg",
				texture: Res.texture.terrain.grass.landscapegrass01diffuse.toTexture()
			},
			{
				id: "landscapegrass02diffuse",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/landscapegrass02diffuse.jpg",
				texture: Res.texture.terrain.grass.landscapegrass02diffuse.toTexture()
			},
			{
				id: "brick_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/brick_basecolor.jpg",
				texture: Res.texture.terrain.tile.brick_basecolor.toTexture(),
				normalMap: Res.texture.terrain.tile.brick_normal.toTexture()
			},
			{
				id: "brick_wide_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/brick_wide_basecolor.jpg",
				texture: Res.texture.terrain.tile.brick_wide_basecolor.toTexture(),
				normalMap: Res.texture.terrain.tile.brick_wide_normal.toTexture()
			},
			{
				id: "chess_tiles_basecolor",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/chess_tiles_basecolor.jpg",
				texture: Res.texture.terrain.tile.chess_tiles_basecolor.toTexture(),
				normalMap: Res.texture.terrain.tile.chess_tiles_normal.toTexture()
			},
			{
				id: "t_grass_a_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_grass_a_basecolor.jpg",
				texture: Res.texture.terrain.grass.t_grass_a_basecolor.toTexture()
			},
			{
				id: "t_grass_b_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_grass_b_basecolor.jpg",
				texture: Res.texture.terrain.grass.t_grass_b_basecolor.toTexture()
			},
			{
				id: "t_grass_c_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_grass_c_basecolor.jpg",
				texture: Res.texture.terrain.grass.t_grass_c_basecolor.toTexture()
			},
			{
				id: "t_grass_flowers_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_grass_flowers_basecolor.jpg",
				texture: Res.texture.terrain.grass.t_grass_flowers_basecolor.toTexture()
			},
			{
				id: "t_stone_grass_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/t_stone_grass_basecolor.jpg",
				texture: Res.texture.terrain.grass.t_stone_grass_basecolor.toTexture()
			},
			{
				id: "grass_basecolor",
				type: TerrainType.Grass,
				previewUrl: "asset/img/preview/terrain/grass/grass_basecolor.jpg",
				texture: Res.texture.terrain.grass.grass_basecolor.toTexture(),
				normalMap: Res.texture.terrain.grass.grass_normal.toTexture()
			}
		];
	}
}

typedef TerrainConfig = {
	var id(default, never):String;
	var texture(default, never):Texture;
	var type(default, never):TerrainType;
	var previewUrl(default, never):String;
	@:optional var normalMap(default, never):Texture;
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
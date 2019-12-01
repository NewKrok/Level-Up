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
				id: "autumn_leaves",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/autumn_leaves.jpg",
				texture: Res.texture.terrain.forest.autumn_leaves.toTexture()
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
				id: "dry_ground",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/dry_ground.jpg",
				texture: Res.texture.terrain.desert.dry_ground.toTexture()
			},
			{
				id: "flower_field",
				type: TerrainType.Field,
				previewUrl: "asset/img/preview/terrain/field/flower_field.jpg",
				texture: Res.texture.terrain.field.flower_field.toTexture()
			},
			{
				id: "forest_floor_green",
				type: TerrainType.Forest,
				previewUrl: "asset/img/preview/terrain/forest/forest_floor_green.jpg",
				texture: Res.texture.terrain.forest.forest_floor_green.toTexture()
			},
			{
				id: "grass",
				type: TerrainType.Field,
				previewUrl: "asset/img/preview/terrain/field/grass.jpg",
				texture: Res.texture.terrain.field.grass.toTexture()
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
				texture: Res.texture.terrain.cliff.stylizedcliff02_basecolor.toTexture()
			},
			{
				id: "stylizedgrass02_basecolor",
				type: TerrainType.Field,
				previewUrl: "asset/img/preview/terrain/field/stylizedgrass02_basecolor.jpg",
				texture: Res.texture.terrain.field.stylizedgrass02_basecolor.toTexture()
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
				texture: Res.texture.terrain.road.stylizedroadstone01_basecolor.toTexture()
			},
			{
				id: "stylizedsandrock01_basecolor",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/stylizedsandrock01_basecolor.jpg",
				texture: Res.texture.terrain.desert.stylizedsandrock01_basecolor.toTexture()
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
				texture: Res.texture.terrain.water.stylizedwater01_basecolor.toTexture()
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
				id: "ash",
				type: TerrainType.Other,
				previewUrl: "asset/img/preview/terrain/other/ash.jpg",
				texture: Res.texture.terrain.other.ash.toTexture()
			},
			{
				id: "vol_13_2_base_color",
				type: TerrainType.Dirt,
				previewUrl: "asset/img/preview/terrain/dirt/vol_13_2_base_color.jpg",
				texture: Res.texture.terrain.dirt.vol_13_2_base_color.toTexture()
			},
			{
				id: "vol_2_1_base_color",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/vol_2_1_base_color.jpg",
				texture: Res.texture.terrain.wood.vol_2_1_base_color.toTexture()
			},
			{
				id: "vol_2_2_base_color",
				type: TerrainType.Wood,
				previewUrl: "asset/img/preview/terrain/wood/vol_2_2_base_color.jpg",
				texture: Res.texture.terrain.wood.vol_2_2_base_color.toTexture()
			},
			{
				id: "vol_7_2_base_color",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/vol_7_2_base_color.jpg",
				texture: Res.texture.terrain.tile.vol_7_2_base_color.toTexture()
			},
			{
				id: "vol_7_3_base_color",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/vol_7_3_base_color.jpg",
				texture: Res.texture.terrain.road.vol_7_3_base_color.toTexture()
			},
			{
				id: "vol_5_1_base_color",
				type: TerrainType.Other,
				previewUrl: "asset/img/preview/terrain/other/vol_5_1_base_color.jpg",
				texture: Res.texture.terrain.other.vol_5_1_base_color.toTexture()
			},
			{
				id: "vol_40_6_base_color",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/vol_40_6_base_color.jpg",
				texture: Res.texture.terrain.desert.vol_40_6_base_color.toTexture()
			},
			{
				id: "vol_40_4_base_color",
				type: TerrainType.Desert,
				previewUrl: "asset/img/preview/terrain/desert/vol_40_4_base_color.jpg",
				texture: Res.texture.terrain.desert.vol_40_4_base_color.toTexture()
			},
			{
				id: "vol_13_4_base_color",
				type: TerrainType.Road,
				previewUrl: "asset/img/preview/terrain/road/vol_13_4_base_color.jpg",
				texture: Res.texture.terrain.road.vol_13_4_base_color.toTexture()
			},
			{
				id: "vol_17_2_base_color",
				type: TerrainType.Field,
				previewUrl: "asset/img/preview/terrain/field/vol_17_2_base_color.jpg",
				texture: Res.texture.terrain.field.vol_17_2_base_color.toTexture()
			},
			{
				id: "vol_28_4_base_color",
				type: TerrainType.Lava,
				previewUrl: "asset/img/preview/terrain/lava/vol_28_4_base_color.jpg",
				texture: Res.texture.terrain.lava.vol_28_4_base_color.toTexture()
			},
			{
				id: "vol_36_2_base_color",
				type: TerrainType.Water,
				previewUrl: "asset/img/preview/terrain/water/vol_36_2_base_color.jpg",
				texture: Res.texture.terrain.water.vol_36_2_base_color.toTexture()
			},
			{
				id: "vol_4_5_base_color",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/vol_4_5_base_color.jpg",
				texture: Res.texture.terrain.tile.vol_4_5_base_color.toTexture()
			},
			{
				id: "vol_4_2_base_color",
				type: TerrainType.Tile,
				previewUrl: "asset/img/preview/terrain/tile/vol_4_2_base_color.jpg",
				texture: Res.texture.terrain.tile.vol_4_2_base_color.toTexture()
			},
			{
				id: "vol_23_1_base_color",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/vol_23_1_base_color.jpg",
				texture: Res.texture.terrain.stone.vol_23_1_base_color.toTexture()
			},
			{
				id: "vol_27_1_base_color",
				type: TerrainType.Stone,
				previewUrl: "asset/img/preview/terrain/stone/vol_27_1_base_color.jpg",
				texture: Res.texture.terrain.stone.vol_27_1_base_color.toTexture()
			}
		];
	}
}

typedef TerrainConfig = {
	var id(default, never):String;
	var texture(default, never):Texture;
	var type(default, never):TerrainType;
	var previewUrl(default, never):String;
}

@:enum abstract TerrainType(String) from String to String
{
	var Dirt = "Dirt";
	var Field = "Field";
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
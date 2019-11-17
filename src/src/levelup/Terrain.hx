package levelup;

import h3d.mat.Texture;
import hxd.Res;
import hxd.res.Model;
import levelup.game.GameState.RaceId;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Terrain
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
				name: "Autumn Leaves",
				uvScale: 20,
				texture: Res.texture.terrain.autumn_leaves.toTexture()
			},
			{
				id: "bricks",
				name: "Bricks",
				uvScale: 30,
				texture: Res.texture.terrain.bricks.toTexture()
			},
			{
				id: "cracked_stone_1",
				name: "Cracked Stone",
				uvScale: 30,
				texture: Res.texture.terrain.cracked_stone_1.toTexture()
			},
			{
				id: "cracked_stone_2",
				name: "Cracked Stone 2",
				uvScale: 30,
				texture: Res.texture.terrain.cracked_stone_2.toTexture()
			},
			{
				id: "desert",
				name: "Desert",
				uvScale: 30,
				texture: Res.texture.terrain.desert.toTexture()
			},
			{
				id: "dirtground",
				name: "Dirt Ground",
				uvScale: 30,
				texture: Res.texture.terrain.DirtGround.toTexture()
			},
			{
				id: "dry_ground",
				name: "Dry Ground",
				uvScale: 30,
				texture: Res.texture.terrain.dry_ground.toTexture()
			},
			{
				id: "flower_field",
				name: "Flower Field",
				uvScale: 30,
				texture: Res.texture.terrain.flower_field.toTexture()
			},
			{
				id: "forest_floor",
				name: "Forest Floor",
				uvScale: 30,
				texture: Res.texture.terrain.forest_floor.toTexture()
			},
			{
				id: "forest_floor_green",
				name: "Forest Floor Green",
				uvScale: 30,
				texture: Res.texture.terrain.forest_floor_green.toTexture()
			},
			{
				id: "grass",
				name: "Grass",
				uvScale: 30,
				texture: Res.texture.terrain.grass.toTexture()
			},
			{
				id: "ice",
				name: "Ice",
				uvScale: 30,
				texture: Res.texture.terrain.ice.toTexture()
			},
			{
				id: "lavaground",
				name: "Lava Ground",
				uvScale: 30,
				texture: Res.texture.terrain.LavaGround.toTexture()
			},
			{
				id: "metal_plate",
				name: "Metal Plate",
				uvScale: 30,
				texture: Res.texture.terrain.metal_plate.toTexture()
			},
			{
				id: "rock",
				name: "Rock",
				uvScale: 30,
				texture: Res.texture.terrain.rock.toTexture()
			},
			{
				id: "sand",
				name: "Sand",
				uvScale: 30,
				texture: Res.texture.terrain.sand.toTexture()
			},
			{
				id: "sand_2",
				name: "Sand 2",
				uvScale: 30,
				texture: Res.texture.terrain.sand_2.toTexture()
			},
			{
				id: "sand_3",
				name: "Sand 3",
				uvScale: 30,
				texture: Res.texture.terrain.sand_3.toTexture()
			},
			{
				id: "snow",
				name: "Snow",
				uvScale: 30,
				texture: Res.texture.terrain.snow.toTexture()
			},
			{
				id: "sticks_leaves",
				name: "Sticks Leaves",
				uvScale: 30,
				texture: Res.texture.terrain.sticks_leaves.toTexture()
			},
			{
				id: "stone",
				name: "Stone",
				uvScale: 30,
				texture: Res.texture.terrain.stone.toTexture()
			},
			{
				id: "stones",
				name: "Stones",
				uvScale: 30,
				texture: Res.texture.terrain.stones.toTexture()
			},
			{
				id: "stylizedcliff02_basecolor",
				name: "Cliff",
				uvScale: 60,
				texture: Res.texture.terrain.StylizedCliff02_basecolor.toTexture()
			},
			{
				id: "stylizedgrass02_basecolor",
				name: "Grass",
				uvScale: 60,
				texture: Res.texture.terrain.StylizedGrass02_basecolor.toTexture()
			},
			{
				id: "stylizedice01snow_basecolor",
				name: "Snow",
				uvScale: 60,
				texture: Res.texture.terrain.StylizedIce01Snow_basecolor.toTexture()
			},
			{
				id: "stylizedmuddystones01_basecolor",
				name: "Stones",
				uvScale: 60,
				texture: Res.texture.terrain.StylizedMuddyStones01_basecolor.toTexture()
			},
			{
				id: "stylizedstone03_basecolor",
				name: "Stones 2",
				uvScale: 60,
				texture: Res.texture.terrain.StylizedStone03_basecolor.toTexture()
			},
			{
				id: "stylizedroadstone01_basecolor",
				name: "Road Stone",
				uvScale: 60,
				texture: Res.texture.terrain.StylizedRoadStone01_basecolor.toTexture()
			},
			{
				id: "stylizedsandrock01_basecolor",
				name: "Dirt Rock",
				uvScale: 60,
				texture: Res.texture.terrain.StylizedSandRock01_basecolor.toTexture()
			},
			{
				id: "stylizedstone02snow_basecolor",
				name: "Snowy Stone",
				uvScale: 60,
				texture: Res.texture.terrain.StylizedStone02Snow_basecolor.toTexture()
			},
			{
				id: "tiles",
				name: "Tiles",
				uvScale: 20,
				texture: Res.texture.terrain.tiles.toTexture()
			},
			{
				id: "stylizedwater01_basecolor",
				name: "Water",
				uvScale: 60,
				texture: Res.texture.terrain.StylizedWater01_basecolor.toTexture()
			},
			{
				id: "water",
				name: "Water 2",
				uvScale: 30,
				texture: Res.texture.terrain.water.toTexture()
			},
			{
				id: "wood_floor",
				name: "Wood Floor",
				uvScale: 20,
				texture: Res.texture.terrain.wood_floor.toTexture()
			}
		];
	}
}

typedef TerrainConfig = {
	var id(default, never):String;
	var name(default, never):String;
	var uvScale(default, never):Int;
	var texture(default, never):Texture;
}
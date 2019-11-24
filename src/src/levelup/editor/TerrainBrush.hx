package levelup.editor;

import h2d.Tile;
import h3d.mat.Texture;
import hxd.BitmapData;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TerrainBrush
{
	static public function getBrush(id)
	{
		return brushes.filter(function (e) { return e.id == id; })[0];
	}

	static public var brushes(default, null):Array<Brush>;

	static public function init()
	{
		brushes = [
			{
				id: 0,
				texture: Res.texture.brush.brush_0.toTexture(),
				bmp: Res.texture.brush.brush_0.toBitmap(),
				tile: Res.texture.brush.brush_0.toTile()
			},
			{
				id: 1,
				texture: Res.texture.brush.brush_1.toTexture(),
				bmp: Res.texture.brush.brush_1.toBitmap(),
				tile: Res.texture.brush.brush_1.toTile()
			},
			{
				id: 2,
				texture: Res.texture.brush.brush_2.toTexture(),
				bmp: Res.texture.brush.brush_2.toBitmap(),
				tile: Res.texture.brush.brush_2.toTile()
			},
			{
				id: 3,
				texture: Res.texture.brush.brush_3.toTexture(),
				bmp: Res.texture.brush.brush_3.toBitmap(),
				tile: Res.texture.brush.brush_3.toTile()
			},
			{
				id: 4,
				texture: Res.texture.brush.brush_4.toTexture(),
				bmp: Res.texture.brush.brush_4.toBitmap(),
				tile: Res.texture.brush.brush_4.toTile()
			},
			{
				id: 5,
				texture: Res.texture.brush.brush_5.toTexture(),
				bmp: Res.texture.brush.brush_5.toBitmap(),
				tile: Res.texture.brush.brush_5.toTile()
			},
			{
				id: 6,
				texture: Res.texture.brush.brush_6.toTexture(),
				bmp: Res.texture.brush.brush_6.toBitmap(),
				tile: Res.texture.brush.brush_6.toTile()
			},
			{
				id: 7,
				texture: Res.texture.brush.brush_7.toTexture(),
				bmp: Res.texture.brush.brush_7.toBitmap(),
				tile: Res.texture.brush.brush_7.toTile()
			}
		];
	}
}

typedef Brush = {
	var id(default, never):Int;
	var texture(default, never):Texture;
	var bmp(default, never):BitmapData;
	var tile(default, never):Tile;
}
package levelup.util;

import haxe.crypto.Base64;
import hxd.BitmapData;
import hxd.PixelFormat;
import hxd.Pixels;
import levelup.game.GameState.AdventureConfig;
import levelup.game.GameState.TerrainLayerInfo;
import coconut.Ui.hxx;
/**
 * ...
 * @author Krisztian Somoracz
 */
class AdventurePreviewGenerator
{
	public static function generate(adv:AdventureConfig)
	{
		var layerCount = 0;
		var createStyle = function(layer:TerrainLayerInfo):Dynamic {
			var style:Dynamic = {
				"background-image": "url(" + TerrainAssets.getTerrain(layer.textureId).previewUrl + ")"
			}

			if (layerCount > 0)
			{
				var bmp = new BitmapData(200, 200);
				bmp.fill(0, 0, bmp.width, bmp.height, 0x00000000);
				bmp.setPixels(new Pixels(bmp.width, bmp.height, Base64.decode(layer.texture), PixelFormat.RGBA));

				Reflect.setField(style, "-webkit-mask-image", "url(data:image/jpeg;base64" + bmp.toNative().canvas.toDataURL("image/png") + ")");
			}

			layerCount++;

			return style;
		};

		return hxx('
			<div class="lu_adventure_editor__adventure_container">
				<for {layer in adv.worldConfig.terrainLayers}>
					<div
						class="lu_adventure_editor__adventure_layer"
						style={createStyle(layer)}
					>
					</div>
				</for>
			</div>
		');
	}
}
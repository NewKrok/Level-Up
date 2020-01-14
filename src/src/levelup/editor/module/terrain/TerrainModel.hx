package levelup.editor.module.terrain;

import coconut.data.Model;
import levelup.editor.module.heightmap.HeightMapModel.BrushType;
import tink.CoreApi.Option;
import tink.pure.List;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TerrainModel implements Model
{
	@:editable var selectedBrushId:Int = 0;
	@:editable var brushSize:Float = 2;
	@:editable var brushOpacity:Float = 1;
	@:editable var brushGradient:Float = 0;
	@:editable var brushNoise:Float = 0;
	@:editable var brushType:BrushType = Up;
	@:editable var layers:List<TerrainLayer> = [];
	@:editable var selectedLayer:TerrainLayer = null;

	@:computed var selectedLayerIndex:Int = layers.length == 0 ? 0 : layers.toArray().indexOf(selectedLayer);

	public function addLayer(forceId:String = null, uvScale:Float = 1)
	{
		addLayerCore(forceId, uvScale);
		if (layers.length == 1)
		{
			selectLayer(switch(layers.first()) { case Some(v): v; case _: null; });
		}
	}

	@:transition function selectLayer(l:TerrainLayer) return { selectedLayer: l };

	@:transition private function addLayerCore(forceId:String, uvScale:Float = 1) return {
		layers: layers.append({
			terrainId: new State<String>(forceId == null ? TerrainAssets.terrains[0].id : forceId),
			uvScale: new State<Float>(uvScale)
		})
	};

	@:transition function removeLayer(l:TerrainLayer)
	{
		var arr = layers.toArray();
		arr.remove(l);
		return { layers: List.fromArray(arr) };
	}
}

typedef TerrainLayer =
{
	var terrainId(default, never):State<String>;
	var uvScale(default, never):State<Float>;
}
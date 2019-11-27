package levelup.editor.module.terrain;

import coconut.data.Model;
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
	@:editable var layers:List<TerrainLayer> = [];
	@:editable var selectedLayer:TerrainLayer = null;

	@:computed var selectedLayerIndex:Int = layers.length == 0 ? 0 : layers.toArray().indexOf(selectedLayer);

	public function addLayer(forceId:String = null)
	{
		addLayerCore(forceId);
		if (layers.length == 1)
		{
			selectLayer(switch(layers.first()) { case Some(v): v; case _: null; });
		}
	}

	@:transition function selectLayer(l:TerrainLayer) return { selectedLayer: l };

	@:transition private function addLayerCore(forceId:String) return {
		layers: layers.append({ terrainId: new State<String>(forceId == null ? TerrainAssets.terrains[0].id : forceId) })
	};
}

typedef TerrainLayer =
{
	var terrainId(default, never):State<String>;
}
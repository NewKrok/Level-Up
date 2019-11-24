package levelup.editor.module.terrain;

import coconut.ui.View;
import js.html.SelectElement;
import levelup.Asset.AssetConfig;
import levelup.TerrainAssets.TerrainConfig;
import levelup.editor.EditorState.AssetItem;
import levelup.editor.module.terrain.TerrainModel.TerrainLayer;
import levelup.game.GameState.PlayerId;
import levelup.game.GameState.RaceId;
import levelup.component.Slider;
import tink.pure.List;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TerrainEditorView extends View
{
	@:attr var baseTerrainId:String;
	@:attr var changeBaseTerrainIdRequest:TerrainConfig->Void;
	@:attr var selectedBrushId:Int;
	@:attr var changeSelectedBrushRequest:Int->Void;
	@:attr var layers:List<TerrainLayer>;
	@:attr var selectedLayer:TerrainLayer;
	@:attr var selectLayer:TerrainLayer->Void;
	@:attr var addLayer:Void->Void;
	@:attr var changeBrushSize:Float->Void;
	@:attr var changeBrushOpacity:Float->Void;

	function render() '
		<div class="lu_editor__base_panel">
			<div class="lu_relative">
				<div class="lu_title"><i class="fas fa-paint-brush lu_right_offset"></i>Brushes</div>
				<div>
					<div class="lu_terrain_brush_selector">
						<for {i in 0...8}>
							<div
								class={"lu_terrain_brush_preview" + (selectedBrushId == i ? " lu_terrain_brush_preview--selected" : "")}
								style={"background-image: url(asset/img/brush/brush_" + i + ".png)"}
								onclick={() -> changeSelectedBrushRequest(i)}>
							</div>
						</for>
					</div>
				</div>
				<div class="lu_title"><i class="fas fa-paint-brush lu_right_offset"></i>Brush Settings</div>
				<div>
					<div class="lu_offset">
						<div class="lu_vertical_offset">
							<i class="fas fa-expand lu_right_offset"></i>Size
						</div>
						<Slider
							min={1}
							max={10}
							startValue={3}
							onChange=$changeBrushSize
						/>
					</div>
					<div class="lu_offset">
						<div class="lu_vertical_offset">
							<i class="fas fa-adjust lu_right_offset"></i>Opacity
						</div>
						<Slider
							min={0.05}
							max = {1}
							startValue={1}
							step={0.05}
							onChange=$changeBrushOpacity
						/>
					</div>
					<div class="lu_offset">
						<div class="lu_vertical_offset">
							<i class="fas fa-dot-circle lu_right_offset"></i>Gradient
						</div>
						<Slider
							min={0}
							max={100}
							onChange={e -> trace(e)}
						/>
					</div>
				</div>
				<div class="lu_title"><i class="fas fa-layer-group lu_right_offset"></i>Terrain Layers ({layers.length})</div>
				<div class="lu_relative">
					<for {l in layers}>
						<div
							class={"lu_terrain_layer" + (selectedLayer == l ? " lu_terrain_layer--selected" : "")}
							style={"background-image: url(asset/img/preview/terrain/" + l.terrainId + ".jpg)"}
							onclick={() -> selectLayer(l)}
						>
							<if {selectedLayer == l}>
								<i class="fas fa-palette lu_terrain_layer__selected_icon"></i>
							</if>
						</div>
					</for>
					<div class="lu_button lu_button--full" onclick=$addLayer>
						<i class="fas fa-plus-circle lu_right_offset"></i> Add Layer
					</div>
				</div>
			</div>
		</div>
	';
}
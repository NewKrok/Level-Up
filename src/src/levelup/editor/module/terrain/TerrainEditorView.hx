package levelup.editor.module.terrain;

import coconut.ui.View;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
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
	@:attr var changeBrushGradient:Float->Void;
	@:attr var changeBrushNoise:Float->Void;

	var isMouseDragActive:Bool = false;
	var dragStartPoint:SimplePoint = { x: 0, y: 0 };

	function render()
	{
		var layersArr = layers.toArray();
		layersArr.reverse();

		return hxx('
			<div class="lu_editor__base_panel">
				<div class="lu_relative lu_fill_height">
					<div class="lu_title"><i class="fas fa-paint-brush lu_right_offset"></i>Brushes</div>
					<div>
						<div class="lu_terrain_brush_selector">
							<div
								class={"lu_terrain_brush_preview lu_terrain_brush_preview--circle" + (selectedBrushId == 0 ? " lu_terrain_brush_preview--selected" : "")}
								onclick={() -> changeSelectedBrushRequest(0)}>
							</div>
							<div
								class={"lu_terrain_brush_preview" + (selectedBrushId == 1 ? " lu_terrain_brush_preview--selected" : "")}
								onclick={() -> changeSelectedBrushRequest(1)}>
							</div>
						</div>
					</div>
					<div class="lu_title"><i class="fas fa-sliders-h lu_right_offset"></i>Brush Settings</div>
					<div>
						<div class="lu_offset">
							<div class="lu_vertical_offset--s">
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
							<div class="lu_vertical_offset--s">
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
							<div class="lu_vertical_offset--s">
								<i class="fas fa-dot-circle lu_right_offset"></i>Gradient
							</div>
							<Slider
								min={0}
								max={0.9}
								startValue={0}
								step={0.05}
								onChange=$changeBrushGradient
							/>
						</div>
						<div class="lu_offset">
							<div class="lu_vertical_offset--s">
								<i class="fas fa-chess-board lu_right_offset"></i>Noise
							</div>
							<Slider
								min={0}
								max={0.9}
								startValue={0}
								step={0.05}
								onChange=$changeBrushNoise
							/>
						</div>
					</div>
					<div class="lu_title"><i class="fas fa-layer-group lu_right_offset"></i>
						Terrain Layers ({layers.length})
					</div>
					<div class="lu_relative lu_terrain_layer_list_container">
						<div class="lu_button lu_button--full" onclick=$addLayer>
							<i class="fas fa-plus-circle lu_right_offset"></i> Add Layer
						</div>
						<div class="lu_col lu_terrain_layer_list">
							<for {i in 0...layersArr.length}>
								<div
									class={"lu_terrain_layer" + (selectedLayer == layersArr[i] ? " lu_terrain_layer--selected" : "")}
									style={"background-image: url(" + TerrainAssets.getTerrain(layersArr[i].terrainId).previewUrl + ")"}
									onclick={() -> selectLayer(layersArr[i])}
								>
									<if {selectedLayer == layersArr[i]}>
										<i class="fas fa-palette lu_terrain_layer__selected_icon"></i>
									</if>
									<if {i == layersArr.length - 1}>
										<i class="fas fa-lock lu_terrain_layer__locked_icon"></i>
									<else>
										<i class="fas fa-bars lu_terrain_layer__drag_icon"
											onmousedown=$startDrag
											onmousemove=$checkDrag
										></i>
									</if>
								</div>
							</for>
						</div>
					</div>
				</div>
			</div>
		');
	}

	function startDrag(e)
	{
		dragStartPoint.x = e.clientX;
		dragStartPoint.y = e.clientY;
		isMouseDragActive = true;
	}

	function stopDrag(e) isMouseDragActive = true;

	function checkDrag(e)
	{
		if (isMouseDragActive)
		{
			if (e.clientY - dragStartPoint.y > 10) trace("up");
			else if (e.clientY - dragStartPoint.y < 10) trace("down");
		}
	}
}
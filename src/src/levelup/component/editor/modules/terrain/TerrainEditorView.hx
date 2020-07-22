package levelup.component.editor.modules.terrain;
import levelup.component.editor.modules.heightmap.HeightMapModel;

import coconut.ui.View;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import js.html.SelectElement;
import levelup.Asset.AssetConfig;
import levelup.TerrainAssets.TerrainConfig;
import levelup.editor.EditorState.AssetItem;
import levelup.component.editor.modules.heightmap.HeightMapModel.BrushType;
import levelup.component.editor.modules.terrain.TerrainModel.TerrainLayer;
import levelup.component.form.slider.Slider;
import tink.pure.List;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TerrainEditorView extends View
{
	@:attr var selectedBrushId:Int;
	@:attr var changeSelectedBrushRequest:Int->Void;
	@:attr var layers:List<TerrainLayer>;
	@:attr var selectedLayer:TerrainLayer;
	@:attr var selectLayer:TerrainLayer->Void;
	@:attr var openTerrainSelector:TerrainLayer->Void;
	@:attr var addLayer:Void->Void;
	@:attr var changeBrushSize:Float->Void;
	@:attr var changeBrushOpacity:Float->Void;
	@:attr var changeBrushGradient:Float->Void;
	@:attr var changeBrushNoise:Float->Void;
	@:attr var changeLayerUVScale:TerrainLayer->Float->Void;
	@:attr var deleteLayer:TerrainLayer->Int->Void;
	@:attr var brushType:BrushType;
	@:attr var changeBrushType:BrushType->Void;

	var isMouseDragActive:Bool = false;
	var dragStartPoint:SimplePoint = { x: 0, y: 0 };

	function render()
	{
		var layersArr = layers.toArray();
		layersArr.reverse();

		return hxx('
			<div class="lu_editor__properties">
				<div class="lu_title">
					<i class="fas fa-paint-brush lu_right_offset"></i>Terrain painter
				</div>
				<div class="lu_editor__properties__block">
					<div class="lu_bottom_offset">
						<i class="fas fa-sliders-h lu_right_offset"></i>Brush shapes
					</div>
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
				<div class="lu_editor__properties__block">
					<div class="lu_bottom_offset">
						<i class="fas fa-sliders-h lu_right_offset"></i>Brush types
					</div>
					<div class="lu_row lu_row--space_evenly lu_text--l">
						<i class={"fas fa-pen" + (brushType == BrushType.Up ? " lu_highlight" : "")} onclick=${changeBrushType(BrushType.Up)}></i>
						<i class={"fas fa-eraser" + (brushType == BrushType.Down ? " lu_highlight" : "")}  onclick=${changeBrushType(BrushType.Down)}></i>
					</div>
				</div>
				<div class="lu_editor__properties__block">
					<div class="lu_bottom_offset">
						<i class="fas fa-sliders-h lu_right_offset"></i>Brush size
					</div>
					<Slider
						min={1}
						max={10}
						startValue={3}
						onChange=$changeBrushSize
					/>
				</div>
				<div class="lu_editor__properties__block">
					<div class="lu_bottom_offset">
						<i class="fas fa-sliders-h lu_right_offset"></i>Brush opacity
					</div>
					<Slider
						min={0.05}
						max = {1}
						startValue={1}
						step={0.05}
						onChange=$changeBrushOpacity
					/>
				</div>
				<div class="lu_editor__properties__block">
					<div class="lu_bottom_offset">
						<i class="fas fa-sliders-h lu_right_offset"></i>Brush gradient
					</div>
					<Slider
						min={0}
						max={1}
						startValue={0}
						step={0.05}
						onChange=$changeBrushGradient
					/>
				</div>
				<div class="lu_editor__properties__block">
					<div class="lu_bottom_offset">
						<i class="fas fa-sliders-h lu_right_offset"></i>Brush noise
					</div>
					<Slider
						min={0}
						max={0.9}
						startValue={0}
						step={0.05}
						onChange=$changeBrushNoise
					/>
				</div>
				<div class="lu_editor__properties__block lu_editor__properties__block--header">
					<div>
						<i class="fas fa-layer-group lu_right_offset"></i>Terrain Layers ({layers.length})
					</div>
					<div class="lu_button lu_button--full" onclick=$addLayer>
						<i class="fas fa-plus-circle lu_right_offset"></i> Add Layer
					</div>
				</div>
				<div class="lu_editor__properties__block lu_editor__properties__block--content lu_terrain_layer_list_container">
					<div class="lu_col lu_terrain_layer_list">
						<for {i in 0...layersArr.length}>
							<div
								class={"lu_terrain_layer" + (selectedLayer == layersArr[i] ? " lu_terrain_layer--selected" : "")}
								onclick={() -> {selectLayer(layersArr[i]);}}
							>
								<div
									class={"lu_terrain_layer__preview"}
									style={"background-image: url(" + TerrainAssets.getTerrain(layersArr[i].terrainId).previewUrl + ")"}
								></div>
								<if {i == layersArr.length - 1}>
									<i class="fas fa-lock lu_terrain_layer__locked_icon"></i>
								</if>
								<div class="lu_terrain_layer__control_bar">
									<i class="fas fa-palette lu_terrain_layer__control_button"
										onclick={() -> openTerrainSelector(layersArr[i])}
									></i>
									<if {i != layersArr.length - 1}>
										<i class="fas fa-trash lu_warning lu_terrain_layer__control_button"
											onclick={e -> deleteLayer(layersArr[i], layersArr.length - 1 - i)}
										></i>
										<i class="fas fa-bars lu_terrain_layer__control_button"
											onmousedown=$startDrag
											onmousemove=$checkDrag
										></i>
									</if>
								</div>
								<Slider
									className="lu_terrain_slider"
									min={0.3}
									max={5}
									startValue={layersArr[i].uvScale}
									step={0.1}
									onChange={v -> changeLayerUVScale(layersArr[i], v)}
								/>
							</div>
						</for>
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
			if (e.clientY - dragStartPoint.y > 10) trace("down");
			else if (e.clientY - dragStartPoint.y < 10) trace("up");
		}
	}
}
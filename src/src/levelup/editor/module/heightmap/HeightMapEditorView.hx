package levelup.editor.module.heightmap;

import coconut.ui.View;
import js.html.SelectElement;
import levelup.Asset.AssetConfig;
import levelup.TerrainAssets.TerrainConfig;
import levelup.editor.EditorState.AssetItem;
import levelup.editor.module.heightmap.HeightMapModel.BrushType;
import levelup.editor.module.terrain.TerrainModel.TerrainLayer;
import levelup.game.GameState.PlayerId;
import levelup.component.Slider;
import tink.pure.List;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HeightMapEditorView extends View
{
	@:attr var selectedBrushId:Int;
	@:attr var drawSpeed:Float;
	@:attr var brushSize:Float;
	@:attr var brushOpacity:Float;
	@:attr var brushGradient:Float;
	@:attr var brushNoise:Float;
	@:attr var changeSelectedBrushRequest:Int->Void;
	@:attr var changeDrawSpeed:Float->Void;
	@:attr var changeBrushSize:Float->Void;
	@:attr var changeBrushOpacity:Float->Void;
	@:attr var changeBrushGradient:Float->Void;
	@:attr var changeBrushNoise:Float->Void;
	@:attr var brushType:BrushType;
	@:attr var changeBrushType:BrushType->Void;

	function render() '
		<div class="lu_editor__properties__container">
			<div class="lu_title">
				<i class="fas fa-map lu_right_offset"></i>Heightmap editor
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
					<i class={"lu_icon_button fas fa-chevron-circle-up" + (brushType == BrushType.Up ? " lu_icon_button--selected" : "")} onclick=${changeBrushType(BrushType.Up)}></i>
					<i class={"lu_icon_button fas fa-chevron-circle-down" + (brushType == BrushType.Down ? " lu_icon_button--selected" : "")}  onclick=${changeBrushType(BrushType.Down)}></i>
					<i class={"lu_icon_button fas fa-minus-circle" + (brushType == BrushType.Flat ? " lu_icon_button--selected" : "")}  onclick=${changeBrushType(BrushType.Flat)}></i>
					<i class={"lu_icon_button fas fa-dot-circle" + (brushType == BrushType.Smooth ? " lu_icon_button--selected" : "")}  onclick=${changeBrushType(BrushType.Smooth)}></i>
				</div>
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-sliders-h lu_right_offset"></i>Draw Speed
				</div>
				<Slider
					min={0}
					max={99}
					startValue={drawSpeed}
					step={1}
					onChange=$changeDrawSpeed
				/>
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-sliders-h lu_right_offset"></i>Brush size
				</div>
				<Slider
					min={1}
					max={19}
					startValue={brushSize}
					step={1}
					onChange=$changeBrushSize
				/>
			</div>
			<if {brushType != BrushType.Smooth && brushType != BrushType.Flat}>
				<div class="lu_editor__properties__block">
					<div class="lu_bottom_offset">
						<i class="fas fa-sliders-h lu_right_offset"></i>Height
					</div>
					<Slider
						min={0.0025}
						max = {0.05}
						startValue={brushOpacity}
						step={0.0001}
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
						startValue={brushGradient}
						step={0.1}
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
						startValue={brushNoise}
						step={0.05}
						onChange=$changeBrushNoise
					/>
				</div>
			</if>
		</div>
	';
}
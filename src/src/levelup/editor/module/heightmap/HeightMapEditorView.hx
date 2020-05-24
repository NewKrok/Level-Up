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
		<div class="lu_editor__base_panel lu_editor__base_panel--height_map">
			<div class="lu_relative lu_fill_height">
				<div class="lu_title">Brush Shapes</div>
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
				<div class="lu_title">Brush Modes</div>
				<div>
					<div class="lu_offset">
						<div class="lu_row lu_row--space_evenly lu_text--l">
							<i class={"lu_icon_button fas fa-chevron-circle-up" + (brushType == BrushType.Up ? " lu_icon_button--selected" : "")} onclick=${changeBrushType(BrushType.Up)}></i>
							<i class={"lu_icon_button fas fa-chevron-circle-down" + (brushType == BrushType.Down ? " lu_icon_button--selected" : "")}  onclick=${changeBrushType(BrushType.Down)}></i>
							<i class={"lu_icon_button fas fa-minus-circle" + (brushType == BrushType.Flat ? " lu_icon_button--selected" : "")}  onclick=${changeBrushType(BrushType.Flat)}></i>
							<i class={"lu_icon_button fas fa-dot-circle" + (brushType == BrushType.Smooth ? " lu_icon_button--selected" : "")}  onclick=${changeBrushType(BrushType.Smooth)}></i>
						</div>
					</div>
				</div>
					<div class="lu_title">Settings</div>
				<div>
					<div class="lu_offset">
						<div class="lu_vertical_offset--s">
							<i class="fas fa-ellipsis-h lu_right_offset"></i>Draw Speed
						</div>
						<Slider
							min={0}
							max={99}
							startValue={drawSpeed}
							step={1}
							onChange=$changeDrawSpeed
						/>
					</div>
					<div class="lu_offset">
						<div class="lu_vertical_offset--s">
							<i class="fas fa-expand lu_right_offset"></i>Size
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
						<div class="lu_offset">
							<div class="lu_vertical_offset--s">
								<i class="fas fa-caret-up lu_right_offset"></i>Height
							</div>
							<Slider
								min={0.0025}
								max = {0.01}
								startValue={brushOpacity}
								step={0.0001}
								onChange=$changeBrushOpacity
							/>
						</div>
						<div class="lu_offset">
							<div class="lu_vertical_offset--s">
								<i class="fas fa-dot-circle lu_right_offset"></i>Gradient
							</div>
							<Slider
								min={0}
								max={1}
								startValue={brushGradient}
								step={0.1}
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
								startValue={brushNoise}
								step={0.05}
								onChange=$changeBrushNoise
							/>
						</div>
					</if>
				</div>
			</div>
		</div>
	';
}
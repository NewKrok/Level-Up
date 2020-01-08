package levelup.editor.module.heightmap;

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
class HeightMapEditorView extends View
{
	@:attr var selectedBrushId:Int;
	@:attr var changeSelectedBrushRequest:Int->Void;
	@:attr var changeDrawSpeed:Float->Void;
	@:attr var changeBrushSize:Float->Void;
	@:attr var changeBrushOpacity:Float->Void;
	@:attr var changeBrushGradient:Float->Void;
	@:attr var changeBrushNoise:Float->Void;

	function render() '
		<div class="lu_editor__base_panel lu_editor__base_panel--height_map">
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
							<i class="fas fa-ellipsis-h lu_right_offset"></i>Draw Speed
						</div>
						<Slider
							min={0}
							max={99}
							startValue={90}
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
							startValue={3}
							step={2}
							onChange=$changeBrushSize
						/>
					</div>
					<div class="lu_offset">
						<div class="lu_vertical_offset--s">
							<i class="fas fa-caret-up lu_right_offset"></i>Height
						</div>
						<Slider
							min={0.001}
							max = {0.5}
							startValue={0.001}
							step={0.001}
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
							startValue={0}
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
							startValue={0}
							step={0.05}
							onChange=$changeBrushNoise
						/>
					</div>
				</div>
				<div class="lu_title lu_height_map__title"><i class="fas fa-map lu_right_offset"></i>Height Map</div>
			</div>
		</div>
	';
}
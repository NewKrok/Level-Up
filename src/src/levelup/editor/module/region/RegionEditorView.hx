package levelup.editor.module.region;

import coconut.ui.View;
import levelup.game.GameWorld.Region;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class RegionEditorView extends View
{
	@:skipCheck @:attr var regions:Array<Region>;
	@:attr var addRegion:Int->Void;

	@:state var selectedType:Int = 0;

	function render()
	{
		return hxx('
			<div class="lu_editor__base_panel">
				<div class="lu_relative lu_fill_height">
					<div class="lu_title">Region Editor</div>
					<div>
						<div class="lu_terrain_brush_selector">
							<div
								class={"lu_terrain_brush_preview lu_terrain_brush_preview--circle" + (selectedType == 0 ? " lu_terrain_brush_preview--selected" : "")}
								onclick={() -> selectedType = 0}>
							</div>
							<div
								class={"lu_terrain_brush_preview" + (selectedType == 1 ? " lu_terrain_brush_preview--selected" : "")}
								onclick={() -> selectedType = 1}>
							</div>
						</div>
					</div>
					<div class="lu_title"><i class="fas fa-layer-group lu_right_offset"></i>
						Regions
					</div>
					<div class="lu_relative lu_terrain_layer_list_container">
						<div class="lu_button lu_button--full" onclick=${addRegion(selectedType)}>
							<i class="fas fa-plus-circle lu_right_offset"></i> Add Region
						</div>
						<div class="lu_col lu_terrain_layer_list">
							<for {r in regions}>
								<div>{r.name}</div>
							</for>
						</div>
					</div>
				</div>
			</div>
		');
	}
}
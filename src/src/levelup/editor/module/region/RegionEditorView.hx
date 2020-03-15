package levelup.editor.module.region;

import coconut.ui.View;
import coconut.data.List;
import levelup.game.GameWorld.Region;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class RegionEditorView extends View
{
	@:skipCheck @:attr var regions:List<Region>;
	@:attr var addRegion:Int->Void;

	function render()
	{
		return hxx('
			<div class="lu_editor__base_panel">
				<div class="lu_relative lu_fill_height">
					<div class="lu_title"><i class="fas fa-object-ungroup lu_right_offset"></i>
						Regions
					</div>
					<div class="lu_relative lu_terrain_layer_list_container">
						<if {regions.length == 0}>
							<div class="lu_offset">
								You don\'t have any regions yet. <span class="lu_highlight">You can draw it with mouse</span>.
							</div>
							<div class="lu_offset">
								<i class="fas fa-info-circle"></i> Regions are useful for defining positions on the map like spawn point for a MOBA game.
							</div>
						<else>
							<ul>
								<for {r in regions}>
									<li class="lu_list_element">{r.name}</li>
								</for>
							</ul>
						</if>
					</div>
				</div>
			</div>
		');
	}
}
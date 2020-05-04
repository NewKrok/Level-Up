package levelup.editor.module.camera;

import coconut.ui.View;
import coconut.data.List;
import levelup.editor.module.camera.CameraModel.EditorCamera;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CameraEditorView extends View
{
	@:skipCheck @:attr var cameras:List<EditorCamera>;
	@:attr var addCamera:Void->Void;

	function render()
	{
		return hxx('
			<div class="lu_editor__base_panel">
				<div class="lu_relative lu_fill_height">
					<div class="lu_title"><i class="fas fa-object-ungroup lu_right_offset"></i>
						Regions
					</div>
					<div class="lu_relative lu_terrain_layer_list_container">
						<if {cameras.length == 0}>
							<div class="lu_offset">
								You don\'t have any camera yet. <span class="lu_highlight">You can add it with the "Create Camera" button</span>.
							</div>
							<div class="lu_offset">
								<i class="fas fa-info-circle"></i> Cameras are useful for defining custom view points in the map which will enable for you for example to create an in-game cinematics for your game.
							</div>
						<else>
							<ul>
								<for {c in cameras}>
									<li class="lu_list_element">{c.name}</li>
								</for>
							</ul>
						</if>
					</div>
				</div>
			</div>
		');
	}
}
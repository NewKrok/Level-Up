package levelup.editor.module.camera;

import coconut.ui.View;
import coconut.data.List;
import com.greensock.TweenMax;
import hxd.Key;
import js.html.InputElement;
import js.html.KeyboardEvent;
import levelup.core.camera.ActionCamera.CameraData;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CameraEditorView extends View
{
	@:skipCheck @:attr var cameras:List<CameraData>;
	@:attr var addCamera:Void->Void;
	@:attr var removeCamera:String->Void;
	@:attr var jumpToCamera:CameraData->Void;
	@:attr var changeCamName:String->String->Void;

	@:state var selectedCamera:String = "";
	@:state var newCamName:String = "";

	@:ref var selectedInput:InputElement;

	function render()
	{
		return hxx('
			<div class="lu_editor__properties__container">
				<div class="lu_title">
					<i class="fas fa-video lu_horizontal_offset"></i>Camera editor
				</div>
				<div class="lu_editor__properties__block lu_editor_camera__add_button" onclick=$addCamera>
					<i class="fas fa-plus-circle lu_right_offset"></i> Add Camera
				</div>
				<div class="lu_editor__properties__block">
					<if {cameras.length == 0}>
						<div class="lu_offset">
							You don\'t have any camera yet. <span class="lu_highlight">You can add it with the "Add Camera" button</span>.
						</div>
						<div class="lu_offset">
							<i class="fas fa-info-circle"></i> Cameras are useful for defining custom view points in the map which will enable for you for example to create an in-game cinematics for your game.
						</div>
					<else>
						<div class="lu_bottom_offset">
							<i class="fas fa-list lu_right_offset"></i>Cameras
						</div>
						<div class="lu_editor_camera__list">
							<for {c in cameras}>
								<div onClick={jumpToCamera(c)} class="lu_editor_camera__list_element lu_row lu_row--space_between">
									<if {c.name == selectedCamera}>
										<input
											class="lu_input"
											ref=$selectedInput
											type="text"
											value={newCamName}
											maxLength={100}
											onchange={e -> newCamName = e.currentTarget.value}
											onblur=$onBlur
											onkeyup=$onKeyUp
										/>
									<else>
										{c.name}
									</if>
									<div class="lu_row">
										<i class="fas fa-edit lu_editor_camera__edit_button lu_right_offset" onclick={e -> { selectedCamera = c.name; newCamName = c.name; TweenMax.delayedCall(0.1, inputFocus); }}></i>
										<i class="fas fa-trash lu_editor_camera__remove_button" onclick={e -> removeCamera(c.name)}></i>
									</div>
								</div>
							</for>
						</div>
					</if>
				</div>
			</div>
		');
	}

	function inputFocus() if (selectedInput != null) selectedInput.focus();
	function onKeyUp(e:KeyboardEvent) if (e.keyCode == Key.ENTER) onBlur();

	function onBlur()
	{
		if (selectedInput != null) saveCamNameRequest();
		selectedCamera = "";
	}

	function saveCamNameRequest()
	{
		if (selectedInput != null)
		{
			newCamName = selectedInput.value;
			var isNew:Bool = true;

			for (c in cameras) if (c.name == newCamName)
			{
				isNew = false;
				break;
			}

			if (isNew) changeCamName(selectedCamera, newCamName);

			selectedCamera = "";
			newCamName = "";
		}
	}
}
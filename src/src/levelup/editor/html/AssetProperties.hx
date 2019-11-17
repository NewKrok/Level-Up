package levelup.editor.html;

import coconut.ui.View;
import levelup.editor.EditorState.AssetItem;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AssetProperties extends View
{
	@:skipCheck @:attr var asset:AssetItem = null;

	function render() '
		<div class="lu_selected_item">
			<div class="lu_title"><i class="fas fa-clipboard-check lu_right_offset"></i>Selected Item</div>
			<ul>
				<li class="lu_list_element">
					<div>Name</div>
					<div>{asset.config.name.replace("SM_", "").replace("_", " ")}</div>
				</li>
				<li class="lu_list_element">
					<div>Position</div>
					<div>x: {round(asset.instance.y)} y: {round(asset.instance.x)} z: {round(asset.instance.z)}</div>
				</li>
				<li class="lu_list_element">
					<div>Rotation</div>
					<div>{asset.instance.getRotationQuat().toString()}</div>
				</li>
				<li class="lu_list_element">
					<div>Scale</div>
					<div>{round(asset.instance.scaleX / asset.config.scale)}</div>
				</li>
			</ul>
		</div>
	';

	function round(num:Float) return Math.floor(num * 100) / 100;
}
package levelup.editor.html;

import coconut.ui.View;
import levelup.Asset.AssetConfig;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorPreview extends View
{
	@:skipCheck @:attr var assetConfig:AssetConfig = null;

	function render() '
		<div class="lu_editor__preview">
			<div class="lu_title"><i class="fas fa-eye lu_right_offset"></i>Preview</div>
			<if {assetConfig != null && assetConfig.previewUrl != null}>
				<img class="lu_editor__preview_image" src={assetConfig.previewUrl}/>
			<else>
				<div class="lu_editor__empty_preview"><i class="fas fa-eye-slash"></i></div>
			</if>
		</div>
	';
}
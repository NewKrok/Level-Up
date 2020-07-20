package levelup.component.editor.modules.skybox;

import coconut.ui.View;
import hpp.util.Language;
import levelup.SkyboxData.SkyboxAssetConfig;
import levelup.component.Slider;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SkyboxView extends View
{
	@:attr var selectedSkybox:String;
	@:attr var isSkyboxLoadingInProgress:Bool;
	@:attr var setSkyboxZOffset:Float->Void;
	@:attr var setSkyboxRotation:Float->Void;
	@:attr var setSkyboxScale:Float->Void;
	@:attr var changeSkyBox:SkyboxAssetConfig->Void;

	function render() '
		<div class="lu_editor__properties">
			<div class="lu_title">
				<i class="fas fa-cloud-moon lu_right_offset"></i>Skybox settings
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-arrows-alt-v lu_right_offset"></i>Vertical Offset
				</div>
				<Slider
					min={-100}
					max={100}
					startValue={0}
					step={1}
					onChange=$setSkyboxZOffset
				/>
			</div>
			{/**<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-sync-alt lu_right_offset"></i>Rotation
				</div>
				<Slider
					min={0}
					max={Math.PI * 2}
					startValue={0}
					step={Math.PI / 90}
					onChange=$setSkyboxRotation
				/>
			</div>*/}
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-expand-alt lu_right_offset"></i>Scale
				</div>
				<Slider
					min={0.1}
					max={4}
					startValue={1}
					step={0.05}
					onChange=$setSkyboxScale
				/>
			</div>
			<div class="lu_editor__properties__block lu_editor__properties__block--header">
				<div class="lu_bottom_offset">
					<i class="fas fa-images lu_right_offset"></i>Select skybox
				</div>
			</div>
			<div class="lu_editor__properties__block lu_editor__properties__block--content">
				<div class="lu_editor_skybox__list">
					<for {skybox in SkyboxData.config}>
						<div class={"lu_editor_skybox__list_element"
								+ (selectedSkybox == skybox.id ? " lu_editor_skybox__list_element--selected" : "")
								+ (isSkyboxLoadingInProgress ? " lu_editor_skybox__list_element--disabled" : "")
							}
						>
							<img
								class={"lu_editor_skybox__list_element__image"
									+ (isSkyboxLoadingInProgress ? " lu_editor_skybox__list_element__image--disabled" : "")
								}
								src={skybox.assets[1]}
								onClick={changeSkyBox(skybox)}
							/>
							<div
								class={"lu_editor_skybox__list_element_loader"
									+ (selectedSkybox == skybox.id && isSkyboxLoadingInProgress ? " lu_editor_skybox__list_element_loader--active" : "")
								}
							>
								<div class="lu_circle_loader lu_circle_loader--s"></div>
							</div>
						</div>
					</for>
				</div>
			</div>
		</div>
	';
}
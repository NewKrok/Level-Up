package levelup.editor.module.skybox;

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
	@:attr var changeSkyBox:SkyboxAssetConfig->Void;

	function render() '
		<div class="lu_editor_skybox">
			<div class="lu_title">
				<i class="fas fa-cloud-moon lu_horizontal_offset"></i>Skybox settings
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-arrows-alt-v lu_right_offset"></i>Z-Offset
				</div>
				<Slider
					min={0}
					max={100}
					startValue={50}
					step={1}
					onChange={null}
				/>
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-sync-alt lu_right_offset"></i>Rotation
				</div>
				<Slider
					min={0}
					max={100}
					startValue={50}
					step={1}
					onChange={null}
				/>
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-images lu_right_offset"></i>Select skybox
				</div>
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
package levelup.component.editor.modules.skybox;

import coconut.ui.View;
import hpp.util.Language;
import levelup.SkyboxData.SkyboxAssetConfig;
import levelup.component.form.slider.Slider;

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
				<i class="fas fa-cloud-moon lu_icon"></i>{Language.get("editor.skybox.title")}
			</div>
			<div class="lu_block">
				<div class="lu_sub-title">
					<i class="fas fa-sliders-h lu_icon"></i>{Language.get("common.general")}
				</div>
				<div class="lu_entry">
					{Language.get("editor.skybox.voffset")}
					<Slider
						min={-100}
						max={100}
						startValue={0}
						step={1}
						onChange=$setSkyboxZOffset
					/>
				</div>
				<div class="lu_entry">
					{Language.get("editor.skybox.scale")}
					<Slider
						min={0.1}
						max={4}
						startValue={1}
						step={0.001}
						onChange=$setSkyboxScale
					/>
				</div>
			</div>
			<div class="lu_block">
				<div class="lu_sub-title">
					<i class="fas fa-sliders-h lu_icon"></i>{Language.get("editor.skybox.select")}
				</div>
				<div class="lu_entry">
					<div class="lu_skybox__list">
						<for {skybox in SkyboxData.config}>
							<div key={skybox.id} class={"lu_skybox"
									+ (selectedSkybox == skybox.id ? " lu_skybox--selected" : "")
									+ (isSkyboxLoadingInProgress ? " lu_skybox--disabled" : "")
								}
							>
								<img
									class={"lu_skybox__image"
										+ (isSkyboxLoadingInProgress ? " lu_skybox__image--disabled" : "")
									}
									src={skybox.assets[1]}
									onClick={changeSkyBox(skybox)}
								/>
								<div
									class={"lu_skybox__loader"
										+ (selectedSkybox == skybox.id && isSkyboxLoadingInProgress ? " lu_skybox__loader--active" : "")
									}
								>
									<div class="lu_circle_loader lu_circle_loader--s"></div>
								</div>
							</div>
						</for>
					</div>
				</div>
			</div>
		</div>
	';
}
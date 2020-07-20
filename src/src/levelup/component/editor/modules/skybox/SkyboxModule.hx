package levelup.component.editor.modules.skybox;

import coconut.ui.RenderResult;
import h3d.Matrix;
import h3d.Vector;
import levelup.editor.EditorState.EditorCore;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class SkyboxModule
{
	var core:EditorCore = _;

	var view:RenderResult;

	var isSkyboxLoadingInProgress:State<Bool> = new State<Bool>(false);
	var selectedSkybox:State<String> = new State<String>("");
	var skyboxZOffset:State<Float> = new State<Float>(0);
	var skyboxRotation:State<Float> = new State<Float>(0);
	var skyboxScale:State<Float> = new State<Float>(1);

	public function new()
	{
		core.model.registerModule({
			id: "SkyboxModule",
			icon: "fa-cloud-moon",
			instance: cast this
		});

		selectedSkybox.set(core.adventureConfig.worldConfig.skybox.id);
		skyboxZOffset.set(core.adventureConfig.worldConfig.skybox.zOffset);
		skyboxRotation.set(core.adventureConfig.worldConfig.skybox.rotation);
		skyboxScale.set(core.adventureConfig.worldConfig.skybox.scale);

		view = SkyboxView.fromHxx({
			selectedSkybox: selectedSkybox,
			isSkyboxLoadingInProgress: isSkyboxLoadingInProgress,
			setSkyboxZOffset: v -> {
				skyboxZOffset.set(v);
				core.world.skybox.z = v;
			},
			setSkyboxRotation: v -> {
				skyboxRotation.set(v);
				// TODO: why it doesn't work
				core.world.skybox.setRotation(v, v, v);
			},
			setSkyboxScale: v -> {
				skyboxScale.set(v);
				core.world.skybox.setScale(v);
			},
			changeSkyBox: skyboxAssetConfig -> {
				isSkyboxLoadingInProgress.set(true);
				selectedSkybox.set(skyboxAssetConfig.id);
				AssetCache.instance.loadImages(skyboxAssetConfig.assets).handle(o -> switch (o)
				{
					case Success(_):
						isSkyboxLoadingInProgress.set(false);
						core.world.createSkybox(skyboxAssetConfig.id);
						core.world.skybox.z = skyboxZOffset.value;
						//core.world.skybox.setRotation(skyboxRotation.value, skyboxRotation.value, skyboxRotation.value);
						core.world.skybox.setScale(skyboxScale.value);

					case Failure(e):
				});
			}
		});
	}

	public function getSkyboxData() return {
		id: selectedSkybox.value,
		zOffset: skyboxZOffset.value,
		rotation: skyboxRotation.value,
		scale: skyboxScale.value
	};
}
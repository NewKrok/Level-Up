package levelup.editor.module.skybox;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class SkyboxModule
{
	var core:EditorCore = _;

	var isSkyboxLoadingInProgress:State<Bool> = new State<Bool>(false);
	var selectedSkybox:State<String> = new State<String>("");

	public function new()
	{
		selectedSkybox.set(core.adventureConfig.worldConfig.skybox.id);

		core.registerView(EditorViewId.VSkyboxModule, SkyboxView.fromHxx({
			selectedSkybox: selectedSkybox,
			isSkyboxLoadingInProgress: isSkyboxLoadingInProgress,
			changeSkyBox: skyboxAssetConfig -> {
				isSkyboxLoadingInProgress.set(true);
				selectedSkybox.set(skyboxAssetConfig.id);
				AssetCache.instance.loadImages(skyboxAssetConfig.assets).handle(o -> switch (o)
				{
					case Success(_):
						isSkyboxLoadingInProgress.set(false);
						core.world.createSkybox(skyboxAssetConfig.id);

					case Failure(e):
				});
			}
		}));
	}
}
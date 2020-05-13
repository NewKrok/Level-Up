package levelup.mainmenu.html;

import coconut.ui.View;
import haxe.Json;
import levelup.game.GameState.AdventureConfig;
import levelup.util.AdventureParser;
import levelup.util.SaveUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AdventureEditorView extends View
{
	@:attr var openAdventureEditor:String->Void;

	var list:Array<AdventureConfig>;

	function render()
	{
		if (list == null) createList();

		return hxx('
			<div>
				<div class="lu_adventure_editor__block">
					<div class="lu_adventure_editor__title">
						Your local adventures
					</div>
					<div class="lu_adventure_editor__list">
						<div
							class="lu_adventure_editor__adventure"
							onClick={openAdventureEditor.bind(null)}
						>
							Create a new adventure in your local device...
						</div>
						<for {adv in list}>
							<div
								class="lu_adventure_editor__adventure"
								style={createBackground(adv)}
								onClick={openAdventureEditor.bind(adv.id)}
							>
								{adv.title}
							</div>
						</for>
					</div>
				</div>
				<div class="lu_adventure_editor__block">
					<div class="lu_adventure_editor__title">
						Your published adventures
					</div>
					<div class="lu_adventure_editor__list">
						<for {adv in list}>
							<div class="lu_adventure_editor__adventure">
								{adv.title}
							</div>
						</for>
					</div>
				</div>
			</div>
		');
	}

	function createList()
	{
		list = [];

		for (rawData in SaveUtil.editorData.customAdventures)
		{
			list.push(AdventureParser.loadLevel(rawData));
		}
	}

	function createBackground(adv:AdventureConfig)
	{
		return 'background: url("data:image/png;base64,' + adv.worldConfig.terrainLayers[0].texture + '")';
	}
}
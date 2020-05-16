package levelup.mainmenu.html;

import coconut.ui.View;
import levelup.game.GameState.AdventureConfig;
import levelup.util.AdventureParser;
import levelup.util.AdventurePreviewGenerator;
import levelup.util.SaveUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CustomAdventuresView extends View
{
	@:attr var openAdventure:String->Void;

	var list:Array<AdventureConfig>;

	function render()
	{
		if (list == null) createList();

		return hxx('
			<div>
				<div class="lu_adventure_editor__block">
					<div class="lu_adventure_editor__title">
						Your Own Adventures
					</div>
					<div class="lu_adventure_editor__list">
						<for {adv in list}>
							<div
								class="lu_adventure_editor__adventure"
								onClick={openAdventure.bind(adv.id)}
							>
								{AdventurePreviewGenerator.generate(adv)}
								<div class="lu_adventure_editor__adventure_title">
									{adv.title}
								</div>
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
}
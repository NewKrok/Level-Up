package levelup.mainmenu.html;

import coconut.ui.View;
import hpp.util.Language;
import levelup.game.GameState.AdventureConfig;
import levelup.util.AdventureParser;
import levelup.util.AdventurePreviewGenerator;
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
						{Language.get("Your Adventures")}
					</div>
					<div class="lu_adventure_editor__list">
						<div
							class="lu_adventure_editor__adventure"
							onClick={openAdventureEditor.bind(null)}
						>
							<i class="fas fa-plus-circle lu_adventure_editor__add_icon"></i>
							<div>{Language.get("Create new Adventure")}</div>
						</div>
						<for {adv in list}>
							<div
								class="lu_adventure_editor__adventure"
								onClick={openAdventureEditor.bind(adv.id)}
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
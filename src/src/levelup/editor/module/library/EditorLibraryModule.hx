package levelup.editor.module.library;

import levelup.Asset.AssetConfig;
import levelup.UnitData.RaceId;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class EditorLibraryModule
{
	var core:EditorCore = _;
	var previewRequest:AssetConfig->Void = _; // TODO Move this logic to here from the EditorState

	var view:EditorLibraryView;

	var selectedRace:State<RaceId> = new State<RaceId>(RaceId.Human);

	public function new()
	{
		// TODO remove selectedPlayer from the editor model
		view = new EditorLibraryView({
			previewRequest: previewRequest,
			selectedRace: selectedRace,
			setSelectedRace: v -> selectedRace.set(v),
			onPlayerSelect: id -> core.model.selectedPlayer = id,
			selectedPlayer: core.model.observables.selectedPlayer
		});

		core.registerView(EditorViewId.VEditorLibraryModule, view.reactify());
	}

	public function removeSelection() view.removeSelection();
}
package levelup.component.editor.modules.library;

import coconut.ui.RenderResult;
import levelup.Asset.AssetConfig;
import levelup.UnitData.RaceId;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class EditorLibraryModule
{
	var core:EditorCore = _;
	var previewRequest:AssetConfig->Void = _; // TODO Move this logic to here from the EditorState

	var typedView:EditorLibraryView;
	var view:RenderResult;

	var selectedRace:State<RaceId> = new State<RaceId>(RaceId.Human);

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MEditorLibrary,
			icon: "fa-folder-open",
			instance: cast this
		});

		// TODO remove selectedPlayer from the editor model
		typedView = new EditorLibraryView({
			previewRequest: previewRequest,
			selectedRace: selectedRace,
			setSelectedRace: v -> selectedRace.set(v),
			onPlayerSelect: id -> core.model.selectedPlayer = id,
			selectedPlayer: core.model.observables.selectedPlayer
		});

		view = typedView.reactify();
	}

	public function removeSelection() typedView.removeSelection();
}
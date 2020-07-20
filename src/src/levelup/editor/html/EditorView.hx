package levelup.editor.html;

import coconut.ui.RenderResult;
import coconut.ui.View;
import levelup.Asset.AssetConfig;
import levelup.component.fpsview.FpsView;
import levelup.editor.EditorModel;
import levelup.component.editor.header.Header;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorView extends View
{
	@:attr var backToLobby:Void->Void;
	@:attr var toggleFullScreen:Void->Void;
	@:attr var save:Void->Void;
	@:attr var createNewAdventure:Void->Void;
	@:attr var testRun:Void->Void;
	@:attr var model:EditorModel;

	@:ref var snapGridInfo:SnapGridInfo;

	function render() '
		<div class="lu_editor">
			<FpsView />
			{model.getView(EditorViewId.VDialogManager)}
			<Header
				backToLobby=$backToLobby
				toggleFullScreen=$toggleFullScreen
				createNewAdventure=$createNewAdventure
				save=$save
				testRun=$testRun
			/>
			{model.getView(EditorViewId.VEditorTools)}
			<if {model.selectedModule != null && model.selectedModule.instance.view != null}>
				{model.selectedModule.instance.view}
			</if>
			<div class="lu_editor_footer">
				<LockedDragInfo
					isXDragLocked={model.observables.isXDragLocked}
					isYDragLocked={model.observables.isYDragLocked}
					toggleXDragLock={model.toggleXDragLock}
					toggleYDragLock={model.toggleYDragLock}
				/>
				<SnapGridInfo
					ref={snapGridInfo}
					showGrid={model.observables.showGrid}
					toggleShowGrid={() -> model.showGrid = !model.showGrid}
					currentSnap={model.observables.currentSnap}
					changeSnap = {snap -> model.currentSnap = snap}
				/>
			</div>
		</div>
	';

	public function increaseSnap() snapGridInfo.increaseSnap();
}
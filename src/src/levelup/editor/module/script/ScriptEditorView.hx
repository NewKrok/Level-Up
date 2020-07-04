package levelup.editor.module.script;

import coconut.data.List;
import coconut.ui.RenderResult;
import coconut.ui.View;
import levelup.editor.module.script.ScriptConfig.ScriptData;
import levelup.game.GameState.Trigger;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ScriptEditorView extends View
{
	@:attr var openSelector:String->Int->ScriptData->Int->Void;
	@:attr var setComment:String->Void;
	@:skipCheck @:attr var selectors:List<RenderResult>;
	@:skipCheck @:attr var scripts:List<Trigger>;
	@:skipCheck @:attr var selectedScript:Trigger;

	@:state var scriptViewState:ScriptViewState = ScriptViewState.Code;
	var scriptViewFeatures:Array<Dynamic> = [
		{ icon: "code", target: ScriptViewState.Code },
		{ icon: "database", target: ScriptViewState.LocalVariables }
	];

	function render() '
		<div class="lu_editor__properties__container">
			{...selectors}
			<div class="lu_title">
				<i class="fas fa-code lu_right_offset"></i>Script Editor
			</div>
			<div class="lu_script__container">
				<div class="lu_script__list">
					<div class="lu_title lu_bottom_offset--s">Scripts</div>
					<div>
						<for {script in scripts}>
							<div class="lu_script__entry">
								{script.id}
							</div>
						</for>
					</div>
				</div>
				<div class="lu_fill lu_col">
					<div class="lu_title lu_bottom_offset--s lu_row lu_row--space_between">
						{selectedScript.id}
						<div class="lu_row">
							<div class="lu_script__entry">
								<for {entry in scriptViewFeatures}>
									<i
										class={"lu_horizontal_offset lu_icon_button fas fa-" + entry.icon + (entry.target == scriptViewState ? " lu_highlight" : "")}
										onClick={scriptViewState = entry.target}
									></i>
								</for>
							</div>
						</div>
					</div>
					<div class="lu_vertical_overflow lu_fill">
						<ScriptCommentView
							scriptId={selectedScript.id}
							comment={selectedScript.comment}
							setComment=$setComment
						/>
						<switch {scriptViewState}>
							<case {ScriptViewState.Code}> <ScriptView {...this} />
							<case {ScriptViewState.LocalVariables}> <LocalVariablesView scriptId={selectedScript.id} />
						</switch>
					</div>
				</div>
			</div>
		</div>
	';
}

enum ScriptViewState {
	Code;
	LocalVariables;
}
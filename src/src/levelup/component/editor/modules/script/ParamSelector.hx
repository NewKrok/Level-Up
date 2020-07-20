package levelup.component.editor.modules.script;

import coconut.ui.View;
import coconut.Ui.hxx;
import hpp.util.GeomUtil.SimplePoint;
import js.Browser;
import js.html.Element;
import js.html.MouseEvent;
import levelup.Player;
import levelup.component.form.dropdown.Dropdown;
import levelup.component.editor.modules.script.ScriptConfig.ParamType;
import levelup.component.editor.modules.script.ScriptConfig.ScriptData;
import levelup.game.GameState.Trigger;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ParamSelector extends View
{
	@:skipCheck @:attr var script:Trigger;
	@:skipCheck @:attr var data:ScriptData;
	@:skipCheck @:attr var setValue:Dynamic->Void;
	@:attr var paramIndex:Int;
	@:attr var close:Void->Void;

	@:state var playerConstantIndex:Int = -1;
	@:state var xOffset:Float = 0;
	@:state var yOffset:Float = 0;

	@:ref var container:Element;
	@:ref var modal:Element;

	var dragLastPoint:SimplePoint;

	function render() '
		<div class="lu_script__param_selector__background" ref=$modal>
			<div
				class="lu_script__param_selector__container"
				style={"left:" + xOffset + "px; top:" + yOffset + "px;"}
				onMouseDown=$handleMouseDown
				ref=$container
			>
				<div class="lu_dialog_close" onclick=$close><i class="fas fa-window-close"></i></div>
				<div class="lu_title lu_grab"><i class="fas fa-wrench lu_right_offset"></i>Set parameter</div>

				<switch {data.paramTypes[paramIndex]}>
					<case {ParamType.PPlayer}>
						{createPlayerConstants()}
						{createLocalVariables()}
						{createGlobalVariables()}

					<case {_}> Unhandled param type: {Std.string(data.paramTypes[paramIndex])}
				</switch>
			</div>
		</div>
	';

	// Create different views for different selectors

	var playerConstantArray = [for (i in 0...10)
		hxx('
			<div class="lu_row">
				<div class="lu_player_color_box lu_right_offset" style={"background-color: #" + Player.colors[i]}></div>
				Player {i + 1}
			</div>
		')
	];
	function createPlayerConstants() return hxx('
		<div class="lu_script__param_selector__entry">
			<input class="lu_form__radio" type="radio" id="constant" name="option" value="constant" />
			<div class="lu_right_offset">Constants</div>
			<Dropdown
				selectedIndex={playerConstantIndex == -1 ? data.values[paramIndex] : playerConstantIndex}
				setSelectedIndex = {v ->
				{
					playerConstantIndex = v;
					setValue(playerConstantIndex);
				}}
				values=$playerConstantArray
			/>
		</div>
	');

	function createLocalVariables() return hxx('
		<div class="lu_script__param_selector__entry">
			<input class="lu_form__radio" type="radio" id="localVariable" name="option" value="localVariable" />
			<div class="lu_right_offset">Local Variables</div>
			<if {script.localVariables != null && script.localVariables.length > 0}>
				<select class="lu_form__select" onChange={v ->
				{
					playerConstantIndex = Std.parseInt(v.currentTarget.value);
					setValue(playerConstantIndex);
				}}>
					<for {i in 0...script.localVariables.length}>
						<option
							selected={false}
							value={script.localVariables[i].name}
						>
							{script.localVariables[i].name}
						</option>
					</for>
				</select>
			<else>
				There is no any local variables for this script. Click here to create one.
			</if>
		</div>
	');

	function createGlobalVariables() return hxx('
		<div class="lu_script__param_selector__entry">
			<input class="lu_form__radio" type="radio" id="localVariable" name="option" value="localVariable" />
			<div class="lu_right_offset">Global Variables</div>
			<if {script.localVariables != null && script.localVariables.length > 0}>
				<select class="lu_form__select" onChange={v ->
				{
					playerConstantIndex = Std.parseInt(v.currentTarget.value);
					setValue(playerConstantIndex);
				}}>
					<for {i in 0...script.localVariables.length}>
						<option
							selected={false}
							value={script.localVariables[i].name}
						>
							{script.localVariables[i].name}
						</option>
					</for>
				</select>
			<else>
				There is no any local variables. Click here to create one.
			</if>
		</div>
	');

	function handleMouseDown(e:MouseEvent)
	{
		dragLastPoint = { x: e.clientX, y: e.clientY };
		Browser.window.addEventListener("mouseup", handleMouseUp);
		Browser.window.addEventListener("mousemove", handleMouseMove);
	}

	function handleMouseUp(e)
	{
		dragLastPoint = null;
		Browser.window.removeEventListener("mouseup", handleMouseUp);
		Browser.window.removeEventListener("mousemove", handleMouseMove);
	}

	function handleMouseMove(e)
	{
		if (dragLastPoint != null && container != null)
		{
			xOffset += (e.clientX - dragLastPoint.x);
			yOffset += (e.clientY - dragLastPoint.y);

			xOffset = Math.min(Math.max(xOffset, -modal.clientWidth / 2 + container.clientWidth / 2), modal.clientWidth / 2 - container.clientWidth / 2);
			yOffset = Math.min(Math.max(yOffset, -modal.clientHeight / 2 + container.clientHeight / 2), modal.clientHeight / 2 - container.clientHeight / 2);

			dragLastPoint = { x: e.clientX, y: e.clientY };
		}
	}
}
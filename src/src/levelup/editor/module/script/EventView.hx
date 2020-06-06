package levelup.editor.module.script;

import coconut.ui.View;
import levelup.game.GameState.TriggerEvent;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EventView extends View
{
	@:skipCheck @:attr var event:TriggerEvent;

	function render() '
		<div class="lu_row">
			<i class="fas fa-circle"></i>
			{/*ScriptConfig.getEventData(event)*/}
			<switch {event}>
				<case {TriggerEvent.EnterRegion(_)}>
					<div>EnterRegion</div>

				<case {TriggerEvent.OnInit}>
					<div>OnInit</div>

				<case {TriggerEvent.TimeElapsed(_)}>
					<div>TimeElapsed</div>

				<case {TriggerEvent.TimePeriodic(_)}>
					<div>TimePeriodic</div>

				<case {_}> Unhandled Event
			</switch>
		</div>
	';
}
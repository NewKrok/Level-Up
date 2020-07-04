package levelup.component;

import coconut.ui.View;
import js.html.InputElement;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Input extends View
{
	@:attr var value:String;
	@:attr var placeHolder:String = "";
	@:attr var className:String = "";
	@:attr var onValueChange:String->Void = null;

	@:ref var component:InputElement;

	function render() '
		<input
			ref=$component
			class={"lu_input " + className}
			onInput=$onInput
			placeholder=$placeHolder
			value=$value
		/>
	';

	function onInput() if (onValueChange != null) onValueChange(component.value);
}
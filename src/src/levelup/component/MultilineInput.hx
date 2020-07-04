package levelup.component;

import coconut.ui.View;
import js.html.TextAreaElement;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MultilineInput extends View
{
	@:attr var value:String;
	@:attr var placeHolder:String = "";
	@:attr var className:String = "";
	@:attr var onValueChange:String->Void = null;

	@:ref var component:TextAreaElement;

	function render() '
		<textarea
			ref=$component
			class={"lu_textarea " + className}
			onInput=$autoGrow
			placeholder=$placeHolder
		>
			$value
		</textarea>
	';

	function autoGrow()
	{
		component.style.height = "5px";
		component.style.height = (component.scrollHeight) + "px";

		if (onValueChange != null) onValueChange(component.value);
	}
}
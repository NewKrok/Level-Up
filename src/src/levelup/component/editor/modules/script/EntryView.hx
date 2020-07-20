package levelup.component.editor.modules.script;

import coconut.ui.View;
import levelup.component.editor.modules.script.ScriptConfig.ScriptData;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EntryView extends View
{
	@:skipCheck @:attr var openSelector:String->Int->ScriptData->Int->Void;
	@:skipCheck @:attr var data:ScriptData;
	@:attr var type:String;
	@:attr var index:Int;

	function render() '
		<div class="lu_script__entry">
			{getDescription()}
		</div>
	';

	function getDescription()
	{
		var rawText = data.description.replace(
			"{highlight_start}",
			"<span class='lu_entry__name_highlight'>"
		).replace(
			"{highlight_end}",
			"</span>"
		);

		var rawParts:Array<String> = cast rawText.split("{p");
		var closingChar = "}";

		return hxx('
			<div>
				<for {i in 0...rawParts.length}>
					<if {i < 1}>
						<raw tag="span" content={rawParts[i]} />
					<else>
						<span
							class="lu_highlight lu_script__param"
							onclick={openSelector(type, index, data, i - 1)}
						>
							{getParamAsString(i - 1)}
						</span>
						<raw tag="span" content={rawParts[i].substr(rawParts[i].indexOf(closingChar) + 1)} />
					</if>
				</for>
			</div>
		');
	}

	function getParamAsString(index:Int):String
	{
		var modifier = data.descriptionParamModifier != null && data.descriptionParamModifier.get(index) != null ? data.descriptionParamModifier.get(index) : null;

		return Std.string(modifier == null
			? data.values[index]
			: modifier(data.values[index]));
	}
}
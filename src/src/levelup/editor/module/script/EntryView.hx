package levelup.editor.module.script;

import coconut.ui.View;
import levelup.editor.module.script.ScriptConfig.ScriptData;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EntryView extends View
{
	@:skipCheck @:attr var data:ScriptData;

	function render() '
		<div class="lu_script__entry">
			<raw tag="div" content={getDescription()} />
		</div>
	';

	function getDescription()
	{
		var res = data.description.replace(
			"{highlight_start}",
			"<span class='lu_entry__name_highlight'>"
		).replace(
			"{highlight_end}",
			"</span>"
		);

		for (i in 0...data.paramTypes.length)
		{
			res = res.replace(
				"{p" + i + "}",
				"<span class='lu_highlight'>" + data.values[i] + "</span>"
			);
		}

		return res;
	}
}
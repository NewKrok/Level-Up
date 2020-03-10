package levelup.editor.dialog;

import coconut.data.Model;
import coconut.ui.RenderResult;
import tink.CoreApi.Option;
import tink.pure.List;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorDialogManagerModel implements Model
{
	@:observable var currentDialog:EditorDialog = null;
	@:observable var queue:List<EditorDialog> = [];

	public function openDialog(dialog)
	{
		if (dialog.forceOpen != null && dialog.forceOpen && currentDialog != null)
		{
			addToQueue(currentDialog, true);
			setCurrentDialog(null);
		}

		if (currentDialog == null) setCurrentDialog(dialog);
		else addToQueue(dialog);
	}

	public function closeCurrentDialog()
	{
		if (currentDialog != null) setCurrentDialog(null);

		if (queue.length > 0)
		{
			var d = switch(queue.first()) { case Some(v): v; case _: null; };
			removeFirstFromQueue();
			setCurrentDialog(d);
		}
	}

	@:transition private function removeFirstFromQueue()
	{
		var arr = queue.toArray();
		arr.shift();
		return { queue: List.fromArray(arr) };
	}

	@:transition private function addToQueue(dialog:EditorDialog, addToTop:Bool = false) return { queue: addToTop ? queue.prepend(dialog) : queue.append(dialog) };
	@:transition private function setCurrentDialog(dialog:EditorDialog) return { currentDialog: dialog };
}

typedef EditorDialog =
{
	var view(default, never):RenderResult;
	@:optional var forceOpen(default, never):Bool;
}
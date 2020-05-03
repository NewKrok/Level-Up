package levelup.component.layout;

import coconut.ui.RenderResult;
import coconut.ui.View;
import coconut.data.List;
import levelup.component.layout.Layout.LayoutEntry;
import tink.CoreApi.Option;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LayoutView extends View
{
	@:attr var registeredViews:List<LayoutEntry>;

	function render() '
		<div id="lu_native_ui" class="lu_native_ui">
			{getView(AdventureLoader)}
			{getView(EditorUi)}
			{getView(GameUi)}
		</div>
	';

	function getView(id):RenderResult return switch (registeredViews.first(e -> return e.id == id))
	{
		case Option.Some(v): v.view;
		case _: null;
	}
}

enum abstract LayoutId(String) from String to String
{
	var AdventureLoader = "AdventureLoader";
	var EditorUi = "EditorUi";
	var GameUi = "GameUi";
}
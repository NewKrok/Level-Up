package levelup.component.layout;

import coconut.data.List;
import coconut.ui.RenderResult;
import js.Browser;
import react.ReactDOM;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Layout
{
	var registeredViews:State<List<LayoutEntry>> = new State(List.fromArray([]));

	public function new()
	{
		var view = new LayoutView({
			registeredViews: registeredViews
		});

		ReactDOM.render(view.reactify(), Browser.document.getElementById("lu_native_ui_container"));
	}

	public function registerView(id:String, view:RenderResult)
	{
		registeredViews.set(registeredViews.value.append({id: id, view: view}));
	}
}

typedef LayoutEntry = {
	var id(default, never):String;
	var view(default, never):RenderResult;
}
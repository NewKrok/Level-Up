package levelup.component.layout;

import coconut.data.List;
import coconut.ui.RenderResult;
import js.Browser;
import react.ReactDOM;
import tink.CoreApi.Option;
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

	public function removeView(id:String)
	{
		var ref:LayoutEntry = switch (registeredViews.value.first(e -> return e.id == id))
		{
			case Option.Some(v): v;
			case _: null;
		}
		var newArr = registeredViews.value.toArray();
		newArr.remove(ref);

		registeredViews.set(List.fromArray(newArr));
	}
}

typedef LayoutEntry = {
	var id(default, never):String;
	var view(default, never):RenderResult;
}
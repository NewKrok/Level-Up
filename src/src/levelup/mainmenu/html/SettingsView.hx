package levelup.mainmenu.html;

import coconut.ui.View;
import h3d.Engine;
import js.Browser;
import js.html.Event;
import js.html.SelectElement;
import levelup.util.SaveUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SettingsView extends View
{
	@:attr var onImportantChange:Void->Void;

	@:state var selectedResolutionQuality:Float = 0.0;
	@:state var selectedShowFPS:Bool = false;
	@:state var subMenuIndex:Int = 0;

	var tabs:Array<String> = [
		"Graphics",
		"Sound",
		"Gameplay",
		"Language"
	];

	override function viewDidMount()
	{
		selectedResolutionQuality = SaveUtil.appData.graphics.resolutionQuality;
		selectedShowFPS = SaveUtil.appData.gameplay.showFPS;
	}

	function render() '
		<div class="lu_main_menu_settings lu_row">
			<div class="lu_main_menu_settings_submenu">
				<for {i in 0...tabs.length}>
					<div
						class={"lu_main_menu_settings_submenu__button" + (subMenuIndex == i ? " lu_main_menu_settings_submenu__button--active" : "")}
						onClick = {() -> subMenuIndex = i}
					>
						{tabs[i]}
					</div>
				</for>
			</div>

			<div class="lu_fill_width">
				<switch {subMenuIndex}>
					<case {0}>
						<div class="lu_main_menu_settings__entry lu_row">
							<div class="lu_right_offset">Resolution</div>
							<select onChange=$setResolutionQuality class="lu_form__select">
								<option selected={selectedResolutionQuality == 0.5} value="0.5">Low</option>
								<option selected={selectedResolutionQuality == 0.75} value="0.75">Medium</option>
								<option selected={selectedResolutionQuality == 1} value="1">High</option>
							</select>
						</div>

					<case {2}>
						<div class="lu_main_menu_settings__entry lu_row">
							<div class="lu_right_offset">Show FPS</div>
							<select onChange=$setShowFPS class="lu_form__select">
								<option selected={selectedShowFPS} value="1">On</option>
								<option selected={!selectedShowFPS} value="0">Off</option>
							</select>
						</div>

					<case {_}><div></div>
				</switch>
			</div>
		</div>
	';

	function setResolutionQuality(e:Event)
	{
		var element:SelectElement = cast e.currentTarget;
		SaveUtil.appData.graphics.resolutionQuality = selectedResolutionQuality = Std.parseFloat(element.value);

		Engine.getCurrent().resize(
			Math.floor(Browser.window.innerWidth * SaveUtil.appData.graphics.resolutionQuality),
			Math.floor(Browser.window.innerHeight * SaveUtil.appData.graphics.resolutionQuality)
		);
	}

	function setShowFPS(e:Event)
	{
		var element:SelectElement = cast e.currentTarget;
		SaveUtil.appData.gameplay.showFPS = selectedShowFPS = Std.parseFloat(element.value) == 1;

		onImportantChange();
	}
}
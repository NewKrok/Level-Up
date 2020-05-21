package levelup.mainmenu.html;

import coconut.ui.View;
import h3d.Engine;
import hpp.util.Language;
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
	@:attr var isMenuBackgroundInLoadingState:Bool;
	@:attr var isTextLanguageInLoadingState:Bool;

	@:attr var onShowFpsChange:Void->Void;
	@:attr var onMenuBackgroundChange:Void->Void;
	@:attr var onTextLanguageChange:Void->Void;

	@:state var selectedResolutionQuality:Float = 0.0;
	@:state var selectedShowFPS:Bool = false;
	@:state var selectedMenuBackground:Int = 0;
	@:state var selectedTextLanguage:Int = 0;

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
		selectedMenuBackground = SaveUtil.appData.gameplay.menuBackground == "main_menu_elf_theme" ? 0 : 1;
		selectedTextLanguage = SaveUtil.appData.language.textLanguage == LanguageKey.English ? 0 : 1;
	}

	function render() '
		<div class="lu_main_menu_settings lu_row">
			<div class="lu_main_menu_settings_submenu">
				<for {i in 0...tabs.length}>
					<div
						class={"lu_main_menu_settings_submenu__button" + (subMenuIndex == i ? " lu_main_menu_settings_submenu__button--active" : "")}
						onClick = {() -> subMenuIndex = i}
					>
						{Language.get(tabs[i])}
					</div>
				</for>
			</div>

			<div class="lu_fill_width">
				<switch {subMenuIndex}>
					<case {0}>
						<div class="lu_main_menu_settings__entry lu_row">
							<div class="lu_right_offset">{Language.get("Resolution")}</div>
							<select onChange=$setResolutionQuality class="lu_form__select">
								<option selected={selectedResolutionQuality == 0.5} value="0.5">{Language.get("Low")}</option>
								<option selected={selectedResolutionQuality == 0.75} value="0.75">{Language.get("Medium")}</option>
								<option selected={selectedResolutionQuality == 1} value="1">{Language.get("High")}</option>
							</select>
						</div>

					<case {2}>
						<div class="lu_main_menu_settings__entry lu_row">
							<div class="lu_right_offset">{Language.get("Show FPS")}</div>
							<select onChange=$setShowFPS class="lu_form__select">
								<option selected={selectedShowFPS} value="1">{Language.get("On")}</option>
								<option selected={!selectedShowFPS} value="0">{Language.get("Off")}</option>
							</select>
						</div>
						<div class="lu_main_menu_settings__entry lu_row">
							<div class="lu_right_offset">{Language.get("Menu background")}</div>
							<if {isMenuBackgroundInLoadingState}>
								<div class="lu_form__select lu_disabled">
									{Language.get("loading...")}
								</div>
							<else>
								<select onChange=$setMenuBackground class="lu_form__select">
									<option selected={selectedMenuBackground == 0} value="0">Elf theme</option>
									<option selected={selectedMenuBackground == 1} value="1">Orc theme</option>
								</select>
							</if>
						</div>

					<case {3}>
						<div class="lu_main_menu_settings__entry lu_row">
							<div class="lu_right_offset">{Language.get("Text language")}</div>
							<if {isTextLanguageInLoadingState}>
								<div class="lu_form__select lu_disabled">
									{Language.get("loading...")}
								</div>
							<else>
								<select onChange=$setLanguage class="lu_form__select">
								<option selected={selectedTextLanguage == 0} value="0">{Language.get("English")}</option>
								<option selected={selectedTextLanguage == 1} value="1">{Language.get("Magyar")}</option>
							</select>
							</if>
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

		onShowFpsChange();
	}

	function setMenuBackground(e:Event)
	{
		var element:SelectElement = cast e.currentTarget;
		selectedMenuBackground = Std.parseInt(element.value);

		SaveUtil.appData.gameplay.menuBackground = selectedMenuBackground == 0 ? "main_menu_elf_theme" : "main_menu_orc_theme";

		onMenuBackgroundChange();
	}

	function setLanguage(e:Event)
	{
		var element:SelectElement = cast e.currentTarget;
		selectedTextLanguage = Std.parseInt(element.value);

		SaveUtil.appData.language.textLanguage = selectedTextLanguage == 0 ? LanguageKey.English : LanguageKey.Hungarian;
		SaveUtil.save();

		onTextLanguageChange();
	}
}
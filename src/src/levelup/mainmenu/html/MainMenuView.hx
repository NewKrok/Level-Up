package levelup.mainmenu.html;

import coconut.ui.View;
import hpp.util.Language;
import levelup.SoundFxAssets.SoundFxKey;
import levelup.component.fpsview.FpsView;
import levelup.util.LanguageUtil;
import levelup.util.SaveUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MainMenuView extends View
{
	@:attr var isMenuBackgroundInLoadingState:Bool;
	@:attr var isTextLanguageInLoadingState:Bool;

	@:attr var openAdventure:String->Void;
	@:attr var openAdventureEditor:String->Void;
	@:attr var reloadMenuBackground:Void->Void;
	@:attr var onTextLanguageChange:Void->Void;

	@:state var menuState:MenuViewState = MainMenu;
	@:state var showFps:Bool = false;

	override function viewDidMount()
	{
		showFps = SaveUtil.appData.gameplay.showFPS;
	}

	function render() '
		<div class="lu_main_menu_container">
			<if {LanguageUtil.languageForceUpdate == 0}></if>
			<div class={"lu_main_menu__world_loader" + (isMenuBackgroundInLoadingState ? "" : " lu_main_menu__world_loader--hidden")}>
				<div class="lu_circle_loader"></div>
			</div>
			<div class={"lu_main_menu" + (menuState == MainMenu ? " lu_main_menu--open" : "")}>
				<img src="./asset/img/logo.png" class="lu_main_menu__logo" />
				<div class="lu_main_menu__button" onClick={changeStateTo(Campaign)}>
					{Language.get("Campaign")}
				</div>
				<div class="lu_main_menu__button" onClick={changeStateTo.bind(CustomAdventures)}>
					{Language.get("Custom Adventures")}
				</div>
				<div class="lu_main_menu__button" onClick={changeStateTo.bind(Multiplayer)}>
					{Language.get("Multiplayer")}
				</div>
				<div class="lu_main_menu__button" onClick={changeStateTo.bind(AdventureEditor)}>
					{Language.get("Adventure Editor")}
				</div>
				<div class="lu_main_menu__button" onClick={changeStateTo.bind(Achievements)}>
					{Language.get("Achievements")}
				</div>
				<div class="lu_main_menu__button" onClick={changeStateTo.bind(Settings)}>
					{Language.get("Settings")}
				</div>
				<div class="lu_main_menu__button" onClick={changeStateTo.bind(Credits)}>
					{Language.get("Credits")}
				</div>
			</div>
			<div class={"lu_main_menu_modal" + (menuState == MainMenu ? " lu_main_menu_modal--open" : "")}>
				<div class="lu_main_menu_modal__header">
					<div class="lu_main_menu_modal__header_button" onClick={changeStateTo.bind(MainMenu)}>
						<i class="fas fa-caret-left lu_right_offset--s"></i> {Language.get("Back")}
					</div>
					<div>{Language.get(getLabelFromState(menuState))}</div>
				</div>
				<div class="lu_main_menu_modal__content">
					<switch {menuState}>
						<case {Campaign}> <CampaignView />
						<case {CustomAdventures}> <CustomAdventuresView openAdventure=$openAdventure />
						<case {Multiplayer}> <MultiplayerView />
						<case {AdventureEditor}> <AdventureEditorView openAdventureEditor=$openAdventureEditor/>
						<case {Achievements}> <AchievementsView />
						<case {Settings}>
							<SettingsView
								onShowFpsChange=$onShowFpsChange
								onMenuBackgroundChange=$reloadMenuBackground
								isMenuBackgroundInLoadingState=$isMenuBackgroundInLoadingState
								onTextLanguageChange = $onTextLanguageChange
								isTextLanguageInLoadingState=$isTextLanguageInLoadingState
							/>
						<case {Credits}> <CreditsView />

						<case {_}>
					</switch>
				</div>
			</div>
			<if {showFps}>
				<FpsView />
			</if>
		</div>
	';

	function onShowFpsChange()
	{
		showFps = SaveUtil.appData.gameplay.showFPS;
	}

	function getLabelFromState(s) return switch(s)
	{
		case Campaign: "Campaign";
		case CustomAdventures: "Custom Adventures";
		case Multiplayer: "Multiplayer";
		case AdventureEditor: "Adventure Editor";
		case Achievements: "Achievements";
		case Settings: "Settings";
		case Credits: "Credits";
		case _: "";
	};

	function changeStateTo(state)
	{
		SoundFxAssets.instance.getSound(SoundFxKey.Click).play();
		if (menuState == Settings) SaveUtil.save();
		menuState = state;
	}
}

enum MenuViewState {
	MainMenu;
	Campaign;
	CustomAdventures;
	Multiplayer;
	AdventureEditor;
	Achievements;
	Settings;
	Credits;
}
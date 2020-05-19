package levelup.util;

import h3d.Vector;
import haxe.ds.Map;
import hpp.util.DeviceData;
import hxd.Save;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SaveUtil
{
	private static var savedAppDataName:String = "(app)__fpp_level_up";
	private static var savedGameDataName:String = "(game)_fpp_level_up";
	private static var savedEditorDataName:String = "(editor)_fpp_level_up";

	public static var appData(default, null):SavedAppData;
	public static var gameData(default, null):SavedGameData;
	public static var editorData(default, null):SavedEditorData;

	public static function load()
	{
		var defaultAppData:SavedAppData = {
			graphics: {
				resolutionQuality: 1
			},
			sound: {
				masterVolume: 0.8,
				isMusicEnabled: true,
				musicVolume: 1,
				isSoundEnabled: true,
				soundVolume: 1,
			},
			gameplay: {
				menuBackground: "main_menu_elf_theme",
				showFPS: false,
				showUnitInfo: ShowUnitInfo.Always
			},
			language: {
				textLanguage: Language.English
			}
		};
		appData = Save.load(defaultAppData, savedAppDataName);

		var defaultGameData:SavedGameData = {
		};
		gameData = Save.load(defaultGameData, savedGameDataName);

		var defaultEditorData:SavedEditorData = {
			showGrid: true,
			customAdventures: []
		};
		editorData = Save.load(defaultEditorData, savedEditorDataName);
	}

	public static function save()
	{
		Save.save(appData, savedAppDataName);
		Save.save(gameData, savedGameDataName);
		Save.save(editorData, savedEditorDataName);
	}
}

typedef SavedGameData = {

}

typedef SavedAppData = {
	var graphics:VideoSettings;
	var sound:SoundSettings;
	var gameplay:GameplaySettings;
	var language:LanguageSettings;
}

typedef VideoSettings = {
	var resolutionQuality:Float;
}

typedef SoundSettings = {
	var masterVolume:Float;
	var isMusicEnabled:Bool;
	var musicVolume:Float;
	var isSoundEnabled:Bool;
	var soundVolume:Float;
}

typedef GameplaySettings = {
	var menuBackground:String;
	var showFPS:Bool;
	var showUnitInfo:ShowUnitInfo;
}

enum ShowUnitInfo {
	None;
	Always;
	WhenItsNotFull;
}

typedef SavedEditorData = {
	var showGrid:Bool;
	var customAdventures:Array<String>;
}

typedef LanguageSettings = {
	var textLanguage:Language;
}

enum abstract Language(String) from String to String
{
	var English = "en";
	var Hungarian = "hu";
}
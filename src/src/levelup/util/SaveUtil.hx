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
	private static var savedAppDataName:String = "(app) _fpp_level_up";
	private static var savedGameDataName:String = "(game) _fpp_level_up";
	private static var savedEditorDataName:String = "(editor) _fpp_level_up";

	public static var appData(default, null):SavedAppData;
	public static var gameData(default, null):SavedGameData;
	public static var editorData(default, null):SavedEditorData;

	public static function load()
	{
		var defaultAppData:SavedAppData = {
			video: {
				resolutionQuality: 1
			},
			gameplay: {
				showFPS: false
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
	var video:VideoSettings;
	var gameplay:GameplaySettings;
}

typedef VideoSettings = {
	var resolutionQuality:Float;
}

typedef GameplaySettings = {
	var showFPS:Bool;
}

typedef SavedEditorData = {
	var showGrid:Bool;
	var customAdventures:Array<String>;
}
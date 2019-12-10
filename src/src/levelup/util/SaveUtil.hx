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
	private static var savedGameDataName:String = "(game) fpp_level_up";
	private static var savedEditorDataName:String = "(editor) fpp_level_up";

	public static var gameData(default, null):SavedGameData;
	public static var editorData(default, null):SavedEditorData;

	public static function load()
	{
		var defaultGameData:SavedGameData = {
			app: {
			},
			game: {
			}
		};
		gameData = Save.load(defaultGameData, savedGameDataName);

		var defaultEditorData:SavedEditorData = {
			customMaps: []
		};
		editorData = Save.load(defaultEditorData, savedEditorDataName);
	}

	public static function save()
	{
		Save.save(gameData, savedGameDataName);
		Save.save(editorData, savedEditorDataName);
	}
}

typedef SavedGameData = {
	var app:ApplicationInfo;
	var game:GameInfo;
}

typedef ApplicationInfo = {
}

typedef GameInfo = {
}

typedef SavedEditorData = {
	var customMaps:Array<String>;
}
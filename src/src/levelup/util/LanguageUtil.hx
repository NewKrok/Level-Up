package levelup.util;

import haxe.Json;
import hpp.util.Language;
import hxd.net.BinaryLoader;
import levelup.util.SaveUtil;
import levelup.util.SaveUtil.LanguageKey;
import tink.CoreApi.Future;
import tink.CoreApi.FutureTrigger;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LanguageUtil
{
	public static var languageForceUpdate:State<Int> = new State<Int>(0);

	public static function loadLanguage():Future<Outcome<Noise, String>>
	{
		var result:FutureTrigger<Outcome<Noise, String>> = Future.trigger();

		var loader = new BinaryLoader(SaveUtil.appData.language.textLanguage == LanguageKey.English
			? "asset/language/lang_en.json"
			: "asset/language/lang_hu.json"
		);
		loader.load();
		loader.onLoaded = data ->
		{
			Language.setLang(Json.parse(hxd.res.Any.fromBytes(loader.url, data).toText()));
			languageForceUpdate.set(languageForceUpdate.value + 1);
			result.trigger(Success(Noise));
		};
		loader.onError = msg -> result.trigger(Failure(msg));

		return result;
	}
}
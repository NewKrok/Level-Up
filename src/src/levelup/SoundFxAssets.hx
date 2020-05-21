package levelup;

import hxd.net.BinaryLoader;
import hxd.res.Sound;
import tink.CoreApi.Future;
import tink.CoreApi.FutureTrigger;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SoundFxAssets
{
	public static var instance:SoundFxAssets;

	// TODO: Move it to data json?
	private var soundFxs:Map<SoundFxKey, String> = [
		Click => "asset/audio/sfx/Bow Handle 2_1.mp3"
	];

	private var soundFxDirectory:Map<SoundFxKey, Sound> = new Map<SoundFxKey, Sound>();

	public function new() instance = this;

	public function getSound(sfxKey:SoundFxKey) return soundFxDirectory.get(sfxKey);

	public function load(list:Array<SoundFxKey>):Future<Outcome<Noise, String>>
	{
		var result:FutureTrigger<Outcome<Noise, String>> = Future.trigger();
		var loadedModelSoundCount = 0;

		var onLoaded = (data, key:SoundFxKey) ->
		{
			var sound = hxd.res.Any.fromBytes(soundFxs.get(key), data).toSound();
			soundFxDirectory.set(key, sound);
			loadedModelSoundCount++;
			if (loadedModelSoundCount == list.length) result.trigger(Success(Noise));
		}

		var loadRoutine = key ->
		{
			var loader = new BinaryLoader(soundFxs.get(key));
			loader.onError = e -> result.trigger(Failure(e));
			loader.load();
			loader.onLoaded = data -> onLoaded(data, key);
		}

		for (sfx in list) loadRoutine(sfx);

		return result;
	}
}

enum SoundFxKey
{
	Click;
}
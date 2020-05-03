package levelup.component.adventureloader;

import Main.CoreFeatures;
import com.greensock.TweenMax;
import levelup.component.layout.LayoutView.LayoutId;
import levelup.game.GameState.AdventureConfig;
import levelup.util.AdventureParser;
import tink.CoreApi.Future;
import tink.CoreApi.FutureTrigger;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class AdventureLoader
{
	var cf:CoreFeatures = _;

	var currentState:State<AdventureLoaderState> = new State<AdventureLoaderState>(Idle);
	var preloaderImage:State<String> = new State<String>("");
	var adventureTitle:State<String> = new State<String>("");
	var adventureSubTitle:State<String> = new State<String>("");
	var adventureDescription:State<String> = new State<String>("");

	var userActionTrigger:FutureTrigger<Outcome<Noise, String>>;

	public function new()
	{
		var view = new AdventureLoaderView({
			currentState: currentState,
			loadPercentage: cf.assetCache.loadPercentage,
			preloaderImage: preloaderImage,
			adventureTitle: adventureTitle,
			adventureSubTitle: adventureSubTitle,
			adventureDescription: adventureDescription,
			onStart: () ->
			{
				currentState.set(FadeOut);
				TweenMax.delayedCall(1, currentState.set.bind(Idle));
				userActionTrigger.trigger(Outcome.Success(Noise));
			}
		});
		cf.layout.registerView(LayoutId.AdventureLoader, view.reactify());
	}

	public function load(rawMap:String):Future<Outcome<AdventureLoaderResult, String>>
	{
		currentState.set(LoadingInProgress);
		var result:FutureTrigger<Outcome<AdventureLoaderResult, String>> = Future.trigger();
		userActionTrigger = Future.trigger();

		var adventureConfig = AdventureParser.loadLevel(rawMap);
		preloaderImage.set(adventureConfig.preloaderImage);
		adventureTitle.set(adventureConfig.title);
		adventureSubTitle.set(adventureConfig.subTitle);
		adventureDescription.set(adventureConfig.description);

		cf.assetCache.load(adventureConfig.neededModelGroups, adventureConfig.neededTextures).handle(o -> switch (o)
		{
			case Success(_):
				TweenMax.delayedCall(1, currentState.set.bind(Loaded));
				result.trigger(Outcome.Success({config: adventureConfig, onUserAction: userActionTrigger}));

			case Failure(e):
		});

		return result;
	}
}

enum AdventureLoaderState
{
	Idle;
	LoadingInProgress;
	Loaded;
	FadeOut;
}

typedef AdventureLoaderResult =
{
	var config:AdventureConfig;
	var onUserAction:FutureTrigger<Outcome<Noise, String>>;
}
package levelup.component.adventureloader;

import Main.CoreFeatures;
import com.greensock.TweenMax;
import js.Browser;
import levelup.component.layout.LayoutView.LayoutId;
import levelup.game.GameState.AdventureConfig;
import levelup.util.AdventureParser;
import tink.CoreApi.Future;
import tink.CoreApi.FutureTrigger;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;
import tink.core.Callback.CallbackLink;
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
	var isEditorMode:State<Bool> = new State<Bool>(true);

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
			isEditorMode: isEditorMode,
			onStart: onStart
		});
		cf.layout.registerView(LayoutId.AdventureLoader, view.reactify());
	}

	function onStart()
	{
		currentState.set(FadeOut);
		TweenMax.delayedCall(1, currentState.set.bind(Idle));
		userActionTrigger.trigger(Outcome.Success(Noise));
	}

	public function load(rawMap:String, isEditorMode:Bool = false):Future<Outcome<AdventureLoaderResult, String>>
	{
		currentState.set(LoadingInProgress);
		var result:FutureTrigger<Outcome<AdventureLoaderResult, String>> = Future.trigger();
		userActionTrigger = Future.trigger();

		var adventureConfig = AdventureParser.loadLevel(rawMap);

		this.isEditorMode.set(isEditorMode);

		if (isEditorMode)
		{
			preloaderImage.set("asset/preloader/editor.jpg");
			adventureTitle.set("Adventure Editor");
			adventureSubTitle.set("0% loading...");
			adventureDescription.set("<div style='text-align: center; color: #FFFF00; font-size: 1.5em'>" + adventureConfig.title + "</div>");

			var cb:CallbackLink;
			cb = cf.assetCache.loadPercentage.bind(v ->
			{
				adventureSubTitle.set(Math.floor(v * 100) + "% loading...");
				if (v == 1) cb.cancel();
			});
		}
		else
		{
			preloaderImage.set(adventureConfig.preloaderImage);
			adventureTitle.set(adventureConfig.title);
			adventureSubTitle.set(adventureConfig.subTitle);
			adventureDescription.set(adventureConfig.description);
		}

		// Preload loader image
		var img = Browser.document.createImageElement();
		img.src = preloaderImage.value;
		img.id = "lu_image_reloader";
		img.className = "lu_hidden";
		Browser.document.body.appendChild(img);

		img.onload = () ->
		{
			Browser.document.body.removeChild(img);
			img = null;

			cf.assetCache.load(adventureConfig.neededModelGroups, adventureConfig.neededTextures, adventureConfig.neededImages).handle(o -> switch (o)
			{
				case Success(_):
					TweenMax.delayedCall(1, () ->
					{
						currentState.set(Loaded);
						onStart();
					});
					result.trigger(Outcome.Success({config: adventureConfig, onUserAction: userActionTrigger}));

				case Failure(e):
			});
		};

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
package levelup.component.adventureloader;

import coconut.ui.View;
import levelup.component.adventureloader.AdventureLoader.AdventureLoaderState;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AdventureLoaderView extends View
{
	@:attr var currentState:AdventureLoaderState;
	@:attr var loadPercentage:Float;
	@:attr var preloaderImage:String;
	@:attr var adventureTitle:String;
	@:attr var adventureSubTitle:String;
	@:attr var adventureDescription:String;
	@:attr var onStart:Void->Void;

	function render() '
	<if {currentState == LoadingInProgress || currentState == Loaded || currentState == FadeOut}>
			<div
				style="background-image: url($preloaderImage);"
				class={"lu_adventure_loader" + (currentState == Loaded ? " lu_adventure_loader--loaded" : "") + (currentState == FadeOut ? " lu_adventure_loader--fadeOut" : "")}
				onclick={() -> if(currentState == Loaded) onStart()}
			>
				<div class="lu_adventure_loader__level_info">
					<div class="lu_adventure_loader__title">
						<raw content=$adventureTitle />
					</div>
					<div class="lu_adventure_loader__sub_title">
						<raw content=$adventureSubTitle />
					</div>
					<div class = "lu_adventure_loader__description">
						<raw content=$adventureDescription />
					</div>
				</div>
				<div class="lu_adventure_loader__container">
					<div class={"lu_adventure_loader__line" + (currentState != LoadingInProgress ? " lu_opacity_pulse" : " lu_opacity_pulse--intensive")} style="width: ${loadPercentage * 100}%">
						<div class={"lu_adventure_loader__circle" + (currentState != LoadingInProgress ? " lu_adventure_loader__circle--loaded" : "")}></div>
						<div class="lu_adventure_loader__line_background"></div>
					</div>
					<div class={"lu_adventure_loader__loaded_text" + (currentState != LoadingInProgress ? " lu_adventure_loader__loaded_text--loaded" : "")}>
						Click to continue...
					</div>
				</div>
			</div>
		<else>
			<div class="lu_hidden"></div>
		</if>
	';
}
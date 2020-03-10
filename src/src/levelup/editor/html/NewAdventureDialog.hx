package levelup.editor.html;

import coconut.ui.View;
import hpp.util.GeomUtil.SimplePoint;
import levelup.component.Slider;
import levelup.editor.EditorState.AssetItem;
import levelup.editor.EditorState.InitialAdventureData;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class NewAdventureDialog extends View
{
	var sizeInfos:Array<SizeInfo> = [
		{
			name: "Small",
			size: {x: 25, y: 25},
			recommendedFor: "Small map size is recommended mostly for non-classic fun maps like 1 player hero survival or other not really RTS based games. This size could be great too to learn how to use this editor - you can save and test it really quick."
		},
		{
			name: "Medium",
			size: {x: 50, y: 50},
			recommendedFor: ""
		},
		{
			name: "Large",
			size: {x: 150, y: 150},
			recommendedFor: ""
		},
		{
			name: "Extra Large",
			size: {x: 200, y: 200},
			recommendedFor: ""
		},
		{
			name: "Custom",
			size: {x: 0, y: 0},
			recommendedFor: "Extra wide or extra high? Not a problem. Release your fantasy and create your own custom sized map!"
		}
	];

	var templateInfos:Array<TemplateInfo> = [
		{
			name: "Empty",
			recommendedFor: "Do you want to create something unique or do you want to create everything from zero by yourself? In this case this what you should choose."
		},
		{
			name: "Hero Survival",
			recommendedFor: "It's containes pre defined hero selector and a simple wave system. Just define your own waves, heros, abilities, items and terrain, modify game dialogs and you are done with your Hero Survival game!"
		},
		{
			name: "MOBA",
			recommendedFor: "It's containes pre defined hero selector and a base team settings. Just define your own heros, items, abilities, and terrain, modify game dialogs and you are done with your MOBA game!"
		},
		{
			name: "Hack\'n\'Slash",
			recommendedFor: "It's containes pre defined hero selector and a base enemy system. Just define your own heros, items, abilities, and terrain, modify game dialogs and you are done with your Hack\'n\'Slash game!"
		}
	];

	@:attr var createNewAdventure:InitialAdventureData->Void;
	@:attr var close:Void->Void;
	@:attr var defaultTerrainIdForNewAdventure:String;
	@:attr var openTerrainChooser:Void->Void;

	@:state var sizeIndex:Int = 0;
	@:state var templateIndex:Int = 0;

	function render() '
		<div class="lu_edialog__content lu_edialog__content--auto-size">
			<div class="lu_dialog_close" onclick=$close><i class="fas fa-window-close"></i></div>
			<div class="lu_title"><i class="fas fa-file lu_right_offset"></i>Create New Adventure</div>
			<div class="lu_offset lu_bottom_offset--l">
				<div class="lu_title">Map size</div>
				<div class="lu_row lu_row--space_evenly">
					<for {i in 0...sizeInfos.length}>
						<div class={"lu_button" + (sizeIndex == i ? " lu_button--selected" : "" )} onclick=${sizeIndex = i}> ${sizeInfos[i].name} {sizeInfos[i].size.x != 0 ? sizeInfos[i].size.x + "x" + sizeInfos[i].size.y : ""}</div>
					</for>
				</div>
				${sizeInfos[sizeIndex].recommendedFor}
			</div>
			<div class="lu_offset lu_bottom_offset--l">
				<div class="lu_title">Base terrain</div>
				<div
					class={"lu_terrain_layer"}
					onclick=$openTerrainChooser
					style={"background-image: url(" + TerrainAssets.getTerrain(defaultTerrainIdForNewAdventure).previewUrl + ")"}
				></div>
			</div>
			<div class="lu_offset lu_bottom_offset--l">
				<div class="lu_title">Height map</div>
				<div class="lu_row lu_vertical_offset--s">
					<div class="lu_width_30_p">Default terrain level</div>
					<Slider
						className="lu_fill_width"
						min={0}
						max={5}
						startValue={2}
						step={1}
					/>
				</div>
				<div class="lu_row">
					<div class="lu_width_30_p">Default terrain hill height</div>
					<Slider
						className="lu_fill_width"
						min={0}
						max={255}
						startValue={127}
						step={1}
					/>
				</div>
			</div>
			<div class="lu_offset lu_bottom_offset--l">
				<div class="lu_title">Select game template</div>
				<div class="lu_row lu_row--space_evenly">
					<for {i in 0...templateInfos.length}>
					<div class={"lu_button" + (templateIndex == i ? " lu_button--selected" : "" )} onclick=${templateIndex = i}> ${templateInfos[i].name}</div>
					</for>
				</div>
				${templateInfos[templateIndex].recommendedFor}
			</div>

			<div class="lu_row">
				<div class="lu_button" onclick=$close>Close</div>
				<div class="lu_button" onclick=$create>Create</div>
			</div>
		</div>
	';

	function create()
	{
		createNewAdventure({
			size: sizeInfos[sizeIndex].size,
			defaultTerrainTextureId: defaultTerrainIdForNewAdventure
		});
	}
}

typedef SizeInfo =
{
	var size:SimplePoint;
	var name:String;
	var recommendedFor:String;
}

typedef TemplateInfo =
{
	var name:String;
	var recommendedFor:String;
}
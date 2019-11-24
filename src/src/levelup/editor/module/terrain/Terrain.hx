package levelup.editor.module.terrain;

import coconut.ui.RenderResult;
import h2d.Graphics;
import h3d.col.Point;
import h3d.mat.BlendMode;
import h3d.mat.Data.Face;
import h3d.mat.Data.Wrap;
import h3d.mat.Material;
import h3d.mat.Texture;
import h3d.prim.Cube;
import h3d.prim.Cylinder;
import h3d.prim.Polygon;
import h3d.scene.Mesh;
import h3d.scene.Scene;
import hpp.util.GeomUtil.SimplePoint;
import hxd.BitmapData;
import hxd.Event;
import hxd.Res;
import levelup.editor.EditorModel;
import levelup.editor.EditorState.EditorActionType;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import levelup.editor.module.terrain.TerrainEditorView;
import levelup.shader.AlphaMask;
import levelup.shader.Opacity;
import tink.pure.List;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class Terrain
{
	var core:EditorCore = _;

	public var model:TerrainModel;

	var preview:Mesh;
	var isDrawActive:Bool;
	var lastDrawedPoint:SimplePoint = { x: 0, y: 0 };
	var dragStartPoint:SimplePoint = null;

	var alphaMap:Graphics = new Graphics();

	public function new()
	{
		model = new TerrainModel();

		var terrainChooser = new TerrainChooser({
			terrainList: List.fromArray(TerrainAssets.terrains),
			selectTerrain: id -> {
				core.dialogManager.closeCurrentDialog();
				model.selectedLayer.terrainId.set(id);

				var newTerrain = TerrainAssets.getTerrain(model.selectedLayer.terrainId);
				var activeMesh = core.world.terrainLayers[model.selectedLayerIndex];
				activeMesh.material.texture = newTerrain.texture;
				activeMesh.material.texture.wrap = Wrap.Repeat;
			},
			close: core.dialogManager.closeCurrentDialog
		});
		var terrainChooserView = terrainChooser.reactify();

		core.registerView(EditorViewId.VTerrainEditor, TerrainEditorView.fromHxx({
			baseTerrainId: core.model.observables.baseTerrainId,
			changeBaseTerrainIdRequest: t ->
			{
				core.logAction({
					actionType: EditorActionType.ChangeBaseTerrain,
					oldValueString: core.model.baseTerrainId,
					newValueString: t.id
				});
				core.model.baseTerrainId = t.id;
			},
			selectedBrushId: model.observables.selectedBrushId,
			changeSelectedBrushRequest: id -> model.selectedBrushId = id,
			layers: model.observables.layers,
			selectedLayer: model.observables.selectedLayer,
			selectLayer: e ->
			{
				if (model.selectedLayer == e)
				{
					terrainChooser.setSelectedTerrainId(e.terrainId);
					core.dialogManager.openDialog({ view: terrainChooserView });
				}
				else model.selectLayer(e);
			},
			addLayer: () ->
			{
				model.addLayer();
				core.world.addTerrainLayer(TerrainAssets.getTerrain(model.layers.toArray()[model.layers.length - 1].terrainId));
			},
			changeBrushSize: e -> model.brushSize = e,
			changeBrushOpacity: e -> model.brushOpacity = e
		}));

		var previewShape = new Cylinder(20, 0.5, 0.02, true);
		previewShape.addNormals();
		previewShape.addUVs();
		preview = new Mesh(previewShape, Material.create(Texture.fromColor(0xFFFF00)), core.s3d);
		preview.material.mainPass.culling = Face.None;
		preview.material.receiveShadows = false;
		preview.material.castShadows = false;
		preview.visible = false;
		preview.z = 0.1;
		preview.setRotation(0, 0, Math.PI / 2);

		Observable.auto(() -> core.model.observables.toolState.value == ToolState.TerrainEditor && model.observables.layers.value.length > 0).bind(isActive -> {
			preview.visible = isActive;
			if (!isActive) isDrawActive = false;
		});

		model.observables.selectedBrushId.bind(id -> {
			alphaMap.clear();
			alphaMap.drawRect(0, 0, core.world.worldConfig.size.y * 2, core.world.worldConfig.size.x * 2);
		});

		model.observables.brushSize.bind(preview.setScale);
	}

	public function onWorldClick(e:Event):Void
	{
		if (preview.visible && e.button == 0)
		{
			draw(e);
			dragStartPoint = null;
		}
	}

	public function onWorldMouseDown(e:Event):Void
	{
		if (preview.visible && e.button == 0) isDrawActive = true;
	}

	public function onWorldMouseUp(e:Event):Void
	{
		if (preview.visible && e.button == 0)
		{
			isDrawActive = false;
			dragStartPoint = null;
		}
	}

	public function onWorldMouseMove(e:Event):Void
	{
		if (preview.visible)
		{
			var previewSize = preview.primitive.getBounds().getSize();
			preview.x = core.snapPosition(e.relX);
			preview.y = core.snapPosition(e.relY);

			if (isDrawActive) draw(e);
		}
	}

	function draw(e)
	{
		if (lastDrawedPoint.x != preview.x || lastDrawedPoint.y != preview.y)
		{
			if (dragStartPoint == null) dragStartPoint = { x: e.relX, y: e.relY };

			lastDrawedPoint.x = preview.x;
			lastDrawedPoint.y = preview.y;

			var tex = core.world.terrainLayers[model.selectedLayerIndex].material.mainPass.getShader(AlphaMask).texture;
			tex.flags.set(Target);
			alphaMap.beginFill(0xFFFFFF, model.brushOpacity);
			alphaMap.drawCircle(
				cast core.world.worldConfig.size.x * 2 - ((core.model.isYDragLocked ? dragStartPoint.x : preview.x) * 2),
				cast core.world.worldConfig.size.y * 2 - ((core.model.isXDragLocked ? dragStartPoint.y : preview.y) * 2),
				model.brushSize,
				10
			);
			alphaMap.drawTo(tex);
			alphaMap.endFill();
		}
	}

	public function onWorldWheel(e:Event):Void
	{

	}
}
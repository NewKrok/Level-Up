package levelup.component.editor.modules.terrain;
import coconut.ui.RenderResult;
import levelup.component.editor.modules.heightmap.HeightMapModel;

import h2d.Graphics;
import h3d.mat.Data.Wrap;
import h3d.prim.Grid;
import h3d.scene.Mesh;
import h3d.shader.AlphaMap;
import h3d.shader.NormalMap;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import levelup.editor.EditorState.EditorActionType;
import levelup.editor.EditorState.EditorCore;
import levelup.component.editor.modules.heightmap.HeightMapModel.BrushType;
import levelup.component.editor.modules.terrain.TerrainEditorView;
import levelup.component.editor.modules.terrain.TerrainModel.TerrainLayer;
import levelup.shader.ForcedZIndex;
import levelup.util.GeomUtil3D;
import tink.pure.List;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class TerrainModule
{
	var core:EditorCore = _;

	public var model:TerrainModel;

	var view:RenderResult;

	var preview:h3d.scene.Graphics;
	var previewPos:SimplePoint = { x: 0, y: 0 };
	var isDrawActive:Bool;
	var lastDrawedPoint:SimplePoint = { x: 0, y: 0 };
	var dragStartPoint:SimplePoint = null;

	var alphaMap:Graphics = new Graphics();

	public function new()
	{
		core.model.registerModule({
			id: "TerrainModule",
			icon: "fa-paint-brush",
			instance: cast this
		});

		model = new TerrainModel();

		if (core.world.worldConfig.terrainLayers != null)
		{
			var index = 0;
			for (l in core.world.worldConfig.terrainLayers)
			{
				var layerInstance:Mesh = core.world.terrainLayers[index];
				var grid:Grid = cast layerInstance.primitive;
				model.addLayer(l.textureId, l.uvScale);
				model.layers.toArray()[model.layers.length - 1].uvScale.observe().bind(v ->
				{
					scaleTerrainTexture(layerInstance, v);
				});
				index++;
			}
		}

		var terrainChooser = new TerrainChooser({
			terrainList: List.fromArray(TerrainAssets.terrains),
			selectTerrain: id -> {
				core.dialogManager.closeCurrentDialog();
				model.selectedLayer.terrainId.set(id);
				var newTerrain = TerrainAssets.getTerrain(model.selectedLayer.terrainId);

				var changeTerrain = () ->
				{
					var activeMesh = core.world.terrainLayers[model.selectedLayerIndex];
					activeMesh.material.texture = AssetCache.instance.getTexture(newTerrain.textureUrl);
					activeMesh.material.texture.wrap = Wrap.Repeat;

					var prevNormalMap = activeMesh.material.mainPass.getShader(NormalMap);
					if (prevNormalMap != null) activeMesh.material.mainPass.removeShader(prevNormalMap);

					if (newTerrain.normalMapUrl != null)
					{
						var normalMap = AssetCache.instance.getTexture(newTerrain.normalMapUrl);
						normalMap.wrap = Wrap.Repeat;
						activeMesh.material.mainPass.addShader(new NormalMap(normalMap));
					}
				}

				if (AssetCache.instance.hasTextureCache(newTerrain.textureUrl)) changeTerrain();
				else
				{
					var list = [newTerrain.textureUrl];
					if (newTerrain.normalMapUrl != null) list.push(newTerrain.normalMapUrl);
					AssetCache.instance.loadTextures(list).handle(changeTerrain);
				}
			},
			close: core.dialogManager.closeCurrentDialog
		});
		var terrainChooserView = terrainChooser.reactify();

		view = TerrainEditorView.fromHxx({
			selectedBrushId: model.observables.selectedBrushId,
			changeSelectedBrushRequest: id -> model.selectedBrushId = id,
			layers: model.observables.layers,
			selectedLayer: model.observables.selectedLayer,
			selectLayer: model.selectLayer,
			openTerrainSelector: (e:TerrainLayer) ->
			{
				terrainChooser.setSelectedTerrainId(e.terrainId.value);
				core.dialogManager.openDialog({ view: terrainChooserView });
			},
			addLayer: () ->
			{
				model.addLayer();
				var terrainData = TerrainAssets.getTerrain(model.layers.toArray()[model.layers.length - 1].terrainId);

				var createLayer = () ->
				{
					core.world.addTerrainLayer(terrainData, 1);
					var layerInstance:Mesh = core.world.terrainLayers[core.world.terrainLayers.length - 1];
					var grid:Grid = cast layerInstance.primitive;
					model.layers.toArray()[model.layers.length - 1].uvScale.observe().bind(v ->
					{
						scaleTerrainTexture(layerInstance, v);
					});
				}

				if (AssetCache.instance.hasTextureCache(terrainData.textureUrl)) createLayer();
				else
				{
					var list = [terrainData.textureUrl];
					if (terrainData.normalMapUrl != null) list.push(terrainData.normalMapUrl);
					AssetCache.instance.loadTextures(list).handle(createLayer);
				}
			},
			changeBrushSize: e -> model.brushSize = e,
			changeBrushOpacity: e -> model.brushOpacity = e,
			changeBrushGradient: e -> model.brushGradient = e,
			changeBrushNoise: e -> model.brushNoise = e,
			changeLayerUVScale: function (l:TerrainLayer, s:Float) l.uvScale.set(s),
			deleteLayer: (l, i) ->
			{
				core.world.removeTerrainLayer(i);
				model.removeLayer(l);
			},
			brushType: model.observables.brushType,
			changeBrushType: v -> model.brushType = v
		});

		preview = new h3d.scene.Graphics(core.s3d);
		preview.material.mainPass.addShader(new ForcedZIndex(10));
		preview.visible = false;

		/*Observable.auto(() ->
			core.model.observables.toolState.value == ModuleId.TerrainEditor
			&& model.observables.layers.value.length > 0
			&& model.observables.selectedLayerIndex.value > 0
		).bind(isActive -> {
			preview.visible = isActive;
			if (!isActive) isDrawActive = false;
		});*/
	}

	function scaleTerrainTexture(layer:Mesh, scale:Float)
	{
		var grid:Grid = cast layer.primitive;

		grid.addUVs();
		grid.uvScale(30 / scale, 30 / scale);
		grid.buffer = null;

		var s = layer.material.mainPass.getShader(AlphaMap);
		if (s != null) s.uvScale.set(0.03333 * scale, 0.03333 * scale);
	}

	public function onWorldClick(e:Event):Void
	{
		if (preview.visible && e.button == 0)
		{
			lastDrawedPoint.x = -1;
			lastDrawedPoint.y = -1;
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
			drawPreview(core.snapPosition(e.relX), core.snapPosition(e.relY));

			if (isDrawActive) draw(e);
		}
	}

	function drawPreview(x, y)
	{
		previewPos.x = x;
		previewPos.y = y;

		preview.clear();
		preview.lineStyle(4, 0xFFFF00, 0.2);

		if (model.selectedBrushId == 0)
		{
			var angle = 0.0;
			var piece = Std.int(5 + model.brushSize / 10 * 20);

			for (i in 0...piece)
			{
				angle += Math.PI * 2 / (piece - 1);
				var xPos = x + Math.cos(angle) * model.brushSize / 2;
				var yPos = y + Math.sin(angle) * model.brushSize / 2;
				var zPos = GeomUtil3D.getHeightByPosition(core.world.heightGrid, xPos, yPos);

				if (i == 0) preview.moveTo(xPos, yPos, zPos);
				else preview.lineTo(xPos, yPos, zPos);
			}
		}
		else
		{
			var piece = Std.int(model.brushSize);
			var pieceSize = model.brushSize / piece;

			var xPos = x + -pieceSize * piece / 2;
			var yPos = y + -pieceSize * piece / 2;
			var zPos = GeomUtil3D.getHeightByPosition(core.world.heightGrid, xPos, yPos);
			preview.moveTo(xPos, yPos, zPos);

			var lastX = xPos;
			var lastY = yPos;

			var draw = function(dX, dY)
			{
				var zPos = GeomUtil3D.getHeightByPosition(core.world.heightGrid, dX, dY);
				preview.lineTo(dX, dY, zPos);
				lastX = dX;
				lastY = dY;
			}

			for (i in 0...piece)
			{
				var xPos = lastX + pieceSize;
				draw(xPos, lastY);

			}
			for (i in 0...piece)
			{
				var yPos = lastY + pieceSize;
				draw(lastX, yPos);
			}
			for (i in 0...piece)
			{
				var xPos = lastX - pieceSize;
				draw(xPos, lastY);
			}
			for (i in 0...piece)
			{
				var yPos = lastY - pieceSize;
				draw(lastX, yPos);
			}
		}
	}

	function draw(e)
	{
		if (lastDrawedPoint.x != previewPos.x || lastDrawedPoint.y != previewPos.y)
		{
			if (dragStartPoint == null) dragStartPoint = { x: e.relX, y: e.relY };

			lastDrawedPoint.x = previewPos.x;
			lastDrawedPoint.y = previewPos.y;
			var calculatedX = (core.model.isYDragLocked ? dragStartPoint.x : previewPos.x) * 2;
			var calculatedY = (core.model.isXDragLocked ? dragStartPoint.y : previewPos.y) * 2;

			var tex = core.world.terrainLayers[model.selectedLayerIndex].material.mainPass.getShader(AlphaMap).texture;
			tex.flags.set(Target);

			var drawColor = model.brushType == BrushType.Up ? 0xFFFFFF : 0x000000;

			alphaMap.beginFill(drawColor, model.brushOpacity);

			if (model.selectedBrushId == 0)
			{
				if (model.brushNoise == 0 && model.brushGradient == 0)
				{
					alphaMap.drawCircle(
						calculatedX,
						calculatedY,
						model.brushSize,
						12
					);
				}
				else
				{
					for (i in 0...cast model.brushSize * 2)
					{
						for (j in 0...cast model.brushSize * 2)
						{
							var absI = Math.abs(i - model.brushSize);
							var absJ = Math.abs(j - model.brushSize);
							var middleDistance = Math.sqrt(absI * absI + absJ * absJ);
							var ratio = middleDistance > model.brushSize ? 0 : 1 - (middleDistance / model.brushSize * model.brushGradient);

							var alphaByGradient = model.brushGradient == 0 ? 1 : Math.sin(ratio * Math.PI / 2);
							var alphaByNoise = model.brushNoise == 0 ? 1 : Math.random();

							if (model.brushNoise == 0 || Math.random() > model.brushNoise)
							{
								alphaMap.beginFill(drawColor, model.brushOpacity * alphaByGradient * alphaByNoise);
								alphaMap.drawRect(
									calculatedX - model.brushSize + i,
									calculatedY - model.brushSize + j,
									1,
									1
								);
							}
						}
					}
				}
			}
			else
			{
				if (model.brushNoise == 0 && model.brushGradient == 0)
				{
					alphaMap.drawRect(
						calculatedX - model.brushSize,
						calculatedY - model.brushSize,
						model.brushSize * 2,
						model.brushSize * 2
					);
				}
				else
				{
					for (i in 0...cast model.brushSize * 2)
					{
						for (j in 0...cast model.brushSize * 2)
						{
							var absI = Math.abs(i - model.brushSize);
							var absJ = Math.abs(j - model.brushSize);
							var middleDistance = absI < absJ ? absJ : absI;
							var ratio = 1 - (middleDistance / model.brushSize * model.brushGradient);

							var alphaByGradient = model.brushGradient == 0 ? 1 : Math.sin(ratio * Math.PI / 2);
							var alphaByNoise = model.brushNoise == 0 ? 1 : Math.random();

							if (model.brushNoise == 0 || Math.random() > model.brushNoise)
							{
								alphaMap.beginFill(drawColor, model.brushOpacity * alphaByGradient * alphaByNoise);
								alphaMap.drawRect(
									calculatedX - model.brushSize + i,
									calculatedY - model.brushSize + j,
									1,
									1
								);
							}
						}
					}
				}
			}
			alphaMap.drawTo(tex);
			alphaMap.endFill();
		}
	}
}
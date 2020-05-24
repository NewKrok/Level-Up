package levelup.editor.module.heightmap;

import h2d.Bitmap;
import h2d.Graphics;
import h2d.Mask;
import h2d.Object;
import h2d.Tile;
import h3d.mat.Texture;
import hpp.heaps.HppG;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import hxd.Res;
import hxd.clipper.Rect;
import levelup.editor.EditorModel.ToolState;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import levelup.editor.module.heightmap.HeightMapModel.BrushType;
import levelup.shader.ForcedZIndex;
import levelup.util.GeomUtil3D;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class HeightMapModule
{
	var core:EditorCore = _;

	public var model:HeightMapModel;

	var preview:h3d.scene.Graphics;
	var previewPos:SimplePoint = { x: 0, y: 0 };
	var isDrawActive:Bool;
	var lastDrawedPoint:SimplePoint = { x: 0, y: 0 };
	var dragStartPoint:SimplePoint = null;

	var alphaMap:Graphics = new Graphics();

	var drawSpeedState = 0;
	var flatBrushColor = 0xFFFFFF;

	public function new()
	{
		model = new HeightMapModel();

		core.registerView(EditorViewId.VHeightMapModule, HeightMapEditorView.fromHxx({
			selectedBrushId: model.observables.selectedBrushId,
			drawSpeed: model.observables.drawSpeed,
			brushSize: model.observables.brushSize,
			brushOpacity: model.observables.brushOpacity,
			brushGradient: model.observables.brushGradient,
			brushNoise: model.observables.brushNoise,
			changeSelectedBrushRequest: id -> model.selectedBrushId = id,
			changeDrawSpeed: e -> model.drawSpeed = e,
			changeBrushSize: e -> model.brushSize = e,
			changeBrushOpacity: e -> model.brushOpacity = e,
			changeBrushGradient: e -> model.brushGradient = e,
			changeBrushNoise: e -> model.brushNoise = e,
			brushType: model.observables.brushType,
			changeBrushType: v -> model.brushType = v
		}));

		preview = new h3d.scene.Graphics(core.s3d);
		preview.material.mainPass.addShader(new ForcedZIndex(10));
		preview.visible = false;

		core.model.observables.toolState.bind(v -> {
			preview.visible = v == ToolState.HeightMapEditor;
			if (!preview.visible) isDrawActive = false;
		});
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
		if (preview.visible && e.button == 0)
		{
			isDrawActive = true;
			flatBrushColor = core.world.heightMap.getPixel(Math.floor(e.relX), Math.floor(e.relY));
		}
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

			drawSpeedState++;
			if (isDrawActive && drawSpeedState % (100 - model.drawSpeed) == 0) draw(e);
		}
	}

	function drawPreview(x:Float, y:Float)
	{
		previewPos.x = x / 2;
		previewPos.y = y / 2;

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

	function draw(e:Event)
	{
		if (lastDrawedPoint.x != previewPos.x || lastDrawedPoint.y != previewPos.y)
		{
			if (dragStartPoint == null) dragStartPoint = { x: Math.round(e.relX / 2), y: Math.round(e.relY / 2) };

			lastDrawedPoint.x = previewPos.x;
			lastDrawedPoint.y = previewPos.y;
			var calculatedX:Int = cast (core.model.isYDragLocked ? dragStartPoint.x : previewPos.x) * 2;
			var calculatedY:Int = cast (core.model.isXDragLocked ? dragStartPoint.y : previewPos.y) * 2;

			var drawColor:Int = model.brushType == BrushType.Flat
				? flatBrushColor
				: model.brushType == BrushType.Smooth
					? core.world.heightMap.getPixel(calculatedX, calculatedY)
					: model.brushType == BrushType.Up ? 0xFFFFFF : 0x000000;

			// TODO solve "Down" opacity problem
			alphaMap.beginFill(drawColor, model.brushType == BrushType.Flat ? 1 : model.brushType == BrushType.Up ? model.brushOpacity : 0.1);

			if (model.selectedBrushId == 0)
			{
				if (model.brushType == BrushType.Flat || (model.brushNoise == 0 && model.brushGradient == 0))
				{
					alphaMap.drawCircle(
						calculatedX,
						calculatedY,
						model.brushSize / 2,
						12
					);
				}
				else
				{
					for (i in 0...cast model.brushSize)
					{
						for (j in 0...cast model.brushSize)
						{
							var absI = Math.abs(i - model.brushSize / 2);
							var absJ = Math.abs(j - model.brushSize / 2);
							var middleDistance = Math.sqrt(absI * absI + absJ * absJ);

							var ratio = model.brushType == BrushType.Smooth
								? middleDistance > model.brushSize / 2 ? 0 : 1 - (middleDistance / (model.brushSize / 2) * 0.5)
								: middleDistance > model.brushSize / 2 ? 0 : 1 - (middleDistance / (model.brushSize / 2) * model.brushGradient);

							var alphaByGradient = model.brushType == BrushType.Smooth
								? Math.sin(ratio * Math.PI / 2)
								: model.brushGradient == 0 ? 1 : Math.sin(ratio * Math.PI / 2);

							var alphaByNoise = model.brushNoise == 0 || model.brushType == BrushType.Flat ? 1 : Math.random();

							if (model.brushType == BrushType.Smooth || model.brushNoise == 0 || Math.random() > model.brushNoise)
							{
								alphaMap.beginFill(drawColor, model.brushOpacity * alphaByGradient * alphaByNoise);
								alphaMap.drawRect(
									calculatedX - model.brushSize / 2 + i,
									calculatedY - model.brushSize / 2 + j,
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
				if (model.brushType == BrushType.Flat || (model.brushNoise == 0 && model.brushGradient == 0))
				{
					alphaMap.drawRect(
						calculatedX - model.brushSize / 2,
						calculatedY - model.brushSize / 2,
						model.brushSize,
						model.brushSize
					);
				}
				else
				{
					for (i in 0...cast model.brushSize)
					{
						for (j in 0...cast model.brushSize)
						{
							var absI = Math.abs(i - model.brushSize / 2);
							var absJ = Math.abs(j - model.brushSize / 2);
							var middleDistance = absI < absJ ? absJ : absI;
							var ratio = 1 - (middleDistance / (model.brushSize / 2) * model.brushGradient);

							var alphaByGradient = model.brushGradient == 0 ? 1 : Math.sin(ratio * Math.PI / 2);
							var alphaByNoise = model.brushNoise == 0 ? 1 : Math.random();

							if (model.brushNoise == 0 || Math.random() > model.brushNoise)
							{
								alphaMap.beginFill(drawColor, model.brushOpacity * alphaByGradient * alphaByNoise);
								alphaMap.drawRect(
									calculatedX - model.brushSize / 2 + i,
									calculatedY - model.brushSize / 2 + j,
									1,
									1
								);
							}
						}
					}
				}
			}

			var bmp = core.world.heightMap;

			var tex = Texture.fromBitmap(bmp);
			tex.flags.set(Target);
			alphaMap.drawTo(tex);
			alphaMap.endFill();
			alphaMap.clear();

			bmp.setPixels(tex.capturePixels());

			if (bb != null) bb.remove();
			bb = new Bitmap(Tile.fromBitmap(bmp));
			HppG.stage2d.addChild(bb);
			bb.x = 100;
			bb.y = 100;

			core.world.updateHeightMap();
			core.updateGrid();
			core.isPathFindingLayerDirty = true;
		}
	}
	var bb = new Bitmap();
}
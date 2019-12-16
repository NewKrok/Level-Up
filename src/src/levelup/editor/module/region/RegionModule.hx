package levelup.editor.module.region;

import h3d.mat.BlendMode;
import h3d.mat.Material;
import h3d.mat.Texture;
import h3d.prim.Grid;
import h3d.scene.Mesh;
import h3d.scene.Object;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import levelup.editor.EditorModel.ToolState;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import levelup.shader.ForcedZIndex;
import levelup.util.SaveUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class RegionModule
{
	var core:EditorCore = _;
	var regionViews:Array<Mesh> = [];

	var regionContainer:Object;
	var dragStartPoint:SimplePoint = null;
	var activeRegion:Mesh = null;

	public function new()
	{
		core.registerView(EditorViewId.VRegionModule, RegionEditorView.fromHxx({
			regions: core.model.observables.regions,
			addRegion: type -> createRegion.bind(10, 10)
		}));

		regionContainer = new Object(core.s3d);

		core.model.observables.toolState.bind(v ->
		{
			regionContainer.visible = v == ToolState.RegionEditor;
		});

		for (r in core.model.regions) createRegion(r.x, r.y, r.width, r.height);
	}

	public function onWorldClick(e:Event):Void
	{
		/*if (core.model.toolState == ToolState.RegionEditor && e.button == 0)
		{
			createRegion(core.snapPosition(e.relX), core.snapPosition(e.relY));
		}*/
	}

	function createRegion(x:Float, y:Float, width:Int, height:Int)
	{
		var region = new Grid(width, height);
		region.addNormals();
		region.addUVs();

		var mesh = new Mesh(region, Material.create(Texture.fromColor(0x0000FF)), regionContainer);
		mesh.material.blendMode = BlendMode.SoftAdd;
		mesh.material.mainPass.addShader(new ForcedZIndex(10));
		mesh.material.castShadows = false;
		mesh.x = x;
		mesh.y = y;

		regionViews.push(mesh);
		updateRegionZPositions();

		return mesh;
	}

	function updateRegionZPositions()
	{
		var mapGrid = core.world.heightGrid;
		var getZPositionFromGrid = function(x, y)
		{
			for (p in mapGrid)
			{
				if (p.x == x && p.y == y) return p.z;
			}

			return 0;
		}

		for (r in regionViews)
		{
			var grid:Grid = cast r.primitive;

			for (p in grid.points)
			{
				p.z = getZPositionFromGrid(Math.floor(r.x + p.x), Math.floor(r.y + p.y));
			}
		}
	}

	public function onWorldMouseDown(e:Event):Void
	{
		if (core.model.toolState == ToolState.RegionEditor && e.button == 0) dragStartPoint = { x: e.relX, y: e.relY };
	}

	public function onWorldMouseUp(e:Event):Void
	{
		if (activeRegion != null)
		{
			var grid:Grid = cast activeRegion.primitive;

			core.model.regions.push({
				id: Std.string(Date.now().getTime() + Math.random()),
				name: getGridName(),
				x: cast activeRegion.x,
				y: cast activeRegion.y,
				width: grid.width,
				height: grid.height
			});

			dragStartPoint = null;
			activeRegion = null;
		}
	}

	function getGridName() return "Region " + core.model.regions.length;

	public function onWorldMouseMove(e:Event):Void
	{
		if (dragStartPoint != null)
		{
			var newWidth:Int = Math.ceil(Math.abs(e.relX - dragStartPoint.x));
			var newHeight:Int = Math.ceil(Math.abs(e.relY - dragStartPoint.y));
			if (newWidth == 0 || newHeight == 0) return;

			if (activeRegion != null)
			{
				var grid:Grid = cast activeRegion.primitive;
				if (newWidth == grid.width && newHeight == grid.height) return;

				regionViews.remove(activeRegion);
				activeRegion.primitive.dispose();
				activeRegion.remove();
			}

			activeRegion = createRegion(
				e.relX > dragStartPoint.x ? Math.floor(dragStartPoint.x) : Math.floor(dragStartPoint.x - newWidth) + 1,
				e.relY > dragStartPoint.y ? Math.floor(dragStartPoint.y) : Math.floor(dragStartPoint.y - newHeight) + 1,
				newWidth, newHeight
			);
		}
	}

	/*function drawPreview(x, y)
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

			var tex = core.world.terrainLayers[model.selectedLayerIndex].material.mainPass.getShader(AlphaMask).texture;
			tex.flags.set(Target);
			alphaMap.beginFill(0xFFFFFF, model.brushOpacity);

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
								alphaMap.beginFill(0xFFFFFF, model.brushOpacity * alphaByGradient * alphaByNoise);
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
								alphaMap.beginFill(0xFFFFFF, model.brushOpacity * alphaByGradient * alphaByNoise);
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
	}*/
}
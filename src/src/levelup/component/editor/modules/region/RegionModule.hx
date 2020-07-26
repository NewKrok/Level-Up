package levelup.component.editor.modules.region;

import coconut.ui.RenderResult;
import h3d.Vector;
import h3d.mat.BlendMode;
import h3d.mat.Material;
import h3d.mat.Texture;
import h3d.prim.Grid;
import h3d.scene.Interactive;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.shader.LineShader;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;
import levelup.shader.ForcedZIndex;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class RegionModule
{
	var core:EditorCore = _;

	var regionViews:Array<Mesh> = [];

	var model:RegionModel;

	var view:RenderResult;

	var regionContainer:Object;
	var dragStartPoint:SimplePoint = null;
	var activeRegionMesh:Mesh = null;
	var hoveredRegion:Mesh = null;
	var draggedRegion:Mesh = null;
	var draggedRegionStartPosition:SimplePoint = null;

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MRegion,
			icon: "fa-object-ungroup",
			instance: cast this
		});

		model = new RegionModel();

		view = RegionEditorView.fromHxx({
			regions: model.observables.regions,
			addRegion: type -> createRegion.bind(10, 10)
		});

		regionContainer = new Object(core.s3d);
		regionContainer.visible = false;

		/*core.model.observables.toolState.bind(v ->
		{
			regionContainer.visible = v == ModuleId.RegionEditor;
		});*/

		for (r in core.model.regions)
		{
			var instance = createRegion(r.x, r.y, r.width, r.height);
			createControllerForRegion(instance);
			r.instance = instance;
		}

		model.addRegions(core.model.regions);
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
		updateZPositions(mesh);

		return mesh;
	}

	function createControllerForRegion(r:Mesh)
	{
		var mainInteractive = new Interactive(r.getCollider(), regionContainer);
		mainInteractive.onOver = e ->
		{
			hoveredRegion = r;
		}
		mainInteractive.onOut = e ->
		{
			hoveredRegion = null;
		}
		mainInteractive.onPush = e ->
		{
			draggedRegion = r;
			dragStartPoint = { x: e.relX, y: e.relY };
			draggedRegionStartPosition = { x: r.x, y: r.y };
		}
		mainInteractive.onRelease = e ->
		{
			draggedRegion = null;
			dragStartPoint = null;
			draggedRegionStartPosition = null;
		}
		mainInteractive.onReleaseOutside = e ->
		{
			draggedRegion = null;
			dragStartPoint = null;
			draggedRegionStartPosition = null;
		}
	}

	function updateZPositions(r)
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

		var grid:Grid = cast r.primitive;
		grid.buffer = null;

		for (p in grid.points)
		{
			p.z = getZPositionFromGrid(Math.floor(r.x + p.x), Math.floor(r.y + p.y));
		}
	}

	public function onWorldMouseDown(e:Event):Void
	{
		/*if (core.model.toolState == ModuleId.RegionEditor && e.button == 0) dragStartPoint = { x: e.relX, y: e.relY };*/
	}

	public function onWorldMouseUp(e:Event):Void
	{
		if (activeRegionMesh != null)
		{
			var grid:Grid = cast activeRegionMesh.primitive;

			var region = {
				id: Std.string(Date.now().getTime() + Math.random()),
				name: getGridName(),
				x: cast activeRegionMesh.x,
				y: cast activeRegionMesh.y,
				width: grid.width,
				height: grid.height
			}

			core.model.regions.push(region);

			createControllerForRegion(activeRegionMesh);
			model.addRegion(region);

			dragStartPoint = null;
			activeRegionMesh = null;
		}
	}

	function getGridName() return "Region " + core.model.regions.length;

	public function onWorldMouseMove(e:Event):Void
	{
		if (dragStartPoint != null && draggedRegion == null)
		{
			var newWidth:Int = Math.ceil(Math.abs(e.relX - dragStartPoint.x));
			var newHeight:Int = Math.ceil(Math.abs(e.relY - dragStartPoint.y));
			if (newWidth == 0 || newHeight == 0) return;

			if (activeRegionMesh != null)
			{
				var grid:Grid = cast activeRegionMesh.primitive;
				if (newWidth == grid.width && newHeight == grid.height) return;

				regionViews.remove(activeRegionMesh);
				activeRegionMesh.primitive.dispose();
				activeRegionMesh.remove();
			}

			activeRegionMesh = createRegion(
				e.relX > dragStartPoint.x ? Math.floor(dragStartPoint.x) : Math.floor(dragStartPoint.x - newWidth) + 1,
				e.relY > dragStartPoint.y ? Math.floor(dragStartPoint.y) : Math.floor(dragStartPoint.y - newHeight) + 1,
				newWidth, newHeight
			);
		}
		else if (draggedRegion != null)
		{
			draggedRegion.x = Math.floor(draggedRegionStartPosition.x + (e.relX - dragStartPoint.x));
			draggedRegion.y = Math.floor(draggedRegionStartPosition.y + (e.relY - dragStartPoint.y));
			updateZPositions(draggedRegion);
		}
	}
}
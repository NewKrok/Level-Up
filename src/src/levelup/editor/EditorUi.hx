package levelup.editor;

import h2d.Object;
import h3d.prim.ModelCache;
import hxd.Event;
import hxd.Key;
import hxd.Window;
import levelup.game.GameWorld;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorUi extends Object
{
	var cache:ModelCache = new ModelCache();

	var draggedInstance:h3d.scene.Object = null;
	var onlyX:Bool = false;
	var onlyY:Bool = false;

	public function new(parent, s3d, world:GameWorld)
	{
		super(parent);

		/*var baseLayout = new Flow(this);
		baseLayout.layout = Vertical;
		baseLayout.verticalSpacing = 10;

		var props = new Flow(baseLayout);
		props.layout = Horizontal;
		props.minWidth = 350;
		props.maxWidth = 350;
		props.multiline = true;

		for (k in Asset.props.keys())
		{
			var entry = new BaseButton(props, {
				labelText: k,
				fontSize: 10,
				onClick: b ->
				{
					var instance:h3d.scene.Object = cache.loadModel(Asset.props.get(k));

					var isDragged = false;
					var dragPoint:Vector;

					var interactive = new Interactive(instance.getBounds(), world);
					interactive.onMove = e -> if (isDragged) instance.setPosition(e.relX, e.relY, instance.z);
					interactive.onRelease = e -> isDragged = false;
					interactive.onPush = e -> isDragged = true;

					world.addToWorldPoint(instance, 10, 10, 1, 0.05, 0);
				}
			});
		}

		var environment = new Flow(baseLayout);
		environment.layout = Horizontal;
		environment.minWidth = 350;
		environment.maxWidth = 350;
		environment.multiline = true;

		for (k in Asset.environment.keys())
		{
			var entry = new BaseButton(environment, {
				labelText: k,
				fontSize: 10,
				onClick: b ->
				{
					var instance:h3d.scene.Object = cache.loadModel(Asset.environment.get(k));

					var isDragged = false;

					var interactive = new Interactive(instance.getBounds(), world);
					interactive.onMove = e ->
					{
						if (isDragged)
						{
							if (onlyX) instance.setPosition(e.relX, instance.y, instance.z);
							else if (onlyY) instance.setPosition(instance.x, e.relY, instance.z);
							else instance.setPosition(e.relX, e.relY, instance.z);
						}
					}
					interactive.onWheel = e -> if (isDragged) instance.setPosition(instance.x, instance.y, instance.z - e.wheelDelta);
					interactive.onRelease = e -> { interactive.shape = instance.getCollider(); isDragged = false; draggedInstance = null; };
					interactive.onPush = e -> { interactive.shape = world.getBounds(); isDragged = true; draggedInstance = instance; };

					world.addToWorldPoint(instance, 10, 10, 0, 0.08, 0);
				}
			});
		}

		baseLayout.x = HppG.stage2d.width - baseLayout.outerWidth;
*/
		Window.getInstance().addEventTarget(onKeyEvent);
	}

	function onKeyEvent(e:Event)
	{
		if (e.kind == EKeyDown)
			switch (e.keyCode)
			{
				case Key.CTRL: onlyX = true;
				case Key.SHIFT: onlyY = true;
			}

		if (e.kind == EKeyUp)
			switch (e.keyCode)
			{
				case Key.CTRL: onlyX = false;
				case Key.SHIFT: onlyY = false;
				case Key.UP if (draggedInstance != null): draggedInstance.setPosition(draggedInstance.x, draggedInstance.y, draggedInstance.z + 0.5);
				case Key.DOWN if (draggedInstance != null): draggedInstance.setPosition(draggedInstance.x, draggedInstance.y, draggedInstance.z - 0.5);
				case Key.LEFT if (draggedInstance != null): draggedInstance.rotate(0, 0, Math.PI / 6);
				case Key.RIGHT if (draggedInstance != null): draggedInstance.rotate(0, 0, -Math.PI / 6);
				case Key.ESCAPE if (draggedInstance != null):
					draggedInstance.setRotation(0, 0, 0);
					draggedInstance.z = 0;
			}
	}
}
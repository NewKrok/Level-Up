package demo.game.character;

import demo.AsyncUtil.Result;
import demo.game.GameWorld;
import demo.game.js.AStar;
import h2d.col.Point;
import h3d.prim.ModelCache;
import h3d.scene.Object;
import h3d.shader.Texture;
import haxe.Timer;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Res;
import hxd.res.Model;
import motion.Actuate;
import motion.easing.Linear;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class BaseCharacter
{
	static inline var baseSpeedBlock:Float = 10;

	var config:CharacterConfig = _;

	public var view:Object;
	public var rotationSpeed:Float = 5;
	public var path(get, never):Array<SimplePoint>;
	public var target(default, null):BaseCharacter;

	var moveToPath:Array<SimplePoint>;
	var currentPathIndex:Int;
	var currentTargetPoint:SimplePoint = { x: 0, y: 0 };
	var currentTargetAngle:Float = 0;
	var viewRotation:Float = 0;
	var cache:ModelCache = new ModelCache();

	var moveResult:Result;
	var moveResultHandler:Void->Void;

	public function new()
	{
		moveResult = { handle: function(handler:Void->Void) { moveResultHandler = handler; } };

		view = cache.loadModel(config.model);
		view.scale(config.modelScale);

		for (m in view.getMaterials())
		{
			var t = m.mainPass.getShader(Texture);
			if(t != null) t.killAlpha = true;
			m.mainPass.culling = None;
			m.getPass("shadow").culling = None;
		}
	}

	public function moveToRandomPoint():Void
	{
		move(new Point(Math.random() * GameWorld.instance.worldSize, Math.random() * GameWorld.instance.worldSize), moveToRandomPoint);
	}

	public function moveTo(point:SimplePoint):Result
	{
		moveResultHandler = null;
		currentPathIndex = -1;

		var path = AStar.search(
			GameWorld.instance.graph,
			GameWorld.instance.graph.grid[cast getWorldPoint().y][cast getWorldPoint().x],
			GameWorld.instance.graph.grid[cast point.y][cast point.x],
			{
				heuristic: untyped __js__("astar.heuristics.diagonal"),
				closest: true
			}
		);
		if (path != null)
		{
			moveToPath = [];
			for (entry in path) moveToPath.push({ x: entry.y, y: entry.x });

			view.playAnimation(cache.loadAnimation(config.model, config.moveAnimationName));
			view.currentAnimation.speed = config.speedMultiplier;
			moveToNextPathPoint();
		}
		else Timer.delay(onMoveEnd, 1);

		return moveResult;
	}

	function moveToNextPathPoint():Void
	{
		currentPathIndex++;

		if (currentPathIndex < moveToPath.length)
		{
			move({ x: moveToPath[currentPathIndex].y, y: moveToPath[currentPathIndex].x }, moveToNextPathPoint);
		}
		else onMoveEnd();
	}

	function onMoveEnd()
	{
		view.stopAnimation();
		if (moveResultHandler != null) moveResultHandler();
	}

	public function getPosition():SimplePoint
	{
		return { x: view.x, y: view.y };
	}

	public function getWorldPoint():SimplePoint
	{
		return { x: Math.floor(view.y / GameWorld.instance.blockSize), y: Math.floor(view.x / GameWorld.instance.blockSize) };
	}

	function move(targetPoint:SimplePoint, onComplete:Void->Void):Void
	{
		// Change target point to world point (Yeah maybe it's not the best place for this calculation)
		currentTargetPoint.x = targetPoint.x = targetPoint.x * GameWorld.instance.blockSize + GameWorld.instance.blockSize / 2;
		currentTargetPoint.y = targetPoint.y = targetPoint.y * GameWorld.instance.blockSize + GameWorld.instance.blockSize / 2;

		currentTargetAngle = Math.atan2(view.y - currentTargetPoint.y, view.x - currentTargetPoint.x) + Math.PI / 2;
		if (currentTargetAngle < 0) currentTargetAngle += Math.PI * 2;

		// Calculate tween time based on distance and character speed
		var distance = GeomUtil.getDistance(targetPoint, { x: view.x, y: view.y });
		var tweenTime = (distance / baseSpeedBlock) * (config.speed / config.speedMultiplier);

		Actuate.tween(view, tweenTime, { x: targetPoint.x, y: targetPoint.y }).ease(Linear.easeNone).onUpdate(updateHack).onComplete(onComplete);
	}

	// If we don't call this method the character "jumping" instead of moving, it looks an Actuate bug with haxe 4.0.0 or some Heaps problem.
	function updateHack():Void
	{
		view.x = view.x;
	}

	public function get_path():Array<SimplePoint>
	{
		return moveToPath;
	}

	public function update(d:Float)
	{
		setRotation();
	}

	function setRotation()
	{
		if (currentTargetPoint.y != view.y || currentTargetPoint.x != view.x)
		{
			if (viewRotation < 0) viewRotation += Math.PI * 2;
			var diff = currentTargetAngle - viewRotation;
			if (Math.abs(diff) > Math.PI)
			{
				if (currentTargetAngle < viewRotation)
				{
					if (currentTargetAngle == 0) currentTargetAngle = Math.PI * 2;
					else currentTargetAngle += Math.PI * 2;

					diff = currentTargetAngle - viewRotation;
				}
				else
				{
					viewRotation += Math.PI * 2;

					diff = currentTargetAngle - viewRotation;
				}
			}
			viewRotation += diff / rotationSpeed;
			view.setRotation(0, 0, viewRotation + Math.PI);
		}
	}

	public function setTarget(t:BaseCharacter) target = t;
}

typedef CharacterConfig =
{
	var model:Model;
	var modelScale:Float;
	var speed:Float;
	var speedMultiplier:Float;
	var moveAnimationName:String;
}
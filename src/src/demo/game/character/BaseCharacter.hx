package demo.game.character;

import demo.AsyncUtil.Result;
import demo.game.GameState.Player;
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
import tink.state.Observable;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class BaseCharacter
{
	static inline var baseSpeedBlock:Float = 10;

	public var owner(default, null):Player = _;
	public var config(default, null):CharacterConfig = _;

	public var view:Object;
	public var rotationSpeed:Float = 5;
	public var path(get, never):Array<SimplePoint>;

	public var target(default, null):BaseCharacter;
	public var nearestTarget(default, null):BaseCharacter;
	var lastTargetWorldPosition:SimplePoint = { x: 0, y: 0 };

	var moveToPath:Array<SimplePoint>;
	var currentPathIndex:Int;
	var currentTargetPoint:SimplePoint = { x: 0, y: 0 };
	var currentTargetAngle:Float = 0;
	var viewRotation:Float = 0;
	var cache:ModelCache = new ModelCache();

	var moveResult:Result;
	var moveResultHandler:Void->Void;

	var attackResult:Result;
	var attackResultHandler:Void->Void;

	public var state:State<CharacterState> = new State<CharacterState>(Idle);
	public var life:State<Float> = new State<Float>(0);

	public function new()
	{
		moveResult = { handle: function(handler:Void->Void) { moveResultHandler = handler; } };
		attackResult = { handle: function(handler:Void->Void) { attackResultHandler = handler; } };

		view = cache.loadModel(config.idleModel);
		view.scale(config.modelScale);

		for (m in view.getMaterials())
		{
			var t = m.mainPass.getShader(Texture);
			if(t != null) t.killAlpha = true;
			m.mainPass.culling = None;
			m.getPass("shadow").culling = None;
		}

		life.set(config.maxLife);
		life.observe().bind(function(v)
		{
			if (v == 0) state.set(Dead);
		});

		state.observe().bind(function(v)
		{
			switch(v)
			{
				case Idle:
					view.playAnimation(cache.loadAnimation(config.idleModel));

				case MoveTo | AttackMoveTo | AttackRequested:
					view.playAnimation(cache.loadAnimation(config.runModel));
					if (view.currentAnimation != null) view.currentAnimation.speed = config.speedMultiplier;

				case AttackTriggered:
					view.playAnimation(cache.loadAnimation(config.attackModel));

				case Dead:
					view.playAnimation(cache.loadAnimation(config.deathModel)).loop = false;
			}
		});
	}

	public function moveTo(point:SimplePoint):Result
	{
		if (state.value == Dead) return null;

		moveResultHandler = null;
		currentPathIndex = -1;
		if (state.value != AttackRequested) state.set(MoveTo);

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
			if (target != null)
			{
				var currentTargetWorldPosition = target.getWorldPoint();
				if (lastTargetWorldPosition.x == currentTargetWorldPosition.x && lastTargetWorldPosition.y == currentTargetWorldPosition.y)
				{
					var couldTriggerAttack = attackRoutine();
					if (couldTriggerAttack) return;
				}
				else
				{

					attack(target);
					return;
				}
			}
			move({ x: moveToPath[currentPathIndex].y, y: moveToPath[currentPathIndex].x }, moveToNextPathPoint);
		}
		else if (target != null)
		{
			attackRoutine();
		}
		else
		{
			onMoveEnd();
		}
	}

	function onMoveEnd()
	{
		state.set(Idle);
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

	public function restartMoveRoutine()
	{
		if (moveToPath != null && moveToPath.length > 0)
		{
			var p = getWorldPoint();
			var index = Std.int(Math.max(currentPathIndex - 1, 0));
			if (p.x - moveToPath[index].x > 0.5 || p.y - moveToPath[index].y > 0.5)
			{
				Actuate.stop(view, null, false, false);
				moveTo({ x: moveToPath[moveToPath.length - 1].x, y: moveToPath[moveToPath.length - 1].y });
			}
			else
			{
				currentPathIndex--;
				Actuate.stop(view, null, false, true);
			}
		}
	}

	public function get_path():Array<SimplePoint>
	{
		return moveToPath;
	}

	public function update(d:Float)
	{
		setRotation();

		if (state.value == AttackRequested && target != null) checkTargetLife();
	}

	function setRotation()
	{
		if (currentTargetPoint.y != view.y || currentTargetPoint.x != view.x || state.value == AttackTriggered)
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

	public function setNearestTarget(t:BaseCharacter) nearestTarget = t;

	public function attack(t:BaseCharacter)
	{
		if (state.value == Dead) return null;

		attackResultHandler = null;
		target = t;

		var p = target.getWorldPoint();
		lastTargetWorldPosition.x = p.x;
		lastTargetWorldPosition.y = p.y;

		state.set(AttackRequested);

		moveTo(target.getWorldPoint());

		return moveResult;
	}

	public function damage(v:Float)
	{
		life.set(Math.max(life.value - v, 0));
	}

	public function attackRoutine():Bool
	{
		if (canAttackTarget())
		{
			state.set(AttackTriggered);
			currentTargetAngle = GeomUtil.getAngle(target.getPosition(), getPosition()) + Math.PI / 2;
			if (currentTargetAngle < 0) currentTargetAngle += Math.PI * 2;

			Timer.delay(function()
			{
				if (canAttackTarget())
				{
					target.damage(calculateDamage());
					checkTargetLife();
				}
				else if (target != null) attack(target);
			}, config.attackDuration);

			Timer.delay(attackRoutine, config.attackSpeed);

			return true;
		}
		else if (target != null && target.state != Dead)
		{
			if (state == AttackTriggered) attack(target);
		}
		else
		{
			state.set(Idle);
		}

		return false;
	}

	function checkTargetLife()
	{
		if (target.state == Dead)
		{
			state.set(Idle);
			if (attackResultHandler != null) attackResultHandler();
		}
	}

	function calculateDamage()
	{
		return Math.random() * (config.damageMax - config.damageMin) + config.damageMin;
	}

	function canAttackTarget()
	{
		return
			target != null
			&& target.state != Dead
			&& GeomUtil.getDistance(getWorldPoint(), target.getWorldPoint()) <= config.attackRadius;
	}
}

typedef CharacterConfig =
{
	var idleModel:Model;
	var runModel:Model;
	var attackModel:Model;
	var deathModel:Model;
	var modelScale:Float;
	var speed:Float;
	var speedMultiplier:Float;
	var attackRadius:Float;
	var attackSpeed:Int;
	var attackDuration:Int;
	var damageMin:Float;
	var damageMax:Float;
	var maxLife:Float;
}

enum CharacterState {
	Idle;
	Dead;
	MoveTo;
	AttackMoveTo;
	AttackRequested;
	AttackTriggered;
}
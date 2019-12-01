package levelup.game.unit;

import h3d.Vector;
import h3d.shader.ColorMult;
import levelup.AsyncUtil;
import levelup.AsyncUtil.Result;
import levelup.game.GameState.PlayerId;
import levelup.game.GameWorld;
import levelup.game.js.AStar;
import h2d.Font;
import h2d.Text;
import h2d.Tile;
import h3d.col.Capsule;
import h3d.col.Point;
import h3d.mat.BlendMode;
import h3d.prim.ModelCache;
import h3d.scene.Interactive;
import h3d.scene.Object;
import h3d.scene.Scene;
import h3d.shader.Texture;
import haxe.Timer;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.res.FontBuilder;
import hxd.res.Model;
import js.lib.Date;
import motion.Actuate;
import motion.easing.Linear;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class BaseUnit
{
	public var id(default, never):UInt = Math.floor(Math.random() * 1000);

	static inline var baseSpeedBlock:Float = 10;

	var s2d:h2d.Object = _;
	var parent:Object = _;
	public var owner(default, null):PlayerId = _;
	public var config(default, null):UnitConfig = _;

	public var onClick:BaseUnit->Void;

	public var view:Object;
	public var rotationSpeed:Float = 5;
	public var path(get, never):Array<SimplePoint>;

	public var target(default, null):BaseUnit;
	public var nearestTarget(default, null):BaseUnit;
	var lastTargetWorldPosition:SimplePoint = { x: 0, y: 0 };

	var moveToPath:Array<SimplePoint>;
	var currentPathIndex:Int;
	var currentTargetPoint:SimplePoint = { x: 0, y: 0 };
	var currentTargetAngle:Float = 0;
	var viewRotation:Float = 0;
	var cache:ModelCache = new ModelCache();

	var interact:Interactive;
	var collider:Capsule;

	var moveResult:Result;
	var moveResultHandler:Void->Void;

	var attackResult:Result;
	var attackResultHandler:Void->Void;

	public var state:State<UnitState> = new State<UnitState>(Idle);
	public var life:State<Float> = new State<Float>(0);
	public var mana:State<Float> = new State<Float>(0);

	var lastAttackTime:Float = 0;
	var attackTimer:Timer;
	var moveEndDelayTimer:Timer;

	var t:Text;

	public function new()
	{
		moveResult = { handle: function(handler:Void->Void) { moveResultHandler = handler; } };
		attackResult = { handle: function(handler:Void->Void) { attackResultHandler = handler; } };

		view = cache.loadModel(config.idleModel);
		view.z = config.zOffset;
		parent.addChild(view);
		view.scale(config.modelScale);

		// 1.8 is a hacky solution to make easier the unit selection
		collider = new Capsule(new Point(0, 0, -1), new Point(0, 0, 1), config.unitSize);

		var colorShader = new ColorMult();
		colorShader.color = new Vector(0.5, 0.5, 0.5, 0.8);

		interact = new Interactive(collider, parent);
		interact.onClick = _ -> if (onClick != null) onClick(this);
		interact.onOver = _ -> view.getMaterials()[0].mainPass.addShader(colorShader);
		interact.onOut = _ -> view.getMaterials()[0].mainPass.removeShader(colorShader);

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
			if (v == 0)
			{
				Actuate.stop(view, null, false, false);
				onMoveEnd();
				state.set(Dead);
			}
		});

		mana.set(config.maxMana);

		// temporary
		//t = new Text(FontBuilder.getFont("Arial", 12), s2d);

		state.observe().bind(function(v)
		{
			switch(v)
			{
				case Idle:
					view.playAnimation(cache.loadAnimation(config.idleModel));
					view.currentAnimation.speed = config.idleAnimSpeedMultiplier * config.speedMultiplier;

				case MoveTo | AttackMoveTo | AttackRequested:
					view.playAnimation(cache.loadAnimation(config.runModel));
					view.currentAnimation.speed = config.runAnimSpeedMultiplier * config.speedMultiplier;

				case AttackTriggered:
					// Handled in a different way bewcause it's hybrid between idle and attack

				case Dead:
					view.playAnimation(cache.loadAnimation(config.deathModel)).loop = false;
					view.currentAnimation.speed = 1;
			}
		});
	}

	function runAttackAnimation()
	{
		view.playAnimation(cache.loadAnimation(config.attackModel));
		view.currentAnimation.loop = false;
		view.currentAnimation.onAnimEnd = function()
		{
			view.playAnimation(cache.loadAnimation(config.idleModel));
			view.currentAnimation.speed = 1;
			checkTargetLife();
		};

		var animDuration = view.currentAnimation.getDuration() * 1000;
		if (config.attackSpeed < animDuration) view.currentAnimation.speed = animDuration / config.attackSpeed;
	}

	public function moveTo(point:SimplePoint):Result
	{
		if (state.value == Dead) return null;

		if (moveToPath != null && moveToPath.length > 0 && point.x == moveToPath[moveToPath.length - 1].x && point.y == moveToPath[moveToPath.length - 1].y)
		{
			return moveResult;
		}

		if (state.value == AttackRequested || state.value == AttackTriggered)
		{
			Actuate.stop(view, null, false, false);
			target = null;
			nearestTarget = null;
			onMoveEnd();
			if (attackResultHandler != null) attackResultHandler();
			attackResultHandler = null;
		}

		moveResultHandler = null;
		moveToRequest(point);

		return moveResult;
	}

	function moveToRequest(point:SimplePoint)
	{
		if (state.value == Dead) return;

		var convertedTargetPoint = toWorldPoint(point);

		currentPathIndex = -1;
		if (state.value != AttackRequested) state.set(MoveTo);

		var path = AStar.search(
			GameWorld.instance.graph,
			GameWorld.instance.graph.grid[cast getWorldPoint().y][cast getWorldPoint().x],
			GameWorld.instance.graph.grid[cast convertedTargetPoint.x][cast convertedTargetPoint.y],
			{
				heuristic: untyped __js__("astar.heuristics.diagonal"),
				closest: true
			}
		);
		if (path != null)
		{
			path.pop();
			moveToPath = [];
			for (entry in path) moveToPath.push({ x: entry.y, y: entry.x });
			moveToPath.push({ x: point.x, y: point.y });

			moveToNextPathPoint();
		}
		else
		{
			moveEndDelayTimer = Timer.delay(onMoveEnd, 1);
		}
	}

	function moveToNextPathPoint():Void
	{
		currentPathIndex++;

		if (moveToPath != null && currentPathIndex < moveToPath.length)
		{
			if (target != null && target.state != Dead)
			{
				var currentTargetWorldPosition = target.getWorldPoint();
				if (
					state != AttackTriggered
					&& lastTargetWorldPosition.x == currentTargetWorldPosition.x
					&& lastTargetWorldPosition.y == currentTargetWorldPosition.y)
				{
					var couldTriggerAttack = attackRoutine();
					if (couldTriggerAttack) return;
				}
				else
				{
					attackRequest();
					return;
				}
			}
			move({ x: moveToPath[currentPathIndex].y, y: moveToPath[currentPathIndex].x }, moveToNextPathPoint);
		}
		else if (target != null && state != AttackTriggered)
		{
			if (target.state != Dead)
			{
				var couldTriggerAttack = attackRoutine();
				if (!couldTriggerAttack)
				{
					moveToRequest(target.getWorldPoint());
				}
			}
		}
		else
		{
			onMoveEnd();
		}
	}

	function onMoveEnd()
	{
		moveToPath = null;
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

	public function toWorldPoint(p:SimplePoint):SimplePoint
	{
		return { x: Math.floor(p.y / GameWorld.instance.blockSize), y: Math.floor(p.x / GameWorld.instance.blockSize) };
	}

	function move(targetPoint:SimplePoint, onComplete:Void->Void):Void
	{
		currentTargetAngle = Math.atan2(view.y - targetPoint.y, view.x - targetPoint.x) + Math.PI / 2;
		if (currentTargetAngle < 0) currentTargetAngle += Math.PI * 2;
		if (currentTargetAngle > Math.PI * 4) currentTargetAngle -= Math.PI * 4;

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
		if (state != AttackTriggered && moveToPath != null && moveToPath.length > 0)
		{
			var p = getWorldPoint();
			var index = Std.int(Math.max(currentPathIndex - 1, 0));
			if (p.x - moveToPath[index].x > 0.5 || p.y - moveToPath[index].y > 0.5)
			{
				reroute();
			}
			else
			{
				currentPathIndex--;
				Actuate.stop(view, null, false, true);
			}
		}
	}

	public function reroute()
	{
		if (state != AttackTriggered && moveToPath != null && moveToPath.length > 0)
		{
			Actuate.stop(view, null, false, false);
			moveToRequest({ x: moveToPath[moveToPath.length - 1].x, y: moveToPath[moveToPath.length - 1].y });
		}
	}

	public function get_path():Array<SimplePoint>
	{
		return moveToPath;
	}

	public function update(d:Float)
	{
		if (target == null && nearestTarget != null && state.value != UnitState.AttackTriggered && state != MoveTo)
		{
			attack(nearestTarget);
		}

		/*t.text = "Id: " + id + "\nState: " + Std.string(state.value) + "\nLife: " + Math.floor(life.value) + "\nRotation: " + Math.floor(currentTargetAngle * 100) / 100;
		var pos = cast(GameWorld.instance.parent, Scene).camera.project(view.x, view.y, view.z, HppG.stage2d.defaultWidth, HppG.stage2d.defaultHeight);
		t.setPosition(pos.x, pos.y);*/

		var now = Date.now();

		// 0.8 is a hacky solution to make easier the unit selection
		collider.a.x = view.x - 0.8 + config.zOffset * 1.7;
		collider.a.y = view.y;
		collider.b.x = view.x - 0.8 + config.zOffset * 1.7;
		collider.b.y = view.y;

		setRotation();

		if (state.value == AttackRequested && target != null) checkTargetLife();

		if (now - lastAttackTime >= config.attackSpeed && state == AttackTriggered)
		{
			attackRoutine();
		}
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
					if (currentTargetAngle > Math.PI * 4) currentTargetAngle -= Math.PI * 4;

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

	public function setNearestTarget(t:BaseUnit) nearestTarget = t;

	public function attack(t:BaseUnit)
	{
		if (state.value == Dead) return null;

		attackResultHandler = null;
		target = t;

		attackRequest();

		return attackResult;
	}

	function attackRequest()
	{
		if (state.value == Dead) return;

		var p = target.getWorldPoint();
		lastTargetWorldPosition.x = p.x;
		lastTargetWorldPosition.y = p.y;

		state.set(AttackRequested);

		moveToRequest(target.getWorldPoint());
	}

	public function damage(v:Float)
	{
		life.set(Math.max(life.value - v, 0));
	}

	function attackRoutine():Bool
	{
		if (canAttackTarget())
		{
			lastAttackTime = Date.now();
			Actuate.stop(view, null, false, false);
			state.set(AttackTriggered);
			runAttackAnimation();
			currentTargetAngle = GeomUtil.getAngle(target.getPosition(), getPosition()) + Math.PI / 2;
			if (currentTargetAngle < 0) currentTargetAngle += Math.PI * 2;

			attackTimer = Timer.delay(function()
			{
				if (canAttackTarget())
				{
					target.damage(calculateDamage());
				}
				else if (target != null && target.state != Dead) attackRequest();
			}, Math.floor(config.damagePercentDelay * view.currentAnimation.getDuration()
				* (config.attackSpeed < view.currentAnimation.getDuration() ? view.currentAnimation.getDuration() / config.attackSpeed : 1) * 1000)
			);

			return true;
		}
		else if (target != null && target.state != Dead)
		{
			if (state == AttackTriggered) attackRequest();
		}
		else
		{
			state.set(Idle);
		}

		return false;
	}

	function checkTargetLife()
	{
		if (target != null && target.state == Dead)
		{
			if (attackResultHandler != null)
			{
				Actuate.stop(view, null, false, true);
				target = null;
				nearestTarget = null;
				onMoveEnd();
				if (attackResultHandler != null) attackResultHandler();
				attackResultHandler = null;
			}
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
			&& GeomUtil.getDistance(getWorldPoint(), target.getWorldPoint()) <= config.attackRange;
	}

	public function dispose()
	{
		Actuate.stop(view, null, false, false);

		if (moveEndDelayTimer != null)
		{
			moveEndDelayTimer.stop();
			moveEndDelayTimer = null;
		}
		if (attackTimer != null)
		{
			attackTimer.stop();
			attackTimer = null;
		}

		view.removeChildren();
		view.remove();

		cache.dispose();
	}
}

typedef UnitConfig =
{
	var id:String;
	var icon:Tile;
	var idleModel:Model;
	var idleAnimSpeedMultiplier:Float;
	var runModel:Model;
	var runAnimSpeedMultiplier:Float;
	var attackModel:Model;
	var deathModel:Model;
	var modelScale:Float;
	var speed:Float;
	var speedMultiplier:Float;
	var attackRange:Float;
	var attackSpeed:Int;
	var damagePercentDelay:Float;
	var damageMin:Float;
	var damageMax:Float;
	var maxLife:Float;
	var maxMana:Float;
	var detectionRange:Float;
	var unitSize:Float;
	var isFlyingUnit:Bool;
	var zOffset:Float;
}

enum UnitState {
	Idle;
	Dead;
	MoveTo;
	AttackMoveTo;
	AttackRequested;
	AttackTriggered;
}
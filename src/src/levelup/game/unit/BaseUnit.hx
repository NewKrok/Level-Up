package levelup.game.unit;

import h2d.Flow;
import h3d.Vector;
import h3d.anim.Animation;
import h3d.anim.SmoothTarget;
import h3d.anim.SmoothTransition;
import h3d.anim.Transition;
import h3d.scene.Graphics;
import h3d.shader.ColorMult;
import h3d.shader.FixedColor;
import levelup.AsyncUtil;
import levelup.AsyncUtil.Result;
import levelup.UnitData.UnitConfig;
import levelup.game.GameState.PlayerId;
import levelup.game.GameWorld;
import levelup.game.js.AStar;
import h2d.Font;
import h2d.Text;
import h2d.Tile;
import h3d.col.Capsule;
import h3d.col.Point;
import h3d.mat.BlendMode;
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
import levelup.game.ui.UnitInfo;
import levelup.shader.Opacity;
import levelup.util.GeomUtil3D;
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
	public var createProjectile(default, null):ProjectileData->Void = _;

	public var onClick:BaseUnit->Void;

	public var view:Object;
	public var animTransition:SmoothTarget;
	public var currentAnimation:Animation;
	public var currentAnimationType:UnitAnimationType;
	public var unitInfo:UnitInfo;

	public var selectionCircle:Graphics;
	public var rotationSpeed:Float = 5;
	public var path(get, never):Array<SimplePoint>;

	public var target(default, null):BaseUnit;
	public var nearestTarget(default, null):BaseUnit;
	var lastTargetWorldPosition:SimplePoint = { x: 0, y: 0 };

	var moveToPath:Array<SimplePoint>;
	var currentPathIndex:Int;
	var currentTargetPoint:SimplePoint = { x: 0, y: 0 };
	var currentTargetAngle:Float = 0;
	public var viewRotation(default, null):Float = 0;

	var interact:Interactive;
	var collider:Capsule;

	var moveResult:Result;
	var moveResultHandler:Void->Void;

	var attackResult:Result;
	var attackResultHandler:Void->Void;

	public var state:State<UnitState> = new State<UnitState>(Idle);
	public var activeCommand:State<UnitCommand> = new State<UnitCommand>(Nothing);
	public var life:State<Float> = new State<Float>(0);
	public var mana:State<Float> = new State<Float>(0);

	var lastAttackTime:Float = 0;
	var attackTimer:Timer;
	var moveEndDelayTimer:Timer;

	var t:Text;
	var debugInfo:Flow;

	public function new()
	{
		moveResult = { handle: function(handler:Void->Void) { moveResultHandler = handler; } };
		attackResult = { handle: function(handler:Void->Void) { attackResultHandler = handler; } };

		view = AssetCache.getModel(config.modelGroup + ".idle");
		view.z = config.zOffset;
		view.scale(config.modelScale);
		parent.addChild(view);

		var s = new FixedColor(0x000000);
		for( view in view.getMaterials() ) {
			var p = view.allocPass("highlight");
			p.culling = None;
			p.depthWrite = false;
			p.addShader(s);
		}

		createSelectionCircle();

		collider = new Capsule(new Point(0, 0, -1), new Point(0, 0, 1), config.unitSize);

		var colorShader = new ColorMult();
		colorShader.color = new Vector(0.5, 0.5, 0.5, 0.8);

		interact = new Interactive(collider, parent);
		interact.onClick = _ -> if (onClick != null) onClick(this);
		interact.onOver = _ -> view.getMaterials()[0].mainPass.addShader(colorShader);
		interact.onOut = _ -> view.getMaterials()[0].mainPass.removeShader(colorShader);

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
		debugInfo = new Flow(s2d);
		debugInfo.backgroundTile = Tile.fromColor(0x000000, 1, 1, 0.5);
		debugInfo.paddingHorizontal = 10;
		debugInfo.paddingVertical = 5;
		debugInfo.borderHeight = 1;
		debugInfo.borderWidth = 1;
		t = new Text(FontBuilder.getFont("Arial", 10), debugInfo);
		t.maxWidth = 300;

		state.observe().bind(function(v)
		{
			switch(v)
			{
				case Idle if (currentAnimationType != UnitAnimationType.Idle):
					/*if (currentAnimation == null)
					{
						currentAnimation = AssetCache.getAnimation(config.modelGroup + ".idle").createInstance(view);
					}

					var newAnim = AssetCache.getAnimation(config.modelGroup + ".idle").createInstance(view);
					newAnim.onAnimEnd = () -> {};
					if (animTransition == null)
					{
						animTransition = new Transition("asd", currentAnimation, newAnim);
						animTransition.onAnimEnd = () -> {};
					}
					else
					{
						animTransition.anim1 = currentAnimation;
						animTransition.anim2 = newAnim;
						animTransition.blendFactor = 0;
					}
					currentAnimation = newAnim;
					view.playAnimation(animTransition);*/

					currentAnimationType = UnitAnimationType.Idle;
					view.playAnimation(AssetCache.getAnimation(config.modelGroup + "." + currentAnimationType));
					view.currentAnimation.speed = config.idleAnimSpeedMultiplier;

				case MoveTo | AttackRequested if (!config.isBuilding):
					currentAnimationType = UnitAnimationType.Walk;
					view.playAnimation(AssetCache.getAnimation(config.modelGroup + "." + currentAnimationType));
					view.currentAnimation.speed = config.runAnimSpeedMultiplier * config.speedMultiplier;
/*
					if (currentAnimation == null)
					{
						currentAnimation = AssetCache.getAnimation(config.modelGroup + ".idle").createInstance(view);
					}

					var newAnim = AssetCache.getAnimation(config.modelGroup + ".walk").createInstance(view);
					newAnim.onAnimEnd = () -> {};

					if (animTransition == null)
					{
						animTransition = new Transition("asd", currentAnimation, newAnim);
						animTransition.onAnimEnd = () -> {};
					}
					else
					{
						animTransition.anim1 = currentAnimation;
						animTransition.anim2 = newAnim;
						animTransition.blendFactor = 0;
					}

					//animTransition = new SmoothTransition(currentAnimation, newAnim, 200000);
					currentAnimation = newAnim;
					view.playAnimation(animTransition);*/

				case AttackTriggered:
					// Handled in a different way bewcause it's hybrid between idle and attack

				case Dead:
					currentAnimationType = UnitAnimationType.Death;
					view.playAnimation(AssetCache.getAnimation(config.modelGroup + "." + currentAnimationType)).loop = false;
					view.currentAnimation.speed = 1;

					var alphaShader = new Opacity(.5);
					view.getMaterials()[0].mainPass.addShader(alphaShader);

					Timer.delay(() -> state.set(Rotten), 2000);

				case Rotten:

				case _:
			}
		});

		unitInfo = new UnitInfo(s2d, this);
	}

	function createSelectionCircle()
	{
		selectionCircle = new Graphics(view);
		selectionCircle.lineStyle(4, 0xFFFFFF);
		var angle = 0.0;
		var piece = Std.int(5 + config.unitSize / 10 * 10);
		for (i in 0...piece)
		{
			angle += Math.PI * 2 / (piece - 1);
			var xPos = Math.cos(angle) * config.unitSize / 2;
			var yPos = Math.sin(angle) * config.unitSize / 2;
			var zPos = 2;//GeomUtil3D.getHeightByPosition(core.world.heightGrid, xPos, yPos);

			if (i == 0) selectionCircle.moveTo(xPos, yPos, zPos);
			else selectionCircle.lineTo(xPos, yPos, zPos);
		}
		selectionCircle.visible = false;
	}

	function runAttackAnimation()
	{
		if (config.hasContinuousAttackAnimation)
		{
			if (currentAnimationType != UnitAnimationType.Attack)
			{
				currentAnimationType = UnitAnimationType.Attack;
				view.playAnimation(AssetCache.getAnimation(config.modelGroup + "." + currentAnimationType));
				view.currentAnimation.speed = config.attackAnimSpeedMultiplier;
			}
		}
		else
		{
			currentAnimationType = UnitAnimationType.Attack;
			view.playAnimation(AssetCache.getAnimation(config.modelGroup + "." + currentAnimationType));
			view.currentAnimation.speed = config.attackAnimSpeedMultiplier;
			view.currentAnimation.loop = false;
			view.currentAnimation.onAnimEnd = function()
			{
				currentAnimationType = UnitAnimationType.Idle;
				view.playAnimation(AssetCache.getAnimation(config.modelGroup + "." + currentAnimationType));
				view.currentAnimation.speed = config.idleAnimSpeedMultiplier * config.speedMultiplier;
				checkTargetLife();
			};
			var animDuration = view.currentAnimation.getDuration() * 1000;
			if (config.attackSpeed < animDuration) view.currentAnimation.speed = animDuration / config.attackSpeed;
		}
	}

	public function attackMoveTo(point:SimplePoint):Result
	{
		if (state.value == Dead) return null;
		activeCommand.set(AttackMoveTo(point));

		return triggerMoveTo(point);
	}

	public function moveTo(point:SimplePoint):Result
	{
		if (state.value == Dead) return null;
		activeCommand.set(MoveTo(point));

		return triggerMoveTo(point);
	}

	function triggerMoveTo(point:SimplePoint)
	{
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
		if (state.value == Dead || config.isBuilding) return;

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

		if (path != null && path.length != 0)
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

			switch (activeCommand.value)
			{
				case UnitCommand.MoveTo(_): activeCommand.set(UnitCommand.Nothing);
				case _:
			}
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
		var isInMoveToCommand = switch (activeCommand.value)
			{
				case UnitCommand.MoveTo(_): true;
				case _: false;
			}

		if (target == null && nearestTarget != null && state.value != UnitState.AttackTriggered && !isInMoveToCommand)
		{
			attack(nearestTarget);
		}

		var camera = cast(GameWorld.instance.parent, Scene).camera;
		var pos2d = camera.project(view.x, view.y, view.z, HppG.stage2d.width, HppG.stage2d.height);

		t.text = "State: " + Std.string(state.value) + "\nCommand: " + Std.string(activeCommand.value) + "\nLife: " + Math.floor(life.value) + "\nRotation: " + Math.floor(currentTargetAngle * 100) / 100;
		debugInfo.setPosition(pos2d.x - debugInfo.getSize().width / 2, pos2d.y + 20);

		unitInfo.setPosition(pos2d.x - unitInfo.getSize().width / 2, pos2d.y - config.height * 60 * (40 / camera.pos.z));

		var now = Date.now();

		// 0.8 is a hacky solution to make easier the unit selection
		collider.a.x = view.x - 0.8 + config.zOffset * 1.7;
		collider.a.y = view.y;
		collider.b.x = view.x - 0.8 + config.zOffset * 1.7;
		collider.b.y = view.y;

		setRotation();

		if (state.value == AttackRequested && target != null) checkTargetLife();

		if (
			now - lastAttackTime >= config.attackSpeed
			&& (
				state == AttackTriggered
				|| (state == AttackRequested && config.isBuilding)
			)
		) {
			attackRoutine();
		}
	}

	function setRotation()
	{
		if (config.canRotate && state.value != Idle && (currentTargetPoint.y != view.y || currentTargetPoint.x != view.x || state.value == AttackTriggered))
		{
			if (viewRotation < 0) viewRotation += Math.PI * 2;
			var diff = currentTargetAngle - viewRotation;
			if (Math.abs(diff) > Math.PI)
			{
				if (currentTargetAngle < viewRotation)
				{
					if (currentTargetAngle == 0) currentTargetAngle = Math.PI * 2;
					else currentTargetAngle += Math.PI * 2;

					if (currentTargetAngle >= Math.PI * 4)
					{
						currentTargetAngle -= Math.PI * 4;
						viewRotation -= Math.PI * 4;
					}

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

	public function setNearestTarget(t:BaseUnit)
	{
		nearestTarget = t;
	}

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
		Actuate.stop(view, null, false, false);

		if (state.value == Dead) return;

		var p = target.getWorldPoint();
		lastTargetWorldPosition.x = p.x;
		lastTargetWorldPosition.y = p.y;

		state.set(AttackRequested);

		moveToRequest(target.getWorldPoint());
	}

	public function damage(v:Float, attacker:BaseUnit = null)
	{
		life.set(Math.max(life.value - v, 0));

		if (attacker != null && target == null && state != Dead)
		{
			target = attacker;
			attackRequest();
		}
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

			attackTimer = Timer.delay(() ->
			{
				if (canAttackTarget())
				{
					if (config.projectileConfig == null) target.damage(calculateDamage(), this);
					else createProjectile({
						owner: this,
						target: target,
						damage: calculateDamage()
					});
				}
				else if (target != null && target.state != Dead) attackRequest();
				else
				{
					target = null;
					nearestTarget = null;
					state.set(Idle);
				}
			}, Math.floor(config.damagePercentDelay * view.currentAnimation.getDuration()
				* (config.attackSpeed < view.currentAnimation.getDuration() ? view.currentAnimation.getDuration() / config.attackSpeed : 1) * 1000)
			);

			return true;
		}
		else if (target != null && target.state != Dead && !config.isBuilding)
		{
			if (state == AttackTriggered) attackRequest();
		}
		else
		{
			target = null;
			nearestTarget = null;
			state.set(Idle);
		}

		return false;
	}

	function checkTargetLife()
	{
		if (target != null && (target.state == Dead || target.state == Rotten))
		{
			target = null;
			nearestTarget = null;

			if (attackResultHandler != null)
			{
				Actuate.stop(view, null, false, true);
				onMoveEnd();
				if (attackResultHandler != null) attackResultHandler();
				attackResultHandler = null;
			}

			switch (activeCommand.value)
			{
				case AttackMoveTo(p): attackMoveTo(p);
				case _:
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
			&& GeomUtil.getDistance(cast view, cast target.view) <= config.attackRange;
	}

	public function select() selectionCircle.visible = true;
	public function deselect() selectionCircle.visible = false;

	public function dispose()
	{
		Actuate.stop(view, null, false, false);

		if (t != null) t.remove();
		if (debugInfo != null) debugInfo.remove();

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

		unitInfo.dispose();

		view.removeChildren();
		view.remove();
	}
}

typedef ProjectileData =
{
	var owner:BaseUnit;
	var target:BaseUnit;
	var damage:Float;
}

enum UnitState {
	Rotten;
	Idle;
	Dead;
	MoveTo;
	AttackRequested;
	AttackTriggered;
}

enum UnitCommand {
	Nothing;
	MoveTo(point:SimplePoint);
	AttackMoveTo(point:SimplePoint);
}

@:enum abstract UnitAnimationType(String) to String
{
	var Idle = "idle";
	var Walk = "walk";
	var Attack = "attack";
	var Death = "death";
}
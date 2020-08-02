package levelup.core.trigger;

import com.greensock.TweenMax;
import h2d.Bitmap;
import h2d.Object;
import h2d.Tile;
import hpp.heaps.HppG;
import hpp.util.GeomUtil.SimplePoint;
import levelup.core.camera.ActionCamera;
import levelup.core.camera.ActionCamera.CameraData;
import levelup.game.GameState;
import levelup.game.GameState.Trigger;
import levelup.game.GameState.TriggerAction;
import levelup.game.GameState.TriggerParams;
import levelup.game.GameState.VariableDefinition;
import levelup.game.GameState.ConditionDefinition;
import levelup.game.GameState.MathDefinition;
import levelup.game.GameState.PositionDefinition;
import levelup.game.GameState.RegionPositionDefinition;
import levelup.game.GameWorld;
import levelup.game.unit.BaseUnit;
import motion.Actuate;
import motion.easing.Linear;
import motion.easing.Quad;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TriggerExecutor
{
	var s2d:h2d.Scene;
	var s3d:h3d.scene.Scene;
	var world:GameWorld;
	var camera:ActionCamera;
	var triggers:Array<Trigger>;
	var regions:Array<Region>;
	var cameras:Array<CameraData>;

	var globalVariables:Map<String, Dynamic> = [];

	public function new(s2d, s3d, world:GameWorld, camera:ActionCamera, triggers:Array<Trigger>, cameras:Array<CameraData>, regions:Array<Region>)
	{
		this.s2d = s2d;
		this.s3d = s3d;
		this.world = world;
		this.camera = camera;
		this.triggers = triggers;
		this.regions = regions;
		this.cameras = cameras;

		world.onUnitEntersToRegion = function(r, u)
		{
			for (t in triggers)
			{
				for (e in t.events)
				{
					switch(e)
					{
						case EnterRegion(region) if (r == region): runTrigger(t, { triggeringUnit: u });
						case _:
					}
				}
			}
		}

		for (t in triggers) initTrigger(t);
	}

	function initTrigger(t:Trigger)
	{
		if (t.isEnabled && t.events != null)
		{
			for (e in t.events)
			{
				switch(e)
				{
					case OnInit: runTrigger(t);
					case TimeElapsed(time): Actuate.timer(time).onComplete(runTrigger.bind(t));
					case TimePeriodic(time): Actuate.timer(time).repeat().onRepeat(runTrigger.bind(t));
					case _:
				}
			}
		}
	}

	function runTrigger(t:Trigger, p:TriggerParams = null)
	{
		if (!t.isEnabled) return;

		if (t.condition != null)
		{
			switch (t.condition)
			{
				case OwnerOf(unitDef, expectedPlayer) if (unitDef == TriggeringUnit && p.triggeringUnit.owner == expectedPlayer): runActions(t.actions, p);

				case _:
			}
		}
		else runActions(t.actions, p);
	}

	function runActions(actions:Array<TriggerAction>, p:TriggerParams)
	{
		var localVariables:Map<String, Dynamic> = [];

		for (i in 0...actions.length)
		{
			var a = actions[i];

			if (a != null)
			{
				switch(a)
				{
					case Log(message): trace(resolveVariableDefinition(message, localVariables));
					case LoadLevel(levelName): HppG.changeState(GameState, [s2d, s3d, levelName]);
					case EnableTrigger(id): for (t in triggers) if (t.id == id) { enableTrigger(t); break; }
					case RunTrigger(id): for (t in triggers) if (t.id == id) { runTrigger(t); break; }
					case SetLocalVariable(name, variable): localVariables.set(name, resolveVariableDefinition(variable, localVariables));
					case SetGlobalVariable(name, variable): globalVariables.set(name, resolveVariableDefinition(variable, localVariables));

					case Wait(time):
						TweenMax.delayedCall(resolveVariableDefinition(time, localVariables), runActions.bind(actions.slice(i + 1), p));
						break;

					case IfElse(condition, ifActions, elseActions):
						if (resolveConditionDefinition(condition, localVariables)) runActions(ifActions, p);
						else runActions(elseActions, p);

					case JumpCameraToUnit(playerId, unitDefinition):
						// TODO Define own player id, it could be different during multiplayer games
						if (playerId == PlayerId.Player1)
						{
							var unit:BaseUnit = resolveUnitDefinition(unitDefinition, localVariables);
							camera.jumpCamera(unit.view.x, unit.view.y);
						}

					case JumpCameraToCamera(playerId, cameraName):
						// TODO Define own player id, it could be different during multiplayer games
						if (playerId == PlayerId.Player1)
						{
							var resolvedCameraName = resolveVariableDefinition(cameraName, localVariables);
							var selectedCamera = cameras.filter(r -> return r.name == resolvedCameraName)[0];
							camera.jumpCamera(
								selectedCamera.position.x,
								selectedCamera.position.y,
								selectedCamera.position.z
							);
							camera.camDistance = selectedCamera.camDistance;
							camera.camAngle = selectedCamera.camAngle;
							camera.cameraRotation = selectedCamera.cameraRotation;
						}

					case AnimateCameraToCamera(playerId, cameraName, time, ease):
						// TODO Define own player id, it could be different during multiplayer games
						if (playerId == PlayerId.Player1)
						{
							var resolvedCameraName = resolveVariableDefinition(cameraName, localVariables);
							var selectedCamera = cameras.filter(r -> return r.name == resolvedCameraName)[0];
							// TODO use tweenmax instead of actuate
							camera.animateCameraTo(
								selectedCamera,
								resolveVariableDefinition(time, localVariables),
								switch(resolveVariableDefinition(ease, localVariables))
								{
									case "quad-ease-out": Quad.easeOut;
									case "quad-ease-in-out": Quad.easeInOut;
									case "quad-ease-in": Quad.easeIn;
									case _: Linear.easeNone;
								}
							);
						}

					case StartCameraShake(playerId, amplitude, time, ease):
						// TODO Define own player id, it could be different during multiplayer games
						if (playerId == PlayerId.Player1)
						{
							camera.startCameraShake(
								resolveVariableDefinition(amplitude, localVariables),
								resolveVariableDefinition(time, localVariables),
								switch(resolveVariableDefinition(ease, localVariables))
								{
									case "quad-ease-out": com.greensock.easing.Quad.easeOut;
									case "quad-ease-in-out": com.greensock.easing.Quad.easeInOut;
									case "quad-ease-in": com.greensock.easing.Quad.easeIn;
									case _: com.greensock.easing.Linear.easeNone;
								}
							);
						}

					// TODO Define own player id, it could be different during multiplayer games
					case StopCameraShake(playerId): if (playerId == PlayerId.Player1) camera.stopCameraShake();

					case FadeOut(playerId, color, time):
						// TODO Define own player id, it could be different during multiplayer games
						if (playerId == PlayerId.Player1)
						{
							world.disposeFadeFilter();
							var filterContainer:Object = new Object(s2d);
							var filter:Bitmap = new Bitmap(Tile.fromColor(resolveVariableDefinition(color, localVariables)), filterContainer);
							filter.width = HppG.stage2d.width;
							filter.height = HppG.stage2d.height;
							TweenMax.to(filterContainer, resolveVariableDefinition(time, localVariables), {
								alpha: 0,
								onComplete: world.disposeFadeFilter
							});
							world.addFadeFilter(filterContainer);
						}

					case FadeIn(playerId, color, time):
						// TODO Define own player id, it could be different during multiplayer games
						if (playerId == PlayerId.Player1)
						{
							world.disposeFadeFilter();
							var filterContainer:Object = new Object(s2d);
							var filter:Bitmap = new Bitmap(Tile.fromColor(resolveVariableDefinition(color, localVariables)), filterContainer);
							filter.width = HppG.stage2d.width;
							filter.height = HppG.stage2d.height;
							filterContainer.alpha = 0;
							TweenMax.to(filterContainer, resolveVariableDefinition(time, localVariables), {
								alpha: 1
							});
							world.addFadeFilter(filterContainer);
						}

					case SelectUnit(playerId, unitDefinition):
						// TODO Define own player id, it could be different during multiplayer games
						//if (playerId == PlayerId.Player1) selectUnit(resolveUnitDefinition(unitDefinition, localVariables));

					case CreateUnit(unitId, owner, positionDefinition):
						var position = resolvePositionDefinition(positionDefinition);
						//createUnit(unitId, owner, position.x, position.y);

					case AttackMoveToRegion(unitDefinition, positionDefinition):
						var position = resolvePositionDefinition(positionDefinition);
						var unit:BaseUnit = resolveUnitDefinition(unitDefinition, localVariables);
						if (unit != null)
						{
							unit.attackMoveTo({ y: position.x, x: position.y });
						}

					case _: trace("Unknown action in action list: " + actions);
				}
			}
			else trace("Unknown action in action list: " + actions);
		}
	}

	function resolveConditionDefinition(conditionDefinition, localVariables:Map<String, Dynamic>):Dynamic return switch(conditionDefinition)
	{
		case Equal(v1, v2): return resolveVariableDefinition(v1, localVariables) == resolveVariableDefinition(v2, localVariables);
		case NotEqual(v1, v2): return resolveVariableDefinition(v1, localVariables) != resolveVariableDefinition(v2, localVariables);
	}

	function resolveVariableDefinition(variableDefinition, localVariables:Map<String, Dynamic>):Dynamic return switch(variableDefinition)
	{
		case Value(value): value;
		case GetLocalVariable(name): localVariables.get(name);
		case GetGlobalVariable(name): globalVariables.get(name);
		case MathOperation(value): resolveMathDefinition(value, localVariables);
	}

	function resolveMathDefinition(mathDefinition, localVariables:Map<String, Dynamic>) return switch (mathDefinition)
	{
		case Multiply(v1, v2): return resolveVariableDefinition(v1, localVariables) * resolveVariableDefinition(v2, localVariables);
		case Division(v1, v2): return resolveVariableDefinition(v1, localVariables) / resolveVariableDefinition(v2, localVariables);
		case Addition(v1, v2): return resolveVariableDefinition(v1, localVariables) + resolveVariableDefinition(v2, localVariables);
		case Subtraction(v1, v2): return resolveVariableDefinition(v1, localVariables) - resolveVariableDefinition(v2, localVariables);
		case ATan2(v1, v2): return Math.atan2(resolveVariableDefinition(v1, localVariables), resolveVariableDefinition(v2, localVariables));
		case Cos(radians): return Math.cos(resolveVariableDefinition(radians, localVariables));
		case Sin(radians): return Math.sin(resolveVariableDefinition(radians, localVariables));
		case Tan(radians): return Math.tan(resolveVariableDefinition(radians, localVariables));
		case Sqrt(v): return Math.sqrt(resolveVariableDefinition(v, localVariables));
		case Floor(v): return Math.floor(resolveVariableDefinition(v, localVariables));
		case Ceil(v): return Math.ceil(resolveVariableDefinition(v, localVariables));
		case Round(v): return Math.round(resolveVariableDefinition(v, localVariables));
		case Random: return Math.random();
	}

	function resolveUnitDefinition(unitDefinition, localVariables:Map<String, Dynamic>) return switch(unitDefinition)
	{
		case LastCreatedUnit: world.units[world.units.length - 1];
		case GetLocalVariable(name): resolveUnitDefinition(localVariables.get(name), localVariables);

		case GetUnit(definition): switch(definition)
			{
				case UnitOfPlayer(playerId, filter): getUnitsOfPlayer(playerId)[switch(filter)
				{
					case Index(value): value;
					case _: 0;
				}];

				case _: null;
			}

		case _: null;
	}

	function getUnitsOfPlayer(playerId)
	{
		return world.units.filter(u -> return u.owner == playerId);
	}

	function resolvePositionDefinition(positionDefinition):SimplePoint
	{
		switch(positionDefinition)
		{
			case PositionDefinition.RegionPosition(regionDefinition):
				switch (regionDefinition)
				{
					case RegionPositionDefinition.CenterOf(region):
						var region = resolveRegionByName(region);
						return { x: region.x + region.width / 2, y: region.y + region.height / 2 };

					case RegionPositionDefinition.RandomPointOf(region):
						var region = resolveRegionByName(region);
						return { x: region.x + region.width * Math.random(), y: region.y + region.height * Math.random() };
				}

			case PositionDefinition.WorldPoint(position): return { x: position.x, y: position.y };
		}

		return { x: 0, y: 0 };
	}

	function resolveRegionByName(name)
	{
		var raw = regions.filter(r -> return r.name == name);

		return raw != null && raw.length > 0 ? raw[0] : null;
	}

	function enableTrigger(t:Trigger)
	{
		t.isEnabled = true;
		initTrigger(t);
	}

	public function dispose()
	{

	}
}
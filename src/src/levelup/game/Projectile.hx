package levelup.game;

import h3d.Vector;
import h3d.mat.Material;
import h3d.mat.Texture;
import h3d.prim.Sphere;
import h3d.scene.Mesh;
import h3d.scene.Object;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import levelup.UnitData.ProjectileType;
import levelup.UnitData.UnitConfig;
import levelup.game.GameState.PlayerId;
import levelup.game.unit.BaseUnit;
import motion.Actuate;
import motion.easing.Linear;
import tink.CoreApi.CallbackLink;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class Projectile
{
	var parent:Object = _;
	var data(default, null):ProjectileData = _;

	public var state:State<ProjectileState> = new State<ProjectileState>(Idle);

	var view:Object;
	var targetObject:TargetObject;
	var lastPosition:{ x:Float, y:Float, z:Float };
	var direction:Vector = new Vector();
	var currentArc:Float;
	var stateLink:CallbackLink;

	public function new()
	{
		var pConfig = data.owner.config.projectileConfig;

		if (pConfig.arc == 0)
		{
			targetObject = {
				x: data.target.view.x,
				y: data.target.view.y,
				z: data.target.view.z + data.target.config.height / 2
			};
		}
		else targetObject = { x: data.target.view.x, y: data.target.view.y };

		view = AssetCache.getModel(pConfig.model);
		view.scale(0.008);
		parent.addChild(view);

		view.getMeshes()[0].defaultTransform.initRotationX(Math.PI / 2);
		view.getMeshes()[0].defaultTransform.initRotationY(Math.PI / 2);
		view.getMeshes()[0].defaultTransform.initRotationZ(Math.PI / 2);
		for (m in view.getMaterials()) m.receiveShadows = false;

		view.x =
			data.owner.view.x
			+ pConfig.initialPoint.x * Math.cos(data.owner.viewRotation + Math.PI / 2)
			+ pConfig.initialPoint.y * Math.cos(data.owner.viewRotation);

		view.y =
			data.owner.view.y
			+ pConfig.initialPoint.x * Math.sin(data.owner.viewRotation + Math.PI / 2)
			+ pConfig.initialPoint.y * Math.sin(data.owner.viewRotation);

		view.z = data.owner.view.z + data.owner.config.projectileConfig.initialPoint.z;
		lastPosition = { x: view.x, y: view.y, z: view.z };
		calculateDirection();

		var baseSpeed = data.owner.config.projectileConfig.speed;
		var distance = GeomUtil.getDistance(targetObject, { x: view.x, y: view.y });
		var tweenTime = distance * baseSpeed;

		if (pConfig.arc != 0)
		{
			Actuate.tween(view, tweenTime / 2, { z: view.z + distance / 10 * pConfig.arc }).ease(motion.easing.Sine.easeOut).onComplete(() ->
				Actuate.tween(view, tweenTime / 2, { z: data.target.view.z + data.target.config.height / 2 }).ease(motion.easing.Sine.easeIn)
			);
		}

		Actuate.tween(view, tweenTime, targetObject).ease(Linear.easeNone).onComplete(() ->
		{
			trace(GeomUtil.getDistance(cast data.target.view, cast view));
			if (data.target != null) damageTarget();
			else state.set.bind(Finished);
		}).onUpdate(() ->
		{
			calculateDirection();

			lastPosition.x = view.x = view.x;
			lastPosition.y = view.y = view.y;
			lastPosition.z = view.z = view.z;
		});

		stateLink = data.target.state.bind(v -> if (v == Dead)
		{
			Actuate.stop(view, null, false, false);
			state.set(Finished);
		});
	}

	function calculateDirection()
	{
		if (view.x != lastPosition.x || view.y != lastPosition.y || view.z != lastPosition.z)
		{
			direction.x = view.x - lastPosition.x;
			direction.y = view.y - lastPosition.y;
			direction.z = view.z - lastPosition.z;
		}
		else
		{
			direction.x = targetObject.x - lastPosition.x;
			direction.y = targetObject.y - lastPosition.y;
			direction.z = targetObject.z - lastPosition.z;
		}

		view.setDirection(direction);
	}

	public function update(d:Float)
	{
		switch (data.owner.config.projectileConfig.type)
		{
			case ProjectileType.Follower:
				targetObject.x = data.target.view.x;
				targetObject.y = data.target.view.y;
				targetObject.z = data.target.view.z + 1;

			case ProjectileType.Pointer:
		}

		if (GeomUtil.getDistance(targetObject, { x: view.x, y: view.y }) < .5) damageTarget();
	}

	function damageTarget()
	{
		switch (data.owner.config.projectileConfig.type)
		{
			case ProjectileType.Pointer if (data.target != null && GeomUtil.getDistance(cast data.target.view, cast view) < 0.5):
				data.target.damage(data.damage, data.owner);

			case ProjectileType.Follower:
				data.target.damage(data.damage, data.owner);

			case _:
		}

		Actuate.stop(view, null, false, false);
		state.set(Finished);
	}

	public function dispose()
	{
		Actuate.stop(view, null, false, false);
		stateLink.dissolve();

		view.remove();
		view = null;
	}
}

enum ProjectileState
{
	Idle;
	Finished;
}
typedef TargetObject =
{
	var x:Float;
	var y:Float;
	@:optional var z:Float;
}
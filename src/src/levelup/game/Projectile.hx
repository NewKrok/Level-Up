package levelup.game;

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

	var view:Mesh;
	var targetObject:{ x:Float, y:Float, z:Float };
	var stateLink:CallbackLink;

	public function new()
	{
		targetObject = { x: data.target.view.x, y: data.target.view.y, z: data.target.view.z }

		var s = new Sphere(0.2);
		s.addNormals();
		s.addUVs();
		view = new Mesh(s, Material.create(Texture.fromColor(0xFFFFFF)), parent);
		view.material.castShadows = false;
		view.material.receiveShadows = false;
		view.x = data.owner.view.x;
		view.y = data.owner.view.y;
		view.z = data.owner.view.z + 1;

		var baseSpeed = data.owner.config.projectileConfig.speed;
		var distance = GeomUtil.getDistance(targetObject, { x: view.x, y: view.y });
		var tweenTime = distance * baseSpeed;

		Actuate.tween(view, tweenTime, targetObject).ease(Linear.easeNone).onComplete(() ->
		{
			if (data.target != null) damageTarget();
			else state.set.bind(Finished);
		}).onUpdate(() -> {
			view.x = view.x;
			view.y = view.y;
			view.z = view.z;
		});

		stateLink = data.target.state.bind(v -> if (v == Dead)
		{
			Actuate.stop(view, null, false, false);
			state.set(Finished);
		});
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
		data.target.damage(data.damage, data.owner);
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
package levelup.game;

import com.greensock.TweenMax;
import h3d.Vector;
import h3d.mat.BlendMode;
import h3d.mat.Material;
import h3d.mat.Texture;
import h3d.parts.GpuParticles;
import h3d.parts.GpuParticles.GpuEmitMode;
import h3d.parts.Particle;
import h3d.parts.Particles;
import h3d.prim.Sphere;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.scene.Trail;
import h3d.shader.AnimatedTexture;
import haxe.Timer;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import levelup.UnitData.ProjectileConfig;
import levelup.UnitData.ProjectileType;
import levelup.UnitData.UnitConfig;
import levelup.game.GameState.PlayerId;
import levelup.game.unit.BaseUnit;
import levelup.shader.KillColor;
import levelup.shader.Opacity;
import levelup.shader.Vibrating;
import levelup.shader.Wave;
import motion.Actuate;
import motion.easing.Linear;
import motion.easing.Sine;
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
	var idleGPUEffect:GpuParticles;
	var parts2:GpuParticles;

	var pConfig:ProjectileConfig;

	var tweenObject:TweenObject;
	var projectilePositonTween:TweenMax;
	var lastPosition:{ x:Float, y:Float, z:Float };
	var direction:Vector = new Vector();
	var currentArc:Float;
	var stateLink:CallbackLink;

	public function new()
	{
		pConfig = data.owner.config.projectileConfig;

		if (pConfig.arc == 0)
		{
			tweenObject = {
				x: data.target.view.x,
				y: data.target.view.y,
				z: data.target.view.z + data.target.config.height / 2
			};
		}
		else tweenObject = { x: data.target.view.x, y: data.target.view.y };

		var projectileAnimData = ProjectileAnimationData.getConfig(pConfig.projectileAnimationId);

		view = AssetCache.getModel(projectileAnimData.modelId);
		view.scale(projectileAnimData.modelScale);
		view.getMeshes()[0].defaultTransform.initRotationX(Math.PI / 2);
		view.getMeshes()[0].defaultTransform.initRotationY(Math.PI / 2);
		view.getMeshes()[0].defaultTransform.initRotationZ(Math.PI / 2);
		for (m in view.getMaterials()) m.receiveShadows = false;

		if (projectileAnimData.idleEffect != null)
		{
			idleGPUEffect = new GpuParticles(parent);
			idleGPUEffect.material.mainPass.depthWrite = false;
			idleGPUEffect.addGroup(createGPUGroupByConfig(projectileAnimData.idleEffect, idleGPUEffect));
		}

		parent.addChild(view);

		view.x =
			data.owner.view.x
			+ pConfig.initialPoint.x * Math.cos(data.owner.viewRotation + Math.PI / 2)
			+ pConfig.initialPoint.y * Math.cos(data.owner.viewRotation);

		view.y =
			data.owner.view.y
			+ pConfig.initialPoint.x * Math.sin(data.owner.viewRotation + Math.PI / 2)
			+ pConfig.initialPoint.y * Math.sin(data.owner.viewRotation);

		view.z = data.owner.view.z + pConfig.initialPoint.z;
		lastPosition = { x: view.x, y: view.y, z: view.z };
		calculateDirection();

		var baseSpeed = pConfig.speed;
		var distance = GeomUtil.getDistance(tweenObject, { x: view.x, y: view.y });
		var tweenTime = distance * baseSpeed;

		if (pConfig.arc != 0)
		{
			Actuate.tween(view, tweenTime / 2, { z: view.z + distance / 10 * pConfig.arc }).ease(Sine.easeOut).onComplete(() ->
				Actuate.tween(view, tweenTime / 2, { z: data.target.view.z + data.target.config.height / 2 }).ease(Sine.easeIn)
			);
		}

		tweenObject.onComplete = () ->
		{
			if (data.target != null) damageTarget();
			else finish();
		};

		tweenObject.onUpdate = () ->
		{
			calculateDirection();

			lastPosition.x = view.x = view.x;
			lastPosition.y = view.y = view.y;
			lastPosition.z = view.z = view.z;
		};

		tweenObject.ease = com.greensock.easing.Linear.easeNone;

		projectilePositonTween = TweenMax.to(view, tweenTime, tweenObject);

		stateLink = data.target.state.bind(v -> if (v == Dead)
		{
			Actuate.stop(view, null, false, false);
			finish();
		});
	}

	function createGPUGroupByConfig(config, groupParent)
	{
		var res = new h3d.parts.GpuParticles.GpuPartGroup(groupParent);
		res.emitMode = switch(config.emitMode)
		{
			case "point": GpuEmitMode.Point;
			case "cone": GpuEmitMode.Cone;
			case "volumeBounds": GpuEmitMode.VolumeBounds;
			case "parentBounds": GpuEmitMode.ParentBounds;
			case "cameraBounds": GpuEmitMode.CameraBounds;
			case "disc": GpuEmitMode.Disc;
			case _: null;
		};
		res.emitDist = config.emitDist;
		res.gravity = config.gravity;
		res.size = config.size;
		res.sizeRand = config.sizeRand;
		res.sizeIncr = config.sizeIncr;
		res.rotSpeed = config.rotSpeed;
		res.rotSpeedRand = config.rotSpeedRand;
		res.speed = config.speed;
		res.speedRand = config.speedRand;
		res.life = config.life;
		res.nparts = config.nparts;
		res.fadeIn = config.fadeIn;
		res.fadeOut = config.fadeOut;
		res.texture = AssetCache.getTexture(config.texture);
		res.frameDivisionX = config.frameDivisionX;
		res.frameDivisionY = config.frameDivisionY;
		res.colorGradient = config.colorGradient != null ? AssetCache.getTexture(config.colorGradient) : null;
		res.sortMode = switch(config.sortMode)
		{
			case "none": GpuSortMode.None;
			case "dynamic": GpuSortMode.Dynamic;
			case _: null;
		};
		return res;
	}

	function finish()
	{
		state.set(Finished);

		disposeProjectile();

		if (idleGPUEffect != null) for (g in idleGPUEffect.getGroups()) g.emitLoop = false;

		Timer.delay(() ->
		{
			state.set(Disappeared);
		}, 1000);

		parts2 = new GpuParticles(parent);
		parts2.x = lastPosition.x;
		parts2.y = lastPosition.y;
		parts2.z = lastPosition.z;

		var smokeG = new GpuPartGroup(parts2);
		smokeG.emitMode = GpuEmitMode.Point;
		smokeG.emitDist = 0.1;
		smokeG.gravity = 0;
		smokeG.size = 1;
		smokeG.sizeRand = 2;
		smokeG.sizeIncr = 20;
		smokeG.rotSpeed = 0.5;
		smokeG.rotSpeedRand = 2;
		smokeG.speed = 0.2;
		smokeG.speedRand = 0.3;
		smokeG.life = 0.3;
		smokeG.nparts = 10;
		smokeG.fadeIn = 0;
		smokeG.fadeOut = 0.1;
		smokeG.texture = AssetCache.getTexture("asset/texture/effect/Circle98.png");
		smokeG.sortMode = GpuSortMode.Dynamic;
		smokeG.emitLoop = false;
		parts2.addGroup(smokeG);

		var smokeG2 = new GpuPartGroup(parts2);
		smokeG2.emitMode = GpuEmitMode.Cone;
		smokeG2.emitAngle = 0.5;
		smokeG2.emitDist = 0.3;
		smokeG2.gravity = 2;
		smokeG2.size = 0.6;
		smokeG2.sizeRand = 1;
		smokeG2.sizeIncr = 0;
		smokeG2.rotInit = 3;
		smokeG2.rotSpeed = 1;
		smokeG2.rotSpeedRand = 6;
		smokeG2.speed = 1;
		smokeG2.speedRand = 2;
		smokeG2.life = 0.4;
		smokeG2.nparts = 15;
		smokeG2.fadeIn = 0;
		smokeG2.fadeOut = 0.1;
		smokeG2.texture = AssetCache.getTexture("asset/texture/effect/Dust2.png");
		smokeG2.colorGradient = AssetCache.getTexture("asset/texture/effect/gradient/gradient_1.jpg");
		smokeG2.sortMode = GpuSortMode.Dynamic;
		smokeG2.emitLoop = false;
		parts2.addGroup(smokeG2);

		parts2.material.mainPass.depthWrite = false;
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
			direction.x = tweenObject.x - lastPosition.x;
			direction.y = tweenObject.y - lastPosition.y;
			direction.z = tweenObject.z - lastPosition.z;
		}

		view.setDirection(direction);
	}

	public function update(d:Float)
	{
		if (state.value == Finished || view == null) return;

		if (view.numChildren > 0)
		{
			view.getChildAt(0).rotate(
				pConfig.xAutoRotation != null ? pConfig.xAutoRotation : 0,
				pConfig.yAutoRotation != null ? pConfig.yAutoRotation : 0,
				pConfig.zAutoRotation != null ? pConfig.zAutoRotation : 0
			);
		}

		if (idleGPUEffect != null)
		{
			idleGPUEffect.x = lastPosition.x;
			idleGPUEffect.y = lastPosition.y;
			idleGPUEffect.z = lastPosition.z;
		}

		switch (pConfig.type)
		{
			case ProjectileType.Follower:
				tweenObject.x = data.target.view.x;
				tweenObject.y = data.target.view.y;
				if (pConfig.arc == 0) tweenObject.z = data.target.view.z;
				projectilePositonTween.updateTo(tweenObject);

			case ProjectileType.Pointer:
		}

		if (isInDamageRange()) damageTarget();
	}

	function damageTarget()
	{
		switch (pConfig.type)
		{
			case ProjectileType.Pointer | ProjectileType.Follower if (isInDamageRange()):
				data.target.damage(data.damage, data.owner);

			case _:
		}

		Actuate.stop(view, null, false, false);
		finish();
	}

	function isInDamageRange()
	{
		return data.target != null && GeomUtil.getDistance(cast data.target.view, cast view) < 0.3;
	}

	function disposeProjectile()
	{
		Actuate.stop(view, null, false, false);
		stateLink.dissolve();

		projectilePositonTween.kill();
		view.remove();
		view = null;
	}

	public function dispose()
	{
		disposeProjectile();

		if (idleGPUEffect != null) idleGPUEffect.remove();
		if (parts2 != null) parts2.remove();
	}
}

enum ProjectileState
{
	Idle;
	Finished;
	Disappeared;
}
typedef TweenObject =
{
	var x:Float;
	var y:Float;
	@:optional var z:Float;
	@:optional var onUpdate:Void->Void;
	@:optional var onComplete:Void->Void;
	@:optional var ease:com.greensock.easing.Ease;
}
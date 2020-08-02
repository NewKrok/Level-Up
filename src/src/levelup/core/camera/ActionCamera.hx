package levelup.core.camera;

import com.greensock.TweenMax;
import h3d.Camera;
import h3d.Quat;
import h3d.Vector;
import levelup.AsyncUtil.Result;
import motion.Actuate;
import motion.easing.IEasing;
import motion.easing.Linear;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class ActionCamera
{
	var camera:Camera = _;

	public var currentCameraPoint(default, never):{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	public var cameraSpeed:Vector = new Vector(5, 5, 5);
	public var cameraRotationSpeed:Float = 5;
	public var cameraAngleSpeed:Float = 5;
	public var camAngle:Float = Math.PI - Math.PI / 4;
	public var cameraRotation:Float = Math.PI / 2;
	public var camDistance:Float = 40;

	var camAnimationPosition:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var cameraPositionModifier:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var currentCamDistance:Float = 0;
	var hasCameraAnimation:Bool = false;
	var camAnimationResult:Result;
	var cameraTarget:CameraTarget;
	var cameraTargetConfig:CameraTargetConfig;
	var prevTargetRotation:Float = 0;

	public function new() {}

	public function update(d:Float)
	{
		var targetPoint = cameraTarget.getPosition != null
			? cameraTarget.getPosition()
			: {
				x: cameraTarget.x,
				y: cameraTarget.y,
				z: cameraTarget.z
			};

		if (hasCameraAnimation)
		{
			currentCameraPoint.x = camAnimationPosition.x;
			currentCameraPoint.y = camAnimationPosition.y;
			currentCameraPoint.z = camAnimationPosition.z;
			currentCamDistance = camDistance;
		}
		else if (cameraTarget == null)
		{
			currentCameraPoint.x = camAnimationPosition.x;
			currentCameraPoint.y = camAnimationPosition.y;
			currentCameraPoint.z = camDistance = camAnimationPosition.z;
		}
		else
		{
			if (cameraTargetConfig != null)
			{
				if ((cameraTargetConfig.useTargetsRotation || cameraTargetConfig.useTargetsAngle) && cameraTarget.getRotationQuat != null)
				{
					var euler = cameraTarget.getRotationQuat().toEuler();
					if (cameraTargetConfig.useTargetsRotation)
					{
						var targetRotation = Math.PI * 2 - euler.z + Math.PI / 2;

						if (Math.abs(prevTargetRotation - targetRotation) > Math.PI)
						{
							cameraRotation += (prevTargetRotation > targetRotation ? -1 : 1) * Math.PI * 2;
						}

						var rotationDiff = Math.abs(targetRotation - cameraRotation);
						if (rotationDiff > Math.PI) cameraRotation -= Math.PI * 2;

						if (rotationDiff > 0.01)
						{
							var newRotation = cameraRotation + (targetRotation - cameraRotation) / cameraRotationSpeed;
							var newDiff = Math.abs(cameraRotation - newRotation);
							cameraRotation = newRotation;

							if (newDiff > Math.PI)
							{
								cameraRotation += Math.PI / 2;
							}
						}

						prevTargetRotation = targetRotation;
					}
					if (cameraTargetConfig.useTargetsAngle)
					{
						camAngle += (-euler.y - camAngle) / cameraAngleSpeed;
					}
				}
				if (cameraTargetConfig.offset != null)
				{
					if (cameraTargetConfig.offset.x != null)
					{
						targetPoint.x += cameraTargetConfig.offset.x * Math.sin(cameraRotation + Math.PI / 2);
						targetPoint.y += cameraTargetConfig.offset.x * Math.cos(cameraRotation + Math.PI / 2);
					}
					if (cameraTargetConfig.offset.y != null)
					{
						targetPoint.x += -cameraTargetConfig.offset.y * Math.sin(cameraRotation);
						targetPoint.y += -cameraTargetConfig.offset.y * Math.cos(cameraRotation);
					}
				}
				if (cameraTargetConfig.maxCamAngle != null) camAngle = Math.min(camAngle, cameraTargetConfig.maxCamAngle);
				if (cameraTargetConfig.minCamAngle != null) camAngle = Math.max(camAngle, cameraTargetConfig.minCamAngle);
			}

			camDistance = Math.max(20, camDistance);
			camDistance = Math.min(60, camDistance);

			currentCameraPoint.x += (targetPoint.x - currentCameraPoint.x) / cameraSpeed.x * d * 30;
			currentCameraPoint.y += (targetPoint.y - currentCameraPoint.y) / cameraSpeed.y * d * 30;

			var distanceOffset = (camDistance - currentCamDistance) / cameraSpeed.z * d * 30;
			if (Math.abs(distanceOffset) < 0.001) currentCamDistance = camDistance;
			else currentCamDistance += distanceOffset;
		}

		camera.target.set(currentCameraPoint.x, currentCameraPoint.y);

		var newDistance = currentCamDistance * Math.cos(camAngle);

		camera.pos.set(
			currentCameraPoint.x + newDistance * Math.sin(cameraRotation) + cameraPositionModifier.x,
			currentCameraPoint.y + newDistance * Math.cos(cameraRotation) + cameraPositionModifier.y,
			((hasCameraAnimation || cameraTarget == null)
				? currentCamDistance * Math.sin(camAngle)
				: currentCamDistance * Math.sin(camAngle))
					+ cameraPositionModifier.z
					+ (cameraTarget != null && !hasCameraAnimation
						? targetPoint.z + (cameraTargetConfig.offset.z != null
							? -cameraTargetConfig.offset.z
							: 0
						)
						: 0
					)
		);
	}

	public function zoom(value) camDistance += value;

	public function moveCamera(x:Float, y:Float, z:Float, time:Float, ease:IEasing = null)
	{
		hasCameraAnimation = true;
		camAnimationPosition.x = currentCameraPoint.x;
		camAnimationPosition.y = currentCameraPoint.y;
		camAnimationPosition.z = currentCameraPoint.z;

		Actuate.stop(camAnimationPosition);
		Actuate.tween(camAnimationPosition, time, { x: x, y: y, z: z })
			.ease(ease == null ? Linear.easeNone : ease)
			.onUpdate(function()
			{
				camAnimationPosition.x = camAnimationPosition.x;
				camAnimationPosition.y = camAnimationPosition.y;
				camAnimationPosition.z = camAnimationPosition.z;
			})
			.onComplete(function()
			{
				hasCameraAnimation = false;
			});

		return camAnimationResult;
	}

	public function animateCameraTo(camera:CameraData, time:Float, ease:IEasing = null)
	{
		hasCameraAnimation = true;
		camAnimationPosition.x = currentCameraPoint.x;
		camAnimationPosition.y = currentCameraPoint.y;
		camAnimationPosition.z = currentCameraPoint.z;

		Actuate.tween(
			this,
			time, {
				camAngle: camera.camAngle,
				camDistance: camera.camDistance,
				cameraRotation: camera.cameraRotation
			}
		).ease(ease == null ? Linear.easeNone : ease);

		Actuate.tween(
			camAnimationPosition,
			time, {
				x: camera.position.x,
				y: camera.position.y
			}
		).ease(ease == null ? Linear.easeNone : ease)
			.onUpdate(function()
			{
				camAnimationPosition.x = camAnimationPosition.x;
				camAnimationPosition.y = camAnimationPosition.y;
				camAnimationPosition.z = camAnimationPosition.z;
			})
			.onComplete(function()
			{
				hasCameraAnimation = false;
			});

		return camAnimationResult;
	}

	public function jumpCamera(x:Float, y:Float, z:Float = null)
	{
		currentCameraPoint.x = x;
		currentCameraPoint.y = y;
		if (z != null) currentCameraPoint.z = z;
		camAnimationPosition.x = currentCameraPoint.x;
		camAnimationPosition.y = currentCameraPoint.y;
		if (z != null) camAnimationPosition.z = currentCameraPoint.z;

		currentCamDistance = camDistance;

		update(0);
	}

	public function startCameraShake(amplitude, time, ease) shakeRoutine(amplitude, time, ease);

	private function shakeRoutine(amplitude, time, ease)
	{
		TweenMax.to(cameraPositionModifier, time, {
			x: Math.random() * (amplitude * 2) - amplitude,
			y: Math.random() * (amplitude * 2) - amplitude,
			z: Math.random() * (amplitude * 2) - amplitude,
			onComplete: shakeRoutine.bind(amplitude, time, ease),
			ease: ease
		});
	}

	public function stopCameraShake()
	{
		TweenMax.killTweensOf(cameraPositionModifier);
	}

	public function setCameraTarget(target, config:CameraTargetConfig = null)
	{
		currentCamDistance = camDistance;
		cameraTarget = target;
		cameraTargetConfig = config;
	}

	public function dispose()
	{
		Actuate.stop(this);
		Actuate.stop(camAnimationPosition);
		stopCameraShake();
	}
}

typedef CameraData =
{
	var name(default, never):String;
	var position(default, never):Vector;
	var camDistance(default, never):Float;
	var camAngle(default, never):Float;
	var cameraRotation(default, never):Float;
}

typedef CameraTarget =
{
	@:optional var getPosition:Void->Simple3DPoint;
	@:optional var getRotationQuat:Void->Quat;
	@:optional var x:Float;
	@:optional var y:Float;
	@:optional var z:Float;
}

typedef Simple3DPoint =
{
	var x:Float;
	var y:Float;
	var z:Float;
}

typedef CameraTargetConfig =
{
	@:optional var offset:Simple3DPoint;
	@:optional var useTargetsAngle:Bool;
	@:optional var minCamAngle:Float;
	@:optional var maxCamAngle:Float;
	@:optional var useTargetsRotation:Bool;
}
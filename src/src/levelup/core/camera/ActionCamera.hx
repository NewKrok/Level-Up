package levelup.core.camera;

import h3d.Camera;
import h3d.Vector;
import levelup.AsyncUtil.Result;
import levelup.game.unit.BaseUnit;
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

	var currentCameraPoint:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var camAnimationPosition:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var currentCamDistance:Float = 0;
	public var cameraSpeed:Vector = new Vector(10, 10, 5);
	public var camAngle:Float = Math.PI - Math.PI / 4;
	public var camRotation:Float = Math.PI / 2;
	public var camDistance:Float = 40;
	var hasCameraAnimation:Bool = false;
	var camAnimationResult:Result;
	var cameraTarget:BaseUnit;

	public function new()
	{

	}

	public function update(d:Float)
	{
		if (hasCameraAnimation || cameraTarget == null)
		{
			currentCameraPoint.x = camAnimationPosition.x;
			currentCameraPoint.y = camAnimationPosition.y;
			currentCameraPoint.z = camDistance = camAnimationPosition.z;
		}
		else
		{
			var targetPoint = cameraTarget.getPosition();

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
			currentCameraPoint.x + newDistance * Math.sin(camRotation),
			currentCameraPoint.y + newDistance * Math.cos(camRotation),
			(hasCameraAnimation || cameraTarget == null)
				? currentCamDistance * Math.sin(camAngle)
				: currentCamDistance * Math.sin(camAngle)
		);
	}

	public function zoom(value) camDistance += value;

	public function moveCamera(x:Float, y:Float, z:Float, time:Float, ease:IEasing = null)
	{
		hasCameraAnimation = true;
		camAnimationPosition.x = currentCameraPoint.x;
		camAnimationPosition.y = currentCameraPoint.y;
		camAnimationPosition.z = currentCameraPoint.z;

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
				camRotation: camera.camRotation
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

	public function setCameraTarget(target)
	{
		currentCamDistance = camDistance;
		cameraTarget = target;
	}
}

typedef CameraData =
{
	var name(default, never):String;
	var position(default, never):Vector;
	var camDistance(default, never):Float;
	var camAngle(default, never):Float;
	var camRotation(default, never):Float;
}
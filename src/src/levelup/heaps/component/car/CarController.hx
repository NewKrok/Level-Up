package levelup.heaps.component.car;

import haxe.ds.Map;
import hxd.Key;
import js.Browser;
import levelup.heaps.component.car.Car;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CarController
{
	var config:CarControllerConfig = null;

	var target:Car;
	var currentSteer = 0.0;
	var currentSpeed = 0.0;
	var controls:Map<Int, Bool> = [
		Key.UP => false,
		Key.DOWN => false,
		Key.LEFT => false,
		Key.RIGHT => false,
		Key.SPACE => false
	];

	public function new(config:CarControllerConfig = null)
	{
		if (config == null) config = {};

		if (config.maxSteer == null) config.maxSteer = 0.5;
		if (config.steerSpeed == null) config.steerSpeed = 1.7;
		if (config.steerSpeedAtMaxSpeed == null) config.steerSpeedAtMaxSpeed = 0.2;
		if (config.steerResetSpeed == null) config.steerResetSpeed = 0.85;
		if (config.acceleration == null) config.acceleration = 100;
		if (config.maxSpeed == null) config.maxSpeed = 250;
		if (config.backwardAcceleration == null) config.backwardAcceleration = 50;
		if (config.backwardMaxSpeed == null) config.backwardMaxSpeed = 150;
		if (config.brake == null) config.brake = 10;

		this.config = config;
	}

	public function setTarget(car:Car)
	{
		target = car;

		Browser.document.getElementById("webgl").addEventListener("keydown", keyHandler);
		Browser.document.getElementById("webgl").addEventListener("keyup", keyHandler);
	}

	public function keyHandler(event)
	{
		controls[event.keyCode] = event.type == "keydown";
	}

	public function update(d:Float)
	{
		if (controls.get(Key.UP))
		{
			currentSpeed += d * config.acceleration;
			currentSpeed = Math.min(currentSpeed, config.maxSpeed);
			target.applyEngineForce(currentSpeed);
		}
		if (controls.get(Key.DOWN))
		{
			currentSpeed -= d * config.backwardAcceleration;
			currentSpeed = Math.max(currentSpeed, -config.backwardMaxSpeed);
			target.applyEngineForce(currentSpeed);
		}
		if (controls.get(Key.LEFT))
		{
			currentSteer -= d *
				(config.steerSpeedAtMaxSpeed +
					(config.steerSpeed - config.steerSpeedAtMaxSpeed) * (1 - currentSpeed
					/ (currentSpeed > 0
						? config.maxSpeed
						: -config.backwardMaxSpeed)));
			currentSteer = Math.max(currentSteer, -config.maxSteer);
			target.setSteeringValue(currentSteer);
		}
		else if (controls.get(Key.RIGHT))
		{
			currentSteer += d *
				(config.steerSpeedAtMaxSpeed +
					(config.steerSpeed - config.steerSpeedAtMaxSpeed) * (1 - currentSpeed
					/ (currentSpeed > 0
						? config.maxSpeed
						: -config.backwardMaxSpeed)));
			currentSteer = Math.min(currentSteer, config.maxSteer);
			target.setSteeringValue(currentSteer);
		}
		if (controls.get(Key.SPACE))
		{
			target.setBrake(config.brake);
		}
		else
		{
			target.setBrake(0);
		}

		if (!controls.get(Key.UP) && !controls.get(Key.DOWN))
		{
			currentSpeed = 0;
			target.applyEngineForce(currentSpeed);
		}
		if (!controls.get(Key.LEFT) && !controls.get(Key.RIGHT) && Math.abs(currentSteer) > 0)
		{
			currentSteer = currentSteer *= config.steerResetSpeed;
			if (Math.abs(currentSteer) < 0.1) currentSteer = 0;
			target.setSteeringValue(currentSteer);
		}
	}
}

typedef CarControllerConfig =
{
	@:optional var maxSteer:Float;
	@:optional var steerSpeed:Float;
	@:optional var steerSpeedAtMaxSpeed:Float;
	@:optional var steerResetSpeed:Float;
	@:optional var acceleration:Float;
	@:optional var maxSpeed:Float;
	@:optional var backwardAcceleration:Float;
	@:optional var backwardMaxSpeed:Float;
	@:optional var brake:Float;
}
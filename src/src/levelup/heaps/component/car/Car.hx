package levelup.heaps.component.car;

import h3d.Quat;
import h3d.scene.Object;
import levelup.AssetCache;
import levelup.extern.Cannon.CannonBody;
import levelup.extern.Cannon.CannonBodyType;
import levelup.extern.Cannon.CannonBox;
import levelup.extern.Cannon.CannonCylinder;
import levelup.extern.Cannon.CannonQuaternion;
import levelup.extern.Cannon.CannonRaycastVehicle;
import levelup.extern.Cannon.CannonVec3;
import levelup.extern.Cannon.CannonWheelConfig;
import levelup.extern.Cannon.CannonWorld;

using Lambda;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class Car
{
	var parent:Object = _;
	var physicsWorld:CannonWorld = _;
	public var config(default, null):CarConfig = _;

	var carBodyModel:Object;
	var wheelModels:Array<h3d.scene.Object>;
	var suspensionModels:Array<h3d.scene.Object>;

	var vehicle:CannonRaycastVehicle;
	var chassisBody:CannonBody;
	var wheelBodies:Array<CannonBody>;

	public function new()
	{
		createBody();
		createWheels();
	}

	function createBody()
	{
		createBodyGraphic();
		createBodyPhysics();
	}

	function createBodyGraphic()
	{
		carBodyModel = AssetCache.instance.getModel(config.id + ".body");
		carBodyModel.defaultTransform.rotate(Math.PI / 2, 0, Math.PI + Math.PI / 2);
		carBodyModel.defaultTransform.translate(0, 0, -150);
		carBodyModel.scale(config.modelScale);
		parent.addChild(carBodyModel);
	}

	function createBodyPhysics()
	{
		var chassisShape = new CannonBox(new CannonVec3(2, 1, 0.5));
		chassisBody = new CannonBody({ mass: 50 });
		chassisBody.addShape(chassisShape);

		vehicle = new CannonRaycastVehicle({
			chassisBody: chassisBody
		});
		vehicle.addToWorld(physicsWorld);
	}

	function createWheels()
	{
		createWheelGraphic();
		createWheelPhysics();
	}

	function createWheelGraphic()
	{

		wheelModels = [];
		suspensionModels = [];

		for (i in 0...4)
		{
			var wheelModel:Object = null;
			var suspensionModel:Object = null;

			if (i % 2 == 0 )
			{
				wheelModel = AssetCache.instance.getModel(config.id + ".leftwheel");
				wheelModel.defaultTransform.translate(10, 0, 0);
				wheelModel.defaultTransform.rotate(0, Math.PI, Math.PI / 2);

				suspensionModel = AssetCache.instance.getModel(config.id + ".leftsuspension");
				suspensionModel.defaultTransform.translate(-25, 0, 0);
				suspensionModel.defaultTransform.rotate(-Math.PI / 2, Math.PI, Math.PI / 2);
				suspensionModel.defaultTransform.translate(0, -150, 0);
			}
			else
			{
				wheelModel = AssetCache.instance.getModel(config.id + ".rightwheel");
				wheelModel.defaultTransform.translate(-10, 0, 0);
				wheelModel.defaultTransform.rotate(0, 0, -Math.PI / 2);

				suspensionModel = AssetCache.instance.getModel(config.id + ".rightsuspension");
				suspensionModel.defaultTransform.translate(-125, 0, 0);
				suspensionModel.defaultTransform.rotate(-Math.PI / 2, Math.PI, Math.PI / 2);
			}

			wheelModel.scale(config.modelScale);
			wheelModels.push(wheelModel);
			parent.addChild(wheelModel);

			suspensionModel.scale(config.modelScale);
			suspensionModels.push(suspensionModel);
			parent.addChild(suspensionModel);
		}
	}

	function createWheelPhysics()
	{
		var options:CannonWheelConfig = {
			radius: 1,
			directionLocal: new CannonVec3(0, 0, -1),
			suspensionStiffness: 20,
			suspensionRestLength: 0.85,
			maxSuspensionTravel: 0.4,
			frictionSlip: 10,
			dampingRelaxation: 2.3,
			dampingCompression: 0.01,
			maxSuspensionForce: 1000000.0,
			rollInfluence: 0.001,
			axleLocal: new CannonVec3(0, 1, 0),
			chassisConnectionPointLocal: new CannonVec3(1, 1, 0),
			customSlidingRotationalSpeed: -1,
			useCustomSlidingRotationalSpeed: true
		};
		var wheelOffsets = [
			[1.9, 1.65, 0.35],
			[1.9, -1.65, 0.35],
			[-1.9, 1.65, 0.35],
			[-1.9, -1.65, 0.35]
		];
		for (i in 0...4)
		{
			options.chassisConnectionPointLocal.set(
				wheelOffsets[i][0],
				wheelOffsets[i][1],
				wheelOffsets[i][2]
			);
			vehicle.addWheel(options);
		}

		wheelBodies = [];
		vehicle.wheelInfos.foreach(wheel ->
		{
			var cylinderShape = new CannonCylinder(wheel.radius, wheel.radius, 1, 20);
			var wheelBody = new CannonBody({ mass: 0 });
			wheelBody.type = CannonBodyType.KINEMATIC;
			wheelBody.collisionFilterGroup = 0;
			var q = new CannonQuaternion();
			q.setFromAxisAngle(new CannonVec3(1, 0, 0), Math.PI / 2);
			wheelBody.addShape(cylinderShape, new CannonVec3(), q);
			wheelBodies.push(wheelBody);
			physicsWorld.addBody(wheelBody);
			return true;
		});
	}

	public function update(d:Float)
	{
		carBodyModel.setPosition(chassisBody.position.x, chassisBody.position.y, chassisBody.position.z);
		var q = new Quat(chassisBody.quaternion.x, chassisBody.quaternion.y, chassisBody.quaternion.z, chassisBody.quaternion.w);
		carBodyModel.setRotationQuat(q);

		var wheelIndex:Int = 0;
		vehicle.wheelInfos.iter(wheel ->
		{
			vehicle.updateWheelTransform(wheelIndex);
			var t = wheel.worldTransform;
			wheelModels[wheelIndex].setPosition(t.position.x, t.position.y, t.position.z);
			var q = new Quat(t.quaternion.x, t.quaternion.y, t.quaternion.z, t.quaternion.w);
			wheelModels[wheelIndex].setRotationQuat(q);

			suspensionModels[wheelIndex].setPosition(t.position.x, t.position.y, t.position.z);
			var q = new Quat(chassisBody.quaternion.x, chassisBody.quaternion.y, chassisBody.quaternion.z, chassisBody.quaternion.w);
			suspensionModels[wheelIndex].setRotationQuat(q);

			wheelIndex++;
		});
	}

	public function setPosition(x:Float, y:Float, z:Float)
	{
		chassisBody.position.copy(new CannonVec3(x, y, z));
		chassisBody.velocity.set(0, 0, 0);
		chassisBody.angularVelocity.set(0, 0, 0);
	}

	public function getPosition() return {
		x: carBodyModel.x,
		y: carBodyModel.y,
		z: carBodyModel.z
	};

	public function setBrake(force:Float)
	{
		vehicle.setBrake(force, 0);
		vehicle.setBrake(force, 1);
		vehicle.setBrake(force, 2);
		vehicle.setBrake(force, 3);
	}

	public function applyEngineForce(force:Float)
	{
		vehicle.applyEngineForce(force, 2);
		vehicle.applyEngineForce(force, 3);
	}

	public function setSteeringValue(steer:Float)
	{
		vehicle.setSteeringValue(steer, 2);
		vehicle.setSteeringValue(steer, 3);
	}

	public function getRotationQuat() return carBodyModel.getRotationQuat();
}

typedef CarConfig =
{
	var id:String;
	var type:CarType;
	var name:String;
	var icon:String;
	var assetGroup:String;
	var modelScale:Float;
}

enum abstract CarType(String) from String to String
{
	var MonsterTruck = "monstertruck";
}
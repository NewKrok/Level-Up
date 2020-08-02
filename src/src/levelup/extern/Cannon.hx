package levelup.extern;

/**
 * Extern for cannon.js
 * Official doc: https://schteppe.github.io/cannon.js/docs/
 * @author Krisztian Somoracz
 */
@:native("CANNON.World") extern class CannonWorld
{
	function new():Void;

	var broadphase:CannonSAPBroadphase;
	var gravity:CannonVec3;
	var defaultContactMaterial:CannonMaterial;
	var addContactMaterial:CannonContactMaterial->Void;
	var step:Float->?Float->?Float->Void;
	var add:CannonBody->Void;
	var addBody:CannonBody->Void;
}

@:native("CANNON.Heightfield") extern class CannonHeightfield
{
	function new(matrix:Array<Array<Float>>, config:CannonHeightfieldConfig):Void;

	var elementSize:Float;
}

@:native("CANNON.SAPBroadphase") extern class CannonSAPBroadphase
{
	function new(world:CannonWorld):Void;
}

@:native("CANNON.Material") extern class CannonMaterial
{
	function new(id:String):Void;

	var friction:Float;
}

@:native("CANNON.ContactMaterial") extern class CannonContactMaterial
{
	function new(materialA:CannonMaterial, materialB:CannonMaterial, config:CannonMaterialConfig):Void;
}

@:native("CANNON.Box") extern class CannonBox
{
	function new(size:CannonVec3):Void;
}

@:native("CANNON.Body") extern class CannonBody
{
	function new(config:CannonBodyConfig):Void;

	var addShape:?Dynamic->?Dynamic->?Dynamic->Void;

	var position:CannonVec3;
	var quaternion:CannonQuaternion;
	var velocity:CannonVec3;
	var angularVelocity:CannonVec3;
	var type:CannonBodyType;
	var collisionFilterGroup:Int;
	var linearDamping:Float;
	var angularDamping:Float;
}

@:native("CANNON.Vec3") extern class CannonVec3
{
	function new(x:Float = 0, y:Float = 0, z:Float = 0):Void;

	var set:Float->Float->Float->Void;
	var copy:CannonVec3->Void;

	var x:Float;
	var y:Float;
	var z:Float;
}

@:native("CANNON.Quaternion") extern class CannonQuaternion
{
	function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0):Void;

	var setFromAxisAngle:CannonVec3->Float->Void;
	var copy:CannonQuaternion->Void;

	var x:Float;
	var y:Float;
	var z:Float;
	var w:Float;
}

@:native("CANNON.Cylinder") extern class CannonCylinder
{
	function new(x:Float, y:Float, z:Float, w:Float):Void;

	var set:Float->Float->Float->Void;
}

@:native("CANNON.RaycastVehicle") extern class CannonRaycastVehicle
{
	function new(config:CannonRaycastVehicleConfig):Void;

	var addToWorld:CannonWorld->Void;
	var addWheel:CannonWheelConfig->Void;
	var updateWheelTransform:Int->Void;
	var setSteeringValue:Float->Int->Void;
	var applyEngineForce:Float->Int->Void;
	var setBrake:Float->Int->Void;

	var chassisBody:CannonBody;
	var wheelInfos:Array<CannonWheelConfig>;
	var sliding(default, never):Bool;
}

typedef CannonMaterialConfig =
{
	@:optional var friction:Float;
	@:optional var restitution:Float;
	@:optional var contactEquationStiffness:Float;
}

typedef CannonBodyConfig =
{
	@:optional var mass:Float;
	@:optional var material:CannonMaterial;
}

typedef CannonRaycastVehicleConfig =
{
	@:optional var chassisBody:CannonBody;
	@:optional var indexRightAxis:Float;
	@:optional var indexUpAxis:Float;
	@:optional var indeForwardAxis:Float;
}

typedef CannonWheelConfig =
{
	@:optional var radius:Float;
	@:optional var chassisConnectionPointLocal:CannonVec3;
	@:optional var useCustomSlidingRotationalSpeed:Bool;
	@:optional var customSlidingRotationalSpeed:Float;
	@:optional var maxSuspensionTravel:Float;
	@:optional var axleLocal:CannonVec3;
	@:optional var directionLocal:CannonVec3;
	@:optional var rollInfluence:Float;
	@:optional var maxSuspensionForce:Float;
	@:optional var dampingCompression:Float;
	@:optional var dampingRelaxation:Float;
	@:optional var frictionSlip:Float;
	@:optional var suspensionRestLength:Float;
	@:optional var suspensionStiffness:Float;
	@:optional var worldTransform:CannonTransform;
}

typedef CannonTransform =
{
	var position:CannonVec3;
	var quaternion:CannonQuaternion;
}

typedef CannonHeightfieldConfig =
{
	@:optional var elementSize:Float;
}

@:enum abstract CannonBodyType(Int) from Int to Int {
	var DYNAMIC = 1;
	var STATIC = 2;
	var KINEMATIC = 4;
}
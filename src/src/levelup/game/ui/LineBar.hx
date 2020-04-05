package levelup.game.ui;

import h2d.Graphics;
import h2d.Object;
import motion.Actuate;
import tink.CoreApi.CallbackLink;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LineBar extends Object
{
	var backGround:Graphics;
	var line:Graphics;
	var stateLink:CallbackLink;

	public function new(parent:Object, value:Observable<Float>, maxValue:Float, width:Float = 200, height:Float = 20, color:UInt = 0xFFFFFF)
	{
		super(parent);

		backGround = new Graphics(this);
		backGround.beginFill(0x000000);
		backGround.drawRect(0, 0, width, height);
		backGround.endFill();

		line = new Graphics(this);
		line.beginFill(color);
		line.drawRect(0, 0, width, height);
		line.endFill();

		stateLink = value.bind(v ->
		{
			Actuate.stop(line);
			Actuate.tween(line, .3, { scaleX: v / maxValue });
		});
	}

	public function dispose()
	{
		stateLink.dissolve();
		stateLink = null;

		line.clear();
		backGround.clear();
	}
}
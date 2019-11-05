package levelup.game.ui;

import h2d.Graphics;
import h2d.Object;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LineBar extends Object
{
	var backGround:Graphics;
	var line:Graphics;

	public function new(parent:Object, value:Observable<Float>, maxValue:Float, width:Float = 200, height:Float = 20, color:UInt = 0xFFFFFF)
	{
		super(parent);

		backGround = new Graphics(this);
		backGround.beginFill(0x000000);
		backGround.drawRect(0, 0, width, height);
		backGround.endFill();
		backGround.beginFill(0x555555);
		backGround.drawRect(2, 2, width - 4, height - 4);
		backGround.endFill();
		backGround.beginFill(0x2E221B);
		backGround.drawRect(4, 4, width - 8, height - 8);
		backGround.endFill();

		line = new Graphics(this);

		value.bind(function(v)
		{
			var width = (width - 12) * (v / maxValue);
			line.clear();
			line.beginFill(color);
			line.drawRect(6, 6, width, height - 12);
			line.endFill();
			line.beginFill(0x000000, 0.4);
			line.drawRect(6, 12, width, 6);
			line.endFill();
		});
	}
}
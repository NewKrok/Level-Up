package demo.game.ui;

import h2d.Graphics;
import h2d.Object;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LifeBar extends Object
{
	var backGround:Graphics;
	var line:Graphics;

	public function new(parent:Object, value:Observable<Float>, maxValue:Float)
	{
		super(parent);

		backGround = new Graphics(this);
		backGround.beginFill(0x555555);
		backGround.drawRect(0, 0, 200, 20);
		backGround.endFill();

		line = new Graphics(this);

		value.bind(function(v)
		{
			line.clear();
			line.beginFill(0xFF3333);
			line.drawRect(0, 0, 200 * (v / maxValue), 20);
			line.endFill();
		});
	}
}
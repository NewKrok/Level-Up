package levelup.game.ui;

import h2d.Flow;
import h2d.Graphics;
import h2d.Object;
import levelup.game.unit.BaseUnit;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class UnitInfo extends Object
{
	var p:Object = _;
	var unit:BaseUnit = _;

	var backGround:Graphics;
	var lifeBar:LineBar;
	var manaBar:LineBar;

	public function new()
	{
		super(p);

		var lineWidth = 50;
		var lineHeight = 5;

		backGround = new Graphics(this);
		backGround.beginFill(0x111111);
		backGround.drawRect(0, 0, lineWidth + 2, lineHeight * 2 + 3);
		backGround.endFill();

		var container = new Flow(this);
		container.layout = Vertical;
		container.x = 1;
		container.y = 1;
		container.verticalSpacing = 1;

		lifeBar = new LineBar(container, unit.life, unit.config.maxLife, lineWidth, lineHeight, 0xFF223E);
		manaBar = new LineBar(container, unit.mana, unit.config.maxMana, lineWidth, lineHeight, 0x7F00FF);
	}

	public function dispose()
	{
		lifeBar.dispose();
		lifeBar = null;

		manaBar.dispose();
		manaBar = null;

		backGround.clear();
		backGround.remove();
		backGround = null;
	}
}
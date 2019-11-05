package levelup.game.ui;

import levelup.game.unit.BaseUnit;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Interactive;
import h2d.Object;
import h2d.filter.Glow;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class HeroUi extends Object
{
	var p:Object = _;
	var unit:BaseUnit = _;
	var onClick:BaseUnit->Void = _;
	var selectedUnit:Observable<BaseUnit> = _;

	var container:Flow;
	var iconContainer:Object;
	var icon:Bitmap;
	var deadMarker:Bitmap;
	var lifeBar:LineBar;
	var manaBar:LineBar;

	public function new()
	{
		super(p);

		container = new Flow(this);
		container.layout = Vertical;
		iconContainer = new Object(container);
		icon = new Bitmap(unit.config.icon, iconContainer);
		icon.smooth = true;
		deadMarker = new Bitmap(Res.ui.icon_dead.toTile(), iconContainer);
		deadMarker.smooth = true;
		lifeBar = new LineBar(container, unit.life, unit.config.maxLife, 128, 24, 0xFF223E);
		manaBar = new LineBar(container, unit.mana, unit.config.maxMana, 128, 24, 0x7F00FF);

		var interactive = new Interactive(container.getSize().width, container.getSize().height, this);
		interactive.onClick = _ -> onClick(unit);

		unit.life.observe().bind(v -> deadMarker.visible = v == 0);

		selectedUnit.bind(v ->
		{
			filter = v == unit ? new Glow(0xFFFFFF, 1, 2, 1, 1, false) : null;
		});
	}
}
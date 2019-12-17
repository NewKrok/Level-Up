package levelup.editor.module.region;

import coconut.data.Model;
import coconut.data.List;
import levelup.game.GameWorld.Region;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class RegionModel implements Model
{
	@:observable var regions:List<Region> = List.fromArray([]);

	@:transition function addRegion(region:Region) return { regions: regions.append(region) };
	@:transition function addRegions(regionArr:Array<Region>) return { regions: List.fromArray(regionArr) };
}
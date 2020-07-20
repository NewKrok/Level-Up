package levelup.component.form.dropdown;

import coconut.data.List;
import coconut.ui.RenderResult;
import coconut.ui.View;
import js.Browser;
import js.html.Element;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Dropdown extends View
{
	@:attr var selectedIndex:Int;
	@:attr var setSelectedIndex:Int->Void;
	@:attr var values:List<RenderResult>;
	@:attr var className:String = "";

	@:computed var selectedValue:RenderResult = values.toArray()[selectedIndex];

	@:state var isOpened:Bool = false;

	@:ref var root:Element;

	override function viewDidMount()
	{
		Browser.document.addEventListener('click', e -> {
			if (root != null && !root.contains(e.target)) isOpened = false;
		});
	}

	function render()
	{
		var arr = values.toArray();

		return hxx('
			<div class={"lu_dropdown " + className + (isOpened ? " lu_dropdown--opened" : "")} onClick=$toggleVisibility ref=$root>
				<div class="lu_head">
					$selectedValue
					<if {isOpened}>
						<i class="fas fa-angle-up lu_dropdown_icon"></i>
					<else>
						<i class="fas fa-angle-down lu_dropdown_icon"></i>
					</if>
				</div>
				<if {isOpened}>
					<div class="lu_list">
						<for {i in 0...arr.length}>
							<if {arr[i] != selectedValue}>
								<div class="lu_value" onClick={setSelectedIndex(i)}>{arr[i]}</div>
							</if>
						</for>
					</div>
				</if>
			</div>
		');
	}

	function toggleVisibility() isOpened = !isOpened;
}
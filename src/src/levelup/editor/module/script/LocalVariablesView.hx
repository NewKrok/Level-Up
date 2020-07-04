package levelup.editor.module.script;

import coconut.data.List;
import coconut.ui.RenderResult;
import coconut.ui.View;
import levelup.component.Dropdown;
import levelup.component.Input;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LocalVariablesView extends View
{
	@:attr var scriptId:String;

	var variableTypes:List<RenderResult> = List.fromArray([
		hxx('<div><i class="fas fa-file-excel lu_var_icon"></i> Boolean</div>'),
		hxx('<div><i class="fas fa-file-excel lu_var_icon"></i> Integer</div>'),
		hxx('<div><i class="fas fa-file-excel lu_var_icon"></i> Float</div>'),
		hxx('<div><i class="fas fa-file-excel lu_var_icon"></i> String</div>'),
		hxx('<div><i class="fas fa-video lu_var_icon"></i> Camera</div>'),
		hxx('<div><i class="fas fa-angle-double-right lu_var_icon"></i> Ease</div>'),
		hxx('<div><i class="fas fa-user lu_var_icon"></i> Player</div>'),
		hxx('<div><i class="fas fa-object-ungroup lu_var_icon"></i> Region</div>'),
		hxx('<div><i class="fas fa-child lu_var_icon"></i> Unit</div>')
	]);

	@:state var selectedIndexes:List<Int> = List.fromArray([1, 2, 3]);

	function render()
	{
		var selectedIndexesArr = selectedIndexes.toArray();

		return hxx('
			<div>
				<div class="lu_script__block">
					<div class="lu_script__block_label">
						<i class="fas fa-database lu_right_offset"></i>
						Local variables for $scriptId script
					</div>
				</div>
				<div class="lu_script__block">
					<div class="lu_row">
						<div class="lu_var_title">Name</div>
						<div class="lu_var_title">Type</div>
						<div class="lu_var_title">Initial Value</div>
					</div>
					<div class="lu_row">
						<Input className="lu_var_content" value="testFloatVariable" placeHolder="" onValueChange={v -> {}} />
						<div class="lu_var_content">
							<Dropdown
								selectedIndex={selectedIndexesArr[0]}
								setSelectedIndex={v ->
								{
									var arr = selectedIndexes.toArray();
									arr[0] = v;
									selectedIndexes = List.fromArray(arr);
								}}
								values=$variableTypes
							/>
						</div>
						<div class="lu_var_content">0.0</div>
					</div>
					<div class="lu_row">
						<Input className="lu_var_content" value="testStringVariable" placeHolder="" onValueChange={v -> {}} />
						<div class="lu_var_content">
							<Dropdown
								selectedIndex={selectedIndexesArr[1]}
								setSelectedIndex = {v ->
								{
									var arr = selectedIndexes.toArray();
									arr[1] = v;
									selectedIndexes = List.fromArray(arr);
								}}
								values=$variableTypes
							/>
						</div>
						<div class="lu_var_content">Hello World!</div>
					</div>
					<div class="lu_row">
						<Input className="lu_var_content" value="testCameraVariable" placeHolder="" onValueChange={v -> {}} />
						<div class="lu_var_content">
							<Dropdown
								selectedIndex={selectedIndexesArr[2]}
								setSelectedIndex = {v ->
								{
									var arr = selectedIndexes.toArray();
									arr[2] = v;
									selectedIndexes = List.fromArray(arr);
								}}
								values=$variableTypes
							/>
						</div>
						<div class="lu_var_content">Untitle Camera 0</div>
					</div>
				</div>
			</div>
		');
	}
}
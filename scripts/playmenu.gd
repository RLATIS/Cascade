extends CanvasLayer

func updateall():
	_on_mq_slider_value_changed($mqSLIDER.value)
	_on_ti_slider_value_changed($tiSLIDER.value)
	_on_it_slider_value_changed($itSLIDER.value)
	_on_seed_inpt_text_changed($seedINPT.text)

func _ready() -> void:
	$seedINPT.text = str(randi_range(1, 9999999))
	_on_medium_pressed()

	$easy.focus_mode = Control.FOCUS_ALL
	$medium.focus_mode = Control.FOCUS_ALL
	$hard.focus_mode = Control.FOCUS_ALL
	$begin.focus_mode = Control.FOCUS_ALL

	$easy.focus_neighbor_right = $medium.get_path()
	$medium.focus_neighbor_right = $hard.get_path()
	$hard.focus_neighbor_right = $easy.get_path()

	$easy.focus_neighbor_left = $hard.get_path()
	$medium.focus_neighbor_left = $easy.get_path()
	$hard.focus_neighbor_left = $medium.get_path()
	
	$easy.focus_neighbor_bottom = $seedINPT.get_path()
	$medium.focus_neighbor_bottom = $seedINPT.get_path()
	$hard.focus_neighbor_bottom = $seedINPT.get_path()

	$seedINPT.focus_neighbor_top = $medium.get_path()
	
	$seedINPT.focus_neighbor_bottom = $mqSLIDER.get_path()
	$mqSLIDER.focus_neighbor_bottom = $tiSLIDER.get_path()
	$tiSLIDER.focus_neighbor_bottom = $itSLIDER.get_path()
	$itSLIDER.focus_neighbor_bottom = $begin.get_path()

	$mqSLIDER.focus_neighbor_top = $seedINPT.get_path()
	$tiSLIDER.focus_neighbor_top = $mqSLIDER.get_path()
	$itSLIDER.focus_neighbor_top = $tiSLIDER.get_path()

	$begin.focus_neighbor_top = $itSLIDER.get_path()

func _on_mq_slider_value_changed(value: float) -> void:
	var am = snappedf(remap(value, 0, 100, 1.1, 4), 0.05)
	$mqAMOUNT.text = str(am) + 'x'
	
	Globals.quotamultiply = am

func _on_ti_slider_value_changed(value: float) -> void:
	var am = snappedf(remap(value, 0, 100, 0, 20), 0.5)
	$tiAMOUNT.text = '+' + str(am) + '%'
	
	Globals.taxincrement = am / 100

func _on_it_slider_value_changed(value: float) -> void:
	$itAMOUNT.text = str(value + 1) + ' Targets'
	
	Globals.initclones = value
	
func _on_easy_pressed() -> void:
	$mqSLIDER.value = 9 # 1.35x
	$tiSLIDER.value = 35 # ~7%
	$itSLIDER.value = 8 # 9
	
	updateall()

func _on_medium_pressed() -> void:
	$mqSLIDER.value = 14 # 1.5x
	$tiSLIDER.value = 51 # 10%
	$itSLIDER.value = 6 # 7
	
	updateall()

func _on_hard_pressed() -> void:
	$mqSLIDER.value = 22.5 # 1.75x
	$tiSLIDER.value = 76 # 15%
	$itSLIDER.value = 4 # 5
	
	updateall()

func _on_seed_inpt_text_changed(new_text: String) -> void:
	var regex := RegEx.new()
	
	regex.compile("[^0-9]") # only numbers
	
	var oldcaret = $seedINPT.caret_column
	var filteredtext = regex.sub(new_text, "", true)
	
	if filteredtext != new_text: # some regex magic
		$seedINPT.text = filteredtext
		$seedINPT.caret_column = oldcaret - (new_text.length() - filteredtext.length())
	
	Globals.seed = int(filteredtext) if filteredtext != "" else 0

extends CanvasLayer

func updateall():
	_on_mq_slider_value_changed($mqSLIDER.value)
	_on_ti_slider_value_changed($tiSLIDER.value)
	_on_it_slider_value_changed($itSLIDER.value)
	_on_seed_inpt_text_changed($seedINPT.text)

func _ready() -> void:
	$mqSLIDER.value = 14 # 1.5x
	$tiSLIDER.value = 76 # 15%
	$itSLIDER.value = 6 # 7
	
	$seedINPT.text = str(randi_range(1, 9999999))
	
	updateall()
	
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
	$mqSLIDER.value = 31 # 2x
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

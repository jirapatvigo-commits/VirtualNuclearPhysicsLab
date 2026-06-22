extends Control

@onready var notebook_list = $Panel/VBoxContainer/NotebookList
@onready var average_button = $Panel/VBoxContainer/HBoxContainer/AverageButton
@onready var statistics_label = $Panel/VBoxContainer/StatisticsLabel
@onready var student_name_edit = $Panel/VBoxContainer/StudentNameEdit
@onready var student_id_edit = $Panel/VBoxContainer/StudentIDEdit
@onready var conclusion_edit = $Panel/VBoxContainer/ConclusionEdit
@onready var export_csv_button = $Panel/VBoxContainer/HBoxContainer/ExportCSVButton
@onready var export_pdf_button = $Panel/VBoxContainer/HBoxContainer/ExportPDFButton
@onready var clear_button = $Panel/VBoxContainer/HBoxContainer/ClearButton
@onready var export_graph_button = $Panel/VBoxContainer/HBoxContainer/ExportGraphButton
@onready var generate_conclusion_button = $Panel/VBoxContainer/HBoxContainer/GenerateConclusionButton
@onready var save_file_dialog = $SaveFileDialog

var graph = null
var records = []
var export_mode := ""

func _ready():
	export_csv_button.pressed.connect(_on_export_csv_pressed)
	export_pdf_button.pressed.connect(_on_export_pdf_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	
	average_button.pressed.connect(
		_on_average_pressed
	)
	
	export_graph_button.pressed.connect(
		_on_export_graph_pressed
	)
	
	generate_conclusion_button.pressed.connect(
		_on_generate_conclusion_pressed
	)

	save_file_dialog.file_selected.connect(
		_on_save_file_selected
	)
	graph = get_tree().get_first_node_in_group("beta_graph")

	if graph != null:
		print("BetaGraph connected.")
	else:
		push_warning("BetaGraph not found.")


func add_record(trial, material, thickness, detected):
	var record = {
		"trial": trial,
		"material": material,
		"thickness": thickness,
		"detected": detected
	}

	records.append(record)

	notebook_list.add_item(
		"Trial %d | Material: %s | Thickness: %d mm | Detected: %d"
		% [
			trial,
			material,
			thickness,
			detected
		]
	)


func _on_clear_pressed():
	records.clear()
	notebook_list.clear()

	print("Notebook cleared.")


func _on_export_csv_pressed():
	export_mode = "csv"

	save_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_file_dialog.title = "Save CSV Report"

	save_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE

	save_file_dialog.current_file = "VNPL_Report.csv"

	save_file_dialog.filters = PackedStringArray([
		"*.csv ; CSV Files"
	])

	save_file_dialog.popup_centered()


func _on_export_pdf_pressed():
	export_mode = "html"

	save_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_file_dialog.title = "Save HTML Report"

	save_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE

	save_file_dialog.current_file = "VNPL_Report.html"

	save_file_dialog.filters = PackedStringArray([
		"*.html ; HTML Files"
	])

	save_file_dialog.popup_centered()


func _on_save_file_selected(path):
	if export_mode == "csv":
		export_csv(path)

	elif export_mode == "html":
		export_html(path)

	elif export_mode == "graph":
		export_graph(path)


func export_csv(path):
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("Cannot save CSV file.")
		return

	var student_name = student_name_edit.text.strip_edges()
	var student_id = student_id_edit.text.strip_edges()

	if student_name == "":
		student_name = "-"

	if student_id == "":
		student_id = "-"

	var datetime = Time.get_datetime_dict_from_system()

	var export_time = "%02d/%02d/%04d %02d:%02d" % [
		datetime["day"],
		datetime["month"],
		datetime["year"],
		datetime["hour"],
		datetime["minute"]
	]
	var conclusion = conclusion_edit.text.strip_edges()

	if conclusion == "":
		conclusion = "-"
	# ข้อมูลรายงาน
	file.store_line("Virtual Nuclear Physics Laboratory")
	file.store_line("Experiment,Beta Absorption")
	file.store_line("Student Name,%s" % student_name)
	file.store_line("Student ID,%s" % student_id)
	file.store_line("Export Date,%s" % export_time)
	file.store_line("Conclusion,%s" % conclusion.replace("\n", " "))

	# เว้นบรรทัด
	file.store_line("")

	# หัวตาราง
	file.store_line(
		"Trial,Material,Thickness(mm),Detected"
	)

	# ข้อมูลการทดลอง
	for record in records:
		file.store_line(
			"%d,%s,%d,%d"
			% [
				record["trial"],
				record["material"],
				record["thickness"],
				record["detected"]
			]
		)

	file.close()

	print("CSV exported:", path)


func export_html(path):
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("Cannot save HTML file.")
		return

	var student_name = student_name_edit.text.strip_edges()
	var student_id = student_id_edit.text.strip_edges()
	var conclusion = conclusion_edit.text.strip_edges()

	if conclusion == "":
		conclusion = "-"

	if student_name == "":
		student_name = "-"

	if student_id == "":
		student_id = "-"

	var datetime = Time.get_datetime_dict_from_system()

	var export_time = "%02d/%02d/%04d %02d:%02d" % [
		datetime["day"],
		datetime["month"],
		datetime["year"],
		datetime["hour"],
		datetime["minute"]
	]

	var html = """
<html>
<head>
<title>VNPL Report</title>

<style>
	body {
		font-family: Arial;
		margin: 40px;
	}

	table {
		border-collapse: collapse;
		width: 100%;
	}

	th, td {
		border: 1px solid black;
		padding: 8px;
		text-align: center;
	}

	h1, h2 {
		text-align: center;
	}

	p {
		margin: 5px 0;
	}
</style>

</head>

<body>
"""

	html += "<h1>Virtual Nuclear Physics Laboratory</h1>"

	html += "<h2>Experiment: Beta Absorption</h2>"

	html += "<p><b>Student Name:</b> %s</p>" % student_name
	html += "<p><b>Student ID:</b> %s</p>" % student_id
	html += "<p><b>Export Date:</b> %s</p>" % export_time
	html += "<br>"
	html += "<h3>Conclusion</h3>"
	html += "<p>%s</p>" % conclusion.replace("\n", "<br>")

	html += """
<br>

<table>
<tr>
<th>Trial</th>
<th>Material</th>
<th>Thickness (mm)</th>
<th>Detected</th>
</tr>
"""

	for record in records:
		html += (
			"<tr><td>%d</td><td>%s</td><td>%d</td><td>%d</td></tr>"
			% [
				record["material"],
				record["trial"],
				record["thickness"],
				record["detected"]
			]
		)

	html += """
</table>

<br>

<p><i>Generated by Virtual Nuclear Physics Laboratory (VNPL)</i></p>

</body>
</html>
"""

	file.store_string(html)

	file.close()

	print("HTML exported:", path)
	
func _on_export_graph_pressed():
	export_mode = "graph"

	save_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_file_dialog.title = "Save Graph"
	save_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_file_dialog.current_file = "VNPL_Graph.png"

	save_file_dialog.filters = PackedStringArray([
		"*.png ; PNG Files"
	])

	save_file_dialog.popup_centered()


func export_graph(path):
	await RenderingServer.frame_post_draw

	var image = get_viewport().get_texture().get_image()

	if image == null:
		push_error("Cannot capture viewport.")
		return

	var error = image.save_png(path)

	if error != OK:
		push_error("Failed to save graph image.")
		return

	print("Graph exported:", path)

func _on_generate_conclusion_pressed():
	if records.size() < 2:
		conclusion_edit.text = (
			"Please perform at least two trials "
			+ "before generating a conclusion."
		)
		return

	var first_detected = records[0]["detected"]
	var last_detected = records[-1]["detected"]

	var conclusion = ""

	if last_detected < first_detected:
		conclusion = (
			"From this experiment, it was observed "
			+ "that increasing the absorber thickness "
			+ "reduced the number of detected beta particles. "
			+ "This result agrees with the theory of "
			+ "beta radiation attenuation."
		)

	elif last_detected > first_detected:
		conclusion = (
			"The detected beta particles increased "
			+ "during the experiment. "
			+ "Please review the experimental setup "
			+ "or repeat the measurements."
		)

	else:
		conclusion = (
			"No significant change in detected beta "
			+ "particles was observed."
		)

	conclusion_edit.text = conclusion

func _on_average_pressed():
	if records.is_empty():
		statistics_label.text = "No experiment data."
		return

	var total = 0
	var maximum = records[0]["detected"]
	var minimum = records[0]["detected"]

	for record in records:
		var value = record["detected"]

		total += value

		if value > maximum:
			maximum = value

		if value < minimum:
			minimum = value

	var average = float(total) / records.size()

	statistics_label.text = (
		"Total Trials : " + str(records.size()) + "\n" +
		"Average Detected : " + str(snapped(average, 0.1)) + "\n" +
		"Maximum : " + str(maximum) + "\n" +
		"Minimum : " + str(minimum)
	)

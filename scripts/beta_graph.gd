extends Control

var graph_data = []


func add_data(thickness, detected):
	graph_data.append({
		"thickness": thickness,
		"detected": detected
	})

	queue_redraw()


func clear_data():
	graph_data.clear()
	queue_redraw()


func _draw():
	if graph_data.is_empty():
		return

	var max_detected = 0

	for point in graph_data:
		max_detected = max(
			max_detected,
			point["detected"]
		)

	var left_margin = 40
	var bottom_margin = 30
	var top_margin = 20
	var right_margin = 10

	var graph_width = size.x - left_margin - right_margin
	var graph_height = size.y - top_margin - bottom_margin

	# แกน Y
	draw_line(
		Vector2(left_margin, top_margin),
		Vector2(left_margin, size.y - bottom_margin),
		Color.WHITE,
		2.0
	)

	# แกน X
	draw_line(
		Vector2(left_margin, size.y - bottom_margin),
		Vector2(size.x - right_margin, size.y - bottom_margin),
		Color.WHITE,
		2.0
	)

	# ค่า max
	draw_string(
		ThemeDB.fallback_font,
		Vector2(5, top_margin + 20),
		str(max_detected),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color.WHITE
	)

	# ค่ากลาง
	draw_string(
		ThemeDB.fallback_font,
		Vector2(5, size.y / 2),
		str(int(max_detected / 2)),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color.WHITE
	)

	# ค่า 0
	draw_string(
		ThemeDB.fallback_font,
		Vector2(15, size.y - bottom_margin + 5),
		"0",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color.WHITE
	)

	var bar_width = graph_width / float(graph_data.size())

	for i in range(graph_data.size()):

		var thickness = graph_data[i]["thickness"]
		var detected = graph_data[i]["detected"]

		var bar_height = (
			float(detected) / max_detected
		) * graph_height

		draw_rect(
			Rect2(
				left_margin + i * bar_width,
				size.y - bottom_margin - bar_height,
				bar_width - 6,
				bar_height
			),
			Color(0.2, 0.8, 0.3)
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				left_margin + i * bar_width + 5,
				size.y - 5
			),
			str(thickness),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			16,
			Color.WHITE
		)

extends Control

var counts = []

func set_data(data):
	counts = data.duplicate()
	queue_redraw()

func _draw():
	if counts.is_empty():
		return

	var frequencies = {}

	for c in counts:
		frequencies[c] = frequencies.get(c, 0) + 1

	var values = frequencies.keys()
	values.sort()

	var max_freq = 0

	for freq in frequencies.values():
		max_freq = max(max_freq, freq)

	var width = size.x
	var height = size.y

	var bar_width = width / float(values.size())

	for i in range(values.size()):
		var value = values[i]
		var freq = frequencies[value]

		var bar_height = (
			float(freq) / max_freq
		) * (height - 30)

		draw_rect(
			Rect2(
				i * bar_width,
				height - bar_height,
				bar_width - 2,
				bar_height
			),
			Color(0.2, 0.6, 0.9)
		)

extends TileMapLayer

const LINKED_CORDS := Vector2i(3,0)
const BLOCKED_CORDS := Vector2i(4,0)

# Change exit colour depending on its state
func mark_cell(cell, linked, blocked) -> void:
	if get_cell_source_id(cell) == -1:
		return
	var flags := get_cell_alternative_tile(cell)
	if linked:
		set_cell(cell, 3, LINKED_CORDS, flags)
	elif blocked:
		set_cell(cell, 3, BLOCKED_CORDS, flags)

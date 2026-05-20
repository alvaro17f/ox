package utils

import "../lib/colors"
import "core:fmt"
import "core:strings"

title_maker_string :: proc(text: string) -> string {
	border := len(text) + 4
	return fmt.tprintf(
		"\n%s%s%s\n%s*%s %s%s%s %s*%s\n%s%s%s",
		colors.BLUE,
		strings.repeat("*", border, context.temp_allocator),
		colors.RESET,
		colors.BLUE,
		colors.RESET,
		colors.RED,
		text,
		colors.RESET,
		colors.BLUE,
		colors.RESET,
		colors.BLUE,
		strings.repeat("*", border, context.temp_allocator),
		colors.RESET,
	)
}

title_maker :: proc(text: string) {
	fmt.print(title_maker_string(text))
}

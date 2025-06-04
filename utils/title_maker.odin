package utils

import s "../style"
import "core:fmt"
import "core:strings"

title_maker :: proc(text: string) {
	border := len(text) + 4

	fmt.printfln(
		"\n%s%s%s",
		s.color.blue,
		strings.repeat("*", border, context.temp_allocator),
		s.color.reset,
	)
	fmt.printfln(
		"%s*%s %s%s%s %s*%s",
		s.color.blue,
		s.color.reset,
		s.color.red,
		text,
		s.color.reset,
		s.color.blue,
		s.color.reset,
	)
	fmt.printfln(
		"%s%s%s",
		s.color.blue,
		strings.repeat("*", border, context.temp_allocator),
		s.color.reset,
	)
}


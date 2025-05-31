package utils

import "../style"
import "core:fmt"
import "core:strings"

title_maker :: proc(text: string) {
	using style

	border := len(text) + 4

	fmt.printfln("\n%s%s%s", color.blue, strings.repeat("*", border), color.reset)
	fmt.printfln(
		"%s*%s %s%s%s %s*%s",
		color.blue,
		color.reset,
		color.red,
		text,
		color.reset,
		color.blue,
		color.reset,
	)
	fmt.printfln("%s%s%s", color.blue, strings.repeat("*", border), color.reset)
}


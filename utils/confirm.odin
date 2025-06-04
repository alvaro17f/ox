package utils

import s "../style"
import "core:fmt"
import "core:os"
import "core:strings"


confirm :: proc(message: string = "Proceed?", default_value: bool = false) -> bool {
	default_value_str := default_value ? "(Y/n)" : "(y/N)"

	buf: [256]byte

	fmt.printf(
		"\n%s%s%s %s%s%s: ",
		s.color.yellow,
		message,
		s.color.reset,
		(default_value ? s.color.green : s.color.red),
		default_value_str,
		s.color.reset,
	)

	n, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.panicf("Error reading confirmation: ", err)
	}
	confirmation := strings.to_lower(string(buf[:n]), context.temp_allocator)

	switch (confirmation) {
	case "y\n", "yes\n":
		return true
	case "n\n", "no\n":
		return false
	}

	return default_value
}


package utils

import "../style"
import "core:fmt"
import "core:os"
import "core:strings"


confirm :: proc(message: string = "Proceed?", default_value: bool = false) -> bool {
	using style

	default_value_str := default_value ? "(Y/n)" : "(y/N)"

	buf: [256]byte

	fmt.printf(
		"\n%s%s%s %s%s%s: ",
		color.yellow,
		message,
		color.reset,
		(default_value ? color.green : color.red),
		default_value_str,
		color.reset,
	)

	n, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.panicf("Error reading confirmation: ", err)
	}
	confirmation := strings.to_lower(string(buf[:n]))

	switch (confirmation) {
	case "y\n", "yes\n":
		return true
	case "n\n", "no\n":
		return false
	}

	return default_value
}


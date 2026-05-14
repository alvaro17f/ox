package utils

import "../lib/colors"
import "core:fmt"
import "core:os"
import "core:strings"


Read_Proc :: proc(fd: ^os.File, buf: []byte) -> (int, os.Error)

read_impl :: proc(fd: ^os.File, buf: []byte) -> (int, os.Error) {
	return os.read(fd, buf)
}

read_fn: Read_Proc = read_impl

confirm :: proc(message: string = "Proceed?", default_value: bool = false, input: ^os.File = os.stdin) -> (result: bool, err: os.Error) {
	default_value_str := default_value ? "(Y/n)" : "(y/N)"

	buf: [256]byte
	pos := 0

	fmt.printf(
		"\n%s%s%s %s%s%s: ",
		colors.YELLOW,
		message,
		colors.RESET,
		(default_value ? colors.GREEN : colors.RED),
		default_value_str,
		colors.RESET,
	)

	// Read one byte at a time until newline
	for pos < len(buf) {
		n, read_err := read_fn(input, buf[pos:pos+1])
		if read_err != nil {
			return default_value, read_err
		}
		if n == 0 {
			break
		}
		if buf[pos] == '\n' {
			pos += 1
			break
		}
		pos += n
	}

	confirmation := strings.to_lower(string(buf[:pos]), context.temp_allocator)

	switch (confirmation) {
	case "y\n", "yes\n":
		return true, nil
	case "n\n", "no\n":
		return false, nil
	}

	return default_value, nil
}

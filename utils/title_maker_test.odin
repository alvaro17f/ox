package utils

import "core:testing"


@test
test_title_maker_border_length :: proc(t: ^testing.T) {
	// title_maker prints to stdout, just verify no crash
	title_maker("Test Title")
	// border = len(text) + 4 = 14
	// This is a smoke test — visual output verified manually
}

@test
test_title_maker_empty :: proc(t: ^testing.T) {
	// empty string should not crash
	title_maker("")
}

package utils

import "core:os"
import "core:testing"


// Mock read that returns error
mock_read_error :: proc(fd: ^os.File, buf: []byte) -> (int, os.Error) {
	return 0, os.General_Error.Invalid_Callback
}

// Mock read that returns 0 bytes
mock_read_zero :: proc(fd: ^os.File, buf: []byte) -> (int, os.Error) {
	return 0, nil
}

@test
test_confirm_yes :: proc(t: ^testing.T) {
	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\n")
	os.close(w)

	result, c_err := confirm(input = r)
	testing.expect_value(t, c_err, nil)
	testing.expect_value(t, result, true)
}

@test
test_confirm_no :: proc(t: ^testing.T) {
	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "n\n")
	os.close(w)

	result, c_err := confirm(input = r)
	testing.expect_value(t, c_err, nil)
	testing.expect_value(t, result, false)
}

@test
test_confirm_yes_full :: proc(t: ^testing.T) {
	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "yes\n")
	os.close(w)

	result, c_err := confirm(input = r)
	testing.expect_value(t, c_err, nil)
	testing.expect_value(t, result, true)
}

@test
test_confirm_no_full :: proc(t: ^testing.T) {
	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "no\n")
	os.close(w)

	result, c_err := confirm(input = r)
	testing.expect_value(t, c_err, nil)
	testing.expect_value(t, result, false)
}

@test
test_confirm_default_true :: proc(t: ^testing.T) {
	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "\n")
	os.close(w)

	result, c_err := confirm(default_value = true, input = r)
	testing.expect_value(t, c_err, nil)
	testing.expect_value(t, result, true)
}

@test
test_confirm_default_false :: proc(t: ^testing.T) {
	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "\n")
	os.close(w)

	result, c_err := confirm(default_value = false, input = r)
	testing.expect_value(t, c_err, nil)
	testing.expect_value(t, result, false)
}

@test
test_confirm_default_override :: proc(t: ^testing.T) {
	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "n\n")
	os.close(w)

	result, c_err := confirm(default_value = true, input = r)
	testing.expect_value(t, c_err, nil)
	testing.expect_value(t, result, false)
}

@test
test_confirm_read_error :: proc(t: ^testing.T) {
	saved := read_fn
	read_fn = mock_read_error
	defer { read_fn = saved }

	r, _, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	result, c_err := confirm(default_value = true, input = r)
	testing.expect(t, c_err != nil, "expected read error")
	testing.expect_value(t, result, true)
}

@test
test_confirm_empty_read :: proc(t: ^testing.T) {
	saved := read_fn
	read_fn = mock_read_zero
	defer { read_fn = saved }

	r, _, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	result, c_err := confirm(default_value = true, input = r)
	testing.expect_value(t, c_err, nil)
	testing.expect_value(t, result, true)
}

package utils

import "core:os"
import "core:testing"


@test
test_exec_echo :: proc(t: ^testing.T) {
	result, err := exec("echo hello", false, false)
	testing.expect_value(t, err, nil)
	testing.expect_value(t, result.success, true)
	testing.expect_value(t, result.exit_code, i32(0))
}

@test
test_exec_true :: proc(t: ^testing.T) {
	result, err := exec("true", false, false)
	testing.expect_value(t, err, nil)
	testing.expect_value(t, result.success, true)
	testing.expect_value(t, result.exit_code, i32(0))
}

@test
test_exec_false :: proc(t: ^testing.T) {
	result, err := exec("false", false, false)
	testing.expect_value(t, err, nil)
	testing.expect_value(t, result.success, false)
	testing.expect_value(t, result.exit_code, i32(1))
}

@test
test_exec_nonexistent :: proc(t: ^testing.T) {
	result, err := exec("/nonexistent_command_12345", false, false)
	testing.expect_value(t, err, nil) // sh returns exit code 127, no os error
	testing.expect_value(t, result.success, false)
	testing.expect_value(t, result.exit_code, i32(127))
}

@test
test_exec_no_output :: proc(t: ^testing.T) {
	result, err := exec("echo silent", false, false)
	testing.expect_value(t, err, nil)
	testing.expect_value(t, result.success, true)
}

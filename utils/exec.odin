package utils

import "core:fmt"
import "core:os"


Exec_Result :: struct {
	exit_code: i32,
	success:   bool,
}

Exec_Proc :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (Exec_Result, os.Error)

exec_impl :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (result: Exec_Result, error: os.Error) {
	assert(len(command) > 0)

	process := os.process_start(
		{
			command = []string{"sh", "-c", command},
			stdin = os.stdin,
			stdout = print_stdout ? os.stdout : nil,
			stderr = print_stderr ? os.stderr : nil,
		},
	) or_return

	state := os.process_wait(process) or_return

	exit_code := i32(state.exit_code)
	assert(exit_code >= 0)
	return Exec_Result{exit_code = exit_code, success = exit_code == 0}, nil
}

exec: Exec_Proc = exec_impl
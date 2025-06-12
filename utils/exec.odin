package utils

import "core:c/libc"
import "core:fmt"
import os "core:os/os2"


when ODIN_ARCH == .arm32 || ODIN_ARCH == .arm64 {
	Status :: struct {
		exit_code: i32,
	}

	exec :: proc(
		command: string,
		print_stdout: bool = true,
		print_stderr: bool = true,
	) -> (
		process_state: Status,
		error: os.Error,
	) {
		exit_code := libc.system(fmt.ctprint(command))

		state := Status {
			exit_code = exit_code,
		}

		return state, nil
	}

} else {
	exec :: proc(
		command: string,
		print_stdout: bool = true,
		print_stderr: bool = true,
	) -> (
		process_state: os.Process_State,
		error: os.Error,
	) {
		process := os.process_start(
			{
				command = []string{"sh", "-c", command},
				stdin = os.stdin,
				stdout = print_stdout ? os.stdout : nil,
				stderr = print_stderr ? os.stderr : nil,
			},
		) or_return

		state := os.process_wait(process) or_return

		os.process_close(process) or_return

		return state, nil
	}

}


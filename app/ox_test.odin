package app

import "../utils"
import "core:fmt"
import "core:os"
import "core:testing"


mock_call_count: int
mock_read_count: int

// Mock read that returns error
mock_read_error :: proc(fd: ^os.File, buf: []byte) -> (int, os.Error) {
	return 0, os.General_Error.Invalid_Callback
}

// Mock read that fails on second confirm (after first newline seen)
mock_read_fail_second :: proc(fd: ^os.File, buf: []byte) -> (int, os.Error) {
	if mock_read_count >= 2 {
		return 0, os.General_Error.Invalid_Callback
	}
	n, err := os.read(fd, buf)
	if n > 0 && buf[0] == '\n' {
		mock_read_count += 1
	}
	return n, err
}

@test
test_ox_workflow_decline :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "n\n")
	os.close(w)

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect_value(t, err, nil)
}

@test
test_ox_workflow_pull_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\n")
	os.close(w)

	saved := utils.exec
	utils.exec = mock_exec_error
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from pull")
}

@test
test_ox_workflow_pull_fail :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\n")
	os.close(w)

	saved := utils.exec
	utils.exec = mock_exec_failure
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from pull failure")
}

@test
test_ox_workflow_update_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\nn\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_update_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		return utils.Exec_Result{}, os.General_Error.Invalid_Command
	}

	saved := utils.exec
	utils.exec = mock_exec_update_error
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
		update   = true,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from nix update")
}

@test
test_ox_workflow_diff_check_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_diff_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		return utils.Exec_Result{}, os.General_Error.Invalid_Command
	}

	saved := utils.exec
	utils.exec = mock_exec_diff_error
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from diff check")
}

@test
test_ox_workflow_status_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\nn\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_status_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 2 {
			return utils.Exec_Result{exit_code = 1, success = false}, nil
		}
		return utils.Exec_Result{}, os.General_Error.Invalid_Command
	}

	saved := utils.exec
	utils.exec = mock_exec_status_error
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from status")
}

@test
test_ox_workflow_add_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\ny\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_add_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 2 {
			return utils.Exec_Result{exit_code = 1, success = false}, nil
		}
		if mock_call_count == 3 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		return utils.Exec_Result{}, os.General_Error.Invalid_Command
	}

	saved := utils.exec
	utils.exec = mock_exec_add_error
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from add")
}

@test
test_ox_workflow_add_check_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\ny\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_add_check_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 2 {
			return utils.Exec_Result{exit_code = 1, success = false}, nil
		}
		if mock_call_count == 3 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 4 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		return utils.Exec_Result{}, os.General_Error.Invalid_Command
	}

	saved := utils.exec
	utils.exec = mock_exec_add_check_error
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from add check")
}

@test
test_ox_workflow_add_still_diff :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\ny\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_still_diff :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 2 {
			return utils.Exec_Result{exit_code = 1, success = false}, nil
		}
		if mock_call_count == 3 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 4 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		return utils.Exec_Result{exit_code = 1, success = false}, nil
	}

	saved := utils.exec
	utils.exec = mock_exec_still_diff
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from still diff")
}

@test
test_ox_workflow_rebuild_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\nn\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_rebuild_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 2 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		return utils.Exec_Result{}, os.General_Error.Invalid_Command
	}

	saved := utils.exec
	utils.exec = mock_exec_rebuild_error
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from rebuild")
}

@test
test_ox_workflow_keep_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\nn\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_keep_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 2 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 3 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		return utils.Exec_Result{}, os.General_Error.Invalid_Command
	}

	saved := utils.exec
	utils.exec = mock_exec_keep_error
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from keep")
}

@test
test_ox_workflow_diff_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\nn\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_diff_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 2 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 3 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 4 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		return utils.Exec_Result{}, os.General_Error.Invalid_Command
	}

	saved := utils.exec
	utils.exec = mock_exec_diff_error
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
		diff     = true,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected error from diff")
}

@test
test_ox_workflow_success :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\nn\n")
	os.close(w)

	saved := utils.exec
	utils.exec = mock_exec_success
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect_value(t, err, nil)
}

@test
test_ox_workflow_success_with_diff :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\nn\n")
	os.close(w)

	saved := utils.exec
	utils.exec = mock_exec_success
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
		diff     = true,
	}

	err = ox_workflow(&config, r)
	testing.expect_value(t, err, nil)
}

@test
test_ox_workflow_add_success :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\ny\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_add_success :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 2 {
			return utils.Exec_Result{exit_code = 1, success = false}, nil
		}
		if mock_call_count == 3 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 4 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 5 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 6 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 7 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		return utils.Exec_Result{exit_code = 0, success = true}, nil
	}

	saved := utils.exec
	utils.exec = mock_exec_add_success
	defer { utils.exec = saved }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect_value(t, err, nil)
}

@test
test_ox_workflow_confirm_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	saved_read := utils.read_fn
	utils.read_fn = mock_read_error
	defer { utils.read_fn = saved_read }

	r, _, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected confirm read error")
}

@test
test_ox_workflow_stage_confirm_error :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	r, w, err := os.pipe()
	testing.expect_value(t, err, nil)
	defer os.close(r)

	os.write_string(w, "y\n")
	os.close(w)

	mock_call_count = 0
	mock_exec_stage_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
		mock_call_count += 1
		if mock_call_count == 1 {
			return utils.Exec_Result{exit_code = 0, success = true}, nil
		}
		if mock_call_count == 2 {
			return utils.Exec_Result{exit_code = 1, success = false}, nil
		}
		return utils.Exec_Result{exit_code = 0, success = true}, nil
	}

	saved_exec := utils.exec
	utils.exec = mock_exec_stage_error
	defer { utils.exec = saved_exec }

	mock_read_count = 0
	saved_read := utils.read_fn
	utils.read_fn = mock_read_fail_second
	defer { utils.read_fn = saved_read }

	config := Config{
		name     = "ox",
		version  = "1.0",
		repo     = repos.path,
		hostname = "test",
		keep     = 10,
	}

	err = ox_workflow(&config, r)
	testing.expect(t, err != nil, "expected stage confirm read error")
}

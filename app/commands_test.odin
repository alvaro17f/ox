package app

import "../utils"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"


Test_Repos :: struct {
	path:      string,
	bare_path: string,
}

create_test_repo :: proc() -> Test_Repos {
	temp_dir := os.get_env("TMPDIR", context.temp_allocator)
	if temp_dir == "" {
		temp_dir = "/tmp"
	}

	// Create bare repo as origin
	bare_repo := fmt.tprintf("%s/ox-test-bare-%p", temp_dir, &temp_dir)
	os.mkdir_all(bare_repo)
	utils.exec(fmt.tprintf("git -C %s init -q --bare", bare_repo), false, false)

	// Create working repo
	repo := fmt.tprintf("%s/ox-test-repo-%p", temp_dir, &temp_dir)
	os.mkdir_all(repo)

	utils.exec(fmt.tprintf("git -C %s init -q", repo), false, false)
	utils.exec(fmt.tprintf("git -C %s config user.email test@test.com", repo), false, false)
	utils.exec(fmt.tprintf("git -C %s config user.name Test", repo), false, false)
	utils.exec(fmt.tprintf("git -C %s remote add origin %s", repo, bare_repo), false, false)
	utils.exec(fmt.tprintf("touch %s/README.md", repo), false, false)
	utils.exec(fmt.tprintf("git -C %s add .", repo), false, false)
	utils.exec(fmt.tprintf("git -C %s commit -q -m init", repo), false, false)
	utils.exec(fmt.tprintf("git -C %s push -q -u origin main", repo), false, false)

	return Test_Repos{path = repo, bare_path = bare_repo}
}

cleanup_test_repo :: proc(repos: Test_Repos) {
	utils.exec(fmt.tprintf("rm -rf %s", repos.path), false, false)
	utils.exec(fmt.tprintf("rm -rf %s", repos.bare_path), false, false)
}

// Mock exec that always returns error
mock_exec_error :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
	return utils.Exec_Result{}, os.General_Error.Invalid_Command
}

// Mock exec that always returns success
mock_exec_success :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
	return utils.Exec_Result{exit_code = 0, success = true}, nil
}

// Mock exec that always returns failure (exit code 1)
mock_exec_failure :: proc(command: string, print_stdout: bool = true, print_stderr: bool = true) -> (utils.Exec_Result, os.Error) {
	return utils.Exec_Result{exit_code = 1, success = false}, nil
}

@test
test_cmd_git_pull :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	success, err := cmd_git_pull(repos.path)
	testing.expect_value(t, err, nil)
}

@test
test_cmd_git_pull_error :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_error
	defer { utils.exec = saved }

	success, err := cmd_git_pull("/fake")
	testing.expect(t, err != nil, "expected error")
	testing.expect_value(t, success, false)
}

@test
test_cmd_is_git_diff_clean :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	has_diff, err := cmd_is_git_diff(repos.path)
	testing.expect_value(t, err, nil)
	testing.expect_value(t, has_diff, false)
}

@test
test_cmd_is_git_diff_dirty :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	utils.exec(fmt.tprintf("echo dirty >> %s/README.md", repos.path), false, false)

	has_diff, err := cmd_is_git_diff(repos.path)
	testing.expect_value(t, err, nil)
	testing.expect_value(t, has_diff, true)
}

@test
test_cmd_is_git_diff_error :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_error
	defer { utils.exec = saved }

	has_diff, err := cmd_is_git_diff("/fake")
	testing.expect(t, err != nil, "expected error")
	testing.expect_value(t, has_diff, false)
}

@test
test_cmd_git_status :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	err := cmd_git_status(repos.path)
	testing.expect_value(t, err, nil)
}

@test
test_cmd_git_status_error :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_error
	defer { utils.exec = saved }

	err := cmd_git_status("/fake")
	testing.expect(t, err != nil, "expected error")
}

@test
test_cmd_git_add :: proc(t: ^testing.T) {
	repos := create_test_repo()
	defer cleanup_test_repo(repos)

	utils.exec(fmt.tprintf("echo new > %s/new.txt", repos.path), false, false)

	err := cmd_git_add(repos.path)
	testing.expect_value(t, err, nil)
}

@test
test_cmd_nix_keep :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_success
	defer { utils.exec = saved }

	err := cmd_nix_keep("/repo", 10)
	testing.expect_value(t, err, nil)
}

@test
test_cmd_nix_update :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_success
	defer { utils.exec = saved }

	err := cmd_nix_update("/repo")
	testing.expect_value(t, err, nil)
}

@test
test_cmd_nix_update_error :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_error
	defer { utils.exec = saved }

	err := cmd_nix_update("/fake")
	testing.expect(t, err != nil, "expected error")
}

@test
test_cmd_nix_rebuild :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_success
	defer { utils.exec = saved }

	err := cmd_nix_rebuild("/repo", "myhost")
	testing.expect_value(t, err, nil)
}

@test
test_cmd_nix_rebuild_error :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_error
	defer { utils.exec = saved }

	err := cmd_nix_rebuild("/fake", "test")
	testing.expect(t, err != nil, "expected error")
}

@test
test_cmd_nix_diff :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_success
	defer { utils.exec = saved }

	err := cmd_nix_diff()
	testing.expect_value(t, err, nil)
}

@test
test_cmd_nix_diff_error :: proc(t: ^testing.T) {
	saved := utils.exec
	utils.exec = mock_exec_error
	defer { utils.exec = saved }

	err := cmd_nix_diff()
	testing.expect(t, err != nil, "expected error")
}

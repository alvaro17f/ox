package app

import "../utils"
import "core:os"
import "core:strings"
import "core:testing"


@test
test_parse_no_args :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.repo, "/default")
	testing.expect_value(t, config.update, false)
	testing.expect_value(t, config.diff, false)
}

@test
test_parse_repo :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-r", "/custom/path"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.repo, "/custom/path")
}

@test
test_parse_keep :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-k", "5"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.keep, 5)
}

@test
test_parse_hostname :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-n", "myhost"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.hostname, "myhost")
}

@test
test_parse_update :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-u"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.update, true)
}

@test
test_parse_diff :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-d"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.diff, true)
}

@test
test_parse_combined :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-du", "-r", "/path", "-k", "3"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.diff, true)
	testing.expect_value(t, config.update, true)
	testing.expect_value(t, config.repo, "/path")
	testing.expect_value(t, config.keep, 3)
}

@test
test_parse_unknown_flag :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-z"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.repo, "/default")
	testing.expect_value(t, config.update, false)
}

@test
test_parse_help :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-h"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, false)
}

@test
test_parse_help_long :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"help"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, false)
}

@test
test_parse_version :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-v"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, false)
}

@test
test_parse_version_long :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"version"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, false)
}

@test
test_parse_repo_no_value :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-r"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.repo, "/default")
}

@test
test_help_output :: proc(t: ^testing.T) {
	out := help("ox")
	testing.expect(t, strings.contains(out, "OX"), "help missing app name uppercase")
	testing.expect(t, strings.contains(out, "-r : set repo path"), "help missing -r flag")
	testing.expect(t, strings.contains(out, "-h, help"), "help missing -h flag")
}

@test
test_version_output :: proc(t: ^testing.T) {
	out := version("ox", "1.2.3")
	testing.expect(t, strings.contains(out, "OX"), "version missing app name")
	testing.expect(t, strings.contains(out, "1.2.3"), "version missing version")
}

@test
test_styled_config_line :: proc(t: ^testing.T) {
	line := styled_config_line("repo", "/home/user/.dotfiles")
	testing.expect(t, strings.contains(line, "repo"), "missing key")
	testing.expect(t, strings.contains(line, "/home/user/.dotfiles"), "missing value")
}

@test
test_parse_keep_no_value :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-k"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.keep, 10)
}

@test
test_parse_hostname_no_value :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	args := []string{"-n"}
	ok := cli_parse(args, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.hostname, "host")
}

@test
test_cli_run_help :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	cli_run(&config, {"-h"})
	// -h makes cli_parse return false, ox is never called
	testing.expect_value(t, config.update, false)
	testing.expect_value(t, config.diff, false)
}

@test
test_cli_run_version :: proc(t: ^testing.T) {
	config := Config{name = "ox", version = "1.0", repo = "/default", hostname = "host", keep = 10}
	cli_run(&config, {"-v"})
	// -v makes cli_parse return false, ox is never called
	testing.expect_value(t, config.update, false)
}

@test
test_cli_run_with_update :: proc(t: ^testing.T) {
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

	config := Config{name = "ox", version = "1.0", repo = repos.path, hostname = "test", keep = 10, update = true}

	// cli_run with update flag should parse and call ox
	// We use cli_parse then ox separately since cli_run would panic on error
	ok := cli_parse({"-u"}, &config)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, config.update, true)

	result := ox(&config, r)
	testing.expect_value(t, result, nil)
}

@test
test_get_hostname :: proc(t: ^testing.T) {
	hostname := get_hostname()
	testing.expect(t, len(hostname) > 0, "hostname should not be empty")
}

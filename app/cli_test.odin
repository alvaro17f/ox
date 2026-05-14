package app

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

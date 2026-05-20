package app

import "../lib/colors"
import "../utils"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:sys/posix"


Config :: struct {
	name:     string,
	version:  string,
	repo:     string,
	hostname: string,
	keep:     int,
	update:   bool,
	diff:     bool,
}

@(private)
help :: proc(app_name: string) -> string {
	assert(len(app_name) > 0)
	return fmt.tprintf(
		`
***************************************************
%s - A simple CLI tool to update your nixos system
***************************************************
-r : set repo path (default is $HOME/.dotfiles)
-n : set hostname (default is OS hostname)
-k : set generations to keep (default is 10)
-u : set update to true (default is false)
-d : set diff to true (default is false)
-h, help : Display this help message
-v, version : Display the current version
  `,
		strings.to_upper(app_name, context.temp_allocator),
	)
}

@(private)
version :: proc(app_name: string, current_version: string) -> string {
	assert(len(app_name) > 0)
	assert(len(current_version) > 0)
	return fmt.tprintf(
		"\n%s%s Version: %s%s%s%s",
		colors.YELLOW,
		strings.to_upper(app_name, context.temp_allocator),
		colors.RESET,
		colors.CYAN,
		current_version,
		colors.RESET,
	)
}

get_hostname :: proc() -> string {
	uname: posix.utsname
	posix.uname(&uname)

	result := strings.clone(string(uname.nodename[:]), context.temp_allocator)
	assert(len(result) > 0)
	return result
}

@(private)
styled_config_line :: proc(key: string, value: $T) -> string {
	assert(len(key) > 0)
	return fmt.tprintf(
		"%s ◉ %s%s%s%s = %s%v%s",
		colors.CYAN,
		colors.RESET,
		colors.RED,
		key,
		colors.RESET,
		colors.CYAN,
		value,
		colors.RESET,
	)
}

@(private)
print_config :: proc(config: ^Config) {
	assert(config != nil)
	assert(len(config.name) > 0)
	assert(len(config.repo) > 0)
	assert(len(config.hostname) > 0)
	assert(config.keep > 0)

	fmt.print(utils.title_maker_string(
		fmt.tprintf("%s Configuration", strings.to_upper(config.name, context.temp_allocator)),
	))
	fmt.println(styled_config_line("repo", config.repo))
	fmt.println(styled_config_line("hostname", config.hostname))
	fmt.println(styled_config_line("keep", config.keep))
	fmt.println(styled_config_line("update", config.update))
	fmt.println(styled_config_line("diff", config.diff))
}


// cli_parse parses command-line arguments and updates config.
// Returns true if execution should continue to ox(), false to stop.
// Exported for testing.
cli_parse :: proc(args: []string, config: ^Config) -> bool {
	assert(config != nil)

	i := 0
	for i < len(args) {
		arg := args[i]
		switch arg {
		case "-h", "help":
			fmt.println(help(config.name))
			return false
		case "-v", "version":
			fmt.println(version(config.name, config.version))
			return false
		case "-r":
			if i + 1 < len(args) {
				config.repo = args[i + 1]
				assert(len(config.repo) > 0)
				i += 2
			} else {
				i += 1
			}
		case "-k":
			if i + 1 < len(args) {
				keep_int, _ := strconv.parse_int(args[i + 1], 10)
				assert(keep_int > 0)
				config.keep = keep_int
				i += 2
			} else {
				i += 1
			}
		case "-n":
			if i + 1 < len(args) {
				config.hostname = args[i + 1]
				assert(len(config.hostname) > 0)
				i += 2
			} else {
				i += 1
			}
		case "-u":
			config.update = true
			i += 1
		case "-d":
			config.diff = true
			i += 1
		case:
			// combined flags like -du or -rud
			if strings.starts_with(arg, "-") {
				for ch in strings.trim_left(arg, "-") {
					switch ch {
					case 'd': config.diff = true
					case 'u': config.update = true
					}
				}
			}
			i += 1
		}
	}

	return true
}


cli_run :: proc(config: ^Config, args: []string, input: ^os.File = os.stdin) {
	assert(config != nil)
	assert(input != nil)

	if (len(args) == 0) {
		err := ox(config, input)
		if err != nil {
			fmt.panicf("Error: %s", err)
		}
	} else if cli_parse(args, config) {
		err := ox(config, input)
		if err != nil {
			fmt.panicf("Error: %s", err)
		}
	}
}

cli :: proc(config: ^Config) {
	assert(config != nil)
	cli_run(config, os.args[1:])
}
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
help :: proc(app_name: string) {
	fmt.printfln(
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
version :: proc(app_name: string, current_version: string) {
	fmt.printfln(
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

	return strings.clone(string(uname.nodename[:]), context.temp_allocator)
}

@(private)
styled_config_line :: proc(key: string, value: $T) {
	fmt.printfln(
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
	utils.title_maker(
		fmt.tprintf("%s Configuration", strings.to_upper(config.name, context.temp_allocator)),
	)
	styled_config_line("repo", config.repo)
	styled_config_line("hostname", config.hostname)
	styled_config_line("keep", config.keep)
	styled_config_line("update", config.update)
	styled_config_line("diff", config.diff)
}


// cli_parse parses command-line arguments and updates config.
// Exported for testing.
cli_parse :: proc(args: []string, config: ^Config) {
	i := 0
	for i < len(args) {
		arg := args[i]
		switch arg {
		case "-h", "help":
			help(config.name)
			return
		case "-v", "version":
			version(config.name, config.version)
			return
		case "-r":
			if i + 1 < len(args) {
				config.repo = args[i + 1]
				i += 2
			} else {
				i += 1
			}
		case "-k":
			if i + 1 < len(args) {
				keep_int, _ := strconv.parse_int(args[i + 1], 10)
				config.keep = keep_int
				i += 2
			} else {
				i += 1
			}
		case "-n":
			if i + 1 < len(args) {
				config.hostname = args[i + 1]
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
}


cli :: proc(config: ^Config) {
	arguments := os.args[1:]

	if (len(arguments) == 0) {
		ox(config)
	} else {
		cli_parse(arguments, config)
		ox(config)
		return
	}
}

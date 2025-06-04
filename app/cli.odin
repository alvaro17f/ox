package app

import s "../style"
import "../utils"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:sys/posix"


@(private)
Config :: struct {
	repo:     string,
	hostname: string,
	keep:     int,
	update:   bool,
	diff:     bool,
}

@(private)
help :: proc() {
	fmt.printfln(
		`
***************************************************
OX - A simple CLI tool to update your nixos system
***************************************************
-r : set repo path (default is $HOME/.dotfiles)
-n : set hostname (default is OS hostname)
-k : set generations to keep (default is 10)
-u : set update to true (default is false)
-d : set diff to true (default is false)
-h, help : Display this help message
-v, version : Display the current version
  `,
	)
}

@(private)
version :: proc(current_version: string) {
	fmt.printfln(
		"\n%sOX Version: %s%s%s",
		s.color.yellow,
		s.color.cyan,
		current_version,
		s.color.reset,
	)
}

@(private)
get_hostname :: proc() -> string {
	uname: posix.utsname
	posix.uname(&uname)

	return strings.clone(string(uname.nodename[:]), context.temp_allocator)
}

@(private)
styled_config_line :: proc(key: string, value: $T) {
	fmt.printfln(
		"%s ◉ %s%s%s%s = %s%v%s",
		s.color.cyan,
		s.color.reset,
		s.color.red,
		key,
		s.color.reset,
		s.color.cyan,
		value,
		s.color.reset,
	)
}

print_config :: proc(config: ^Config) {
	utils.title_maker("OX Configuration")
	styled_config_line("repo", config.repo)
	styled_config_line("hostname", config.hostname)
	styled_config_line("keep", config.keep)
	styled_config_line("update", config.update)
	styled_config_line("diff", config.diff)
}


cli :: proc(current_version: string) {
	arguments := os.args[1:]

	config := Config {
		repo     = fmt.tprintf("%s/.dotfiles", os.get_env("HOME", context.temp_allocator)),
		hostname = get_hostname(),
		keep     = 10,
		update   = false,
		diff     = false,
	}

	if (len(arguments) == 0) {
		ox(&config)
	} else {
		for argument, idx in arguments {
			switch (argument) {
			case "-h", "help":
				help()
				return
			case "-v", "version":
				version(current_version)
				return
			case:
				if (!strings.starts_with(argument, "-")) {
					break
				}

				if (strings.contains_rune(argument, 'd')) {
					config.diff = true
				}

				if (strings.contains_rune(argument, 'u')) {
					config.update = true
				}

				if (strings.contains_rune(argument, 'r')) {
					repo: string

					rest := strings.join(arguments[idx + 1:], " ", context.temp_allocator)
					idx_end := strings.index_rune(rest, '-')

					if (idx_end == -1) {
						repo = rest
					} else {
						repo = rest[:idx_end]
					}

					config.repo = strings.trim(repo, " ")
				}

				if (strings.contains_rune(argument, 'k')) {
					keep: string

					rest := strings.join(arguments[idx + 1:], " ", context.temp_allocator)
					idx_end := strings.index_rune(rest, '-')

					if (idx_end == -1) {
						keep = rest
					} else {
						keep = rest[:idx_end]
					}

					keep_int, _ := strconv.parse_int(strings.trim(keep, " "), 10)

					config.keep = keep_int
				}

				if (strings.contains_rune(argument, 'n')) {
					hostname: string

					rest := strings.join(arguments[idx + 1:], " ")
					idx_end := strings.index_rune(rest, '-')

					if (idx_end == -1) {
						hostname = rest
					} else {
						hostname = rest[:idx_end]
					}

					config.hostname = strings.trim(hostname, " ")
				}
			}
		}

		ox(&config)
		return
	}
}


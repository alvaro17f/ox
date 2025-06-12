package main

import "app"
import "core:fmt"
import "core:mem"
import "core:os"

NAME :: "ox"
VERSION :: #config(VERSION, "dev")


_main :: proc() {
	config := app.Config {
		name     = NAME,
		version  = VERSION,
		repo     = fmt.tprintf("%s/.dotfiles", os.get_env("HOME", context.temp_allocator)),
		hostname = app.get_hostname(),
		keep     = 10,
		update   = false,
		diff     = false,
	}

	app.cli(&config)
	free_all(context.temp_allocator)
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintfln("\n=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	_main()
}


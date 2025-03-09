package main

import battery "../../."
import "core:fmt"
import "core:mem"
import "core:os"
import "core:flags"

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}
	config: battery.Config
	flags.parse_or_exit(&config, os.args)
	status, err := battery.run()
	if err != nil {
		fmt.eprintfln("couln't read battery status: %s", err)
		os.exit(1)
	}
	if config.minimal {
		fmt.println(status.ChargePercent)
		return
	}
	fmt.printfln("Battery %d%% charged.", status.ChargePercent)
}

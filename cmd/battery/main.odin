package main

import battery "../../."
import "core:flags"
import "core:fmt"
import "core:mem"
import "core:os"

main :: proc() {
	arena: mem.Arena
	buf: [1 * mem.Kilobyte]byte
	mem.arena_init(&arena, buf[:])
	defer mem.arena_free_all(&arena)

	context.allocator = mem.arena_allocator(&arena)

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

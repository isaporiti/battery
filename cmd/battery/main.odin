package main

import battery "../../."
import "core:fmt"
import "core:os"

main :: proc() {
	status, err := battery.run()
	if err != nil {
		fmt.eprintfln("couln't read battery status: %s", err)
		os.exit(1)
	}
	fmt.printfln("Battery %d%% charged.", status.ChargePercent)
}

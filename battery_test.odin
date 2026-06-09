package battery

import "core:mem"
import "core:os"
import "core:path/filepath"
import "core:testing"

@(test)
test_parse_pmset_output :: proc(t: ^testing.T) {
	arena: mem.Arena
	buf: [1 * mem.Kilobyte]byte
	mem.arena_init(&arena, buf[:])
	defer mem.arena_free_all(&arena)
	context.allocator = mem.arena_allocator(&arena)

	current_dir, dir_err := os.get_working_directory(context.allocator)
	if dir_err != nil {
		testing.fail(t)
		return
	}

	pmset_ouput_path, join_err := filepath.join(
		[]string{current_dir, "testdata", "pmset_output.txt"},
	)
	if join_err != .None {
		testing.fail(t)
		return
	}

	data, file_err := os.read_entire_file(pmset_ouput_path, context.allocator)
	if file_err != nil {
		testing.fail(t)
		return
	}

	status, parse_err := parse_pmset_output(string(data))
	if parse_err != nil {
		testing.fail(t)
		return
	}

	testing.expect(t, status.ChargePercent == 40)
}

@(test)
test_parse_pmset_output_no_match_error :: proc(t: ^testing.T) {
	arena: mem.Arena
	buf: [1 * mem.Kilobyte]byte
	mem.arena_init(&arena, buf[:])
	defer mem.arena_free_all(&arena)
	context.allocator = mem.arena_allocator(&arena)

	status, err := parse_pmset_output("won't match")

	testing.expect(t, err == .NoMatchError)
	testing.expect(t, status.ChargePercent == 0)
}

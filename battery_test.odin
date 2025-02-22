package battery

import "core:os"
import "core:path/filepath"
import "core:testing"

@(test)
test_parse_pmset_output :: proc(t: ^testing.T) {
	current_dir := os.get_current_directory()
	defer delete(current_dir)

	pmset_ouput_path, join_err := filepath.join(
		[]string{current_dir, "testdata", "pmset_output.txt"},
	)
	if join_err != .None {
		testing.fail(t)
		return
	}
	defer delete(pmset_ouput_path)

	data, ok := os.read_entire_file(pmset_ouput_path)
	if !ok {
		testing.fail(t)
		return
	}
	defer delete(data)

	status, parse_err := parse_pmset_output(string(data))
	if parse_err != nil {
		testing.fail(t)
		return
	}

	testing.expect(t, status.ChargePercent == 40)
}

@(test)
test_parse_pmset_output_no_match_error :: proc(t: ^testing.T) {
	status, err := parse_pmset_output("won't match")

	testing.expect(t, err == .NoMatchError)
	testing.expect(t, status.ChargePercent == 0)
}

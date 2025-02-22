package battery

import "core:testing"

@(test)
test_get_pmset_output :: proc(t: ^testing.T) {
	out, out_err := get_pmset_output()
	if out_err != nil {
		testing.fail(t)
		return
	}
	defer delete(out)

	status, parse_err := parse_pmset_output(out)
	if parse_err != nil {
		testing.fail(t)
	}
	testing.expect(t, status.ChargePercent != 0)
}

package battery

import "core:os"
import "core:strconv"
import "core:text/regex"

run :: proc() -> (Status, Error) {
	out, out_err := get_pmset_output()
	if out_err != nil {
		return Status{}, out_err
	}

	status, parse_err := parse_pmset_output(out)
	if parse_err != nil {
		return Status{}, parse_err
	}

	return status, nil
}

Config :: struct {
	minimal: bool `args:"name=minimal" usage:"Return the current battery percentage only."`,
}

Status :: struct {
	ChargePercent: int,
}

Error :: union #shared_nil {
	os.Error,
	regex.Error,
	CustomRegexError,
}

CustomRegexError :: enum {
	NoMatchError,
}

@(private)
get_pmset_output :: proc() -> (string, Error) {
	_, stdout, _, err := os.process_exec(
		os.Process_Desc{command = []string{"/usr/bin/pmset", "-g", "ps"}},
		context.allocator,
	)
	if err != nil {
		return "", err
	}

	return string(stdout), nil
}

@(private)
parse_pmset_output :: proc(data: string) -> (Status, Error) {
	charge_regex, err := regex.create("([0-9]+)%", {})
	if err != nil {
		return Status{}, err
	}

	capture, capture_ok := regex.match_and_allocate_capture(charge_regex, data)
	if !capture_ok {
		return Status{}, .NoMatchError
	}

	charge_percent, parse_ok := strconv.parse_int(capture.groups[1])
	if !parse_ok {
		return Status{}, .NoMatchError
	}
	return Status{ChargePercent = charge_percent}, nil
}

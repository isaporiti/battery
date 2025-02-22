package battery

import "core:fmt"
import "core:os/os2"
import "core:strconv"
import "core:text/regex"

run :: proc() -> (Status, Error) {
	out, out_err := get_pmset_output()
	if out_err != nil {
		return Status{}, out_err
	}
	defer delete(out)
	status, parse_err := parse_pmset_output(out)
	if parse_err != nil {
		return Status{}, parse_err
	}
	return status, nil
}

Status :: struct {
	ChargePercent: int,
}

Error :: union #shared_nil {
	os2.Error,
	regex.Error,
	CustomRegexError,
}

CustomRegexError :: enum {
	NoMatchError,
}

@(private)
get_pmset_output :: proc() -> (string, Error) {
	_, stdout, _, err := os2.process_exec(
		os2.Process_Desc{command = []string{"/usr/bin/pmset", "-g", "ps"}},
		context.allocator,
	)
	if err != nil {
		return "", err
	}

	return string(stdout), nil
}

@(private)
parse_pmset_output :: proc(data: string) -> (Status, Error) {
	charge_regex, err := regex.create("([0-9]+)%", {.Global})
	if err != nil {
		return Status{}, err
	}
	defer regex.destroy(charge_regex)

	capture, ok := regex.match_and_allocate_capture(charge_regex, data)
	if !ok {
		return Status{}, .NoMatchError
	}
	defer regex.destroy(capture)

	return Status{ChargePercent = strconv.atoi(capture.groups[0])}, nil
}

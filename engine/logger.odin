package engine

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:time"

Log_Level :: enum {
	Debug,
	Trace,
	Info,
	Warn,
	Error,
	Fatal,
}

Logger :: struct {
	enable_colors: bool,
	min_level:     Log_Level,
}

logger: Logger

Log_Level_Color := [Log_Level]string {
	.Debug = ANSI_BLUE,
	.Trace = ANSI_GRAY,
	.Info  = ANSI_GREEN,
	.Warn  = ANSI_YELLOW,
	.Error = ANSI_RED,
	.Fatal = ANSI_RED,
}

Log_Level_Label := [Log_Level]string {
	.Debug = "[Debug]:",
	.Trace = "[Trace]:",
	.Info  = "[Info ]:",
	.Warn  = "[Warn ]:",
	.Error = "[Error]:",
	.Fatal = "[Fatal]:",
}

@(private = "file")
ANSI_RESET :: "\x1b[0m"

@(private = "file")
ANSI_RED :: "\x1b[31m"

@(private = "file")
ANSI_GREEN :: "\x1b[32m"

@(private = "file")
ANSI_YELLOW :: "\x1b[33m"

@(private = "file")
ANSI_BLUE :: "\x1b[34m"

@(private = "file")
ANSI_GRAY :: "\x1b[90m"

logger_initialize :: proc() -> b8 {
	// TODO: create log file.

	logger.enable_colors = true

	when ODIN_DEBUG {
		logger.min_level = .Debug
	} else {
		logger.min_level = .Info
	}

	return true
}

logger_shutdown :: proc() {
	// TODO: cleanup logging/write queue entries
}

log_fatal :: proc(
	message: string,
	args: ..any,
	loc: runtime.Source_Code_Location = #caller_location,
) {
	logger_log_output(.Fatal, loc, message, ..args)
}

log_error :: proc(
	message: string,
	args: ..any,
	loc: runtime.Source_Code_Location = #caller_location,
) {
	logger_log_output(.Error, loc, message, ..args)
}

log_warn :: proc(
	message: string,
	args: ..any,
	loc: runtime.Source_Code_Location = #caller_location,
) {
	logger_log_output(.Warn, loc, message, ..args)
}

log_info :: proc(
	message: string,
	args: ..any,
	loc: runtime.Source_Code_Location = #caller_location,
) {
	logger_log_output(.Info, loc, message, ..args)
}

log_debug :: proc(
	message: string,
	args: ..any,
	loc: runtime.Source_Code_Location = #caller_location,
) {
	logger_log_output(.Debug, loc, message, ..args)
}

log_trace :: proc(
	message: string,
	args: ..any,
	loc: runtime.Source_Code_Location = #caller_location,
) {
	logger_log_output(.Trace, loc, message, ..args)
}

@(private = "file")
pad_right :: proc(s: string, width: int) -> string {
	if len(s) >= width {
		return s
	}

	buf := make([]u8, width)
	copy(buf, s)

	for i := len(s); i <= width; i += 1 {
		buf[i] = ' '
	}

	return string(buf)
}

@(private = "file")
pad2 :: proc(v: i8) -> string {
	if v < 10 {
		return fmt.tprintf("0{0}", v)
	}

	return fmt.tprintf("{0}", v)
}

@(private = "file")
logger_log_output :: proc(
	level: Log_Level,
	loc: runtime.Source_Code_Location = #caller_location,
	format: string,
	args: ..any,
) {
	if level < logger.min_level {
		return
	}

	label := Log_Level_Label[level]

	if logger.enable_colors {
		fmt.print(Log_Level_Color[level])
	}

	now := time.now()
	date_time, _ := time.time_to_datetime(now)

	file := filepath.base(loc.file_path)
	fmt.printf(
		"{0} {1}:{2}:{3} UTC {4}:{5}: ",
		label,
		pad2(date_time.hour),
		pad2(date_time.minute),
		pad2(date_time.second),
		file,
		loc.line,
	)

	fmt.printfln(format, ..args)

	if logger.enable_colors {
		fmt.print(ANSI_RESET)
	}

	// if level == .Fatal {
	// 	os.exit(1)
	// }
}

package engine

import "core:fmt"

Log_Level :: enum {
	Fatal = 0,
	Error,
	Warn,
	Info,
	Debug,
	Trace,
	Max,
}

logger_initialize :: proc() -> b8 {
	// TODO: create log file.
	return true
}

logger_shutdown :: proc() {
	// TODO: cleanup logging/write queue entries
}

log_fatal :: proc(message: string, args: ..any) {
	logger_log_output(.Fatal, message, ..args)
}

log_error :: proc(message: string, args: ..any) {
	logger_log_output(.Error, message, ..args)
}

log_warn :: proc(message: string, args: ..any) {
	logger_log_output(.Warn, message, ..args)
}

log_info :: proc(message: string, args: ..any) {
	logger_log_output(.Info, message, ..args)
}

log_debug :: proc(message: string, args: ..any) {
	logger_log_output(.Debug, message, ..args)
}

log_trace :: proc(message: string, args: ..any) {
	logger_log_output(.Trace, message, ..args)
}

@(private = "file")
logger_log_output :: proc(level: Log_Level, message: string, args: ..any) {
	level_strings := [max(Log_Level)]string {
		"[FATAL]: ",
		"[ERROR]: ",
		"[WARN ]: ",
		"[INFO ]: ",
		"[DEBUG]: ",
		"[TRACE]: ",
	}

	is_error: b8 = level <= .Error

	out_message := fmt.tprintf(message, ..args)
	out_message2 := fmt.tprintf("%s%s", level_strings[level], out_message)

	fmt.println(out_message2)
}

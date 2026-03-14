package testbed

import "../engine"

main :: proc() {
	engine.log_fatal("A test message: %.2f", 3.14)
	engine.log_error("A test message: %.2f", 3.14)
	engine.log_warn("A test message: %.2f", 3.14)
	engine.log_info("A test message: %.2f", 3.14)
	engine.log_debug("A test message: %.2f", 3.14)
	engine.log_trace("A test message: %.2f", 3.14)
}

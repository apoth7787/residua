package testbed

import "../engine"
import "../engine/platform"

main :: proc() {
	engine.log_fatal("A test message: %.2f", 3.14)
	engine.log_error("A test message: %.2f", 3.14)
	engine.log_warn("A test message: %.2f", 3.14)
	engine.log_info("A test message: %.2f", 3.14)
	engine.log_debug("A test message: %.2f", 3.14)
	engine.log_trace("A test message: %.2f", 3.14)

	state: platform.Platform_State
	if (platform.platform_startup(&state, "Residua Testbed", 100, 100, 1280, 720)) {
		for {
			if platform.platform_pump_messages(&state) == true {
				break
			}
		}
	}
	platform.platform_shutdown(&state)
}

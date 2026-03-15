package engine

import "platform"

Application_Config :: struct {
	start_pos_x:  int,
	start_pos_y:  int,
	start_width:  int,
	start_height: int,
	name:         cstring,
}

Application_State :: struct {
	game_inst:    ^Game,
	is_running:   b8,
	is_suspended: b8,
	platform:     platform.Platform_State,
	width:        i32,
	height:       i32,
	last_time:    f64,
}

@(private = "file")
initialized: b8

@(private = "file")
app_state: Application_State

application_create :: proc(game_inst: ^Game) -> b8 {
	if initialized {
		log_fatal("application_create called more then once.")
		return false
	}

	app_state.game_inst = game_inst

	logger_initialize()

	//TODO: Remove these
	log_fatal("A test message: %.2f", 3.14)
	log_error("A test message: %.2f", 3.14)
	log_warn("A test message: %.2f", 3.14)
	log_info("A test message: %.2f", 3.14)
	log_debug("A test message: %.2f", 3.14)
	log_trace("A test message: %.2f", 3.14)

	app_state.is_running = true
	app_state.is_suspended = false

	if !platform.platform_startup(
		&app_state.platform,
		game_inst.app_config.name,
		i32(game_inst.app_config.start_pos_x),
		i32(game_inst.app_config.start_pos_y),
		i32(game_inst.app_config.start_width),
		i32(game_inst.app_config.start_height),
	) {
		return false
	}

	if !app_state.game_inst.initialize(app_state.game_inst) {
		log_fatal("Game failed to initialize.")
		return false
	}

	app_state.game_inst.on_resize(app_state.game_inst, app_state.width, app_state.height)

	initialized = true

	return true
}

application_run :: proc() -> b8 {
	for app_state.is_running {
		if platform.platform_pump_messages(&app_state.platform) {
			app_state.is_running = false
		}

		if !app_state.is_suspended {
			if !app_state.game_inst.update(app_state.game_inst, f32(0)) {
				log_fatal("Game update failed, shutting down")
				app_state.is_running = false
			}

			if !app_state.game_inst.render(app_state.game_inst, f32(0)) {
				log_fatal("Game render failed, shutting down")
				app_state.is_running = false
			}
		}
	}

	app_state.is_running = false

	platform.platform_shutdown(&app_state.platform)

	return true
}

package testbed

import "../engine"
import "core:os"

Game_State :: struct {
	delta_time: f32,
}

main :: proc() {
	engine.memory_initialize()

	game_inst: engine.Game
	if !create_game(&game_inst) {
		engine.log_fatal("Could not create game")
		os.exit(-1)
	}

	if game_inst.render == nil ||
	   game_inst.update == nil ||
	   game_inst.initialize == nil ||
	   game_inst.on_resize == nil {
		engine.log_fatal("The game function pointers must be assigned!")
		os.exit(-2)
	}

	if !engine.application_create(&game_inst) {
		engine.log_fatal("Application failed to create")
		os.exit(1)
	}

	if !engine.application_run() {
		engine.log_info("Application did not shutdown gracefully")
	}

	engine.memory_shutdown()
}

create_game :: proc(out_game: ^engine.Game) -> b8 {
	out_game.app_config.start_pos_x = 100
	out_game.app_config.start_pos_y = 100
	out_game.app_config.start_width = 1280
	out_game.app_config.start_height = 720
	out_game.app_config.name = "Residua Testbed"
	out_game.initialize = game_initialize
	out_game.update = game_update
	out_game.render = game_render
	out_game.on_resize = game_on_resize
	out_game.state = engine.memory_allocate_tag(size_of(Game_State), .Game)

	return true
}

game_initialize :: proc(game_inst: ^engine.Game) -> b8 {
	engine.log_debug("game_initialize called")
	return true
}

game_update :: proc(game_inst: ^engine.Game, delta_time: f32) -> b8 {
	return true
}

game_render :: proc(game_inst: ^engine.Game, delta_time: f32) -> b8 {
	return true
}

game_on_resize :: proc(game_inst: ^engine.Game, width, height: i32) {

}

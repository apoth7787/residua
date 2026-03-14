package platform

import "vendor:sdl3"

Internal_State :: struct {
	window:   ^sdl3.Window,
	renderer: ^sdl3.Renderer,
}

platform_startup :: proc(
	plat_state: ^Platform_State,
	application_name: cstring,
	x, y, width, height: i32,
) -> b8 {
	if !sdl3.Init({.VIDEO, .EVENTS}) {
		return false
	}

	plat_state.internal_state = new(Internal_State)
	state := cast(^Internal_State)plat_state.internal_state

	state.window = sdl3.CreateWindow(application_name, width, height, nil)
	if state.window == nil {
		return false
	}

	state.renderer = sdl3.CreateRenderer(state.window, nil)
	if state.renderer == nil {
		return false
	}

	return true
}

platform_shutdown :: proc(plat_state: ^Platform_State) {
	state := cast(^Internal_State)plat_state.internal_state

	if state.renderer != nil {
		sdl3.DestroyRenderer(state.renderer)
	}

	if state.window != nil {
		sdl3.DestroyWindow(state.window)
	}

	sdl3.Quit()
}

platform_pump_messages :: proc(plat_state: ^Platform_State) -> b8 {
	state := cast(^Internal_State)plat_state.internal_state

	quit_flagged: b8 = false
	event: sdl3.Event

	for sdl3.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			quit_flagged = true
		}
	}

	return quit_flagged
}

platform_get_absolute_time :: proc() -> f64 {
	counter := sdl3.GetPerformanceCounter()
	freq := sdl3.GetPerformanceFrequency()
	return f64(counter) / f64(freq)
}

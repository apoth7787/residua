package engine

Event_Context :: struct #raw_union {
	i64: [2]i64,
	u64: [2]u64,
	f64: [2]f64,
	i32: [4]i32,
	u32: [4]u32,
	f32: [4]f32,
	i16: [8]i16,
	u16: [8]u16,
	i8:  [16]i8,
	u8:  [16]u8,
	r:   [16]rune,
}

Event_Code :: enum {
	Application_Quit      = 0x01,
	Key_Pressed           = 0x02,
	Key_Released          = 0x03,
	Mouse_Button_Pressed  = 0x04,
	Mouse_Button_Released = 0x05,
	Mouse_Moved           = 0x06,
	Mouse_Wheel           = 0x07,
	Resized               = 0x08,
	Max                   = 0xFF,
}

Event_Registered :: struct {
	listener: rawptr,
	callback: event_on_event_pfn,
}

Event_Code_Entry :: struct {
	events: [dynamic]Event_Registered,
}

EVENT_MAX_MESSAGE_CODES :: 16384

Event_System_State :: struct {
	registered: [EVENT_MAX_MESSAGE_CODES]Event_Code_Entry,
}

event_is_initialized: b8
event_state: Event_System_State

event_on_event_pfn :: proc(code: u16, sender, listener_inst: rawptr, data: Event_Context) -> b8

event_initialize :: proc() -> b8 {
	if event_is_initialized == true {
		return false
	}

	event_is_initialized = true

	return true
}

event_shutdown :: proc() {
	for i in 0 ..< EVENT_MAX_MESSAGE_CODES {
		if event_state.registered[i].events != nil {
			delete(event_state.registered[i].events)
			event_state.registered[i].events = nil
		}
	}
}

event_register :: proc(code: u16, listener: rawptr, on_event: event_on_event_pfn) -> b8 {
	if event_is_initialized == false {
		return false
	}

	if event_state.registered[code].events == nil {
		event_state.registered[code].events, _ = make([dynamic]Event_Registered)
	}

	registered_count: u64 = u64(len(event_state.registered[code].events))
	for i in 0 ..< registered_count {
		if event_state.registered[code].events[i].listener == listener {
			return false
		}
	}

	event: Event_Registered
	event.listener = listener
	event.callback = on_event
	append(&event_state.registered[code].events, event)

	return true
}

event_unregister :: proc(code: u16, listener: rawptr, on_event: event_on_event_pfn) -> b8 {
	if event_is_initialized == false {
		return false
	}

	if event_state.registered[code].events == nil {
		return false
	}

	registered_count: u64 = u64(len(event_state.registered[code].events))
	for i in 0 ..< registered_count {
		e: Event_Registered = event_state.registered[code].events[i]
		if e.listener == listener && e.callback == on_event {
			unordered_remove(&event_state.registered[code].events, i)
			return true
		}
	}

	return false
}

event_fire :: proc(code: u16, sender: rawptr, event_context: Event_Context) -> b8 {
	if event_is_initialized == false {
		return false
	}

	if event_state.registered[code].events == nil {
		return false
	}

	registered_count: u64 = u64(len(event_state.registered[code].events))
	for i in 0 ..< registered_count {
		e: Event_Registered = event_state.registered[code].events[i]
		if e.callback(code, sender, e.listener, event_context) {
			return true
		}
	}

	return false
}

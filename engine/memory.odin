package engine

import "core:fmt"
import "core:mem"
import "core:strings"

Memory_Tag :: enum {
	Unknown,
	Array,
	Dynamic,
	String,
	Application,
	Renderer,
	Game,
	Scene,
	Max_Tags,
}

Memory_Stats :: struct {
	total_allocated:    u64,
	tagged_allocations: [max(Memory_Tag)]u64,
}

memory_tag_strings: [max(Memory_Tag)]string = {
	"Unknown    : ",
	"Array      : ",
	"Dynamic    : ",
	"String     : ",
	"Application: ",
	"Renderer   : ",
	"Game       : ",
	"Scene      : ",
}

stats: Memory_Stats

memory_initialize :: proc() {
	memory_zero(&stats, size_of(stats))
}

memory_shutdown :: proc() {

}

memory_allocate_tag :: proc(size: u64, tag: Memory_Tag) -> rawptr {
	if tag == .Unknown {
		log_warn("memory_allocate_tag called using Memory_Tag.Unknown. Re-class this allocation.")
	}

	stats.total_allocated += size
	stats.tagged_allocations[tag] += size

	block: rawptr = memory_allocate(size)
	memory_zero(block, size)
	return block
}

memory_free_tag :: proc(block: rawptr, size: u64, tag: Memory_Tag) {
	if tag == .Unknown {
		log_warn("memory_free_tag called using Memory_Tag.Unknown. Re-class this allocation.")
	}

	stats.total_allocated -= size
	stats.tagged_allocations[tag] -= size

	memory_free(block)
}

memory_allocate :: proc(size: u64, alignment: u64 = 0) -> rawptr {
	ptr, err := mem.alloc(int(size))
	if err != nil {
		panic("Memory allocation failed")
	}
	return ptr
}

memory_free :: proc(block: rawptr) {
	mem.free(block)
}

memory_zero :: proc(block: rawptr, size: u64) {
	mem.zero(block, int(size))
}

memory_copy :: proc(dest, source: rawptr, size: u64) {
	mem.copy(dest, source, int(size))
}

memory_set :: proc(dest: rawptr, value: u8, size: u64) {
	mem.set(dest, value, int(size))
}

memory_log_usage_string :: proc() {
	KIB: u64 : 1024
	MIB: u64 : KIB * KIB
	GIB: u64 : MIB * KIB

	sb := strings.builder_make()
	strings.write_string(&sb, "System memory use (tagged):\n")

	for i in min(Memory_Tag) ..< max(Memory_Tag) {
		unit: [3]rune = "Xib"
		amount: f32 = 1.0

		if stats.tagged_allocations[i] >= GIB {
			unit[0] = 'G'
			amount = f32(stats.tagged_allocations[i]) / f32(GIB)
		} else if stats.tagged_allocations[i] >= MIB {
			unit[0] = 'M'
			amount = f32(stats.tagged_allocations[i]) / f32(MIB)
		} else if stats.tagged_allocations[i] >= KIB {
			unit[0] = 'K'
			amount = f32(stats.tagged_allocations[i]) / f32(KIB)
		} else {
			unit[0] = 'B'
			amount = f32(stats.tagged_allocations[i])
		}

		if unit[0] == 'B' {
			// NOTE: only print out the first rune in the array since the other parts don't make sense in this context
			fmt.sbprintfln(&sb, "%s%.2f%r", memory_tag_strings[i], amount, unit[0])
		} else {
			fmt.sbprintfln(
				&sb,
				"%s%.2f%r%r%r",
				memory_tag_strings[i],
				amount,
				unit[0],
				unit[1],
				unit[2],
			)
		}
	}

	memory_usage := strings.to_string(sb)

	log_info(memory_usage)

	strings.builder_destroy(&sb)
}

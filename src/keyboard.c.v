module mouse

import time

// KeyCode is a key on the keyboard for Apple's ApplicationServices.h.
@[_allow_multiple_values]
pub enum KeyCode {
	// MacOS
	// Alphabet keys
	a             = 0
	s             = 1
	d             = 2
	f             = 3
	h             = 4
	g             = 5
	z             = 6
	x             = 7
	c             = 8
	v             = 9
	b             = 11
	q             = 12
	w             = 13
	e             = 14
	r             = 15
	y             = 16
	t             = 17
	key_1         = 18
	key_2         = 19
	key_3         = 20
	key_4         = 21
	key_6         = 22
	key_5         = 23
	equal         = 24
	key_9         = 25
	key_7         = 26
	minus         = 27
	key_8         = 28
	key_0         = 29
	right_bracket = 30
	o             = 31
	u             = 32
	left_bracket  = 33
	i             = 34
	p             = 35
	l             = 37
	j             = 38
	quote         = 39
	k             = 40
	semicolon     = 41
	backslash     = 42
	comma         = 43
	slash         = 44
	n             = 45
	m             = 46
	period        = 47
	grave         = 50

	// Modifier keys
	left_shift  = 56
	right_shift = 60
	left_ctrl   = 59
	right_ctrl  = 62
	left_alt    = 58
	right_alt   = 61
	left_cmd    = 55
	right_cmd   = 54

	// Function keys
	f1  = 122
	f2  = 120
	f3  = 99
	f4  = 118
	f5  = 96
	f6  = 97
	f7  = 98
	f8  = 100
	f9  = 101
	f10 = 109
	f11 = 103
	f12 = 111
	f13 = 105
	f14 = 107
	f15 = 113
	f16 = 106
	f17 = 64
	f18 = 79
	f19 = 80
	f20 = 90

	// Control keys
	return_key = 36
	tab        = 48
	space      = 49
	delete     = 51
	escape     = 53
	command    = 55
	shift      = 56
	caps_lock  = 57
	option     = 58
	control    = 59

	// Arrow keys
	up_arrow    = 126
	down_arrow  = 125
	left_arrow  = 123
	right_arrow = 124

	// Numpad keys
	numpad_0        = 82
	numpad_1        = 83
	numpad_2        = 84
	numpad_3        = 85
	numpad_4        = 86
	numpad_5        = 87
	numpad_6        = 88
	numpad_7        = 89
	numpad_8        = 91
	numpad_9        = 92
	numpad_dot      = 65
	numpad_divide   = 75
	numpad_multiply = 67
	numpad_minus    = 78
	numpad_plus     = 69
	numpad_enter    = 76
}

@[inline]
pub fn KeyCode.from_byte(c u8) ?KeyCode {
	return match c {
		`a` { KeyCode.a }
		`s` { KeyCode.s }
		`d` { KeyCode.d }
		`f` { KeyCode.f }
		`h` { KeyCode.h }
		`g` { KeyCode.g }
		`z` { KeyCode.z }
		`x` { KeyCode.x }
		`c` { KeyCode.c }
		`v` { KeyCode.v }
		`b` { KeyCode.b }
		`q` { KeyCode.q }
		`w` { KeyCode.w }
		`e` { KeyCode.e }
		`r` { KeyCode.r }
		`y` { KeyCode.y }
		`t` { KeyCode.t }
		`1` { KeyCode.key_1 }
		`2` { KeyCode.key_2 }
		`3` { KeyCode.key_3 }
		`4` { KeyCode.key_4 }
		`6` { KeyCode.key_6 }
		`5` { KeyCode.key_5 }
		`=` { KeyCode.equal }
		`9` { KeyCode.key_9 }
		`7` { KeyCode.key_7 }
		`-` { KeyCode.minus }
		`8` { KeyCode.key_8 }
		`0` { KeyCode.key_0 }
		`]` { KeyCode.right_bracket }
		`o` { KeyCode.o }
		`u` { KeyCode.u }
		`[` { KeyCode.left_bracket }
		`i` { KeyCode.i }
		`p` { KeyCode.p }
		`l` { KeyCode.l }
		`j` { KeyCode.j }
		`'` { KeyCode.quote }
		`k` { KeyCode.k }
		`;` { KeyCode.semicolon }
		`\\` { KeyCode.backslash }
		`,` { KeyCode.comma }
		`/` { KeyCode.slash }
		`n` { KeyCode.n }
		`m` { KeyCode.m }
		`.` { KeyCode.period }
		`\`` { KeyCode.grave }
		` ` { .space }
		else { return none }
	}
}

@[params]
pub struct KeyboardWriteParams {
__global:
	speed time.Duration = 50 * time.millisecond
}

@[noinit]
pub struct Keyboard {}

// Keyboard.press emulates a key press.
@[inline]
pub fn Keyboard.press(key_code KeyCode) {
	keyboard_event(key_code, true)
	time.sleep(50 * time.millisecond)
	keyboard_event(key_code, false)
}

// Keyboard.write types out a string.
@[inline]
pub fn Keyboard.write(str string, params KeyboardWriteParams) {
	for c in str {
		if code := KeyCode.from_byte(c) {
			keyboard_event(code, true)
			time.sleep(params.speed)
			keyboard_event(code, false)
		}
	}
}

// keyboard_event creates an event
fn keyboard_event(key_code KeyCode, is_key_down_event bool) {
	$if macos {
		event := C.CGEventCreateKeyboardEvent(unsafe { nil }, int(key_code), is_key_down_event)
		C.CGEventPost(C.kCGHIDEventTap, event)
		C.CFRelease(event)
	} $else {
		$compile_error('unsupported OS')
	}
}

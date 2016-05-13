import concat from table
import char from string

--- utils
----{{{
zsplit = (n = 1) => [c for c in @\gmatch "."\rep n]
string = string  -- in THIS chunk, add `zsplit` to `string` module
string.zsplit = zsplit

map = (fn, xs) -> [fn x for x in *xs]
hexdecode = (cnt = 1) -> ("%02X"\rep cnt)\format
hextobin = (hex) ->
	btable = {
		"0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111",
		"1000", "1001", "1010", "1011", "1100", "1101", "1110", "1111"
	}

	concat map (=> btable[(tonumber "0x#{@}") + 1]), hex\zsplit!

bintoint = (bin) ->
	i = -1
	with ret = 0
		for c in bin\reverse!\gmatch"."
			i += 1
			ret += 2^i * tonumber(c)

hextoint = (hex) -> bintoint hextobin hex
hextochar = (ahex) -> string.char tonumber "0x#{ahex}"

insgen = (ins) ->
	abc = (a, b, c) ->
		unpack map bintoint, {a, b, c}
	abx = (a, b, c) ->
		unpack map bintoint, {a, b .. c}
	ax = (a, _, _) -> bintoint a

	op_list =  {
		{"MOVE", abc}, {"LOADK", abx}, {"LOADKX", abx}, {"LOADBOOL", abc}, {"LOADNIL", abc}, {"GETUPVAL", abc},
		{"GETTABUP", abc}, {"GETTABLE", abc}, {"SETTABUP", abc}, {"SETUPVAL", abc}, {"SETTABLE", abc}, {"NEWTABLE", abc},
		{"SELF", abc}, {"ADD", abc}, {"SUB", abc}, {"MUL", abc}, {"DIV", abc}, {"MOD", abc},
		{"POW", abc }, {"UNM", abc }, {"NOT", abc }, {"LEN", abc }, {"CONCAT", abc }, {"JMP", abx },
		{"EQ", abc }, {"LT", abc }, {"LE", abc }, {"TEST", abc }, {"TESTSET", abc }, {"CALL", abc },
		{"TAILCALL", abc }, {"RETURN", abc }, {"FORLOOP", abx }, {"FORPREP", abx }, {"TFORCALL", abc }, {"TFORLOOP", abx },
		{"SETLIST", abc }, {"CLOSURE", abx }, {"VARARG", abc }, {"EXTRAARG", ax}
	}

	b, c, a, i = (hextobin ins)\match "(#{"."\rep 9})(#{"."\rep 9})(#{"."\rep 8})(#{"."\rep 6})"
	{op, fn} = op_list[(bintoint i) + 1]

	{ins, op, fn(a, b, c)}

prerr = (ne, msg) -> not ne and io.stdout\write(msg , '\n')
----}}}

-- decodeer
----{{{
hblockdecode = (input) -> with input
	return {
		hsig: \read 4
		version: (hexdecode! (\read 1)\byte!)\gsub("(%d)(%d)", "%1.%2")
		format: (\read 1)\byte!
		endian: (\read 1)\byte!
		size: {
			int: (\read 1)\byte!
			size_t: (\read 1)\byte!
			instruction: (\read 1)\byte!
			lua_number: (\read 1)\byte!
		}
		intflag: (\read 1)\byte!
		luac_data: \read 6
	}

headassert = (header) -> pcall ->
		assert header.hsig == char(0x1b, 0x4c, 0x75, 0x61), "HEADER SIGNATURE ERROR" -- header signature
		assert header.luac_data == char(0x19, 0x93, 0x0d, 0x0a, 0x1a, 0x0a), "CONVERSION ERROR"


providetools = (input, header) ->
	header or= hblockdecode input

	mayberotate = if header.endian < 1 then (=> @) else (xs) -> [xs[i] for i = #xs, 1, -1]
	undumpchar = -> hexdecode! (input\read 1)\byte!
	undump_n = (n) -> hexdecode(n) unpack mayberotate {(input\read n)\byte 1, n}
	undumpint = -> undump_n 4
	{
		:mayberotate
		:undump_n
		:undumpchar
		:undumpint
	}

fnblockdecode = (input, header) -> with header or hblockdecode input
	import mayberotate, undump_n, undumpchar, undumpint from providetools input, header

	line = {
		defined: undumpint!
		lastdefined: undumpint!
		}

	params = undumpchar!
	vararg = undumpchar!
	regnum = undumpchar!

	instruction = with num: hextoint undumpint!
		.ins = [insgen undumpint! for _ = 1, .num]

	-- num = hextoint undumpint!

	constant = with num: hextoint undumpint!
		f = -> with type: tonumber undumpchar!
			.val = switch .type
				when 1 undumpchar!
				when 3 undump_n 7
				when 4 concat mayberotate map (=> hextochar @),  (undump_n (hextoint undump_n 8) - 1)\zsplit 2
				else nil
			undumpchar! -- remove '\0'

		.list = [f! for _ = 1, .num]

	-- protosize = hextoint undumpint!
		-- n = size of `p` (lobject.h L471)
		-- for range(n): dumpFunction

		-- upvalues
		-- n = number of upvalues (8bit)
		-- for range(n): char twice

	return {
		:line
		:params
		:vararg
		:regnum
		:instruction
		:constant
		-- :protosize
	}
----}}}

---- like python, `if __name__ == '__main__'` in Lua (not MoonScript)
----{{{
if ...
	io.close with input = assert(io.open(arg[1], "rb"))
		prerr pcall ->
			header = hblockdecode input

			assert headassert header

			fnblock =  fnblockdecode input, header

			for k, v in pairs header
				if type(v) == "table"
					for k_, v_ in pairs v
						print "#{k}.#{k_}", v_
				else
					print k, v

			with fnblock
				with .instruction
					print "=====INSTRUCTIONS====="
					for i = 1, .num
						io.write .ins[i][1], ":  ", "%8s"\format .ins[i][2]
						print unpack map (=> "%4d"\format @), table.move .ins[i], 3, 5, 1, {}

				with .constant
					print "=====CONSTANTS====="
					typetable = {"nil", "bool", "number", "string"}
					for i = 1, .num
						if l = .list[i]
							print "%dth: %7s  %s"\format i, typetable[l.type], l.val


			str =  input\read "*a"
			len = #str
			if len > 0
				printashex = (str, len) ->
					cnt = 0
					for cc in str\gmatch".."
						io.write "%02X"\format tonumber cc\byte!
						cnt += 1
						io.write cnt % len < 1 and '\n' or ' '

					cnt % len > 0 and print!

				print "======REST======\n#{len // 2 }bits left, #{input\seek!}bits read"
				printashex str, 16
----}}}

-- return modules
---{{{
{
	:hblockdecode, :headassert, :providetools, :fnblockdecode, util: {
		:zsplit
		:map
		:hexdecode
		:bintoint
		:hextobin
		:insgen
		:prerr
	}
}
---}}}

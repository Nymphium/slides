unpack = unpack or table.unpack

input = assert(io.open(arg[1], "rb"))
string.zsplit = (n = 1) => [c for c in @\gmatch "."\rep n]

map = (fn, xs) -> [fn x for x in *xs]
rotate = (xs) -> [xs[i] for i = #xs, 1, -1]
hexundump = (cnt = 1) -> ("%02X"\rep cnt)\format
id = => @
undumpchar = -> hexundump! (input\read 1)\byte!
hextobin = (hex) ->
	btable = {
		"0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111",
		"1000", "1001", "1010", "1011", "1100", "1101", "1110", "1111"
	}

	table.concat for c in hex\gmatch"."
		btable[(tonumber "0x#{c}") + 1]

bintoint = (bin) ->
	i = -1
	with ret = 0
		for c in bin\reverse!\gmatch"."
			i += 1
			ret += 2^i * tonumber(c)

assert (input\read 4) == string.char(0x1b, 0x4c, 0x75, 0x61), "HEADER SIGNATURE ERROR" -- header signature

local code

assert_luac_data = (b) -> assert b == string.char(0x19, 0x93, 0x0d, 0x0a, 0x1a, 0x0a), "CONVERSION ERROR"

prerr = (ne, msg) ->
	not ne and io.stdout\write(msg , '\n')

prerr pcall ->
	with input
		code = {
			version: (undumpchar!)\gsub("(%d)(%d)", "%1.%2")
			format: (\read 1)\byte!
		}

		-- if code.version == "5.3"
			-- assert_luac_data input\read 6
			-- code.size = {
				-- int: (\read 1)\byte!
				-- size_t: (\read 1)\byte!
				-- instruction: (\read 1)\byte!
				-- lua_integer: (\read 1)\byte!
				-- lua_number: (\read 1)\byte!
			-- }

			-- code.endian = ((\read 2) == string.char 0x56, 0x78) and 0 or 1
		-- else
		code.endian = (\read 1)\byte!
		code.size = {
			int: (\read 1)\byte!
			size_t: (\read 1)\byte!
			instruction: (\read 1)\byte!
			lua_number: (\read 1)\byte!
		}
		code.intflag = (\read 1)\byte!

		-- if code.version == "5.2"
		assert_luac_data input\read 6

	mayberotate = if code.endian < 1
				id
			else rotate

	undumpn = (n) -> hexundump(n) unpack mayberotate {(input\read n)\byte 1, n}
	undumpint =  -> undumpn 4

	with code
		.line = {
			defined: undumpint!
			lastdefined: undumpint!
			}

		.params = undumpchar!
		.vararg = undumpchar!
		.regnum = undumpchar!

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

		.instruction = {
			num: tonumber "0x"..undumpint!
		}

		.instruction.ins = [insgen undumpint! for _ = 1, .instruction.num]

		.constant = {
			num: tonumber "0x" .. undumpint!
			val: {}
		}

		with .constant
			for i = 1, .num
				table.insert .val, with {type: tonumber undumpchar!}
					.val = switch .type
						when 1 undumpchar!
						when 3 undumpn 8
						when 4
							len = undumpn 8
							table.concat mayberotate map string.char, [tonumber"0x#{c}" for c in (undumpn tonumber len)\gmatch".."]
						else nil

		-- n = size of `p` (lobject.h L471)
		-- for range(n): dumpFunction

		-- upvalues
		-- n = number of upvalues (8bit)
		-- for range(n): char twice

prerr pcall ->
	for k, v in pairs code
		if type(v) == "table"
			for k_, v_ in pairs v
				print "#{k}.#{k_}", v_
		else
			print k, v

	print "=====INSTRUCTIONS====="
	for i = 1, code.instruction.num
		print (require'inspect') code.instruction.ins[i]

	print "=====CONSTANTS====="
	for i = 1, code.constant.num
		if val = code.constant.val[i]
			print "#{i}th:", val.type, val.val

	str =  input\read "*a"
	if #str > 0
		print "======REST======\n" .. (("%02X"\rep #str)\format str\byte 1, #str)

input\close!


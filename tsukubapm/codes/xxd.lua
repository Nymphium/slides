local List = {
    pop = function(self)
        return table.remove(self, 1)
    end,
    push = function(self, i)
        table.insert(self, #self + 1, i)
    end,
    new = function(self)
        return setmetatable({}, {__index = self})
    end
}

local fh = assert(io.open(arg[1], "rb"))
local txt = fh:read("all*")

local BYTENUM = tonumber(arg[2] or 1)
local NEWLINE_NUM = tonumber(arg[3] or 16)
local list = List:new()
local cnt = 0

-- for c in fh:read(1) do
for c in txt:gmatch(".") do
    cnt = cnt + 1

    local rowlen = cnt % NEWLINE_NUM
    if rowlen == 1 then
        io.write(("%06x: "):format(cnt - 1))
    end

    list:push(c)

    io.write(string.format("%02x",(c:byte())))

    if cnt % BYTENUM < 1 then
        if rowlen < 1 then
            io.write" "
            for i = 1, #list do
                local cp = list:pop()
                if cp:match("[%z%c]") then
                    io.write(".")
                else
                    io.write(cp)
                end
            end

            io.write('\n')
        else
            io.write " "
        end
    end
end

io.write((" "):rep(((16 - cnt) % NEWLINE_NUM + 2 * BYTENUM)), "  ")

while #list > 0 do
    local cp = list:pop()
    io.write(cp:match("[%z%c]") and "." or cp)
end

assert(fh:close())

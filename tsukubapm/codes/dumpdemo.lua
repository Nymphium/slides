tex.print([==[\begin{lstlisting}[numbers=none]]==])
local function foo() end -- この関数内の環境を書き出す
local LEN = 31
local acc, cnt = "", 0
for c in string.dump(foo):gmatch(".") do
	acc = acc .. ("%02X"):format(c:byte())
	cnt = cnt + 1
	if cnt % LEN < 1 then
		tex.print(acc)
		acc = ""
	else acc = acc .. " "
	end
end
if #acc > 0 then tex.print(acc) end
tex.print([[\end{lstlisting}]])

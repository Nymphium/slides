local header = {"1B", "4C", "75", "61", "52", "00", "01", "04", "08", "04", "08", "00", "19", "93", "0D", "0A", "1A", "0A"}
tex.print([[\uncover<1>{]] .. table.concat(header, " ") .."}")
tex.print([[\uncover<2>{]] .. [[\alert{]] .. table.concat(header, " ", 1, 4).. [[} \textcolor{gray}{]]..table.concat(header, " ", 5, 18).. "}}")

for i = 5, 12 do
	tex.print([[\uncover<]].. (i - 2).. [[>{\textcolor{gray}{]] ..table.concat(header, " ", 1, i - 1) ..[[} \alert{]].. header[i].. [[} \textcolor{gray}{]].. table.concat(header, " ", i + 1, 18) .. "}}")
end

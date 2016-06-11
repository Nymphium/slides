cnt = 0

return {
	itemprint = function(str, overrite)
		if overrite then cnt = overrite end
		tex.print([[\alt<]] .. cnt .. [[>{\textcolor{red}{]] .. str .. "}}{" .. str .. "}")
		cnt = cnt + 1
	end
}

cnt = 0

return {
	itemprint = function(str, overrite)
		if overrite then cnt = overrite end
		tex.print([[\only<]] .. cnt ..[[>{\textcolor{red}{]] .. str .. "}}"..[[\uncover<]] .. (cnt + 1) .. "->{" ..str .. "}")
		cnt = cnt + 1
	end
}

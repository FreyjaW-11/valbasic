labels = {}
variables = {}
function read_file()
	local file, _ = io.open(arg[1], "r")
	local return_value = {}
	for line in file:lines() do
		local temp = {}
		for word in string.gmatch(line, "([^\t ]+)") do
			temp[#temp + 1] = word
		end
		return_value[#return_value + 1] = temp
	end
	file:close()
	return return_value
end
function write_file(lines)
	local file, _ = io.open(arg[1] .. ".BAS", "w")
	for _, line in ipairs(lines) do
		file:write(line .. "\n")
	end
	file:close()
end
function find_user_tokens(code)
	local variable_length = 0
	local function to_cbm_var(line1)
		local name = string.char(math.floor(variable_length / 26) + string.byte("A")) .. string.char((variable_length % 26) + string.byte("A"))
		if line1 == "STRING" then
			name = "$" .. name
		elseif line1 == "INTEGER" then
			name = "%" .. name
		end
		variable_length = variable_length + 1
		return name
	end
	for index, line in ipairs(code) do
		if line[1]:sub(-1) == ":" then
			labels[line[1]:sub(1, #line[1] - 1)] = index
		else
			for x, word in ipairs(line) do
				if word == "STRING" or word == "INTEGER" or word == "FLOAT" then
					local y, _ = string.find(line[x + 1], "(", 1, true) or #word
					variables[line[x + 1]] = to_cbm_var(line[x])
				end
			end
		end
	end
	return code
end
function label_to_line_number(code)
	for _, line in ipairs(code) do
		for index, word in ipairs(line) do
			--TODO support THEN <LABEL>
			if word == "THEN" and (line[index + 1] == "GOTO" or line[index + 1] == "GOSUB") then
				if labels[line[index + 2]] ~= nil then
					line[index + 2] = tostring(labels[line[index + 2]])
				end
			elseif word == "GOSUB" or word == "GOTO" then
				if labels[line[index + 1]] ~= nil then
					line[index + 1] = labels[line[index + 1]]
				end
			end
		end
	end
	return code
end
function re_fuse_lines(lines)
	local return_value = {}
	for _, line in ipairs(lines) do
		local temp = ""
		for __, word in ipairs(line) do
			temp = temp .. word .. " "
		end
		return_value[#return_value + 1] = temp
	end
	return return_value
end
function cbm_friendly_variables(lines)
	for key, variable in pairs(variables) do
		for x, line in ipairs(lines) do
			--print(line)
			lines[x] = (string.gsub(lines[x], key, variable))
			--print(line .. "\n")
		end
	end
	return lines
end
function cbm_variable_declaration(lines)
	local type_keywords = {"STRING", "INTEGER", "FLOAT"}
	for x, line in ipairs(lines) do
		for __, keyword in ipairs(type_keywords) do
			if string.find(line, keyword, 1, true) then
				if string.find(line, "FOR", 1, true) then
					lines[x] = line:gsub(keyword, "")
				elseif string.find(line, "(", 1, true) and not string.find(line, "=", 1, true) then
					lines[x] = line:gsub(keyword, "DIM")
				else
					lines[x] = line:gsub(keyword, "LET")
				end
			end
		end 
	end
	return lines
end
function add_line_numbers(lines)
	for index, line in ipairs(lines) do
		lines[index] = tostring(index) .. " " .. line
	end
	return lines
end
function friendly_label_declaration(lines)
	for x, line in ipairs(lines) do
		if string.sub(line, #line) == ":" then
			lines[x] = "REM"
		end
	end
	return lines
end
function strip_trailing(lines)
	for x, line in ipairs(lines) do
		lines[x] = string.gsub(line, "%s$", "")
	end
	return lines
end
function transpiler()
	local code = read_file()
	find_user_tokens(code)
	code = label_to_line_number(code)
	code = strip_trailing(re_fuse_lines(code))
	code = cbm_friendly_variables(code)
	code = cbm_variable_declaration(code)
	code = friendly_label_declaration(code)
	code = add_line_numbers(code)
	--for _, line in ipairs(code) do print(line) end
	write_file(code)
end
transpiler()

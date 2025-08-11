
CodeAssist = {}

local dictionary, length = {}, 0
for i = 32, 127 do
	if i ~= 34 and i ~= 92 then
		local c = string.char(i)
		dictionary[c], dictionary[length] = length, c
		length = length + 1
	end
end

local escapemap = {}
for i = 1, 34 do
	i = ({34, 92, 127})[i-31] or i
	local c, e = string.char(i), string.char(i + 31)
	escapemap[c], escapemap[e] = e, c
end
CodeAssist.escape = function(s)
	return (s:gsub("[%c\"\\]", function(c)
		return "\127"..escapemap[c]
	end))
end

CodeAssist.unescape = function(s)
	return (s:gsub("\127(.)", function(c)
		return escapemap[c]
	end))
end

CodeAssist.copy = function(t)
	local new = {}
	for k, v in pairs(t) do
		new[k] = v
	end
	return new
end

CodeAssist.tobase93 = function(n)
	local value = ""
	repeat
		local remainder = n%93
		value = dictionary[remainder]..value
		n = (n - remainder)/93
	until n == 0
	return value
end

CodeAssist.tobase10 = function(value)
	local n = 0
	for i = 1, #value do
		n = n + 93^(i-1)*dictionary[value:sub(-i, -i)]
	end
	return n
end

CodeAssist.compress = function(text)
	local dictionary = CodeAssist.copy(dictionary)
	local key, sequence, size = "", {}, #dictionary
	local width, spans, span = 1, {}, 0
	local function listkey(key)
		local value = CodeAssist.tobase93(dictionary[key])
		if #value > width then
			width, span, spans[width] = #value, 0, span
		end
		sequence[#sequence+1] = (" "):rep(width - #value)..value
		span = span + 1
	end
	text = CodeAssist.escape(text)
	for i = 1, #text do
		local c = text:sub(i, i)
		local new = key..c
		if dictionary[new] then
			key = new
		else
			listkey(key)
			key, size = c, size+1
			dictionary[new], dictionary[size] = size, new
		end
	end
    listkey(key)
	spans[width] = span
    return table.concat(spans, ",").."|"..table.concat(sequence)
end

CodeAssist.decompress = function (text)
	local dictionary = CodeAssist.copy(dictionary)
	local sequence, spans, content = {}, text:match("(.-)|(.*)")
	local groups, start = {}, 1
	for span in spans:gmatch("%d+") do
		local width = #groups+1
		groups[width] = content:sub(start, start + span*width - 1)
		start = start + span*width
	end
	local previous;
	for width = 1, #groups do
		for value in groups[width]:gmatch(('.'):rep(width)) do
			local entry = dictionary[CodeAssist.tobase10(value)]
			if previous then
				if entry then
					sequence[#sequence+1] = entry
					dictionary[#dictionary+1] = previous..entry:sub(1, 1)
				else
					entry = previous..previous:sub(1, 1)
					sequence[#sequence+1] = entry
					dictionary[#dictionary+1] = entry
				end
			else
				sequence[1] = entry
			end
			previous = entry
		end
	end
	return CodeAssist.unescape(table.concat(sequence))
end



CodeAssist.DeepCopyTable = function(original)
    local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = CodeAssist.DeepCopyTable(v)
		end
		copy[k] = v
	end
	return copy
end

CodeAssist.GetRGBFromString = function(ReceivedSTVal)
	local ST = string.split(ReceivedSTVal, ",")
	local NewColor = Color3.fromRGB(ST[1], ST[2], ST[3])
		
	return NewColor
end

return CodeAssist
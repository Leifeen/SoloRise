
CodeAssist = {}

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
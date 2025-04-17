
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


return CodeAssist
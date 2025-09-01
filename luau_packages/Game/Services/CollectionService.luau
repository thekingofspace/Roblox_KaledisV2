local module = {}

module.Tagged = module.Tagged or {}

function module:AddTag(Instance, Tag: string)
	if typeof(Instance) ~= "table" then
		return
	end

	Instance.Changed_Signal:Fire()

	if not table.find(Instance.Tags, Tag) then
		table.insert(Instance.Tags, Tag)
	end

	module.Tagged[Tag] = module.Tagged[Tag] or {}
	module.Tagged[Tag][Instance] = true
end

function module:RemoveTag(Instance, Tag: string)
	if typeof(Instance) ~= "table" then
		return
	end

	Instance.Changed_Signal:Fire()

	local idx = table.find(Instance.Tags, Tag)
	if idx then
		table.remove(Instance.Tags, idx)
	end

	if module.Tagged[Tag] then
		module.Tagged[Tag][Instance] = nil

		if next(module.Tagged[Tag]) == nil then
			module.Tagged[Tag] = nil
		end
	end
end

function module:GetTagged(Tag: string): {Instance?}
	local Array = {}

	for inst in pairs(module.Tagged[Tag] or {}) do
		table.insert(Array, inst)
	end

	return Array
end

function module:DropTag(Tag: string)
	if module.Tagged[Tag] then
		for inst in pairs(module.Tagged[Tag]) do
			local idx = table.find(inst.Tags, Tag)
			if idx then
				table.remove(inst.Tags, idx)
				inst.Changed_Signal:Fire()
			end
		end
		module.Tagged[Tag] = nil
	end
end

return module

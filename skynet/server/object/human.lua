local Human = class("Human")

function Human.create(ori)
    return Human.new(ori)
end

function Human:ctor(ori)
	local o = clone(ori)
	self.otype = "human"
	self.pos = o.pos
end

return Human
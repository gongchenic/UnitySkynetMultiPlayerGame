local Treeman = class("Treeman")

function Treeman.create(ori)
    return Treeman.new(ori)
end

function Treeman:ctor(ori)
	local o = clone(ori)
	self.otype = "treeman"
	self.pos = o.pos
end

return Treeman
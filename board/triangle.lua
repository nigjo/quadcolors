require "lib.board"

TrianglesPitch=FCBoard:new()

function TrianglesPitch:createSelectorGem(size)
	local a = 2*size
	local ru=a/math.sqrt(3)
	local h=size*math.sqrt(3)
	local dy=(a-h)
	-- print(size, a,ru,h)
	local p=FCBoard.createSelectorGem(self, size)
	p:add(0,-ru+dy)
	p:add(size,h-ru+dy)
	p:add(-size,h-ru+dy)
	--print(#p.points)
	return p
end

TrianglesPatch=FCPatch:new()

function TrianglesPitch:init(knotcount)
	
	--if knotcount%2 == 1 then knotcount = knotcount + 1 end
	
	self.tris = {
		TrianglesPatch:new(1,1,self.width,self.height,1,self.height),
		TrianglesPatch:new(self.width,self.height,1,1,self.width,1)
	}

	while #self.tris < knotcount do
		local splitIdx=math.random(#self.tris)
		-- print(#self.tris,splitIdx)
		local points=self.tris[splitIdx].points
		-- first line is hypothenuse
		print(points[1])
		local dx=(points[1]-points[3])/2
		local cx=points[3]+dx
		local dy=(points[2]-points[4])/2
		local cy=points[4]+dy
		--print(dx,dy, math.sqrt(dx*dx+dy*dy))
		if math.sqrt(dx*dx+dy*dy)>50 then
			local nextpatch = TrianglesPatch:new(
				points[3],points[4],
				points[5],points[6],
				cx,cy
			)
			table.insert(self.tris, nextpatch)
			points[3] = points[5]
			points[4] = points[6]
			points[5] = cx
			points[6] = cy
		end
	end
	-- print(#self.tris,splitIdx)
end

-- local function length(x1,y1,x2,y2)	
	-- return math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))
-- end

-- local function triarea1(...)
	-- local points={...}
	-- local a = length(points[1],points[2],points[3],points[4])
	-- local b = length(points[3],points[4],points[5],points[6])
	-- local c = length(points[5],points[6],points[1],points[2])
	-- local s = (a+b+c)/2
	-- return math.sqrt(s*(s-a)*(s-b)*(s-c))
-- end

local function triarea(...)
	local points={...}
	return math.abs(
			  points[1]*(points[4] - points[6])
			+ points[3]*(points[6] - points[2])
			+ points[5]*(points[2] - points[4])
		)/2
end

function TrianglesPitch:updateValidCounter()
	FCBoard.updateValidCounter(self, self.tris)
end

function TrianglesPitch:findPatch(x,y)
	print("search ",x,y)
	for i,tridata in ipairs(self.tris) do
		local p = tridata.points
		local area = triarea(unpack(p))
		local a1 = triarea(x,y,p[1],p[2],p[3],p[4])
		local a2 = triarea(x,y,p[3],p[4],p[5],p[6])
		local a3 = triarea(x,y,p[1],p[2],p[5],p[6])
		if area == a1+a2+a3 then
			return tridata
		end
	end
end

local function signum(x)
	if x>0 then return 1
	elseif x<0 then return -1
	else return 0
	end
end

local function _checkStrecken(x1,y1,x2,y2,px1,py1,px2,py2)
	local dx1=math.min(px1,px2)-math.min(x1,x2)
	local dy1=math.min(py1,py2)-math.min(y1,y2)
	local dx2=math.max(px1,px2)-math.max(x1,x2)
	local dy2=math.max(py1,py2)-math.max(y1,y2)
	
	local okx=(dx1==0 or dx2==0) or signum(dx1)~=signum(dx2)
	local oky=(dy1==0 or dy2==0) or signum(dy1)~=signum(dy2)
	
	return okx and oky
end

--- find triangles next to a selected on.
-- this method works only because one of the triangles has always one full
-- side facing the other. t1 facing t2 or t2 facing t1.
function FCBoard:_getNeighbors(fcPolgon)
	local siblings={}
	for idxP=1,#fcPolgon.points,2 do
		local x1=fcPolgon.points[idxP]
		local y1=fcPolgon.points[idxP+1]
		local x2=fcPolgon.points[(idxP+1)%#fcPolgon.points+1]
		local y2=fcPolgon.points[(idxP+2)%#fcPolgon.points+1]

		local fn
		if (x2-x1)==0 then
			fn=nil
			-- print("scan",idxP, "senkrecht")
		else
			local m = (y2-y1)/(x2-x1)
			local b = y2-m*x2
			fn=function(x)
				return m*x+b
			end
			-- print("scan",idxP, "fn="..(math.floor(m*100)/100).."x+"..(math.floor(b*100)/100))
		end

		for idxN,patch in ipairs(self.tris) do
			if patch ~= fcPolgon then
				for pn=1,#patch.points,2 do
					local px1=patch.points[pn]
					local py1=patch.points[pn+1]
					local px2=patch.points[(pn+1)%#patch.points+1]
					local py2=patch.points[(pn+2)%#patch.points+1]
					if fn==nil then
						--senkrechte
						if px1==x1 and px2==x2 then
							-- print ("point",idxN)
							if _checkStrecken(x1,y1,x2,y2,px1,py1,px2,py2) then
								-- print ("adding", idxN,x1,y1,x2,y2,px1,py1,px2,py2)
								table.insert(siblings, patch)
							end
						end
					elseif math.abs(fn(px1)-py1)<.01 and math.abs(fn(px2)-py2)<.01 then
						-- print ("point",idxN)
						if _checkStrecken(x1,y1,x2,y2,px1,py1,px2,py2) then
							-- print ("adding", idxN,x1,y1,x2,y2,px1,py1,px2,py2)
							table.insert(siblings, patch)
						end
					end
				end
			end
		end
	end
	return siblings
end

function TrianglesPitch:draw()
	for i,tridata in ipairs(self.tris) do
		-- love.graphics.setColor(1,0,0,i/#self.tris)
		local cx,cy
		if tridata.centroid==nil then
			cx=tridata.points[1]+(tridata.points[3]-tridata.points[1])/2
			cy=tridata.points[2]+(tridata.points[4]-tridata.points[2])/2
			tridata.centroid={x=cx+(tridata.points[5]-cx)/2,y=cy+(tridata.points[6]-cy)/2}
		else
			
		end

		if tridata.colidx >0 then
			self:drawFieldGem(tridata)
		end
		love.graphics.setColor(1,1,1,1)
		love.graphics.polygon("line", unpack(tridata.points))
		-- love.graphics.print(i,tridata.centroid.x-8,tridata.centroid.y-8)
	end
	-- if self._lastSelected ~= nil then
		-- self:_debugDrawNeighbors(self._lastSelected)
		-- local col={}
		-- col[1]={1,0,0}
		-- col[3]={0,1,0}
		-- col[5]={0,0,1}
		-- for i=1,#self._lastSelected.points,2 do
			-- love.graphics.setColor(col[i])
			-- love.graphics.line(
				-- self._lastSelected.points[i],self._lastSelected.points[i+1],
				-- self._lastSelected.points[(i+1)%#self._lastSelected.points+1],
				-- self._lastSelected.points[(i+2)%#self._lastSelected.points+1])
		-- end
	-- end
end

return TrianglesPitch
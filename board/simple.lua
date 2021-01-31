require "lib.board"
QuadraticPitch=FCBoard:new()

function QuadraticPitch:createSelectorGem(size)
	local gem = FCBoard.createSelectorGem(self, size)
	gem:add(-size,-size)
	gem:add(size,-size)
	gem:add(size,size)
	gem:add(-size,size)
	print("polygon", #gem.points)
	return gem
end

function QuadraticPitch:init(knotCount)
	self.cols=knotCount;
	local sq = math.sqrt(knotCount);
	local testC=knotCount;
	while testC-1>=sq do
		testC = testC - 1
		if knotCount%testC == 0 then
			self.cols=testC
		end
	end
	self.rows=knotCount / self.cols
	self.selections = {}
end

function QuadraticPitch:findPatch(x,y)
	local dx = self.width / self.cols
	local dy = self.height / self.rows
	local col = math.floor(x/dx)
	local row = math.floor(y/dy)
	--print(x,y,dx,dy,col,row,row*self.cols+col)
	if col>=0 and col<self.cols
			and row>=0 and row<self.rows then
		if self.selections[row*self.cols+col] == nil then
			self.selections[row*self.cols+col] = FCPatch:new()
			print(type(self.selections[row*self.cols+col]))
		end
		
		return self.selections[row*self.cols+col]
	end
end

function QuadraticPitch:check(idx, nextcol)
	local colData = self.selections[idx]
	return colData ~= nil and colData.colidx ~= 0 and colData.colidx ~= nextcol
end

function QuadraticPitch:updateValidCounter()
	local counter = 0
	for y=0,self.rows-1 do
		for x=0,self.cols-1 do
			local colData = self.selections[y*self.cols+x]
			if colData ~= nil and colData.colidx ~= 0 then
				local ok = true
				ok = ok and (x==0 or self:check(y*self.cols+x-1, colData.colidx))
				ok = ok and (y==0 or self:check((y-1)*self.cols+x, colData.colidx))
				ok = ok and (x+1==self.cols or self:check(y*self.cols+x+1, colData.colidx))
				ok = ok and (y+1==self.rows or self:check((y+1)*self.cols+x, colData.colidx))
				
				if ok then counter = counter + 1 end
			end
		end
	end
	gamedata:setValidCount(counter)
end

function QuadraticPitch:draw()
	love.graphics.setColor(1,1,1,1)
	local dx = self.width / self.cols
	local dy = self.height / self.rows
	for x=0,self.cols do
		love.graphics.line(dx*x,0,dx*x,self.height)
	end
	for y=0,self.rows-1 do
		love.graphics.setColor(1,1,1,1)
		love.graphics.line(0,dy*y,self.width,dy*y)
		for x=0,self.cols-1 do
			local colData = self.selections[y*self.cols+x]
			if colData ~= nil then
				if colData.poly == nil then
					colData.poly = FCPolygon:new()
					colData.poly:add(x*dx,y*dy)
					colData.poly:add(x*dx+dx,y*dy)
					colData.poly:add(x*dx+dx,y*dy+dy)
					colData.poly:add(x*dx,y*dy+dy)
				end
				print(colData,colData.poly,colData.colidx)
				self:drawFieldGem(colData.poly, colData.colidx)
			end
		end
	end
end

return QuadraticPitch
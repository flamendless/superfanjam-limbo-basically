local PLAYER = OBJ:extend()
local tag = "PLAYER"

function PLAYER:new(anim,x,y,spd,ground)
	self.x = x or 0
	self.y = y or 0
	self.h = 18
	self.w = 10
	self.curAnim = anim
	self.animations = {
		anim_pIdle,
		anim_pRun,
		anim_pJump,
		anim_pFalling
	}
	self.spd = spd
	self.maxSpd = self.spd * 2
	self.dir = 1
	self.hspd = 1
	self.vspd = 1
	self.jump = 30
	self.maxJump = self.jump * 1.25
	self.jAccel = 60
	self.accel = 50
	self.reach = 0

	self.onFloor = true
	self.isRunning = false
	self.isJumping = false
	self.isFalling = false
	self.canJump = true

	self:load()
end

function PLAYER:load()
end

function PLAYER:update(dt)
	self.curAnim:update(dt)
	
	self:collision(dt)
	self:updateSprite(dt)

	self:horizontalMovement(dt)
	self:verticalMovement(dt)
	self:jumping(dt)
	self:falling(dt)
	

	if self.x >= settings.gameWidth then
		if GAMESTATES.getState() == "GAME_INTRO" then
			GAMESTATES.setState(GAMESTATES.getLevels()[1])
		else
			GAMESTATES.nextLevel()
		end
	end
end

function PLAYER:collision(dt)
	local g = ENTITIES.getEntity("GROUND")
	local gy = g.y

	self.reach = g.y - (self.h * 2)

	self.onFloor = g:collision()
	
	if self.onFloor then
		self.canJump = true
	end

	while g:overrideCollision() do
		self.y = self.y - 1 * dt
	end
end

function PLAYER:horizontalMovement(dt)
	local left = love.keyboard.isDown(keybindings.KEY_LEFT)
	local right = love.keyboard.isDown(keybindings.KEY_RIGHT)

	if left then
		self.hspd = -1
		if self.onFloor then
			self.isRunning = true
		end
	elseif right then
		self.hspd = 1
		if self.onFloor then
			self.isRunning = true
		end
	elseif left == false and right == false then
		self:deccelerate(dt)
		self.isRunning = false
	end

	self:accelerate(dt)

	self.x = self.x + (self.hspd * self.spd) * dt
end

function PLAYER:accelerate(dt)
	if self.spd < self.maxSpd then
		self.spd = self.spd + self.accel * dt
	end
end

function PLAYER:deccelerate(dt)
	if self.spd > 0 then
		self.spd = self.spd - (self.accel * 2) * dt
	end
end

function PLAYER:verticalMovement(dt)
	local up = love.keyboard.isDown(keybindings.KEY_UP)

	if up and self.canJump then
		if self.y > self.reach then
			self.vspd = -1
		else
			self.canJump = false
		end
	end

	self.y = self.y + (self.vspd * self.jump) * dt
end

function PLAYER:jumping(dt)
	if self.onFloor then
		if self.jump < self.maxJump then
			self.jump = self.jump + self.jAccel * dt
		end
	end
end

function PLAYER:falling(dt)
	if self.onFloor == false then
		self.vspd = 1
	end
end

function PLAYER:draw()
	love.graphics.setColor(255,255,255,255)
	self.curAnim:draw(assets.images.playerSheet,
		self.x,
		self.y)
end

function PLAYER:keypressed(key)
	if key == keybindings.KEY_LEFT then
		self.curAnim = anim_pRun
		self.hspd = -1
		if self.dir == 1 then
			self.dir = -1
			self:changeSprite()
		end
	elseif key == keybindings.KEY_RIGHT then
		self.curAnim = anim_pRun
		self.hspd = 1
		if self.dir == -1 then
			self.dir = 1
			self:changeSprite()
		end
	end
end

function PLAYER:keyreleased(key)
end

function PLAYER:changeSprite()
	for k,v in pairs(self.animations) do
		v:flipH()
	end
end

function PLAYER:updateSprite(dt)
	if self.vspd == -1 then
		self.isJumping = true
		self.isFalling = false
	elseif self.vspd == 1 and self.onFloor == false then
		self.isJumping = false
		self.isFalling = true
	end

	if self.onFloor == true then
		if self.isRunning then
			self.curAnim = anim_pRun
		else
			self.curAnim = anim_pIdle
		end
	else
		if self.isJumping then
			self.curAnim = anim_pJump
			self:spriteControl(anim_pJump)
		elseif self.isFalling then
			self.curAnim = anim_pFalling
			self:spriteControl(anim_pFalling)
		end
	end
end

function PLAYER:spriteControl(anim)
	if self.curAnim == anim then
		if anim.position == anim:getTotalFrames() then
			anim:gotoFrame(anim:getTotalFrames())
		end
	end
end

function PLAYER:getTag()
	return tag
end

return PLAYER

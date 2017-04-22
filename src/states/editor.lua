local editor = {}

function editor:enter()

  self.points = {}
  for x = -1,1 do
    for y = -1,1 do
      for z = 0,0 do
        table.insert(self.points,{x/2,y/2,z/2})
      end
    end
  end
  self.segments = {}

  self.x = love.graphics.getWidth()-104-512
  self.y = 104
  self.s = 512

  self.cam = libs.picocam.new{
    width=love.graphics.getWidth()/2,
    height=love.graphics.getHeight(),
  }

end

function editor:update(dt)
  self.cam.theta = self.cam.theta + dt
end

function editor:draw()

  if self.img then
    love.graphics.draw(self.img,self.x,self.y)
  end

  love.graphics.print(
    "c .. create point at mouse position\n"..
    "CTRL + c .. create point and mirrored x point at mouse position\n"..
    "escape .. deselect all points and segments\n"..
    "d .. delete selected points and segments\n"..
    "e .. create segment\n"..
    "up/right/down/left .. move selected points along x/y axis\n"..
    "s .. toggle selection of point and segments\n"..
    "mousewheel .. move selected points along z axis\n"..
    "left-shift .. change precision from 0.01 to 0.1\n"..
    "l .. toggle image into frame (reloads)\n"..
    "F[X] .. load file X\n"..
    "CTRL + F[X] .. save file X\n")

  love.graphics.setColor(255,255,255,127)
  for i,v in pairs(self.points) do
    if v.selected then
      local x,y = self:getWindowPosition(v[1],v[2])
      love.graphics.print("{"..v[1]..","..v[2]..","..v[3].."}",x,y)
    end
  end

  for i,v in pairs(self.points) do
    local x,y = self:getWindowPosition(v[1],v[2])
    if v.selected then
      love.graphics.setColor(0,255,0)
    else
      love.graphics.setColor(255,255,255)
    end
    love.graphics.circle("line",x,y,4)
  end
  love.graphics.setColor(255,255,255)

  for i,v in pairs(self.segments) do
    local p1x,p1y = self:getWindowPosition(v[1][1],v[1][2])
    local p2x,p2y = self:getWindowPosition(v[2][1],v[2][2])
    if v.selected then
      love.graphics.setColor(0,255,0)
    else
      love.graphics.setColor(255,255,255)
    end
    love.graphics.line(p1x,p1y,p2x,p2y)
  end

  local mx,my = self:getMousePosition()
  local ex,ey = self:getWindowPosition(mx,my)

  love.graphics.print("{"..mx..","..my.."}",
    self.x,self.y-love.graphics.getFont():getHeight())
  love.graphics.rectangle("line",self.x,self.y,self.s,self.s)

  love.graphics.push()
  love.graphics.scale(2)
  love.graphics.translate(-128,-192)

  for i,v in pairs(self.points) do
    if v.selected then
      love.graphics.setColor(0,255,0)
    else
      love.graphics.setColor(255,255,255)
    end
    self.cam:point(v)
  end

  for i,v in pairs(self.segments) do
    if v.selected then
      love.graphics.setColor(0,255,0)
    else
      love.graphics.setColor(255,255,255)
    end
    self.cam:line(v[1],v[2])
  end

  love.graphics.pop()

  love.graphics.setColor(255,0,0)
  love.graphics.circle("line",ex,ey,4)

  love.graphics.setColor(255,255,255)

end

function editor:keypressed(key)

  local m = {self:getMousePosition()}
  m[3]=0

  local nearest,nearest_distance = nil,math.huge
  for i,v in pairs(self.points) do
    local distance = math.sqrt(
      (v[1]-m[1])^2+
      (v[2]-m[2])^2
      --(v[3]-m[3])^2
    )
    if distance < nearest_distance then
      nearest,nearest_distance = v,distance
    end
  end
  for i,v in pairs(self.segments) do
    local ax = (v[1][1]+v[2][1])/2
    local ay = (v[1][2]+v[2][2])/2
    --local az = (v[1][3]+v[2][3])/2
    local distance = math.sqrt(
      (ax-m[1])^2+
      (ay-m[2])^2
      --(az-m[3])^2
    )
    if distance < nearest_distance then
      nearest,nearest_distance = v,distance
    end
  end

  if key == "l" then
    self.img = self.img and nil or love.graphics.newImage("editor.png")
  end

  if key == "c" then
    table.insert(self.points,{m[1],m[2],m[3]})
    if love.keyboard.isDown("lctrl") then
      table.insert(self.points,{-m[1],m[2],m[3]})
    end
  end

  if key == "escape" then
    for i,v in pairs(self.points) do
      v.selected = nil
    end
    for i,v in pairs(self.segments) do
      v.selected = nil
    end
  end

  if key == "d" then

    local toremovepoints = {}
    local newpoints = {}
    for i,v in pairs(self.points) do
      if v.selected then
        table.insert(toremovepoints,v)
      else
        table.insert(newpoints,v)
      end
    end
    self.points = newpoints

    local newsegments = {}
    for i,v in pairs(self.segments) do
      for j,w in pairs(toremovepoints) do
        if v[1] == w or v[2] == w then
          v.selected = true
        end
      end
      if not v.selected then
        table.insert(newsegments,v)
      end
    end
    self.segments = newsegments
  end

  if key == "e" then
    for i,v in pairs(self.points) do
      for j,w in pairs(self.points) do
        if v.selected and w.selected and v ~= w then
          if not self:segmentAlreadyExists(v,w) then
            table.insert(self.segments,{v,w})
          end
        end
      end
    end
  end

  if key == "up" then
    for i,v in pairs(self.points) do
      if v.selected then
        v[2] = v[2] - (love.keyboard.isDown("lshift") and 0.1 or 0.01)
      end
    end
  end

  if key == "right" then
    for i,v in pairs(self.points) do
      if v.selected then
        v[1] = v[1] + (love.keyboard.isDown("lshift") and 0.1 or 0.01)
      end
    end
  end

  if key == "down" then
    for i,v in pairs(self.points) do
      if v.selected then
        v[2] = v[2] + (love.keyboard.isDown("lshift") and 0.1 or 0.01)
      end
    end
  end

  if key == "left" then
    for i,v in pairs(self.points) do
      if v.selected then
        v[1] = v[1] - (love.keyboard.isDown("lshift") and 0.1 or 0.01)
      end
    end
  end

  if nearest and nearest_distance < 0.1 then

    if key == "s" then
      nearest.selected = nearest.selected == nil and true or nil
    end

  end

  for i = 1,12 do
    local fkey = "f"..i
    if love.keyboard.isDown(fkey) then
      local fname = fkey..".json"
      if love.keyboard.isDown("lctrl") then 
        print("save "..fname)
        local data = {}
        for i,v in pairs(self.segments) do
          table.insert(data,{
            {v[1][1],v[1][2],v[1][3]},
            {v[2][1],v[2][2],v[2][3]},
          })
        end
        local raw = libs.json.encode(data)
        love.filesystem.write(fname,raw)
      else
        print("load "..fname)
        self.points = {}
        self.segments = {}
        local raw = love.filesystem.read(fname)
        print(fname)
        local data = libs.json.decode(raw)
        for i,v in pairs(data) do

          local p1 = self:pointAlreadyExists(v[1])
          if p1 == false then
            p1 = v[1]
            table.insert(self.points,p1)
          end

          local p2 = self:pointAlreadyExists(v[2])
          if p2 == false then
            p2 = v[2]
            table.insert(self.points,p2)
          end

          table.insert(self.segments,{p1,p2})

        end
      end
    end
  end

end

function editor:wheelmoved(x, y)
  for i,v in pairs(self.points) do
    if v.selected then
      if y > 0 then
        v[3] = v[3] - (love.keyboard.isDown("lshift") and 0.1 or 0.01)
      elseif y < 0 then
        v[3] = v[3] + (love.keyboard.isDown("lshift") and 0.1 or 0.01)
      end
    end
  end
end

function editor:pointAlreadyExists(p)
  for i,v in pairs(self.points) do
    if v[1] == p[1] and v[2] == p[2] and v[3] == p[3] then
      return v
    end
  end
  return false
end

function editor:segmentAlreadyExists(s1,s2)
  for i,v in pairs(self.segments) do
    if (v[1] == s1 and v[2] == s2) or (v[2] == s1 and v[1] == s2) then
      return true
    end
  end
  return false
end

function editor:getMousePosition()
  local mx,my = love.mouse.getPosition()
  -- lol don't care to optimize this at all
  local x = (mx - self.x - self.s/2) / (self.s/2)
  local y = (my - self.y - self.s/2) / (self.s/2)
  if love.keyboard.isDown("lshift") then
    return math.floor(x*10+0.5)/10,math.floor(y*10+0.5)/10
  end
  return x,y
end

function editor:getWindowPosition(ix,iy)
  local x = self.x + self.s/2+ix*self.s/2
  local y = self.y + self.s/2+iy*self.s/2
  return x,y
end

return editor

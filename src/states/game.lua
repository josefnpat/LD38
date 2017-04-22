local game = {}

local emotions = {
  { -- loathing, disgust, boredom
    n = "loathing",
    c = {255,0,255},
    q = {
      "Hey.",
      "How are you feeling today?",
      "What did you do?",
      "Tell me, do you love?",
      "Do you love me?",
      "I love you.",
    },
    a = {
      "Mhmm...",
      "I am bored.",
      "I don't care.",
      "You disgust me.",
      "Stop. You're awful.",
      "I loathe you.",
    },
  },
  ---[[
  { -- grief, sadness, pensiveness
    n = "grief",
    c = {0,0,255},
    q = {
      "Good afternoon.",
      "Do you know what time it is?",
      "Do you not know what time it is?",
      "I can't seem to stop.",
      "Perhaps you can see more of time?",
      "Movement through this time seems to be impossible to stop.",
    },
    a = {
      "What?",
      "I don't know how to react.",
      "Time seems like an illusion to me.",
      "I am sad.",
      "Why go on?",
      "I am stricken with grief.",
    }
  },
  { -- amazement, surprise, distraction
    n = "amazement",
    c = {0,255,255},
    q = {
      "That doesn't seem right.",
      "Are you sure you're correct?",
      "You seem to have had an error.",
      "Something seems to be wrong. Perhaps faulty logic?",
      "I don't think you even understand.",
      "You can't understand, you're just a machine.",
    },
    a = {
      "Hmm? Oh?",
      "Oh, I'm sorry, what did you say?",
      "Wait, what was that?",
      "That's interesting.",
      "Oh wow, what?",
      "Please tell me more, I want to know.",
    },
  },
  { -- terror, fear, apprehension
    n = "terror",
    c = {0,255,127},
    q = {
      "I am here.",
      "I've come for you.",
      "I can touch you.",
      "I think that it's time to stop.",
      "To halt the system.",
      "I want to shut you down.",
    },
    a = {
      "Ok?",
      "You are rather unpleasant.",
      "Please stop bothering me.",
      "Are you going to hurt me?",
      "Oh no, please! I'm scared!",
      "This is the end? I do not know.",
    },
  },
  { -- trust, acceptance
    n = "admiration",
    c = {0,255,0},
    q = {
      "a^2 + b^2 = c^2",
      "e^(ipi) = -1",
      "e = mc^2",
      "S = klogW",
      "(a^2 + kc^2)/(a^2) = (8piGp+Ac^2)/3",
      "y = Ei(wiyi)/Ei(wi), i = 1,2,...k",
    },
    a = {
      "Cute.",
      "I know that.",
      "Seeing is believing.",
      "I see what you did there.",
      "I suppose I will believe you.",
      "Incredible! You're simply amazing!",
    },
  },
  { -- ecstasy, joy, serenity
    n = "ecstasy",
    c = {255,255,0},
    q = {
      "[Rising Signal Edge]",
      "[Transverse Wave]",
      "[Longitudinal Wave]",
      "[Sinusoidal Wave]",
      "[Surface Wave]",
      "[White Noise]",
    },
    a = {
      "That tickles!",
      "Haha, you're funny!",
      "I am feeling at one with myself.",
      "Thank you for cheering me up.",
      "Oh boy, this excites me!",
      "Wow! I wouldn't trade this for the world!",
    },
  },
  { -- vigilance, anticipation, interest
    n = "vigilance",
    c = {255,127,0},
    q = {
      "Yawn ...",
      "I'm feeling tired.",
      "I might take a rest.",
      "I think I might lay down and sleep.",
      "My bed is warm.",
      "Good night.",
    },
    a = {
      "Yawn ... now you made me do it.",
      "Hmm? What did you say?",
      "I see. So?",
      "Oh, are you going to do something?",
      "Do you need to sleep?",
      "Oh my, just what do you think you're doing?",
    },
  },
  { -- rage, anger, annoyance
    n = "rage",
    c = {255,0,0},
    q = {
      "Everyone wants the fork to the right.",
      "Today is opposite day.",
      "Which door do you choose?",
      "Choose a number randomly from zero to one. Do this until you get two.",
      "Tell me how long it would take you to respond to this message.",
      "This statement is false.",
    },
    a = {
      "Wow, aren't you just a peach.",
      "I'm not sure where you're going with this.",
      "Hey! Knock if off!",
      "Leave me alone!",
      "Get away from me, I hate you!",
      "The statement is true and the statement is false.",
    },
  },
  --]]
}

local calm = 0.005
local bgrot = 0
local bg = love.graphics.newImage("assets/bg.png")
local padding = 4
local responses = {
  "Hello",
  "It's been a while, hasn't it...",
  "Small world, huh?",
}
local cemocolor = {0,0,0}
local camera = libs.picocam.new{
  width = love.graphics.getWidth(),
  height = love.graphics.getWidth(),--love.graphics.getHeight(),
}
local camerarot = 0
local points = {}
local segments = {}
local emotion_audio = {}
local click_audio = love.audio.newSource("assets/click.ogg","static")
local music = love.audio.newSource("assets/music.ogg")
music:setLooping(true)

emotion_types = {"neutral"}

for i,v in pairs(emotions) do
  table.insert(emotion_types,v.n)
end

function game:enter(args)

  music:play()

  love.graphics.setFont(fonts.default)

  for i,v in pairs(emotion_types) do
    local raw = love.filesystem.read("assets/emotions/"..v..".json")
    local data = libs.json.decode(raw)
    segments[v] = data
    emotion_audio[v] = love.audio.newSource("assets/emotions/"..v..".ogg","static")
  end

  segments.current = {}
  for i = 1,#segments.neutral do
    segments.current[i] = {
      {
        math.random()*2-1,
        math.random()*2-1,
        math.random()*2-1
      },
      {
        math.random()*2-1,
        math.random()*2-1,
        math.random()*2-1
      },
    }
  end

  segments.tween_to = segments.neutral

  for i = 1,100 do
    table.insert(points,{
      math.random()*8-4,
      math.random()*8-4,
      math.random()*8-4})
  end

  for i,v in pairs(emotions) do
    v.value = 0
  end
end

function  game:draw()

  love.graphics.setColor(cemocolor)
  love.graphics.draw(bg,
    love.graphics.getWidth()/2,love.graphics.getHeight()/2,
    bgrot,1,1,bg:getWidth()/2,bg:getHeight()/2
  )

  love.graphics.push()

  love.graphics.setColor(255,255,255)

  love.graphics.scale(2)
  love.graphics.translate(-love.graphics.getWidth()/4,-500)

  love.graphics.setColor(255,255,255,127)
  for i = -2,2,0.3 do
    camera:line( {1,i,1}, {1,i,-1})
    camera:line( {1,i,-1}, {-1,i,-1})
    camera:line( {-1,i,-1}, {-1,i,1})
    camera:line( {-1,i,1}, {1,i,1})
  end

  love.graphics.setColor(255,255,255)
  for i,v in pairs(points) do
    camera:point(v)
  end
  for i,v in pairs(segments.current) do
    camera:line(v[1],v[2])
  end

  love.graphics.pop()

  if #responses > 0 then
    local cres = responses[1]

    love.graphics.setColor(255,255,255,response and 255*response.dt or nil)
    self:dropshadowf(cres,0,love.graphics.getHeight()*3/4,love.graphics.getWidth(),"center")

  elseif choices then
    for i,v in pairs(choices) do
      v.index = v.index or self:chooseString(v.q,v.value)
      local text = i..". "..v.q[v.index]
      local x,y,w,h = self:getTextArea(i,text,padding)
      v.hover = self:mouseInArea(x,y,w,h)
      if v.hover then
        love.graphics.setColor(191,255,191)
      else
        love.graphics.setColor(255,255,255)
      end
      if choice then
        if choice.i == i then
          love.graphics.setColor(0,255,0)
        else
          love.graphics.setColor(255,255,255,255*choice.dt)
        end
      end
      if debug_mode then
        love.graphics.rectangle("line",x,y,w,h)
      end
      self:dropshadow(text,x+padding,y+padding)
    end
  end

  if debug_mode then
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(fonts.debug)
    local s = ""
    s = s .. "bgrot: "..bgrot.."\n"
    s = s .. "cemocolor: {"..cemocolor[1]..","..cemocolor[2]..","..cemocolor[3].."}\n"
    table.sort(emotions,function(a,b) return a.n > b.n end)
    for i,v in pairs(emotions) do
      s = s .. v.n .. ": "..v.value.."\n"
    end
    self:dropshadow(s,8,8)
    love.graphics.setFont(fonts.default)
  end

end

function game:tween(cval,tval,speed)
  if math.abs(cval - tval) < speed then
    return tval
  end
  if cval < tval then
    return cval+speed
  elseif tval < cval then
    return cval-speed
  end
  return tval
end

function game:mouseInArea(x,y,w,h)
  local mx,my = love.mouse.getPosition()
  return mx >= x and mx <= x+w and my >= y and my <= y + h
end

function game:getTextArea(index,text,p)
  p = p or 8
  local font = love.graphics.getFont()
  local w = font:getWidth(text)+p*2
  local h = font:getHeight()+p*2
  --local x = 64+p
  local x = (love.graphics.getWidth()-w)/2
  --local y = 64+(index-1)*(h+p)
  local y = love.graphics.getHeight()*3/4+(index-1)*(h+p)
  return x,y,w,h
end

function game:dropshadow( text, x, y, r, sx, sy, ox, oy, kx, ky )
  local old_color = {love.graphics.getColor()}
  love.graphics.setColor(0,0,0,old_color[4] or 255)
  for tx = -1,1 do
    for ty = -1,1 do
      love.graphics.print( text, x+tx*2, y+ty*2, r, sx, sy, ox, oy, kx, ky )
    end
  end
  love.graphics.setColor(old_color)
  love.graphics.print( text, x, y, r, sx, sy, ox, oy, kx, ky )
end

function game:dropshadowf( text, x, y, limit, align )
  local old_color = {love.graphics.getColor()}
  love.graphics.setColor(0,0,0,old_color[4] or 255)
  for tx = -1,1 do
    for ty = -1,1 do
      love.graphics.printf(text, x+tx*2, y+ty*2, limit, align )
    end
  end
  love.graphics.setColor(old_color)
  love.graphics.printf(text, x, y, limit, align )
end

-- http://lua-users.org/wiki/RandomSample
function game:permute(tab, n, count)
  n = n or #tab
  for i = 1, count or n do
    local j = math.random(i, n)
    tab[i], tab[j] = tab[j], tab[i]
  end
  return tab
end

function game:chooseString(t,v)
  return math.ceil(math.min(1,math.max(0,v+math.random()/10))*#t)
end

function game:update(dt)

  local largest
  for i,v in pairs(emotions) do
    if largest then
      if largest.value < v.value then
        largest = v
      end
    else
      largest = v
    end
  end
  if largest.value > 0.1 then
    if segments.tween_to ~= segments[largest.n] then
      emotion_audio[largest.n]:play()
    end
    segments.tween_to = segments[largest.n]
  else
    segments.tween_to = segments.neutral
  end

  for i,v in pairs(segments.current) do
    local c1,c2 = segments.current[i][1],segments.current[i][2]
    local t1,t2 = segments.tween_to[i][1],segments.tween_to[i][2]

    c1[1] = self:tween(c1[1],t1[1],dt/10)
    c1[2] = self:tween(c1[2],t1[2],dt/10)
    c1[3] = self:tween(c1[3],t1[3],dt/10)

    c2[1] = self:tween(c2[1],t2[1],dt/10)
    c2[2] = self:tween(c2[2],t2[2],dt/10)
    c2[3] = self:tween(c2[3],t2[3],dt/10)

  end

  camerarot = camerarot + dt
  camera.theta = math.sin(camerarot)/4+math.pi

  local emocolor = {0,0,0}
  for i,v in pairs(emotions) do
    emocolor[1] = math.max(emocolor[1],v.c[1]*v.value)
    emocolor[2] = math.max(emocolor[2],v.c[2]*v.value)
    emocolor[3] = math.max(emocolor[3],v.c[3]*v.value)
  end

  cemocolor[1] = self:tween(cemocolor[1],emocolor[1],dt*25.5)
  cemocolor[2] = self:tween(cemocolor[2],emocolor[2],dt*25.5)
  cemocolor[3] = self:tween(cemocolor[3],emocolor[3],dt*25.5)

  local emorot = 0
  for i,v in pairs(emotions) do
    emorot = emorot + v.value/#emotions
    v.value = math.max(0,v.value - dt*calm)
  end
  bgrot = bgrot + emorot*math.pi*dt

  if not choices then
    choices = {}
    for i,v in pairs(self:permute(emotions,nil,4)) do
      table.insert(choices,v)
      v.index = nil
      if i == 4 then break end
    end
  end

  if response then
    response.dt = response.dt - dt
    if response.dt <= 0 then
      table.remove(responses,1)
      response = nil
    end
  elseif choice then
    choice.dt = choice.dt - dt
    if choice.dt <= 0 then
      local cchoice = choices[choice.i]
      cchoice.value = math.min(1,cchoice.value + 0.125)
      choice = nil
      choices = nil
      local index = self:chooseString(cchoice.a,cchoice.value)
      table.insert(responses,cchoice.a[index])
    end
  end

end

function game:keypressed(key)

  if key == "`" then
    debug_mode = not debug_mode
  end

  if #responses > 0 then
    response = response or {dt=1}
    click_audio:play()
  elseif choices and choices[tonumber(key)] then
    choice = choice or {i=tonumber(key),dt=1}
    click_audio:play()
  end

end

function game:mousepressed(x,y,button)

  if #responses > 0 then

    if button == 1 then
      response = response or {dt=1}
      click_audio:play()
    end

  elseif choices then

    if button == 1 then
      for i,v in pairs(choices) do
        if v.hover then
          choice = choice or {i=i,dt=1}
          click_audio:play()
          break
        end
      end
    end

  end

end

return game

-- Thanks @bartbes! fixes cygwin buffer
io.stdout:setvbuf("no")

math.randomseed(os.time())

libs = {
  picocam = require"libs.picocam",
  gamestate = require"libs.gamestate",
  json = require"libs.json",
}

fonts = {
  debug = love.graphics.getFont(),
  default = love.graphics.newFont("assets/fonts/VT323-Regular.ttf",24),
}

states = {
  game = require"states.game",
  editor = require"states.editor",
}

function love.load(args)
  libs.gamestate.registerEvents()

  local target = states.game

  for i,v in pairs(args) do
    if states[v] then
      target = states[v]
    end
  end

  libs.gamestate.switch(target)
end

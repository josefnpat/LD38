game_name = "Fugue Gevoelens"
git_hash,git_count = "missing git.lua",-1
pcall( function() return require("git") end );

function love.conf(t)
  t.window.width = 1280
  t.window.height = 720
  t.window.title = game_name .. " by @josefnpat (MissingSentinelSoftware.com)"..
    "for Ludum Dare 38 [v"..git_count.."-"..git_hash.."]"
  t.identity = "Fugue_Gevoelens_LD38"
end

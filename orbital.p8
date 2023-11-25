pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- orbital
-- a physics experiment by @gerwitz

planets={}
g = 0.001 -- will be divided by distance, multiplied by mass

function add_planet(size)
  p = {}
  p.size = size or (rnd(3)+1)
  -- position
  p.x = rnd(128)
  p.y = rnd(128)
  -- motion vector
  p.dx = 0
  p.dy = 0

  add(planets, p)
end

function apply_gravity(planet)
  for p in all(planets) do
    if ((p.x == planet.x) and (p.y == planet.y)) then
      printh("same")
    else
      x_delta = planet.x - p.x
      y_delta = planet.y - p.y
      distance = approx_magnitude(x_delta, y_delta)
      gforce = g * (p.size^2 + planet.size^2) / -distance
      planet.dx += x_delta * gforce
      planet.dy += y_delta * gforce
    end
  end
end

-- thanks to https://www.lexaloffle.com/bbs/?tid=36059
function approx_magnitude(a,b)
 local a0, b0 = abs(a), abs(b)
 return max(a0,b0)*0.9609 + min(a0,b0)*0.3984
end

function move(planet)
  mass = planet.size^2
  planet.x = (planet.x + planet.dx/mass) % 128
  planet.y = (planet.y + planet.dy/mass) % 128
end

function _init()
  planets={}
  add_planet(1)
  add_planet(1)
  add_planet(1)
  add_planet(2)
  add_planet(4)
end

function _update60()
  foreach(planets, apply_gravity)
  foreach(planets, move)
end

function _draw()
	cls()
  for p in all(planets) do
    spr(p.size, p.x, p.y)
  end
end

__gfx__
00000000000000000000000000000000000000000000000000677600000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000660000067760006777760000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000006600000577500007777000677776067777776000000000000000000000000000000000000000000000000000000000000000000000000
00077000000660000067760000777700067777600777777077777777000000000000000000000000000000000000000000000000000000000000000000000000
00077000000660000067760000777700067777600777777077777777000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000006600000577500007777000677776067777776000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000660000067760006777760000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000677600000000000000000000000000000000000000000000000000000000000000000000000000

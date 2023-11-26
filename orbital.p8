pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- orbital
-- a physics experiment by @gerwitz

planets={}
next_id=0

g = 0.001 -- will be divided by distance, multiplied by mass
max_size = 5
max_speed = 3
logfile = "orbital.txt"

function log(msg)
  printh(tostr(time())..": "..tostr(msg), logfile)
  printh(#planets.." planets:", logfile)
  for p in all(planets) do
    printh("- "..tostr(p.x)..","..tostr(p.y).."/"..tostr(p.dx)..","..tostr(p.dy).." - "..tostr(p.size), logfile)
  end
end

function add_planet(size, x, y, dx, dy)
  p = {}
  p.id = next_id
  next_id += 1
  p.size = size or (rnd(3)+1)
  -- position
  p.x = x or rnd(128)
  p.y = y or rnd(128)
  -- motion vector
  p.dx = dx or rnd(max_speed)-(max_speed/2)
  p.dy = dy or rnd(max_speed)-(max_speed/2)

  add(planets, p)
end

function apply_gravity(planet)
  for p in all(planets) do
    if (p.id != planet.id) then
      x_delta = planet.x - p.x
      y_delta = planet.y - p.y
      distance = approx_magnitude(x_delta, y_delta)
      if (distance < planet.size + p.size) then
        merge(planet, p)
        return
      end
      gforce = g * (p.size^3 + planet.size^3) / -(distance)
      new_dx = planet.dx + x_delta * gforce
      new_dy = planet.dy + y_delta * gforce
      speed = abs(new_dx) + abs(new_dy)
      if (speed > max_speed) then
        slowdown = 1 / (speed / max_speed)
        new_dx *= slowdown
        new_dy *= slowdown
      end
      planet.dx = new_dx
      planet.dy = new_dy
    end
  end
end

function merge(survivor, victim)
  -- older survives
  if (survivor.id < victim.id) survivor, victim = victim, survivor
  s_mass = survivor.size^2
  v_mass = victim.size^2
  new_dx = (survivor.dx/s_mass) + (victim.dx/v_mass)
  new_dy = (survivor.dy/s_mass) + (victim.dy/v_mass)
  survivor.dx = new_dx
  survivor.dy = new_dy
  survivor.size = survivor.size + victim.size
  del(planets, victim)
  --if (survivor.size > 7) _init()
  if (survivor.size > max_size) explode(survivor)
end

function explode(donor)
  local fragments = donor.size
  local center_x = donor.x
  local center_y = donor.y
  del(planets, donor)
  for i=0,fragments-1 do
    add_planet(1, (center_x + (fragments/2)*cos(i/8))%128, (fragments/2)*sin(i/8)%128, cos(i/8), sin(i/8))
  end
end

function move(planet)
  mass = planet.size^3
  planet.x = (planet.x + planet.dx/mass) % 128
  planet.y = (planet.y + planet.dy/mass) % 128
end

function _init()
  planets={}
  for i=0,6 do
    add_planet(1, rnd(128), rnd(128))
  end
end

function _update60()
  foreach(planets, apply_gravity)
  foreach(planets, move)
end

function _draw()
  grayvid()
  cls(15)

  for p in all(planets) do
    draw_disc(p.x, p.y, p.size+.3)
  end
end

-- distance without sqrt
-- thanks to https://www.lexaloffle.com/bbs/?tid=36059
function approx_magnitude(a,b)
 local a0, b0 = abs(a), abs(b)
 return max(a0,b0)*0.9609 + min(a0,b0)*0.3984
end

-- anti-aliased filled circle
-- thanks to https://www.lexaloffle.com/bbs/?tid=30810
local ramp={[0]=7,7,7,7,7,6,6,6,13,13,13,5,5,1,1,0}
function grayvid()
    for i=0,15 do
        pal(i,i,0)
        pal(i,ramp[i],1)
     palt(i,false)
    end
end
function draw_disc(x0,y0,r)
  if(r==0) return
  local x,y,dx,dy=flr(r),0,1,1
  r*=2
  local err=dx-r

  while x>=y do
    local dist=1+err/r

    rectfill(x0-x+1,y0+y,x0+x-1,y0+y,0)
    rectfill(x0-x+1,y0-y,x0+x-1,y0-y,0)
    rectfill(x0-y,y0-x+1,x0+y,y0-x+1,0)
    rectfill(x0-y,y0+x-1,x0+y,y0+x-1,0)

    shadepix(x0+x,y0+y,dist)
    shadepix(x0+y,y0+x,dist)
    shadepix(x0-y,y0+x,dist)
    shadepix(x0+x,y0-y,dist)

    shadepix(x0-x,y0+y,dist)
    shadepix(x0-y,y0-x,dist)
    shadepix(x0+y,y0-x,dist)
    shadepix(x0-x,y0-y,dist)

    if err<=0 then
      y+=1
      err+=dy
      dy+=2
    end
    if err>0 then
      x-=1
      dx+=2
      err+=dx-r
    end
  end
end
function shadepix(x,y,k)
  pset(x, y, pget(x,y)*k)
end

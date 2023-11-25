pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- orbital
-- a physics experiment by @gerwitz

planets={}
next_id=0
g = 0.001 -- will be divided by distance, multiplied by mass

function add_planet(size)
  p = {}
  p.id = next_id
  next_id += 1
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
    if (p.id != planet.id) then
      x_delta = planet.x - p.x
      y_delta = planet.y - p.y
      distance = approx_magnitude(x_delta, y_delta)
      if (distance < planet.size + p.size) then
        merge(planet, p)
        return
      end
      gforce = g * (p.size^2 + planet.size^2) / -distance
      planet.dx += x_delta * gforce
      planet.dy += y_delta * gforce
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
  add_planet(1)
  add_planet(1)
end

function _update()
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

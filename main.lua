-- ToonRoyale: primeiro prototipo offline. Arte vetorial TEMPORARIA, nao sprites finais.
local W = require("src.world")
local world, player, cam
local function color(r,g,b,a) love.graphics.setColor(r/255,g/255,b/255,(a or 255)/255) end
function love.load()
  love.graphics.setDefaultFilter("nearest","nearest")
  world=W.new(6400,6400,20261021)
  player={x=3200,y=3200,r=17,speed=230,angle=0}
  cam={x=player.x,y=player.y}
end
function love.update(dt)
  dt=math.min(dt,0.05)
  local dx=(love.keyboard.isDown("d","right") and 1 or 0)-(love.keyboard.isDown("a","left") and 1 or 0)
  local dy=(love.keyboard.isDown("s","down") and 1 or 0)-(love.keyboard.isDown("w","up") and 1 or 0)
  local n=math.sqrt(dx*dx+dy*dy)
  if n>0 then dx,dy=dx/n,dy/n end
  local nx=math.max(player.r,math.min(world.width-player.r,player.x+dx*player.speed*dt))
  local ny=math.max(player.r,math.min(world.height-player.r,player.y+dy*player.speed*dt))
  if not W.collides(world,nx,player.y,player.r) then player.x=nx end
  if not W.collides(world,player.x,ny,player.r) then player.y=ny end
  local mx,my=love.mouse.getPosition()
  local sw,sh=love.graphics.getDimensions()
  player.angle=math.atan2 and math.atan2(my-sh/2,mx-sw/2) or math.atan(my-sh/2,mx-sw/2)
  local smooth=1-math.exp(-12*dt)
  cam.x=cam.x+(player.x-cam.x)*smooth
  cam.y=cam.y+(player.y-cam.y)*smooth
end
function love.draw()
  local sw,sh=love.graphics.getDimensions()
  love.graphics.push()
  love.graphics.translate(math.floor(sw/2-cam.x),math.floor(sh/2-cam.y))
  W.draw(world,cam.x-sw/2,cam.y-sh/2,sw,sh)
  color(38,51,43);love.graphics.circle("fill",player.x,player.y,20)
  color(234,192,143);love.graphics.circle("fill",player.x,player.y,16)
  color(74,91,102);love.graphics.circle("fill",player.x,player.y-3,12)
  color(234,192,143);love.graphics.circle("fill",player.x,player.y-8,9)
  local a=player.angle
  color(53,63,64);love.graphics.setLineWidth(6)
  love.graphics.line(player.x+math.cos(a)*8,player.y+math.sin(a)*8,player.x+math.cos(a)*29,player.y+math.sin(a)*29)
  love.graphics.pop()
  color(20,33,26,205);love.graphics.rectangle("fill",14,14,365,75,10)
  color(245,247,230);love.graphics.print("TOONROYALE | PROTOTIPO OFFLINE",26,24)
  love.graphics.print("WASD mover | Mouse mirar | Mundo 6400x6400",26,48)
  color(255,255,255)
end
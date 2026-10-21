-- ToonRoyale: primeira fase offline sobre os modulos do Moo-Quest.
-- Sem inventar entidades de rede: o mapa local existe somente neste modo.
local Camera=require("src.camera")
local Config=require("src.game.config")
local Tiles=require("src.game.toon_tiles")
local O={}
local floor,sqrt,cos,sin,pi=math.floor,math.sqrt,math.cos,math.sin,math.pi
local CELL=272

local function hash(x,y,z) return Tiles.hash(x,y,z) end

function O.newWorld()
  local n=math.ceil(Config.mapScale/CELL)
  local world={width=Config.mapScale,height=Config.mapScale,
    cells={},objects={},cellSize=CELL,columns=n}
  for cy=0,n-1 do
    for cx=0,n-1 do
      local v=hash(cx,cy,17)
      if v>0.45 then
        local x=cx*CELL+48+hash(cx,cy,19)*(CELL-96)
        local y=cy*CELL+48+hash(cx,cy,21)*(CELL-96)
        local typ=v>0.96 and 3 or v>0.78 and 2 or v>0.65 and 1 or 0
        -- Troncos e rochas bloqueiam; arbustos decorativos sao atravessaveis.
        local radius=typ==0 and 32 or typ==1 and 0 or 25
        -- Area aberta para o primeiro spawn, sem aprisionar o personagem.
        local dx,dy=x-Config.mapScale/2,y-(Config.mapScale/2-1100)
        if dx*dx+dy*dy>360*360 then
          local obj={x=x,y=y,type=typ,scale=typ==0 and 110 or typ==1 and 83 or 77,
            radius=radius}
          world.cells[cy*n+cx+1]=obj
          world.objects[#world.objects+1]=obj
        end
      end
    end
  end
  return world
end

local function nearby(w,x,y,fn)
  local cx,cy=floor(x/CELL),floor(y/CELL)
  for iy=math.max(0,cy-1),math.min(w.columns-1,cy+1) do
    for ix=math.max(0,cx-1),math.min(w.columns-1,cx+1) do
      local o=w.cells[iy*w.columns+ix+1]
      if o then fn(o) end
    end
  end
end

function O.collides(w,x,y,r)
  if x<r or y<r or x>w.width-r or y>w.height-r then return true end
  local blocked=false
  nearby(w,x,y,function(o)
    local dx,dy=x-o.x,y-o.y
    if o.radius>0 and dx*dx+dy*dy<(r+o.radius)^2 then blocked=true end
  end)
  return blocked
end

function O.install()
  local world,camera,player,showUI
  local smokeFrames=0
  function love.load()
    love.graphics.setDefaultFilter("linear","linear")
    world=O.newWorld()
    camera=Camera.new()
    player={x=Config.mapScale/2,y=Config.mapScale/2-1100,
      radius=18,speed=270,angle=0}
    camera:follow(player.x,player.y)
    showUI=true
    Tiles.init()
  end
  function love.update(dt)
    dt=math.min(dt,0.06)
    local dx=(love.keyboard.isDown("d","right") and 1 or 0)-
      (love.keyboard.isDown("a","left") and 1 or 0)
    local dy=(love.keyboard.isDown("s","down") and 1 or 0)-
      (love.keyboard.isDown("w","up") and 1 or 0)
    local len=sqrt(dx*dx+dy*dy)
    if len>0 then dx,dy=dx/len,dy/len end
    local nx=player.x+dx*player.speed*dt
    if not O.collides(world,nx,player.y,player.radius) then
      player.x=nx
    end
    local ny=player.y+dy*player.speed*dt
    if not O.collides(world,player.x,ny,player.radius) then
      player.y=ny
    end
    local mx,my=love.mouse.getPosition()
    local w,h=love.graphics.getDimensions()
    local aim=math.atan2 or function(y,x)
      if x==0 then return y>=0 and pi/2 or -pi/2 end
      return math.atan(y/x)+(x<0 and (y>=0 and pi or -pi) or 0)
    end
    player.angle=aim(my-h/2,mx-w/2)
    camera:followReference(player.x,player.y,dt)
  end
  function love.draw()
    local w,h=love.graphics.getDimensions()
    Tiles.drawGround(camera,w,h)
    -- Desenho e oclusao ordenados por Y: copa pode passar na frente do heroi.
    local visibles={}
    local x0,y0=camera:screenToWorld(-220,-220)
    local x1,y1=camera:screenToWorld(w+220,h+220)
    local cx0,cy0=floor(x0/CELL),floor(y0/CELL)
    local cx1,cy1=floor(x1/CELL),floor(y1/CELL)
    for cy=math.max(0,cy0),math.min(world.columns-1,cy1) do
      for cx=math.max(0,cx0),math.min(world.columns-1,cx1) do
        local o=world.cells[cy*world.columns+cx+1]
        if o then visibles[#visibles+1]=o end
      end
    end
    visibles[#visibles+1]={x=player.x,y=player.y,player=true}
    table.sort(visibles,function(a,b) return a.y<b.y end)
    for _,o in ipairs(visibles) do
      local x,y=camera:worldToScreen(o.x,o.y)
      if o.player then Tiles.drawPlayer(x,y,player.angle,camera.zoom)
      else Tiles.drawResource(o.type,x,y,o.scale,camera.zoom,o.x,o.y) end
    end
    local x0s,y0s=camera:worldToScreen(0,0)
    local x1s,y1s=camera:worldToScreen(world.width,world.height)
    love.graphics.setColor(0.14,0.31,0.23)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line",x0s,y0s,x1s-x0s,y1s-y0s)
    if showUI then
      love.graphics.setColor(0.08,0.17,0.14,0.88)
      love.graphics.rectangle("fill",16,16,425,82,9,9)
      love.graphics.setColor(0.92,0.97,0.87)
      love.graphics.print("TOONROYALE  |  MUNDO OFFLINE",29,28)
      love.graphics.print("WASD: mover   Mouse: mirar   F1: ocultar painel",29,54)
      love.graphics.setColor(0.08,0.17,0.14,0.8)
      love.graphics.rectangle("fill",16,h-43,297,30,7,7)
      love.graphics.setColor(0.93,0.97,0.90)
      love.graphics.print(("Mapa 14400 x 14400  |  X %d  Y %d"):format(
        floor(player.x),floor(player.y)),27,h-35)
    end
    love.graphics.setColor(1,1,1,1)
    if os.getenv("TOONROYALE_SMOKE")=="1" then
      smokeFrames=smokeFrames+1
      if smokeFrames>=4 then
        print("TOONROYALE OFFLINE VISUAL SMOKE PASS")
        love.event.quit(0)
      end
    end
  end
  function love.resize(w,h)
    if camera then camera:resize(w,h) end
  end
  function love.keypressed(key)
    if key=="f1" then showUI=not showUI
    elseif key=="escape" then love.event.quit() end
  end
end
return O

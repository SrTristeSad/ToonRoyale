-- ToonRoyale: visual tile-based sem dependencias externas.
-- Os canvases gerados aqui sao sprites temporarios: nao substituem PNGs finais.
-- Os detalhes sao deterministas, sem emendas visiveis entre os tiles.
local T={}
T.TILE=96
local ground,resources,avatar
local initialized=false
local floor,cos,sin,pi=math.floor,math.cos,math.sin,math.pi

local function hash(x,y,salt)
  local n=sin(x*127.1+y*311.7+(salt or 0)*74.7)*43758.5453
  return n-floor(n)
end
T.hash=hash

local function color(r,g,b,a)
  love.graphics.setColor(r/255,g/255,b/255,(a or 255)/255)
end
local function circle(x,y,r)
  love.graphics.circle("fill",x,y,r)
end
local function ellipse(x,y,rx,ry)
  love.graphics.ellipse("fill",x,y,rx,ry)
end
local function makeCanvas(width,height,fn)
  local c=love.graphics.newCanvas(width,height)
  c:setFilter("linear","linear")
  love.graphics.setCanvas(c)
  love.graphics.clear(0,0,0,0)
  fn()
  love.graphics.setCanvas()
  return c
end

local function grassTile(seed)
  return makeCanvas(96,96,function()
    -- Fundo identico em todas as variantes: nenhum quadriculado artificial.
    color(104,161,85)
    love.graphics.rectangle("fill",0,0,96,96)
    for i=1,17 do
      local x=6+floor(hash(i,seed,1)*83)
      local y=6+floor(hash(i,seed,2)*82)
      local v=hash(i,seed,3)
      if v>0.70 then
        color(82,144,75,145)
        ellipse(x+2,y+3,7,2)
      end
      color(51,126,70,v>0.48 and 160 or 110)
      love.graphics.setLineWidth(1.8)
      love.graphics.line(x,y+4,x-3,y-1)
      love.graphics.line(x,y+4,x+3,y-3)
      if v>0.38 then
        color(155,195,111,160)
        love.graphics.line(x+1,y+4,x+1,y-3)
      end
    end
    for i=1,3 do
      local x=10+hash(seed,i,5)*75
      local y=10+hash(seed,i,6)*75
      color(174,188,112,110)
      circle(x,y,1.6)
    end
  end)
end

local function treeSprite(variant)
  return makeCanvas(256,256,function()
    local sway=(variant-2)*3
    -- Vista diretamente de cima. A copa utiliza 3 tons principais:
    -- borda escura, sombra intermediaria e verde base central.
    local centers={
      {-62,-18,51},{-37,-63,48},{18,-71,52},{69,-37,48},
      {66,26,51},{22,69,49},{-43,60,52},{-73,25,43},
      {-8,-17,64},{22,13,59}
    }
    love.graphics.push()
    love.graphics.translate(128+sway,127)
    color(30,74,49)
    for _,v in ipairs(centers) do circle(v[1]*1.02,v[2]*1.02,v[3]+8) end
    color(46,105,60)
    for i,v in ipairs(centers) do
      circle(v[1]-4,v[2]-5,v[3]+1)
    end
    -- O segundo tom forma recortes perto das extremidades e volume.
    color(61,130,70)
    for i,v in ipairs(centers) do
      circle(v[1]+6,v[2]-3,v[3]*0.70)
    end
    color(84,157,80)
    circle(-23,-25,47)
    circle(32,-15,44)
    circle(9,36,37)
    -- Pequenos contornos foliares, sem brilho especular nem sombra projetada.
    color(40,106,61,160)
    love.graphics.setLineWidth(3)
    for i=1,20 do
      local a=hash(i,variant,5)*2*pi
      local r=20+hash(i,variant,8)*75
      local x,y=cos(a)*r,sin(a)*r
      local dd=6+hash(i,variant,12)*10
      love.graphics.arc("line","open",x,y,dd,a-0.55,a+0.65)
    end
    love.graphics.pop()
  end)
end

local function rockSprite(variant,gold)
  return makeCanvas(256,256,function()
    love.graphics.push()
    love.graphics.translate(128,132)
    love.graphics.rotate((variant-2)*0.11)
    -- Pedra top-down com facetas geometricas limpas e sem sombra no solo.
    color(47,68,65)
    love.graphics.polygon("fill",-104,22,-88,-57,-37,-86,40,-91,98,-46,109,35,60,80,-38,86)
    if gold then color(140,105,35) else color(102,119,116) end
    love.graphics.polygon("fill",-97,18,-81,-55,-33,-79,38,-84,91,-42,102,31,56,73,-33,79)
    if gold then color(197,148,49) else color(143,160,156) end
    love.graphics.polygon("fill",-81,-55,-33,-79,38,-84,77,-42,32,-9,-38,-8)
    if gold then color(114,85,39) else color(77,96,96) end
    love.graphics.polygon("fill",-97,18,-81,-55,-38,-8,-8,46,-33,79)
    if gold then color(167,121,41) else color(110,126,125) end
    love.graphics.polygon("fill",32,-9,77,-42,91,-42,102,31,56,73,-8,46)
    -- Juntas entre as faces, visiveis mas discretas.
    if gold then color(102,80,38) else color(64,83,83) end
    love.graphics.setLineWidth(3)
    love.graphics.line(-38,-8,32,-9)
    love.graphics.line(32,-9,-8,46)
    love.graphics.line(-38,-8,-8,46)
    if gold then
      color(225,182,70)
      love.graphics.polygon("fill",-17,-39,10,-49,24,-22,6,-8,-22,-14)
      color(244,209,105)
      love.graphics.polygon("fill",40,24,57,11,67,26,56,41)
    else
      color(86,105,104)
      love.graphics.line(-46,15,-56,33,-36,46)
    end
    love.graphics.pop()
  end)
end

local function bushSprite(variant)
  return makeCanvas(256,256,function()
    love.graphics.push()
    love.graphics.translate(128,132)
    local x=(variant-2)*4
    color(29,81,48)
    circle(-49+x,10,58);circle(44+x,5,65);circle(1+x,-42,63)
    color(44,112,60)
    circle(-46+x,-4,48);circle(39+x,-11,50);circle(0+x,-39,50)
    color(79,150,76)
    circle(-25+x,-28,37);circle(26+x,-32,35);circle(3+x,6,35)
    love.graphics.pop()
  end)
end

local function playerSprite()
  return makeCanvas(112,112,function()
    love.graphics.push()
    love.graphics.translate(56,56)
    -- Rosto apontando para a direita quando angle=0.
    color(35,50,53)
    ellipse(-22,-21,12,10);ellipse(-22,21,12,10)
    color(35,91,111)
    ellipse(-4,0,30,26)
    color(52,127,147)
    ellipse(0,0,27,24)
    color(221,170,120)
    circle(18,-29,10);circle(18,29,10)
    color(68,44,33)
    circle(16,0,24)
    color(229,184,135)
    circle(22,0,21)
    color(59,45,39)
    ellipse(12,-4,17,20)
    color(238,194,148)
    ellipse(28,0,9,15)
    color(40,50,51)
    circle(34,-7,2);circle(34,8,2)
    love.graphics.pop()
  end)
end

function T.init()
  if initialized then return end
  love.graphics.push("all")
  ground={}
  for i=1,6 do ground[i]=grassTile(i) end
  resources={tree={},rock={},gold={},bush={}}
  for i=1,3 do
    resources.tree[i]=treeSprite(i)
    resources.rock[i]=rockSprite(i,false)
    resources.gold[i]=rockSprite(i,true)
    resources.bush[i]=bushSprite(i)
  end
  avatar=playerSprite()
  love.graphics.pop()
  initialized=true
end

function T.drawGround(camera,w,h)
  T.init()
  local s=T.TILE
  local x0,y0,x1,y1
  if camera.screenToWorld then
    x0,y0=camera:screenToWorld(0,0)
    x1,y1=camera:screenToWorld(w,h)
  else
    -- Alguns render tests legados do Moo-Quest usam camera simplificada.
    -- Reconstituir area visivel por origem/zoom preserva compatibilidade.
    local ox,oy=camera:worldToScreen(0,0)
    local zoom=camera.zoom or 1
    x0,y0=-ox/zoom,-oy/zoom
    x1,y1=(w-ox)/zoom,(h-oy)/zoom
  end
  local ax,ay=floor(x0/s)-1,floor(y0/s)-1
  local bx,by=floor(x1/s)+1,floor(y1/s)+1
  love.graphics.setColor(1,1,1,1)
  for y=ay,by do
    for x=ax,bx do
      local v=1+floor(hash(x,y,9)*#ground)
      local xx,yy=camera:worldToScreen(x*s,y*s)
      love.graphics.draw(ground[v],xx,yy,0,camera.zoom,camera.zoom)
    end
  end
end

function T.drawResource(kind,x,y,r,zoom)
  T.init()
  local key=kind==0 and "tree" or kind==1 and "bush" or
    kind==2 and "rock" or kind==3 and "gold" or nil
  if not key then return false end
  local variants=resources[key]
  local i=1+floor(hash(floor(x),floor(y),11)*#variants)
  local img=variants[i]
  local size=math.max(1,(r or 85)*2.1*(zoom or 1))
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(img,x,y,0,size/img:getWidth(),size/img:getHeight(),
    img:getWidth()/2,img:getHeight()/2)
  return true
end

function T.drawPlayer(x,y,angle,zoom)
  T.init()
  love.graphics.setColor(1,1,1,1)
  local scale=0.72*(zoom or 1)
  love.graphics.draw(avatar,x,y,angle or 0,scale,scale,
    avatar:getWidth()/2,avatar:getHeight()/2)
end

return T

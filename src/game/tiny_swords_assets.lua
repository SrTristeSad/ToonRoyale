-- Tiny Swords Free Pack: importado localmente, nao armazenado no GitHub.
-- Pixel Frog: https://pixelfrog-assets.itch.io/tiny-swords
local A={}
A.root="assets/third_party/tiny_swords/"
A.tile=64
A.manifest={
  "tileset/grass.png",
  "trees/tree1.png","trees/tree2.png","trees/tree3.png","trees/tree4.png",
  "rocks/rock1.png","rocks/rock2.png","rocks/rock3.png","rocks/rock4.png",
  "bushes/bush1.png","bushes/bush2.png","bushes/bush3.png","bushes/bush4.png",
  "gold/gold1.png","gold/gold2.png","gold/gold3.png",
  "gold/gold4.png","gold/gold5.png","gold/gold6.png"
}
local initialized=false
local sprites,grass,quads
local floor=math.floor
local function hash(x,y,s)
  local n=math.sin(x*127.1+y*311.7+(s or 0)*74.7)*43758.5453
  return n-floor(n)
end
local function loadImage(name)
  local path=A.root..name
  if not love.filesystem.getInfo(path,"file") then return nil end
  local ok,img=pcall(love.graphics.newImage,path)
  if not ok or not img then return nil end
  img:setFilter("nearest","nearest")
  return img
end
function A.init()
  if initialized then return sprites~=nil end
  initialized=true
  for _,name in ipairs(A.manifest) do
    if not love.filesystem.getInfo(A.root..name,"file") then return false end
  end
  local loaded={}
  for _,name in ipairs(A.manifest) do
    local img=loadImage(name)
    if not img then return false end
    loaded[name]=img
  end
  grass=loaded["tileset/grass.png"]
  if grass:getWidth()~=576 or grass:getHeight()~=384 then return false end
  local all={tree={},rock={},gold={},bush={}}
  local function animated(name,frameWidth,frameHeight,frames)
    local img=loaded[name]
    if img:getWidth()~=frameWidth*frames
      or img:getHeight()~=frameHeight then return nil end
    local quad={}
    for i=0,frames-1 do
      quad[#quad+1]=love.graphics.newQuad(i*frameWidth,0,frameWidth,frameHeight,
        img:getWidth(),img:getHeight())
    end
    return {image=img,frames=quad,width=frameWidth,height=frameHeight}
  end
  for i=1,4 do
    all.tree[i]=animated("trees/tree"..i..".png",192,i<=2 and 256 or 192,8)
    all.bush[i]=animated("bushes/bush"..i..".png",128,128,8)
    local img=loaded["rocks/rock"..i..".png"]
    if img:getWidth()~=64 or img:getHeight()~=64 then return false end
    all.rock[i]={image=img,width=64,height=64}
    if not all.tree[i] or not all.bush[i] then return false end
  end
  for i=1,6 do
    local img=loaded["gold/gold"..i..".png"]
    if img:getWidth()~=128 or img:getHeight()~=128 then return false end
    all.gold[i]={image=img,width=128,height=128}
  end
  quads={
    love.graphics.newQuad(64,64,64,64,576,384),
    love.graphics.newQuad(384,64,64,64,576,384)
  }
  sprites=all
  return true
end
function A.available()
  return A.init()
end
function A.drawGround(camera,w,h)
  if not A.available() then return false end
  local s=A.tile
  local x0,y0,x1,y1
  if camera.screenToWorld then
    x0,y0=camera:screenToWorld(0,0)
    x1,y1=camera:screenToWorld(w,h)
  else
    local ox,oy=camera:worldToScreen(0,0)
    local zoom=camera.zoom or 1
    x0,y0=-ox/zoom,-oy/zoom
    x1,y1=(w-ox)/zoom,(h-oy)/zoom
  end
  local startX,startY=floor(x0/s)-1,floor(y0/s)-1
  local endX,endY=floor(x1/s)+1,floor(y1/s)+1
  local zoom=camera.zoom or 1
  love.graphics.setColor(1,1,1,1)
  for ty=startY,endY do
    for tx=startX,endX do
      local variant=1+floor(hash(tx,ty,45)*#quads)
      local px,py=camera:worldToScreen(tx*s,ty*s)
      love.graphics.draw(grass,quads[variant],px,py,0,zoom,zoom)
    end
  end
  return true
end
function A.drawResource(typ,x,y,worldScale,zoom,wx,wy)
  if not A.available() then return false end
  local category=typ==0 and "tree" or typ==1 and "bush"
    or typ==2 and "rock" or typ==3 and "gold"
  if not category then return false end
  local options=sprites[category]
  local salt=category=="tree" and 17 or category=="bush" and 19 or 21
  local n=1+floor(hash(floor(wx or x),floor(wy or y),salt)*#options)
  local spr=options[n]
  local z=zoom or 1
  local s=worldScale or 85
  local destinationWidth
  if category=="tree" then
    destinationWidth=s*1.9
  elseif category=="bush" then
    destinationWidth=s*2
  elseif category=="gold" then
    destinationWidth=s*4
  else
    destinationWidth=s*2.2
  end
  local drawScale=destinationWidth/spr.width*z
  local frame
  if spr.frames then
    local now=love.timer and love.timer.getTime() or 0
    local phase=hash(floor(wx or x),floor(wy or y),37)*8
    frame=spr.frames[1+(floor(now*10+phase)%#spr.frames)]
  end
  local originY=category=="tree" and spr.height-16 or spr.height/2
  love.graphics.setColor(1,1,1,1)
  if frame then
    love.graphics.draw(spr.image,frame,x,y,0,drawScale,drawScale,
      spr.width/2,originY)
  else
    love.graphics.draw(spr.image,x,y,0,drawScale,drawScale,
      spr.width/2,originY)
  end
  return true
end
return A

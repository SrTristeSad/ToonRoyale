local M={}
local function hash(x,y,seed)
  local n=math.sin(x*127.1+y*311.7+seed*0.001)*43758.5453
  return n-math.floor(n)
end
local function c(r,g,b,a) love.graphics.setColor(r/255,g/255,b/255,(a or 255)/255) end
function M.new(width,height,seed)
  local w={width=width,height=height,seed=seed,cell=160,objects={}}
  for cy=0,math.ceil(height/w.cell)-1 do
    for cx=0,math.ceil(width/w.cell)-1 do
      local v=hash(cx,cy,seed)
      local x=cx*w.cell+25+hash(cx+7,cy,seed)*110
      local y=cy*w.cell+25+hash(cx,cy+9,seed)*110
      if (x-3200)^2+(y-3200)^2>250^2 then
        if v>0.40 then
          local kind=v>0.81 and "rock" or v>0.55 and "tree" or "bush"
          w.objects[#w.objects+1]={x=x,y=y,kind=kind,r=kind=="tree" and 31 or kind=="rock" and 24 or 16}
        end
      end
    end
  end
  return w
end
function M.collides(w,x,y,r)
  for _,o in ipairs(w.objects) do
    if o.kind~="bush" and math.abs(o.x-x)<o.r+r and math.abs(o.y-y)<o.r+r then
      local dx,dy=o.x-x,o.y-y
      if dx*dx+dy*dy<(o.r+r)^2 then return true end
    end
  end
  return false
end
local function drawObject(o)
  local x,y=o.x,o.y
  if o.kind=="tree" then
    c(43,71,45,70);love.graphics.ellipse("fill",x+9,y+17,43,22)
    c(95,69,44);love.graphics.circle("fill",x,y+8,11)
    c(24,83,50);love.graphics.circle("fill",x-16,y-7,25)
    c(35,110,60);love.graphics.circle("fill",x+14,y-11,27)
    c(51,137,72);love.graphics.circle("fill",x-2,y-21,28)
    c(77,157,84);love.graphics.circle("fill",x-8,y-28,14)
  elseif o.kind=="rock" then
    c(39,64,48,80);love.graphics.ellipse("fill",x+5,y+14,31,15)
    c(76,94,96);love.graphics.polygon("fill",x-28,y+9,x-20,y-15,x+4,y-25,x+25,y-11,x+30,y+13,x+5,y+22)
    c(125,140,138);love.graphics.polygon("fill",x-20,y-15,x+4,y-25,x+10,y-6,x-5,y+5,x-28,y+9)
    c(95,113,115);love.graphics.polygon("fill",x+4,y-25,x+25,y-11,x+30,y+13,x+10,y-6)
  else
    c(31,93,48);love.graphics.circle("fill",x-10,y,15)
    c(46,122,59);love.graphics.circle("fill",x+9,y-5,17)
    c(66,146,73);love.graphics.circle("fill",x-1,y-13,13)
  end
end
function M.draw(w,left,top,sw,sh)
  c(104,158,86);love.graphics.rectangle("fill",0,0,w.width,w.height)
  local cell=64
  local x0=math.max(0,math.floor(left/cell))
  local y0=math.max(0,math.floor(top/cell))
  local x1=math.min(math.ceil(w.width/cell),math.ceil((left+sw)/cell))
  local y1=math.min(math.ceil(w.height/cell),math.ceil((top+sh)/cell))
  for y=y0,y1 do for x=x0,x1 do
    local v=hash(x,y,w.seed)
    local px,py=x*cell,y*cell
    if v>0.53 then c(92,149,79,75);love.graphics.ellipse("fill",px+23,py+34,28,18) end
    if v>0.24 then
      c(54,122,62,180)
      love.graphics.line(px+10,py+15,px+7,py+8)
      love.graphics.line(px+10,py+15,px+14,py+7)
      love.graphics.line(px+42,py+49,px+39,py+42)
      love.graphics.line(px+42,py+49,px+46,py+43)
    end
  end end
  for _,o in ipairs(w.objects) do
    if o.x>left-65 and o.x<left+sw+65 and o.y>top-65 and o.y<top+sh+65 then drawObject(o) end
  end
  c(36,74,51);love.graphics.setLineWidth(8);love.graphics.rectangle("line",4,4,w.width-8,w.height-8)
end
return M
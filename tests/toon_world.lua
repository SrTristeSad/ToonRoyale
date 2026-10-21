-- Verificacoes puras do mundo offline (executaveis sem servidor Node).
local Offline=require("src.game.toon_offline")
local Config=require("src.game.config")
local w=Offline.newWorld()
assert(w.width==Config.mapScale and w.height==Config.mapScale)
assert(#w.objects>200,"world requires trees and rocks")
assert(not Offline.collides(w,Config.mapScale/2,Config.mapScale/2-1100,18),
  "spawn zone should start free")
assert(Offline.collides(w,-1,100,18),"outside world must collide")
local first=w.objects[1]
assert(first and Offline.collides(w,first.x,first.y,16),
  "resource must block movement")
local w2=Offline.newWorld()
assert(#w.objects==#w2.objects)
for i=1,math.min(30,#w.objects) do
  assert(w.objects[i].x==w2.objects[i].x)
  assert(w.objects[i].y==w2.objects[i].y)
end

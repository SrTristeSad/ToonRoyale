package.path="./?.lua;./?/init.lua;"..package.path
local A=require("src.game.tiny_swords_assets")
assert(A.tile==64)
assert(A.root=="assets/third_party/tiny_swords/")
assert(#A.manifest==19,"tree+rock+bush+gold+tilemap = 19 source images")
local seen={}
for _,name in ipairs(A.manifest) do
  assert(name:match("^[%w_/]+%d*%.png$"),"unsafe import path")
  assert(not seen[name],"duplicate import path")
  seen[name]=true
end
for i=1,4 do
  assert(seen["trees/tree"..i..".png"])
  assert(seen["bushes/bush"..i..".png"])
  assert(seen["rocks/rock"..i..".png"])
end
for i=1,6 do assert(seen["gold/gold"..i..".png"]) end
print("Tiny Swords loader manifest, sizes and local-only paths checked")

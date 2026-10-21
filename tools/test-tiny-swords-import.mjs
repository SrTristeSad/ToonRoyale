// Generate an entirely synthetic ZIP to test the importer without
// downloading or republishing ANY Pixel Frog artwork.
import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import {spawnSync} from "node:child_process";
import AdmZip from "adm-zip";
import sharp from "sharp";
const p="Tiny Swords (Free Pack)/";
const rules=[
  ["Terrain/Tileset/Tilemap_color2.png",576,384],
  ...[1,2,3,4].map(i=>["Terrain/Resources/Wood/Trees/Tree"+i+".png",1536,i<=2?256:192]),
  ...[1,2,3,4].map(i=>["Terrain/Decorations/Rocks/Rock"+i+".png",64,64]),
  ...[1,2,3,4].map(i=>["Terrain/Decorations/Bushes/Bushe"+i+".png",1024,128]),
  ...[1,2,3,4,5,6].map(i=>["Terrain/Resources/Gold/Gold Stones/Gold Stone "+i+".png",128,128])
];
const zip=new AdmZip();
for(const [name,width,height] of rules){
  const png=await sharp({create:{width,height,channels:4,
    background:{r:85,g:155,b:95,alpha:1}}}).png().toBuffer();
  zip.addFile(p+name,png);
}
const root=fs.mkdtempSync(path.join(os.tmpdir(),"tiny-swords-fixture-"));
const archive=path.join(root,"synthetic-tiny-swords.zip");
zip.writeZip(archive);
const run=spawnSync(process.execPath,["tools/import-tiny-swords.mjs",archive],
  {encoding:"utf8"});
if(run.stdout)process.stdout.write(run.stdout);
if(run.stderr)process.stderr.write(run.stderr);
if(run.status!==0)throw Error("Importer failed: "+run.status);
const assets="assets/third_party/tiny_swords/";
const installed=JSON.parse(fs.readFileSync(assets+"LOCAL_ASSETS.json","utf8"));
if(installed.includedAssets.length!==19)throw Error("Expected 19 imported assets");
for(const name of installed.includedAssets){
  const src=assets+name;
  if(!fs.existsSync(src))throw Error("Missing imported art "+src);
}
console.log("PASS: 19 local images, dimensions and source archive mapping");

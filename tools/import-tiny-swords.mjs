#!/usr/bin/env node
// Tiny Swords Free Pack: imported privately from the player's own ZIP.
// Pixel Frog prohibits asset-file redistribution. Never commit generated PNGs.
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import AdmZip from "adm-zip";

const source=process.argv[2];
if (!source || !fs.existsSync(source)) {
  console.error('Uso: node tools/import-tiny-swords.mjs "Tiny Swords (Free Pack).zip"');
  process.exit(1);
}
const mapping=[
  ["Terrain/Tileset/Tilemap_color2.png","tileset/grass.png"],
  ...[1,2,3,4].map(i=>["Terrain/Resources/Wood/Trees/Tree"+i+".png","trees/tree"+i+".png"]),
  ...[1,2,3,4].map(i=>["Terrain/Decorations/Rocks/Rock"+i+".png","rocks/rock"+i+".png"]),
  ...[1,2,3,4].map(i=>["Terrain/Decorations/Bushes/Bushe"+i+".png","bushes/bush"+i+".png"]),
  ...[1,2,3,4,5,6].map(i=>["Terrain/Resources/Gold/Gold Stones/Gold Stone "+i+".png","gold/gold"+i+".png"])
];
const png=Buffer.from("89504e470d0a1a0a","hex");
let zip;
try { zip=new AdmZip(source); }
catch (e) { console.error("ZIP invalido:",e.message); process.exit(1); }
const entries=zip.getEntries().filter(entry=>!entry.isDirectory);
const collected=[];
for (const [suffix,destination] of mapping) {
  const name="Tiny Swords (Free Pack)/"+suffix;
  const entry=entries.find(e=>e.entryName.replaceAll("\\","/")===name);
  if (!entry) {
    console.error("Nao encontrado no ZIP:",name);
    process.exit(1);
  }
  const data=entry.getData();
  if (data.length<64 || data.length>20*1024*1024
    || !data.subarray(0,8).equals(png)) {
    console.error("PNG invalido:",name);
    process.exit(1);
  }
  collected.push({destination,data});
}
const root=path.resolve("assets/third_party/tiny_swords");
for (const item of collected) {
  const out=path.join(root,item.destination);
  fs.mkdirSync(path.dirname(out),{recursive:true});
  fs.writeFileSync(out,item.data);
}
const manifest={
  pack:"Tiny Swords Free Pack",
  author:"Pixel Frog",
  website:"https://pixelfrog-assets.itch.io/tiny-swords",
  includedAssets:collected.map(x=>x.destination),
  notice:"Local installation only. Do not commit or redistribute these files."
};
fs.writeFileSync(path.join(root,"LOCAL_ASSETS.json"),JSON.stringify(manifest,null,2)+"\n");
console.log("[OK] "+collected.length+" PNGs instalados em "+root);
console.log("[OK] Abra INICIAR-TOONROYALE.bat; nao envie a pasta ao GitHub.");

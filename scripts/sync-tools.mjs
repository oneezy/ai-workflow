import { access, copyFile, mkdir } from "node:fs/promises";
import path from "node:path";

const siteRoot = process.cwd();
const canonical = path.resolve(siteRoot, "../tools.csv");
const publicDir = path.resolve(siteRoot, "public");
const publicCopy = path.join(publicDir, "tools.csv");

await mkdir(publicDir, { recursive: true });

try {
  await access(canonical);
  await copyFile(canonical, publicCopy);
  console.log("Synced canonical tools.csv");
} catch {
  await access(publicCopy);
  console.log("Using the packaged tools.csv snapshot");
}

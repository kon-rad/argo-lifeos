// Validates every line of an NDJSON file against the event schema.
// Usage: node scripts/validate-ndjson.mjs <schema.json> <file.ndjson>
import { readFileSync } from "node:fs";
import Ajv2020 from "ajv/dist/2020.js";
import addFormats from "ajv-formats";

const [schemaPath, dataPath] = process.argv.slice(2);
const ajv = new Ajv2020({ allErrors: true, strict: true });
addFormats(ajv);
const validate = ajv.compile(JSON.parse(readFileSync(schemaPath, "utf8")));

let failed = 0;
readFileSync(dataPath, "utf8").split("\n").forEach((line, i) => {
  if (!line.trim()) return;
  if (!validate(JSON.parse(line))) {
    failed++;
    console.error(`line ${i + 1}:`, JSON.stringify(validate.errors));
  }
});
if (failed) process.exit(1);
console.log("ok");

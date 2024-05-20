#!/usr/bin/env -S deno run --allow-all

// read results_amd.json and results_intel.json
const amd = JSON.parse(await Deno.readTextFile("results_amd.json"));
const intel = JSON.parse(await Deno.readTextFile("results_intel.json"));
const graviton = JSON.parse(await Deno.readTextFile("results_graviton.json"));

// for each entry in each, add instance c7a or c7i and time 2024-05-15T12:00:00Z
for (const entry of amd) {
  entry.instance = "c7a.xlarge";
  entry.time = "2024-05-15T12:00:00Z";
}
for (const entry of intel) {
  entry.instance = "c7i.xlarge";
  entry.time = "2024-05-15T12:00:00Z";
}

// write the results to the same files
await Deno.writeTextFile("results_amd.json", JSON.stringify(amd, null, 2));
await Deno.writeTextFile("results_intel.json", JSON.stringify(intel, null, 2));
await Deno.writeTextFile(
  "results.json",
  JSON.stringify([...amd, ...intel, ...graviton], null, 2),
);

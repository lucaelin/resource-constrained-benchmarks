#!/usr/bin/env -S deno run --allow-all

import { walk } from "https://deno.land/std/fs/mod.ts";

const files: {
  cores: number;
  memory: number;
  experiment: string;
  results: { metric: string; run: number; sample: number; value: string }[];
}[] = [];

for await (const entry of walk(new URL("../", import.meta.url).pathname)) {
  if (entry.isFile) {
    const match = entry.path.match(/([\d\. ]+)Core - ([\d\. ]+)MB\/(.+)\.txt/);
    if (match) {
      const content = await Deno.readTextFile(entry.path);
      files.push({
        cores: parseFloat(match[1]),
        memory: parseFloat(match[2]),
        experiment: match[3],
        results: content.split("\n").map((line) => {
          const [metric, run, sample, value] = line.split(" - ");
          return {
            metric,
            run: parseInt(run),
            sample: parseInt(sample),
            value,
          };
        }),
      });
    }
  }
}

const stats: {
  cores: number;
  memory: number;
  experiment: string;
  results: {
    crashes: { mean: number; deviation: number; samples: number };
    build: { mean: number; deviation: number; samples: number };
    startup: { mean: number; deviation: number; samples: number };
    firstRequest: { mean: number; deviation: number; samples: number };
    requests100: { mean: number; deviation: number; samples: number }[];
    throughput:
      ({ mean: number; deviation: number; samples: number } | undefined)[];
    memoryStartup: { mean: number; deviation: number; samples: number };
    memoryLoad: { mean: number; deviation: number; samples: number };
  };
}[] = [];

function meanAndDev(
  values: number[],
): { mean: number; deviation: number; samples: number } | undefined {
  if (values.length === 0) return undefined;
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const deviation = Math.sqrt(
    values.reduce((a, b) => a + (b - mean) ** 2, 0) / values.length,
  );
  const samples = values.length;
  return { mean, deviation, samples };
}

for (const file of files) {
  const build = file.results.filter((r) => r.metric === "compose build");
  const startup = file.results.filter((r) => r.metric === "service up");
  const requests100 = file.results.filter((r) => r.metric === "warmup request");
  const firstRequest = requests100.filter((r) => r.sample === 1);
  const throughput = file.results.filter((r) => r.metric === "throughput");
  const memoryStartup = file.results.filter((r) =>
    r.metric === "memory" && r.sample === 1
  );
  const memoryLoad = file.results.filter((r) =>
    r.metric === "memory" && r.sample === 2
  );

  stats.push({
    cores: file.cores,
    memory: file.memory,
    experiment: file.experiment,
    results: {
      crashes: {
        mean: memoryLoad.length -
          memoryLoad.filter((r) => r.value.match(/.* ([\d\.]+)MiB \/ .*/)?.[1])
            .length,
        deviation: 0,
        samples: memoryLoad.length,
      },
      build: meanAndDev(build.map((r) => parseFloat(r.value)))!,
      startup: meanAndDev(startup.map((r) => parseFloat(r.value)))!,

      firstRequest: meanAndDev(firstRequest.map((r) => parseFloat(r.value)))!,
      requests100: Array(100).fill(0).map((_, i) => {
        return meanAndDev(
          requests100.filter((r) => r.sample === i + 1).map((r) =>
            parseFloat(r.value)
          ),
        )!;
      }),

      throughput: Array(100).fill(0).map((_, i) => {
        return meanAndDev(
          throughput.filter((r) => r.sample === i + 1).map((r) =>
            parseFloat(r.value)
          ),
        );
      }),

      memoryStartup: meanAndDev(
        memoryStartup.map((r) =>
          parseFloat(r.value.match(/.* ([\d\.]+)MiB \/ .*/)?.[1] ?? "")
        ),
      )!,
      memoryLoad: meanAndDev(
        memoryLoad.map((r) =>
          parseFloat(r.value.match(/.* ([\d\.]+)MiB \/ .*/)?.[1] ?? "")
        ),
      )!,
    },
  });
}

// write stats to results.json
await Deno.writeTextFile(
  new URL("./results.json", import.meta.url).pathname,
  JSON.stringify(
    stats.sort((a, b) => {
      if (a.experiment === b.experiment) {
        if (a.cores === b.cores) {
          return a.memory - b.memory;
        }
        return a.cores - b.cores;
      }
      return a.experiment.localeCompare(b.experiment);
    }),
    null,
    2,
  ),
);
console.log(stats);

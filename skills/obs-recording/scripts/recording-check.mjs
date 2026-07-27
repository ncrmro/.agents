#!/usr/bin/env node

import { existsSync } from "node:fs";
import { dirname, extname, join, resolve } from "node:path";
import { spawnSync } from "node:child_process";

function fail(message, code = 1) {
  console.error(`recording-check: ${message}`);
  process.exit(code);
}

function optionValue(args, name) {
  const index = args.indexOf(name);
  if (index === -1) return null;
  if (!args[index + 1] || args[index + 1].startsWith("--")) {
    fail(`${name} requires a value`, 2);
  }
  return args[index + 1];
}

function positionalArguments(args) {
  const optionsWithValues = new Set([
    "--audio-stream",
    "--diarize",
    "--model",
    "--output-base",
  ]);
  const positional = [];
  for (let index = 0; index < args.length; index += 1) {
    const argument = args[index];
    if (optionsWithValues.has(argument)) {
      index += 1;
    } else if (!argument.startsWith("--")) {
      positional.push(argument);
    }
  }
  return positional;
}

function run(command, args) {
  const result = spawnSync(command, args, {
    encoding: "utf8",
    maxBuffer: 16 * 1024 * 1024,
  });
  if (result.error?.code === "ENOENT") {
    fail(`${command} is not available on PATH`, 2);
  }
  if (result.error) {
    fail(`${command} failed: ${result.error.message}`);
  }
  if (result.status !== 0) {
    fail(
      `${command} exited ${result.status}: ${(result.stderr || result.stdout).trim()}`,
    );
  }
  return result;
}

function lastNumber(text, pattern) {
  const matches = [...text.matchAll(pattern)];
  if (matches.length === 0) return null;
  const value = matches.at(-1)[1];
  if (value === "-inf") return Number.NEGATIVE_INFINITY;
  return Number(value);
}

function silenceEvents(text) {
  const events = [];
  for (const match of text.matchAll(/silence_start:\s*([\d.]+)/g)) {
    events.push({ type: "start", seconds: Number(match[1]) });
  }
  for (const match of text.matchAll(
    /silence_end:\s*([\d.]+)\s*\|\s*silence_duration:\s*([\d.]+)/g,
  )) {
    events.push({
      type: "end",
      seconds: Number(match[1]),
      durationSeconds: Number(match[2]),
    });
  }
  return events.sort((left, right) => left.seconds - right.seconds);
}

function audioFindings(metrics) {
  const findings = [];
  if (
    metrics.maxDbfs === Number.NEGATIVE_INFINITY ||
    metrics.integratedLufs === Number.NEGATIVE_INFINITY
  ) {
    findings.push({
      level: "error",
      code: "audio-silent",
      message: "No measurable audio signal was detected.",
    });
    return findings;
  }
  if (metrics.truePeakDbfs !== null && metrics.truePeakDbfs >= -1) {
    findings.push({
      level: "warning",
      code: "audio-clipping-risk",
      message: `True peak is ${metrics.truePeakDbfs.toFixed(1)} dBFS; keep peaks below -1 dBFS.`,
    });
  }
  if (
    (metrics.maxDbfs !== null && metrics.maxDbfs < -18) ||
    (metrics.integratedLufs !== null && metrics.integratedLufs < -30)
  ) {
    findings.push({
      level: "warning",
      code: "audio-quiet",
      message: `Peak ${metrics.maxDbfs.toFixed(1)} dBFS and integrated ${metrics.integratedLufs.toFixed(1)} LUFS are low for spoken audio.`,
    });
  }
  return findings;
}

function inspectAudio(inputFile, stream) {
  const streamMap = `0:${stream.index}`;
  const volume = run("ffmpeg", [
    "-hide_banner",
    "-nostats",
    "-i",
    inputFile,
    "-map",
    streamMap,
    "-af",
    "volumedetect",
    "-f",
    "null",
    "-",
  ]).stderr;
  const loudness = run("ffmpeg", [
    "-hide_banner",
    "-nostats",
    "-i",
    inputFile,
    "-map",
    streamMap,
    "-af",
    "ebur128=peak=true",
    "-f",
    "null",
    "-",
  ]).stderr;
  const silence = run("ffmpeg", [
    "-hide_banner",
    "-nostats",
    "-i",
    inputFile,
    "-map",
    streamMap,
    "-af",
    "silencedetect=noise=-50dB:d=0.2",
    "-f",
    "null",
    "-",
  ]).stderr;

  const metrics = {
    meanDbfs: lastNumber(volume, /mean_volume:\s*(-inf|-?[\d.]+) dB/g),
    maxDbfs: lastNumber(volume, /max_volume:\s*(-inf|-?[\d.]+) dB/g),
    integratedLufs: lastNumber(
      loudness,
      /\bI:\s*(-inf|-?[\d.]+) LUFS/g,
    ),
    loudnessRangeLu: lastNumber(loudness, /\bLRA:\s*([\d.]+) LU/g),
    truePeakDbfs: lastNumber(loudness, /\bPeak:\s*(-inf|-?[\d.]+) dBFS/g),
    silenceEvents: silenceEvents(silence),
  };

  return {
    index: stream.index,
    title: stream.tags?.title || null,
    codec: stream.codec_name,
    channels: stream.channels,
    channelLayout: stream.channel_layout || null,
    sampleRate: Number(stream.sample_rate),
    metrics,
    findings: audioFindings(metrics),
  };
}

function transcribeShared(inputFile, audioStream, outputBase, args) {
  const command =
    process.env.OBS_TRANSCRIBE_COMMAND ||
    join(dirname(resolve(process.argv[1])), "transcribe-recording.sh");
  const commandArgs = [
    inputFile,
    "--audio-stream",
    String(audioStream.index),
    "--output-base",
    outputBase,
    "--diarize",
    optionValue(args, "--diarize") || "auto",
    "--json",
  ];
  const model = optionValue(args, "--model");
  if (model) commandArgs.push("--model", model);
  if (args.includes("--require-gpu")) commandArgs.push("--require-gpu");
  if (args.includes("--install")) commandArgs.push("--install");
  const result = run(command, commandArgs);
  try {
    return JSON.parse(result.stdout);
  } catch {
    fail(`shared transcriber returned invalid JSON: ${result.stdout.trim()}`);
  }
}

function usage() {
  console.log(`Usage: recording-check.mjs FILE [options]

Inspect without modifying the recording:
  recording-check.mjs FILE

Create TXT, SRT, and JSON transcripts alongside the recording:
  recording-check.mjs FILE --transcribe

Options:
  --audio-stream INDEX  Analyze/transcribe one audio stream instead of all
  --transcribe          Run the shared GPU-first transcriber after validation
  --model FILE          Select a local ggml Whisper model
  --output-base PATH    Transcript path without an extension
  --diarize POLICY      auto, always, or never (default: auto)
  --require-gpu         Refuse a required CPU transcription stage
  --install             Explicitly install missing tools on Nix
  --help                Show this help

The command never normalizes or rewrites the input media and refuses to
overwrite existing transcript files.`);
}

const args = process.argv.slice(2);
if (args.length === 0 || args.includes("--help") || args.includes("-h")) {
  usage();
  process.exit(args.length === 0 ? 2 : 0);
}

const positional = positionalArguments(args);
if (positional.length !== 1) fail("exactly one media file is required", 2);
const inputArgument = positional[0];
const inputFile = resolve(inputArgument);
if (!existsSync(inputFile)) fail(`file does not exist: ${inputFile}`, 2);

const probe = JSON.parse(
  run("ffprobe", [
    "-v",
    "error",
    "-show_format",
    "-show_streams",
    "-of",
    "json",
    inputFile,
  ]).stdout,
);
const allAudioStreams = probe.streams.filter(
  (stream) => stream.codec_type === "audio",
);
if (allAudioStreams.length === 0) fail("recording has no audio streams");

const requestedStream = optionValue(args, "--audio-stream");
const selectedAudioStreams =
  requestedStream === null
    ? allAudioStreams
    : allAudioStreams.filter(
        (stream) => stream.index === Number(requestedStream),
      );
if (selectedAudioStreams.length === 0) {
  fail(`audio stream ${requestedStream} was not found`, 2);
}

const report = {
  file: inputFile,
  format: {
    name: probe.format.format_name,
    durationSeconds: Number(probe.format.duration),
    sizeBytes: Number(probe.format.size),
  },
  videoStreams: probe.streams
    .filter((stream) => stream.codec_type === "video")
    .map((stream) => ({
      index: stream.index,
      codec: stream.codec_name,
      width: stream.width,
      height: stream.height,
      frameRate: stream.avg_frame_rate,
    })),
  audioStreams: selectedAudioStreams.map((stream) =>
    inspectAudio(inputFile, stream),
  ),
};

if (args.includes("--transcribe")) {
  if (selectedAudioStreams.length !== 1) {
    fail(
      "select exactly one audio stream with --audio-stream before transcribing",
      2,
    );
  }
  const inputExtension = extname(inputFile);
  const defaultOutputBase = inputExtension
    ? inputFile.slice(0, -inputExtension.length)
    : inputFile;
  report.transcript = transcribeShared(
    inputFile,
    selectedAudioStreams[0],
    resolve(optionValue(args, "--output-base") || defaultOutputBase),
    args,
  );
}

console.log(JSON.stringify(report, null, 2));

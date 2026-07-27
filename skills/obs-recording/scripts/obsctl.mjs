#!/usr/bin/env node

import {
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  statfsSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { dirname, extname, join, resolve } from "node:path";
import { homedir } from "node:os";
import { createHash, randomUUID } from "node:crypto";

const DEFAULT_CONFIG_DIR =
  process.env.OBS_CONFIG_DIR || join(homedir(), ".config", "obs-studio");
const DEFAULT_MIN_FREE_GIB = Number(process.env.OBS_MIN_FREE_GIB || 20);
const INPUT_VOLUME_METERS_SUBSCRIPTION = 1 << 16;
const READ_ONLY_REQUESTS = new Set([
  "GetVersion",
  "GetStats",
  "GetHotkeyList",
  "GetProfileList",
  "GetCurrentProfile",
  "GetProfileParameter",
  "GetSceneCollectionList",
  "GetCurrentSceneCollection",
  "GetVideoSettings",
  "GetRecordDirectory",
  "GetRecordStatus",
  "GetStreamStatus",
  "GetVirtualCamStatus",
  "GetReplayBufferStatus",
  "GetSceneList",
  "GetCurrentProgramScene",
  "GetCurrentPreviewScene",
  "GetSceneItemList",
  "GetGroupSceneItemList",
  "GetSceneItemEnabled",
  "GetSceneItemLocked",
  "GetSceneItemTransform",
  "GetInputList",
  "GetInputKindList",
  "GetSpecialInputs",
  "GetInputSettings",
  "GetInputMute",
  "GetInputVolume",
  "GetInputAudioBalance",
  "GetInputAudioSyncOffset",
  "GetInputAudioMonitorType",
  "GetInputAudioTracks",
  "GetSourceActive",
  "GetSourceScreenshot",
  "GetSourceFilterKindList",
  "GetSourceFilterList",
  "GetSourceFilterDefaultSettings",
  "GetSourceFilter",
  "GetOutputList",
  "GetOutputStatus",
  "GetOutputSettings",
  "GetTransitionKindList",
  "GetSceneTransitionList",
  "GetCurrentSceneTransition",
]);

function fail(message, code = 1) {
  console.error(`obsctl: ${message}`);
  process.exit(code);
}

function sha256Base64(value) {
  return createHash("sha256").update(value).digest("base64");
}

function expandHome(value) {
  if (value === "~") return homedir();
  if (value.startsWith("~/")) return join(homedir(), value.slice(2));
  return value;
}

function parseJson(value, label) {
  try {
    return JSON.parse(value);
  } catch (error) {
    throw new Error(`${label} is not valid JSON: ${error.message}`);
  }
}

function loadWebSocketConfig() {
  const configFile =
    process.env.OBS_WEBSOCKET_CONFIG ||
    join(DEFAULT_CONFIG_DIR, "plugin_config", "obs-websocket", "config.json");
  let config = {};
  if (existsSync(configFile)) {
    config = parseJson(readFileSync(configFile, "utf8"), configFile);
  }

  const port = Number(config.server_port || 4455);
  return {
    configFile,
    configExists: existsSync(configFile),
    serverEnabled: config.server_enabled ?? null,
    authRequired: config.auth_required ?? null,
    url: process.env.OBS_WEBSOCKET_URL || `ws://127.0.0.1:${port}`,
    password:
      process.env.OBS_WEBSOCKET_PASSWORD || config.server_password || "",
  };
}

class ObsWebSocketClient {
  constructor({ url, password, timeoutMs = 10_000, eventSubscriptions = 0 }) {
    this.url = url;
    this.password = password;
    this.timeoutMs = timeoutMs;
    this.eventSubscriptions = eventSubscriptions;
    this.socket = null;
    this.pending = new Map();
    this.eventHandlers = new Set();
  }

  async connect() {
    if (typeof WebSocket === "undefined") {
      throw new Error(
        "Node.js with the built-in WebSocket client is required (Node 22+)",
      );
    }

    await new Promise((resolveConnect, rejectConnect) => {
      let connected = false;
      const timer = setTimeout(
        () => rejectConnect(new Error(`connection timed out: ${this.url}`)),
        this.timeoutMs,
      );
      const socket = new WebSocket(this.url);
      this.socket = socket;

      socket.onerror = () => {
        clearTimeout(timer);
        rejectConnect(new Error(`cannot connect to ${this.url}`));
      };
      socket.onclose = () => {
        if (!connected) {
          clearTimeout(timer);
          rejectConnect(
            new Error(`connection closed before authentication: ${this.url}`),
          );
        }
        for (const { reject, timer: requestTimer } of this.pending.values()) {
          clearTimeout(requestTimer);
          reject(new Error("OBS WebSocket connection closed"));
        }
        this.pending.clear();
      };
      socket.onmessage = (event) => {
        const message = parseJson(String(event.data), "OBS WebSocket message");

        if (message.op === 0) {
          const identify = {
            rpcVersion: 1,
            eventSubscriptions: this.eventSubscriptions,
          };
          if (message.d.authentication) {
            if (!this.password) {
              clearTimeout(timer);
              rejectConnect(
                new Error(
                  "OBS requires authentication but no password was provided",
                ),
              );
              socket.close();
              return;
            }
            const { salt, challenge } = message.d.authentication;
            const secret = sha256Base64(this.password + salt);
            identify.authentication = sha256Base64(secret + challenge);
          }
          socket.send(JSON.stringify({ op: 1, d: identify }));
          return;
        }

        if (message.op === 2) {
          connected = true;
          clearTimeout(timer);
          resolveConnect();
          return;
        }

        if (message.op === 5) {
          for (const handler of this.eventHandlers) {
            try {
              handler(message.d);
            } catch {
              // A diagnostic event handler must not break request processing.
            }
          }
          return;
        }

        if (message.op === 7) {
          const waiter = this.pending.get(message.d.requestId);
          if (!waiter) return;
          clearTimeout(waiter.timer);
          this.pending.delete(message.d.requestId);
          if (message.d.requestStatus.result) {
            waiter.resolve(message.d.responseData || {});
          } else {
            waiter.reject(
              new Error(
                `${message.d.requestType} failed (${message.d.requestStatus.code})${
                  message.d.requestStatus.comment
                    ? `: ${message.d.requestStatus.comment}`
                    : ""
                }`,
              ),
            );
          }
        }
      };
    });
  }

  call(requestType, requestData) {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
      return Promise.reject(new Error("OBS WebSocket is not connected"));
    }

    return new Promise((resolveCall, rejectCall) => {
      const requestId = randomUUID();
      const timer = setTimeout(() => {
        this.pending.delete(requestId);
        rejectCall(new Error(`${requestType} timed out`));
      }, this.timeoutMs);
      this.pending.set(requestId, {
        resolve: resolveCall,
        reject: rejectCall,
        timer,
      });
      this.socket.send(
        JSON.stringify({
          op: 6,
          d: {
            requestType,
            requestId,
            ...(requestData ? { requestData } : {}),
          },
        }),
      );
    });
  }

  onEvent(handler) {
    this.eventHandlers.add(handler);
    return () => this.eventHandlers.delete(handler);
  }

  close() {
    this.socket?.close();
  }
}

async function withClient(operation, clientOptions = {}) {
  const websocket = loadWebSocketConfig();
  const client = new ObsWebSocketClient({ ...websocket, ...clientOptions });
  await client.connect();
  try {
    return await operation(client, websocket);
  } finally {
    client.close();
  }
}

async function safeCall(client, requestType, requestData) {
  try {
    return await client.call(requestType, requestData);
  } catch (error) {
    return { error: error.message };
  }
}

async function getAudioState(client, inputs) {
  const audio = [];
  for (const input of inputs) {
    const request = { inputName: input.inputName };
    const mute = await safeCall(client, "GetInputMute", request);
    const volume = await safeCall(client, "GetInputVolume", request);
    if (!mute.error || !volume.error) {
      audio.push({
        inputName: input.inputName,
        inputKind: input.inputKind,
        inputMuted: mute.inputMuted ?? null,
        inputVolumeDb: volume.inputVolumeDb ?? null,
        inputVolumeMul: volume.inputVolumeMul ?? null,
      });
    }
  }
  return audio;
}

function mulToDb(value) {
  if (!Number.isFinite(value) || value <= 0) return -100;
  return Math.max(-100, 20 * Math.log10(value));
}

async function collectAudioMeters(client, durationSeconds, thresholdDb) {
  const inputs = (await client.call("GetInputList")).inputs || [];
  const audio = await getAudioState(client, inputs);
  const aggregates = new Map();
  let eventCount = 0;

  const unsubscribe = client.onEvent((event) => {
    if (event.eventType !== "InputVolumeMeters") return;
    eventCount += 1;
    for (const input of event.eventData?.inputs || []) {
      const levels = Array.isArray(input.inputLevelsMul)
        ? input.inputLevelsMul
        : [];
      const aggregate = aggregates.get(input.inputName) || {
        inputName: input.inputName,
        inputUuid: input.inputUuid || null,
        sampleCount: 0,
        channelCount: 0,
        maxMagnitudeMul: 0,
        maxPeakMul: 0,
        maxRawPeakMul: 0,
        peakSamples: [],
        rawPeakSamples: [],
      };
      aggregate.sampleCount += 1;
      aggregate.channelCount = Math.max(aggregate.channelCount, levels.length);
      let eventPeakMul = 0;
      let eventRawPeakMul = 0;
      for (const channel of levels) {
        if (!Array.isArray(channel)) continue;
        aggregate.maxMagnitudeMul = Math.max(
          aggregate.maxMagnitudeMul,
          Number(channel[0]) || 0,
        );
        aggregate.maxPeakMul = Math.max(
          aggregate.maxPeakMul,
          Number(channel[1]) || 0,
        );
        eventPeakMul = Math.max(eventPeakMul, Number(channel[1]) || 0);
        aggregate.maxRawPeakMul = Math.max(
          aggregate.maxRawPeakMul,
          Number(channel[2]) || 0,
        );
        eventRawPeakMul = Math.max(
          eventRawPeakMul,
          Number(channel[2]) || 0,
        );
      }
      aggregate.peakSamples.push(eventPeakMul);
      aggregate.rawPeakSamples.push(eventRawPeakMul);
      aggregates.set(input.inputName, aggregate);
    }
  });

  await new Promise((resolveWait) =>
    setTimeout(resolveWait, durationSeconds * 1000),
  );
  unsubscribe();

  const thresholdMul = 10 ** (thresholdDb / 20);
  const percentile = (values, fraction) => {
    if (values.length === 0) return 0;
    const sorted = [...values].sort((a, b) => a - b);
    return sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * fraction))];
  };
  const knownInputs = new Map(audio.map((input) => [input.inputName, input]));
  const names = new Set([...knownInputs.keys(), ...aggregates.keys()]);
  const results = [...names]
    .sort((a, b) => a.localeCompare(b))
    .map((inputName) => {
      const input = knownInputs.get(inputName) || {
        inputName,
        inputKind: null,
        inputMuted: null,
        inputVolumeDb: null,
        inputVolumeMul: null,
      };
      const aggregate = aggregates.get(inputName) || {
        sampleCount: 0,
        channelCount: 0,
        maxMagnitudeMul: 0,
        maxPeakMul: 0,
        maxRawPeakMul: 0,
        peakSamples: [],
        rawPeakSamples: [],
      };
      const signalSampleCount = aggregate.peakSamples.filter(
        (value) => value >= thresholdMul,
      ).length;
      const rawSignalSampleCount = aggregate.rawPeakSamples.filter(
        (value) => value >= thresholdMul,
      ).length;
      const minimumSignalSamples = Math.max(
        1,
        Math.ceil(aggregate.sampleCount * 0.05),
      );
      return {
        ...input,
        sampleCount: aggregate.sampleCount,
        channelCount: aggregate.channelCount,
        postFaderMagnitudeDb: mulToDb(aggregate.maxMagnitudeMul),
        postFaderPeakDb: mulToDb(aggregate.maxPeakMul),
        postFaderP95PeakDb: mulToDb(
          percentile(aggregate.peakSamples, 0.95),
        ),
        rawPeakDb: mulToDb(aggregate.maxRawPeakMul),
        rawP95PeakDb: mulToDb(
          percentile(aggregate.rawPeakSamples, 0.95),
        ),
        signalSampleCount,
        signalFraction:
          aggregate.sampleCount > 0
            ? signalSampleCount / aggregate.sampleCount
            : 0,
        rawSignalSampleCount,
        rawSignalFraction:
          aggregate.sampleCount > 0
            ? rawSignalSampleCount / aggregate.sampleCount
            : 0,
        signalDetected: signalSampleCount >= minimumSignalSamples,
        rawSignalDetected: rawSignalSampleCount >= minimumSignalSamples,
        peakExceededZeroDb: aggregate.maxPeakMul >= 1,
      };
    });

  return {
    capturedAt: new Date().toISOString(),
    durationSeconds,
    thresholdDb,
    eventCount,
    inputs: results,
  };
}

async function getStatus(client, requestedSceneName) {
  const version = await client.call("GetVersion");
  const stats = await client.call("GetStats");
  const recording = await client.call("GetRecordStatus");
  const recordDirectory = await client.call("GetRecordDirectory");
  const video = await safeCall(client, "GetVideoSettings");
  const scenes = await client.call("GetSceneList");
  const inputsResponse = await client.call("GetInputList");
  const sceneName = requestedSceneName || scenes.currentProgramSceneName;
  const sceneItems = sceneName
    ? await safeCall(client, "GetSceneItemList", { sceneName })
    : { sceneItems: [] };
  const audio = await getAudioState(client, inputsResponse.inputs || []);

  return {
    capturedAt: new Date().toISOString(),
    version: {
      obsVersion: version.obsVersion,
      obsWebSocketVersion: version.obsWebSocketVersion,
      rpcVersion: version.rpcVersion,
      platform: version.platform,
      platformDescription: version.platformDescription,
    },
    stats,
    recording,
    recordDirectory: recordDirectory.recordDirectory,
    video: video.error ? { error: video.error } : video,
    currentProgramSceneName: scenes.currentProgramSceneName,
    currentPreviewSceneName: scenes.currentPreviewSceneName ?? null,
    scenes: scenes.scenes || [],
    inspectedSceneName: sceneName,
    sceneItems: sceneItems.sceneItems || [],
    sceneItemsError: sceneItems.error || null,
    inputs: inputsResponse.inputs || [],
    audio,
  };
}

function getDiskState(recordDirectory) {
  try {
    const fsStats = statfsSync(expandHome(recordDirectory));
    const totalBytes = Number(fsStats.blocks) * Number(fsStats.bsize);
    const freeBytes = Number(fsStats.bavail) * Number(fsStats.bsize);
    return {
      totalGiB: totalBytes / 1024 ** 3,
      freeGiB: freeBytes / 1024 ** 3,
      freePercent: totalBytes > 0 ? (freeBytes / totalBytes) * 100 : null,
    };
  } catch (error) {
    return { error: error.message };
  }
}

function getLatestLog() {
  const logDirectory = join(DEFAULT_CONFIG_DIR, "logs");
  if (!existsSync(logDirectory)) {
    return { error: `OBS log directory not found: ${logDirectory}` };
  }

  const logs = readdirSync(logDirectory)
    .filter((name) => name.endsWith(".txt"))
    .map((name) => {
      const fullName = join(logDirectory, name);
      return { fullName, mtimeMs: statSync(fullName).mtimeMs };
    })
    .sort((a, b) => b.mtimeMs - a.mtimeMs);
  if (logs.length === 0) return { error: "no OBS logs found" };

  const latest = logs[0];
  const interesting = readFileSync(latest.fullName, "utf8")
    .split(/\r?\n/)
    .filter((line) =>
      /\b(error|failed|warning|critical|overload|skipped frames|audio buffering)\b/i.test(
        line,
      ),
    )
    .slice(-40);
  return {
    file: latest.fullName,
    modifiedAt: new Date(latest.mtimeMs).toISOString(),
    interesting,
  };
}

function isLoopback(urlValue) {
  try {
    const hostname = new URL(urlValue).hostname.replace(/^\[|\]$/g, "");
    return ["127.0.0.1", "localhost", "::1"].includes(hostname);
  } catch {
    return false;
  }
}

function isVideoLike(item) {
  return /capture|camera|screen|window|pipewire|image|browser|media|ffmpeg|vlc|color/i.test(
    `${item.inputKind || ""} ${item.sourceType || ""}`,
  );
}

function visibleSceneItemRect(item) {
  const transform = item.sceneItemTransform;
  if (!transform) return null;
  const scaleX = Math.abs(Number(transform.scaleX) || 0);
  const scaleY = Math.abs(Number(transform.scaleY) || 0);
  const width = Math.max(
    0,
    (Number(transform.width) || 0) -
      (Number(transform.cropLeft || 0) + Number(transform.cropRight || 0)) *
        scaleX,
  );
  const height = Math.max(
    0,
    (Number(transform.height) || 0) -
      (Number(transform.cropTop || 0) + Number(transform.cropBottom || 0)) *
        scaleY,
  );
  const alignment = Number(transform.alignment) || 0;
  const positionX = Number(transform.positionX) || 0;
  const positionY = Number(transform.positionY) || 0;
  const left = alignment & 1
    ? positionX
    : alignment & 2
      ? positionX - width
      : positionX - width / 2;
  const top = alignment & 4
    ? positionY
    : alignment & 8
      ? positionY - height
      : positionY - height / 2;
  return { left, top, right: left + width, bottom: top + height, width, height };
}

function loadManifest(manifestFile) {
  const absolute = resolve(expandHome(manifestFile));
  const manifest = parseJson(readFileSync(absolute, "utf8"), absolute);
  if (manifest.version !== 1) {
    throw new Error(`unsupported manifest version: ${manifest.version}`);
  }
  return { absolute, manifest };
}

function validateManifest(manifest, status, disk) {
  const findings = [];
  const expectedScene = manifest.scene?.name;
  if (
    expectedScene &&
    !status.scenes.some((scene) => scene.sceneName === expectedScene)
  ) {
    findings.push({
      level: "error",
      code: "scene-missing",
      message: `required scene is missing: ${expectedScene}`,
    });
  }
  if (expectedScene && status.inspectedSceneName !== expectedScene) {
    findings.push({
      level: "error",
      code: "wrong-scene-inspected",
      message: `manifest scene was not inspected: ${expectedScene}`,
    });
  }

  for (const source of manifest.sources || []) {
    const actual = status.sceneItems.find(
      (item) => item.sourceName === source.name,
    );
    if (!actual && source.required !== false) {
      findings.push({
        level: "error",
        code: "source-missing",
        message: `required source is missing: ${source.name}`,
      });
      continue;
    }
    if (!actual) continue;
    if (
      Array.isArray(source.kinds) &&
      source.kinds.length > 0 &&
      !source.kinds.includes(actual.inputKind)
    ) {
      findings.push({
        level: "warning",
        code: "source-kind",
        message: `${source.name} has kind ${actual.inputKind}; expected ${source.kinds.join(
          " or ",
        )}`,
      });
    }
    if (source.visible === true && actual.sceneItemEnabled !== true) {
      findings.push({
        level: "error",
        code: "source-hidden",
        message: `required source is hidden: ${source.name}`,
      });
    }
  }

  for (const expected of manifest.audioInputs || []) {
    const actual = status.audio.find(
      (input) => input.inputName === expected.name,
    );
    if (!actual && expected.required !== false) {
      findings.push({
        level: "error",
        code: "audio-missing",
        message: `required audio input is missing: ${expected.name}`,
      });
      continue;
    }
    if (
      actual &&
      typeof expected.muted === "boolean" &&
      actual.inputMuted !== expected.muted
    ) {
      findings.push({
        level: "error",
        code: "audio-mute-state",
        message: `${expected.name} muted=${actual.inputMuted}; expected ${expected.muted}`,
      });
    }
    if (
      actual &&
      Number.isFinite(expected.minGainDb) &&
      actual.inputVolumeDb < expected.minGainDb
    ) {
      findings.push({
        level: "error",
        code: "audio-gain",
        message: `${expected.name} gain=${actual.inputVolumeDb} dB; expected at least ${expected.minGainDb} dB`,
      });
    }
  }

  const expectedVideo = manifest.video || {};
  const comparisons = [
    ["baseWidth", status.video.baseWidth],
    ["baseHeight", status.video.baseHeight],
    ["outputWidth", status.video.outputWidth],
    ["outputHeight", status.video.outputHeight],
  ];
  for (const [field, actual] of comparisons) {
    if (expectedVideo[field] && expectedVideo[field] !== actual) {
      findings.push({
        level: "warning",
        code: `video-${field}`,
        message: `${field}=${actual}; expected ${expectedVideo[field]}`,
      });
    }
  }
  if (
    expectedVideo.fps &&
    status.video.fpsNumerator &&
    status.video.fpsDenominator
  ) {
    const actualFps =
      status.video.fpsNumerator / status.video.fpsDenominator;
    if (Math.abs(actualFps - expectedVideo.fps) > 0.01) {
      findings.push({
        level: "warning",
        code: "video-fps",
        message: `fps=${actualFps}; expected ${expectedVideo.fps}`,
      });
    }
  }

  const minFreeGiB =
    manifest.recording?.minFreeGiB ?? DEFAULT_MIN_FREE_GIB;
  if (!disk.error && disk.freeGiB < minFreeGiB) {
    findings.push({
      level: "error",
      code: "disk-free",
      message: `only ${disk.freeGiB.toFixed(
        1,
      )} GiB free; manifest requires ${minFreeGiB} GiB`,
    });
  }
  return findings;
}

async function buildDoctor(client, websocket, manifestFile) {
  let manifestInfo = null;
  if (manifestFile) manifestInfo = loadManifest(manifestFile);
  const requestedSceneName = manifestInfo?.manifest.scene?.name;
  const status = await getStatus(client, requestedSceneName);
  const disk = getDiskState(status.recordDirectory);
  const log = getLatestLog();
  const findings = [];

  if (websocket.serverEnabled === false) {
    findings.push({
      level: "error",
      code: "websocket-disabled",
      message: "obs-websocket is disabled in its local config",
    });
  }
  if (websocket.authRequired === false) {
    findings.push({
      level: "warning",
      code: "authentication-disabled",
      message: "obs-websocket authentication is disabled",
    });
  }
  if (!isLoopback(websocket.url)) {
    findings.push({
      level: "warning",
      code: "non-loopback-client",
      message: `client connects to a non-loopback address: ${websocket.url}`,
    });
  }
  if (!disk.error) {
    if (
      disk.freeGiB < DEFAULT_MIN_FREE_GIB ||
      (disk.freePercent !== null && disk.freePercent < 10)
    ) {
      findings.push({
        level: "warning",
        code: "disk-low",
        message: `${disk.freeGiB.toFixed(1)} GiB (${disk.freePercent.toFixed(
          1,
        )}%) free in the recording filesystem`,
      });
    }
  } else {
    findings.push({
      level: "warning",
      code: "disk-unknown",
      message: `cannot inspect recording filesystem: ${disk.error}`,
    });
  }

  const enabledVideo = status.sceneItems.filter(
    (item) => item.sceneItemEnabled && isVideoLike(item),
  );
  if (enabledVideo.length === 0) {
    findings.push({
      level: "warning",
      code: "no-visible-video",
      message: `no enabled video-like source found in scene ${status.inspectedSceneName}`,
    });
  }
  if (!status.video.error) {
    const canvasWidth = Number(status.video.baseWidth);
    const canvasHeight = Number(status.video.baseHeight);
    for (const item of enabledVideo) {
      const rect = visibleSceneItemRect(item);
      if (!rect || rect.width === 0 || rect.height === 0) continue;
      const completelyOutside =
        rect.right <= 0 ||
        rect.bottom <= 0 ||
        rect.left >= canvasWidth ||
        rect.top >= canvasHeight;
      const clipped =
        rect.left < -1 ||
        rect.top < -1 ||
        rect.right > canvasWidth + 1 ||
        rect.bottom > canvasHeight + 1;
      if (completelyOutside) {
        findings.push({
          level: "warning",
          code: "source-off-canvas",
          message: `${item.sourceName} is enabled but outside the ${canvasWidth}x${canvasHeight} canvas`,
        });
      } else if (clipped) {
        findings.push({
          level: "warning",
          code: "source-clipped",
          message: `${item.sourceName} extends beyond the ${canvasWidth}x${canvasHeight} canvas (${Math.round(
            rect.left,
          )},${Math.round(rect.top)} to ${Math.round(rect.right)},${Math.round(
            rect.bottom,
          )}); verify the program image`,
        });
      }
    }
  }
  if (status.audio.length === 0) {
    findings.push({
      level: "warning",
      code: "no-audio-inputs",
      message: "no audio-capable OBS inputs were found",
    });
  }
  for (const input of status.audio) {
    if (
      input.inputMuted === false &&
      (input.inputVolumeMul === 0 || input.inputVolumeDb <= -90)
    ) {
      findings.push({
        level: "warning",
        code: "audio-zero-gain",
        message: `${input.inputName} is unmuted but its fader gain is ${input.inputVolumeDb} dB`,
      });
    }
  }

  const renderRatio =
    status.stats.renderTotalFrames > 0
      ? status.stats.renderSkippedFrames / status.stats.renderTotalFrames
      : 0;
  const outputRatio =
    status.stats.outputTotalFrames > 0
      ? status.stats.outputSkippedFrames / status.stats.outputTotalFrames
      : 0;
  if (renderRatio > 0.01) {
    findings.push({
      level: "warning",
      code: "render-skips",
      message: `${(renderRatio * 100).toFixed(2)}% of rendered frames skipped`,
    });
  }
  if (outputRatio > 0.01) {
    findings.push({
      level: "warning",
      code: "output-skips",
      message: `${(outputRatio * 100).toFixed(2)}% of output frames skipped`,
    });
  }

  if (manifestInfo) {
    findings.push(...validateManifest(manifestInfo.manifest, status, disk));
  }

  return {
    ok: !findings.some((finding) => finding.level === "error"),
    websocket: {
      url: websocket.url,
      configFile: websocket.configFile,
      configExists: websocket.configExists,
      serverEnabled: websocket.serverEnabled,
      authRequired: websocket.authRequired,
      authenticated: Boolean(websocket.password),
    },
    status,
    disk,
    log,
    manifest: manifestInfo
      ? { file: manifestInfo.absolute, version: manifestInfo.manifest.version }
      : null,
    findings,
  };
}

function formatBytes(value) {
  if (!Number.isFinite(value)) return "unknown";
  const units = ["B", "KiB", "MiB", "GiB", "TiB"];
  let amount = value;
  let index = 0;
  while (amount >= 1024 && index < units.length - 1) {
    amount /= 1024;
    index += 1;
  }
  return `${amount.toFixed(index === 0 ? 0 : 1)} ${units[index]}`;
}

function printStatus(status) {
  const fps =
    status.video.fpsNumerator && status.video.fpsDenominator
      ? status.video.fpsNumerator / status.video.fpsDenominator
      : status.stats.activeFps;
  console.log(
    `OBS ${status.version.obsVersion} · obs-websocket ${status.version.obsWebSocketVersion} · ${status.version.platform}`,
  );
  console.log(
    `Recording: ${
      status.recording.outputActive
        ? status.recording.outputPaused
          ? "paused"
          : "active"
        : "idle"
    } · ${status.recording.outputTimecode} · ${formatBytes(
      status.recording.outputBytes,
    )}`,
  );
  console.log(
    `Scene: ${status.currentProgramSceneName} · inspected: ${status.inspectedSceneName}`,
  );
  if (!status.video.error) {
    console.log(
      `Video: ${status.video.baseWidth}x${status.video.baseHeight} → ${status.video.outputWidth}x${status.video.outputHeight} @ ${Number(
        fps,
      ).toFixed(2)} fps`,
    );
  }
  console.log(`Record directory: ${status.recordDirectory}`);
  console.log(
    `OBS load: ${status.stats.cpuUsage.toFixed(1)}% CPU · ${status.stats.memoryUsage.toFixed(
      1,
    )} MiB`,
  );
  console.log("Sources:");
  for (const item of status.sceneItems) {
    console.log(
      `  ${item.sceneItemEnabled ? "on " : "off"} ${item.sourceName} [${
        item.inputKind || item.sourceType || "unknown"
      }]`,
    );
  }
  console.log("Audio:");
  for (const input of status.audio) {
    const volume =
      input.inputVolumeDb === null
        ? ""
        : ` · ${Number(input.inputVolumeDb).toFixed(1)} dB`;
    console.log(
      `  ${input.inputMuted ? "muted" : "live "} ${input.inputName}${volume}`,
    );
  }
}

function printDoctor(report) {
  printStatus(report.status);
  if (!report.disk.error) {
    console.log(
      `Disk: ${report.disk.freeGiB.toFixed(1)} GiB free (${report.disk.freePercent.toFixed(
        1,
      )}%)`,
    );
  }
  console.log(
    `WebSocket: ${report.websocket.url} · auth ${
      report.websocket.authRequired ? "required" : "not required"
    }`,
  );
  console.log(`Latest log: ${report.log.file || report.log.error}`);
  if (report.findings.length === 0) {
    console.log("Doctor: no findings");
  } else {
    console.log("Findings:");
    for (const finding of report.findings) {
      console.log(
        `  ${finding.level.toUpperCase()} ${finding.code}: ${finding.message}`,
      );
    }
  }
}

async function waitForRecordState(client, expectedActive, expectedPaused) {
  const deadline = Date.now() + 8_000;
  let status = null;
  while (Date.now() < deadline) {
    status = await client.call("GetRecordStatus");
    const activeMatches = status.outputActive === expectedActive;
    const pauseMatches =
      expectedPaused === undefined || status.outputPaused === expectedPaused;
    if (activeMatches && pauseMatches) return status;
    await new Promise((resolveWait) => setTimeout(resolveWait, 200));
  }
  throw new Error(
    `recording did not reach expected state active=${expectedActive}${
      expectedPaused === undefined ? "" : ` paused=${expectedPaused}`
    }`,
  );
}

function hasFlag(args, flag) {
  return args.includes(flag);
}

function optionValue(args, flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  if (!args[index + 1] || args[index + 1].startsWith("--")) {
    fail(`${flag} requires a value`, 2);
  }
  return args[index + 1];
}

function positionalArgs(args) {
  const withValues = new Set([
    "--manifest",
    "--output",
    "--source",
    "--format",
    "--min-free-gib",
    "--seconds",
    "--threshold-db",
  ]);
  const result = [];
  for (let index = 0; index < args.length; index += 1) {
    if (withValues.has(args[index])) {
      index += 1;
    } else if (!args[index].startsWith("--")) {
      result.push(args[index]);
    }
  }
  return result;
}

function printHelp() {
  console.log(`Usage: obsctl.mjs <command> [options]

Read-only:
  doctor [--manifest FILE] [--json]  Inspect config, connection, scene, audio, disk, and logs
  status [--json]                    Show recording and current scene state
  scenes [--json]                    List scenes and identify the current one
  sources [SCENE] [--json]           List sources in a scene
  audio [--json]                     List audio inputs, mute state, and volume
  meters [--seconds N] [--json]      Sample live pre/post-fader audio signal
  logs [--json]                      Show notable lines from the latest OBS log
  request TYPE [JSON] [--json]       Run an allowlisted read-only WebSocket request

Explicit recording actions:
  start [--min-free-gib N] [--force] Start if idle after disk/source preflight
  stop                               Stop if active and return the output path
  pause                              Pause if active and not already paused
  resume                             Resume if paused
  split                              Start a new recording file while recording
  chapter [NAME]                     Add a Hybrid MP4/MOV chapter marker
  screenshot --output FILE [--source NAME] [--format png]

Advanced:
  request TYPE [JSON] --allow-write  Run a mutating or unknown request explicitly

Environment:
  OBS_WEBSOCKET_URL, OBS_WEBSOCKET_PASSWORD, OBS_WEBSOCKET_CONFIG,
  OBS_CONFIG_DIR, OBS_MIN_FREE_GIB

The script never exposes the WebSocket password and intentionally has no toggle
command. Use explicit, state-aware start/stop/pause/resume operations.`);
}

async function main() {
  const rawArgs = process.argv.slice(2);
  const jsonOutput = hasFlag(rawArgs, "--json");
  const positional = positionalArgs(rawArgs);
  const command = positional[0] || "help";

  if (["help", "-h", "--help"].includes(command)) {
    printHelp();
    return;
  }

  if (command === "logs") {
    const log = getLatestLog();
    if (jsonOutput) console.log(JSON.stringify(log, null, 2));
    else {
      console.log(`Latest log: ${log.file || log.error}`);
      for (const line of log.interesting || []) console.log(line);
    }
    return;
  }

  const clientOptions =
    command === "meters"
      ? { eventSubscriptions: INPUT_VOLUME_METERS_SUBSCRIPTION }
      : {};

  await withClient(async (client, websocket) => {
    if (command === "status") {
      const status = await getStatus(client);
      if (jsonOutput) console.log(JSON.stringify(status, null, 2));
      else printStatus(status);
      return;
    }

    if (command === "doctor") {
      const report = await buildDoctor(
        client,
        websocket,
        optionValue(rawArgs, "--manifest"),
      );
      if (jsonOutput) console.log(JSON.stringify(report, null, 2));
      else printDoctor(report);
      if (!report.ok) process.exitCode = 1;
      return;
    }

    if (command === "scenes") {
      const scenes = await client.call("GetSceneList");
      if (jsonOutput) console.log(JSON.stringify(scenes, null, 2));
      else {
        console.log(`Current program scene: ${scenes.currentProgramSceneName}`);
        for (const scene of scenes.scenes || []) {
          console.log(
            `${scene.sceneName === scenes.currentProgramSceneName ? "* " : "  "}${
              scene.sceneName
            }`,
          );
        }
      }
      return;
    }

    if (command === "sources") {
      const sceneName =
        positional[1] ||
        (await client.call("GetCurrentProgramScene")).currentProgramSceneName;
      const response = await client.call("GetSceneItemList", { sceneName });
      if (jsonOutput) {
        console.log(JSON.stringify({ sceneName, ...response }, null, 2));
      } else {
        console.log(`Scene: ${sceneName}`);
        for (const item of response.sceneItems || []) {
          console.log(
            `${item.sceneItemEnabled ? "on " : "off"} ${item.sourceName} [${
              item.inputKind || item.sourceType || "unknown"
            }] id=${item.sceneItemId}`,
          );
        }
      }
      return;
    }

    if (command === "audio") {
      const inputs = (await client.call("GetInputList")).inputs || [];
      const audio = await getAudioState(client, inputs);
      if (jsonOutput) console.log(JSON.stringify(audio, null, 2));
      else {
        for (const input of audio) {
          const volume =
            input.inputVolumeDb === null
              ? ""
              : ` · ${Number(input.inputVolumeDb).toFixed(1)} dB`;
          console.log(
            `${input.inputMuted ? "muted" : "live "} ${input.inputName}${volume} [${
              input.inputKind
            }]`,
          );
        }
      }
      return;
    }

    if (command === "meters") {
      const durationSeconds = Number(
        optionValue(rawArgs, "--seconds") || 3,
      );
      const thresholdDb = Number(
        optionValue(rawArgs, "--threshold-db") || -60,
      );
      if (
        !Number.isFinite(durationSeconds) ||
        durationSeconds < 0.5 ||
        durationSeconds > 30
      ) {
        fail("--seconds must be between 0.5 and 30", 2);
      }
      if (
        !Number.isFinite(thresholdDb) ||
        thresholdDb < -100 ||
        thresholdDb > 0
      ) {
        fail("--threshold-db must be between -100 and 0", 2);
      }
      const report = await collectAudioMeters(
        client,
        durationSeconds,
        thresholdDb,
      );
      if (jsonOutput) {
        console.log(JSON.stringify(report, null, 2));
      } else {
        console.log(
          `Audio meters: ${report.durationSeconds}s · signal threshold ${report.thresholdDb} dB`,
        );
        for (const input of report.inputs) {
          console.log(
            `${input.signalDetected ? "signal" : "quiet "} ${input.inputName} · p95 ${input.postFaderP95PeakDb.toFixed(
              1,
            )} dB · max ${input.postFaderPeakDb.toFixed(1)} dB · raw p95 ${input.rawP95PeakDb.toFixed(
              1,
            )} dB · ${
              input.sampleCount
            } samples`,
          );
        }
      }
      return;
    }

    if (command === "request") {
      const requestType = positional[1];
      if (!requestType) fail("request requires an OBS request type", 2);
      const requestData = positional[2]
        ? parseJson(positional[2], "request data")
        : undefined;
      if (
        !READ_ONLY_REQUESTS.has(requestType) &&
        !hasFlag(rawArgs, "--allow-write")
      ) {
        fail(
          `${requestType} is not in the read-only allowlist; pass --allow-write to run it`,
          2,
        );
      }
      const response = await client.call(requestType, requestData);
      console.log(JSON.stringify(response, null, 2));
      return;
    }

    if (command === "start") {
      const status = await getStatus(client);
      if (status.recording.outputActive) {
        console.log(
          JSON.stringify(
            { changed: false, reason: "already-active", ...status.recording },
            null,
            2,
          ),
        );
        return;
      }
      const disk = getDiskState(status.recordDirectory);
      const minFreeGiB = Number(
        optionValue(rawArgs, "--min-free-gib") || DEFAULT_MIN_FREE_GIB,
      );
      const enabledVideo = status.sceneItems.filter(
        (item) => item.sceneItemEnabled && isVideoLike(item),
      );
      const blockers = [];
      if (!disk.error && disk.freeGiB < minFreeGiB) {
        blockers.push(
          `only ${disk.freeGiB.toFixed(1)} GiB free; require ${minFreeGiB} GiB`,
        );
      }
      if (enabledVideo.length === 0) {
        blockers.push("no enabled video-like source in the current scene");
      }
      if (blockers.length > 0 && !hasFlag(rawArgs, "--force")) {
        fail(`start preflight failed: ${blockers.join("; ")} (use --force to override)`);
      }
      await client.call("StartRecord");
      const recording = await waitForRecordState(client, true, false);
      console.log(
        JSON.stringify(
          {
            changed: true,
            sceneName: status.currentProgramSceneName,
            recordDirectory: status.recordDirectory,
            warnings: blockers,
            ...recording,
          },
          null,
          2,
        ),
      );
      return;
    }

    if (command === "stop") {
      const before = await client.call("GetRecordStatus");
      if (!before.outputActive) {
        console.log(
          JSON.stringify(
            { changed: false, reason: "already-idle", ...before },
            null,
            2,
          ),
        );
        return;
      }
      const stopped = await client.call("StopRecord");
      const recording = await waitForRecordState(client, false);
      const outputPath = stopped.outputPath || null;
      console.log(
        JSON.stringify(
          {
            changed: true,
            outputPath,
            outputExists: outputPath ? existsSync(outputPath) : null,
            ...recording,
          },
          null,
          2,
        ),
      );
      return;
    }

    if (command === "pause" || command === "resume") {
      const before = await client.call("GetRecordStatus");
      if (!before.outputActive) fail("cannot change pause state while idle");
      const shouldPause = command === "pause";
      if (before.outputPaused === shouldPause) {
        console.log(
          JSON.stringify(
            {
              changed: false,
              reason: shouldPause ? "already-paused" : "already-running",
              ...before,
            },
            null,
            2,
          ),
        );
        return;
      }
      await client.call(shouldPause ? "PauseRecord" : "ResumeRecord");
      const recording = await waitForRecordState(client, true, shouldPause);
      console.log(JSON.stringify({ changed: true, ...recording }, null, 2));
      return;
    }

    if (command === "split") {
      const before = await client.call("GetRecordStatus");
      if (!before.outputActive) fail("cannot split while recording is idle");
      await client.call("SplitRecordFile");
      console.log(JSON.stringify({ changed: true, action: "split" }, null, 2));
      return;
    }

    if (command === "chapter") {
      const before = await client.call("GetRecordStatus");
      if (!before.outputActive) fail("cannot add a chapter while recording is idle");
      const chapterName = positional.slice(1).join(" ") || undefined;
      await client.call(
        "CreateRecordChapter",
        chapterName ? { chapterName } : undefined,
      );
      console.log(
        JSON.stringify({ changed: true, action: "chapter", chapterName }, null, 2),
      );
      return;
    }

    if (command === "screenshot") {
      const outputFile = optionValue(rawArgs, "--output");
      if (!outputFile) fail("screenshot requires --output FILE", 2);
      const sourceName =
        optionValue(rawArgs, "--source") ||
        (await client.call("GetCurrentProgramScene")).currentProgramSceneName;
      const imageFormat =
        optionValue(rawArgs, "--format") ||
        extname(outputFile).replace(/^\./, "") ||
        "png";
      const response = await client.call("GetSourceScreenshot", {
        sourceName,
        imageFormat,
      });
      const match = /^data:[^;]+;base64,(.+)$/.exec(response.imageData || "");
      if (!match) fail("OBS returned an unexpected screenshot payload");
      const absoluteOutput = resolve(expandHome(outputFile));
      mkdirSync(dirname(absoluteOutput), { recursive: true });
      writeFileSync(absoluteOutput, Buffer.from(match[1], "base64"), {
        mode: 0o600,
      });
      console.log(
        JSON.stringify(
          {
            changed: true,
            sourceName,
            outputFile: absoluteOutput,
            bytes: statSync(absoluteOutput).size,
          },
          null,
          2,
        ),
      );
      return;
    }

    fail(`unknown command: ${command}`, 2);
  }, clientOptions);
}

main().catch((error) => fail(error.message));

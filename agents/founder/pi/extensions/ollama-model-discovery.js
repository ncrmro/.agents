const DEFAULT_HOST = "http://127.0.0.1:11434";
const DEFAULT_CONTEXT_WINDOW = 131_072;
const DEFAULT_MAX_TOKENS = 16_384;
const REQUEST_TIMEOUT_MS = 5_000;

function normalizeHost(value) {
  let host = value?.trim() || DEFAULT_HOST;
  if (!/^https?:\/\//i.test(host)) {
    host = `http://${host}`;
  }

  return host.replace(/\/+$/, "").replace(/\/(?:api|v1)$/i, "");
}

async function fetchJson(url, options = {}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal,
      headers: {
        accept: "application/json",
        ...options.headers,
      },
    });

    if (!response.ok) {
      throw new Error(`${response.status} ${response.statusText}`);
    }

    return await response.json();
  } finally {
    clearTimeout(timeout);
  }
}

function contextWindowFrom(details) {
  const modelInfo = details?.model_info;
  if (!modelInfo || typeof modelInfo !== "object") {
    return DEFAULT_CONTEXT_WINDOW;
  }

  const contextLengths = Object.entries(modelInfo)
    .filter(([key, value]) => key.endsWith(".context_length") && Number.isFinite(value))
    .map(([, value]) => Number(value));

  return contextLengths.length > 0
    ? Math.max(...contextLengths)
    : DEFAULT_CONTEXT_WINDOW;
}

function modelSupports(details, capability) {
  return Array.isArray(details?.capabilities)
    && details.capabilities.includes(capability);
}

function isReasoningModel(name, details) {
  if (modelSupports(details, "thinking") || modelSupports(details, "reasoning")) {
    return true;
  }

  return /(?:deepseek|gpt-oss|nemotron|qwq|qwen3|reason)/i.test(name);
}

function createModel(tag, details) {
  const id = tag.name || tag.model;
  const contextWindow = contextWindowFrom(details);
  const hasVision = modelSupports(details, "vision");

  return {
    id,
    name: id,
    reasoning: isReasoningModel(id, details),
    input: hasVision ? ["text", "image"] : ["text"],
    contextWindow,
    maxTokens: Math.min(contextWindow, DEFAULT_MAX_TOKENS),
    cost: {
      input: 0,
      output: 0,
      cacheRead: 0,
      cacheWrite: 0,
    },
  };
}

async function modelDetails(host, name) {
  try {
    return await fetchJson(`${host}/api/show`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: name,
        verbose: true,
      }),
    });
  } catch {
    return undefined;
  }
}

async function discoverModels(host) {
  const result = await fetchJson(`${host}/api/tags`);
  const tags = Array.isArray(result?.models) ? result.models : [];

  return await Promise.all(
    tags
      .filter((tag) => typeof (tag.name || tag.model) === "string")
      .map(async (tag) => {
        const name = tag.name || tag.model;
        return createModel(tag, await modelDetails(host, name));
      }),
  );
}

function registerModels(pi, host, models) {
  pi.registerProvider("ollama", {
    baseUrl: `${host}/v1`,
    api: "openai-completions",
    apiKey: "ollama",
    compat: {
      supportsDeveloperRole: false,
      supportsReasoningEffort: false,
    },
    models,
  });
}

function notify(context, message, level = "info") {
  if (context?.ui?.notify) {
    context.ui.notify(message, level);
  }
}

export default async function ollamaModelDiscovery(pi) {
  const host = normalizeHost(process.env.OLLAMA_HOST);

  const refresh = async (context) => {
    try {
      const models = await discoverModels(host);
      if (models.length === 0) {
        throw new Error(`Ollama returned no models from ${host}`);
      }

      registerModels(pi, host, models);
      notify(
        context,
        `Registered ${models.length} Ollama models from ${host}.`,
      );
      return models;
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      notify(context, `Ollama model discovery failed: ${message}`, "warning");
      console.warn(`[ollama-model-discovery] ${message}`);
      return [];
    }
  };

  pi.registerCommand("ollama-refresh", {
    description: "Discover and register models from the configured Ollama host",
    handler: async (_args, context) => {
      await refresh(context);
    },
  });

  await refresh();
}

export {
  createModel,
  discoverModels,
  normalizeHost,
};

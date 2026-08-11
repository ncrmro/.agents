# Narration

Use one provider for each narration render. The helper creates a 48 kHz stereo
PCM WAV at approximately -16 LUFS. The media editor can mix this WAV into the
final video.

## Provider decision

| Provider | Select it when | Data boundary |
| --- | --- | --- |
| Piper | The script must stay local, or the work must run offline. | Piper reads the local script and model. |
| ElevenLabs | The user requests an ElevenLabs voice and approves the service request. | ElevenLabs receives the narration text, voice ID, model ID, and settings. |

Do not silently change the provider. Stop if the selected provider is not
available.

## Narration script

Store the script at `raw/narration.txt`. Put one sentence on each non-empty
line. The Piper path creates one speech take for each line. This prevents Piper
from omitting sentences during a multi-sentence render.

Keep the script free of credentials, private messages, and unrelated project
data. ElevenLabs receives the complete script.

## Piper

Piper is a local neural text-to-speech engine. Install it with Nix:

```bash
nix profile install nixpkgs#piper-tts
```

Download or provide one Piper ONNX voice model and its JSON configuration.
Then run:

```bash
scripts/render-narration.sh \
  --provider piper \
  --script raw/narration.txt \
  --output derived/narration.wav \
  --native-output derived/narration.piper.wav \
  --piper-model /path/to/voice.onnx
```

The helper uses `/path/to/voice.onnx.json` by default. Use `--piper-config`
when the configuration has a different path. Use `--segment-pause` to change
the pause between script lines.

## ElevenLabs

ElevenLabs is an external paid service. On a configured Keystone host, the
helper reads `/run/secrets/elevenlabs-api-key`. The runtime secret file MUST be
readable by the current user. For another host, set `ELEVENLABS_API_KEY_FILE`
or use `--api-key-file`. `ELEVENLABS_API_KEY` takes precedence when it is set.
Do not type the key as a command argument. Set `ELEVENLABS_VOICE_ID`, or pass
the non-secret voice ID with `--voice-id`.

The canonical credential is the `elevenlabs-api-key` field in
`~/repos/ncrmro/ks-config/secrets/shared.yaml`. SOPS encrypts this file. Do not
copy the decrypted value into this skill, a project repository, a manifest, or
shell history. If `/run/secrets/elevenlabs-api-key` is absent, the user MAY
decrypt only that field into a permission-restricted temporary file. The user
MUST complete every YubiKey PIN and touch action. Pass the temporary file with
`--api-key-file`, and remove it after the render.

Before a multi-scene render, query `/v1/user/subscription` and compare
`character_count` with `character_limit`. Stop before generation if the
remaining quota cannot contain the approved script. An HTTP 402 response means
the render did not produce usable narration.

Get user approval for the request. Then run:

```bash
scripts/render-narration.sh \
  --provider elevenlabs \
  --script raw/narration.txt \
  --output derived/narration.wav \
  --native-output derived/narration.elevenlabs.mp3 \
  --voice-id "$ELEVENLABS_VOICE_ID" \
  --confirm-external
```

The default model is `eleven_multilingual_v2`. The default response format is
`mp3_44100_128`. Use `--model-id` or `--output-format` to change them. Use
`--zero-retention` only when the ElevenLabs account supports zero retention.

The helper sends the key through a temporary curl configuration file. It does
not put the key in the process arguments. It removes the temporary file when
the request ends.

Current API references:

- <https://elevenlabs.io/docs/api-reference/text-to-speech/convert>
- <https://elevenlabs.io/docs/api-reference/authentication>
- <https://elevenlabs.io/docs/api-reference/voices/search>
- <https://elevenlabs.io/docs/api-reference/models/list>

## Manifest

Record these fields in `production.yml`:

```yaml
narration:
  provider: elevenlabs
  script: raw/narration.txt
  voice_id: approved-voice-id
  model_id: eleven_multilingual_v2
  native_artifact: derived/narration.elevenlabs.mp3
  output: derived/narration.wav
  external_request: true
  approval: user-approved
```

For Piper, set `external_request: false` and `approval: not-required`. Do not
put an API key in the manifest.

## Validation

1. Use `ffprobe` to check the normalized WAV.
2. Check that the WAV has a 48 kHz stereo audio stream.
3. Transcribe the WAV with `media-editor`.
4. Compare the transcript with `raw/narration.txt`.
5. Mix the WAV into the video.
6. Transcribe the final MP4.
7. Check that the final transcript contains every narration sentence.

The provider tests use local command stubs. They do not call ElevenLabs or use
credits.

#!/usr/bin/env python3
"""Freeze the prompt tree that produced a render.

A prompt file pulls in other files by @-reference, and all of them change
between generations. Without a snapshot you cannot answer "what did we actually
ask for when this image came out wrong" -- the files have moved on.

Usage:
    IMAGESET_ROOT=. ./snapshot-prompt.py <prompt-id>

The image set directory holds prompts/<id>.md plus the fragments those prompts
reference. The script writes out/prompts/<hash>/ with a copy of every file in
the tree and a manifest, then prints the hash. The hash is over the content, so
an unchanged tree reuses its snapshot instead of duplicating it.

Name every render with the hash of the tree that made it. That is what makes a
regression a diff instead of a guess.
"""

import datetime
import hashlib
import json
import os
import re
import shutil
import sys

ROOT = os.path.abspath(os.environ.get("IMAGESET_ROOT", os.getcwd()))
PROMPTS = os.path.join(ROOT, "prompts")
OUT = os.path.join(ROOT, "out", "prompts")

# A reference sits inside the sentence that needs it, so match anywhere on a
# line and not only at the start of one.
REFERENCE = re.compile(r"@([\w./-]+\.md)")


def tree(prompt_id):
    """The prompt file and every file it pulls in, resolved recursively.

    A scene references a subject; the subject references its own components.
    One level of resolution would send the render a subject description without
    the parts that subject names.
    """
    root_file = os.path.join(PROMPTS, f"{prompt_id}.md")
    if not os.path.exists(root_file):
        sys.exit(f"no prompt file for {prompt_id}")

    files, seen = [], set()

    def walk(path, label):
        if path in seen:
            return
        seen.add(path)
        if not os.path.exists(path):
            sys.exit(f"broken reference: {label}")
        files.append((label, path))
        with open(path, encoding="utf-8") as handle:
            text = handle.read()
        for relative in REFERENCE.findall(text):
            child = os.path.normpath(os.path.join(os.path.dirname(path), relative))
            walk(child, os.path.relpath(child, ROOT))

    walk(root_file, os.path.relpath(root_file, ROOT))
    return files


def main(prompt_id):
    files = tree(prompt_id)

    digest = hashlib.sha256()
    for label, path in files:
        digest.update(label.encode())
        with open(path, "rb") as handle:
            digest.update(handle.read())
    short = digest.hexdigest()[:16]

    destination = os.path.join(OUT, short)
    if os.path.exists(destination):
        print(short)  # this exact tree is already frozen
        return

    os.makedirs(destination, exist_ok=True)
    manifest = {
        "prompt": prompt_id,
        "taken": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
        "hash": short,
        "files": [],
    }
    for label, path in files:
        flat = label.replace("/", "__")
        shutil.copy2(path, os.path.join(destination, flat))
        with open(path, "rb") as handle:
            body = handle.read()
        manifest["files"].append({
            "source": label,
            "stored": flat,
            "sha256": hashlib.sha256(body).hexdigest(),
            "bytes": len(body),
        })
    with open(os.path.join(destination, "manifest.json"), "w", encoding="utf-8") as handle:
        json.dump(manifest, handle, indent=2)
    print(short)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])

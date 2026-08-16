#!/usr/bin/env python3
"""Freeze the prompt tree that produced a render, and resolve it to one document.

A prompt file pulls in other files by @-reference, and all of them change
between generations. Without a snapshot you cannot answer "what did we actually
ask for when this image came out wrong" -- the files have moved on.

This script also does the resolving. Do not ask the generating agent to follow
the @ references itself: whether it reads the right files, no files, or every
file in the directory varies by model and by run, and it fails silently in both
directions. Resolve here, pass the text inline, and the tree stops being a
matter of agent judgement.

Usage:
    IMAGESET_ROOT=. ./snapshot-prompt.py <prompt-id>
    IMAGESET_ROOT=. ./snapshot-prompt.py --resolve <prompt-id>
    IMAGESET_ROOT=. ./snapshot-prompt.py --fragments <hash>

The image set directory holds prompts/<id>.md plus the fragments those prompts
reference. The default mode writes out/prompts/<hash>/ with a copy of every file
in the tree, a manifest, and resolved.txt -- the exact bytes to send -- then
prints the hash. The hash is over the content, so an unchanged tree reuses its
snapshot instead of duplicating it.

--resolve prints the resolved document and writes nothing.
--fragments prints the file list of a frozen snapshot, one per line. That
manifest is the only trustworthy record of what a render was built from.

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


def name_of(label):
    """The bare name a file is known by once it is inlined."""
    return os.path.splitext(os.path.basename(label))[0]


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


def resolve(prompt_id):
    """The whole tree as one document, ready to send.

    The referenced files come first, in the order they are reached, and the
    scene prompt comes last, so the instruction nearest the generation is the
    one describing this image.

    Each @path/name.md token is rewritten to the bare name, so a sentence like
    "a fixture per @some-fixture.md bolts to the plate" still reads as a
    sentence once the file it points at is inlined beside it. Each section
    header carries that same bare name, so the sentence and the section agree.
    """
    files = tree(prompt_id)
    ordered = files[1:] + files[:1]   # referenced files first, the prompt last

    sections = []
    for label, path in ordered:
        with open(path, encoding="utf-8") as handle:
            body = handle.read().strip()
        body = REFERENCE.sub(lambda m: name_of(m.group(1)), body)
        sections.append(f"=== {name_of(label)} ===\n\n{body}")
    return "\n\n".join(sections) + "\n"


def fragments(digest):
    """Every file in a frozen snapshot, from its manifest."""
    manifest_path = os.path.join(OUT, digest, "manifest.json")
    if not os.path.exists(manifest_path):
        sys.exit(f"no snapshot {digest}")
    with open(manifest_path, encoding="utf-8") as handle:
        manifest = json.load(handle)
    return [entry["source"] for entry in manifest["files"]]


def freeze(prompt_id):
    files = tree(prompt_id)
    document = resolve(prompt_id)

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

    # The exact bytes the generation receives. Freeze the resolved document as
    # well as its parts: a render is only reproducible from what was sent.
    resolved_path = os.path.join(destination, "resolved.txt")
    with open(resolved_path, "w", encoding="utf-8") as handle:
        handle.write(document)
    manifest["resolved"] = {
        "stored": "resolved.txt",
        "sha256": hashlib.sha256(document.encode()).hexdigest(),
        "bytes": len(document.encode()),
    }

    with open(os.path.join(destination, "manifest.json"), "w", encoding="utf-8") as handle:
        json.dump(manifest, handle, indent=2)
    print(short)


if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) == 2 and args[0] == "--resolve":
        sys.stdout.write(resolve(args[1]))
    elif len(args) == 2 and args[0] == "--fragments":
        for entry in fragments(args[1]):
            print(entry)
    elif len(args) == 1 and not args[0].startswith("-"):
        freeze(args[0])
    else:
        sys.exit(__doc__)

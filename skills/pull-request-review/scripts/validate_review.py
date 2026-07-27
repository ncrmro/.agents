#!/usr/bin/env python3
"""Validate a pull-request review specification against added diff lines."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")
VALID_ACTIONS = {"APPROVE", "COMMENT", "REQUEST_CHANGES"}


def added_lines(patch: str) -> dict[str, set[int]]:
    """Return repository paths mapped to added right-side line numbers."""
    result: dict[str, set[int]] = {}
    current_path: str | None = None
    right_line: int | None = None

    for raw_line in patch.splitlines():
        if raw_line.startswith("+++ b/"):
            current_path = raw_line[6:]
            result.setdefault(current_path, set())
            right_line = None
            continue

        match = HUNK_RE.match(raw_line)
        if match:
            right_line = int(match.group(1))
            continue

        if current_path is None or right_line is None:
            continue
        if raw_line.startswith("\\"):
            continue
        if raw_line.startswith("+"):
            result[current_path].add(right_line)
            right_line += 1
        elif raw_line.startswith("-"):
            continue
        else:
            right_line += 1

    return result


def require_string(value: Any, field: str, errors: list[str]) -> None:
    if not isinstance(value, str) or not value.strip():
        errors.append(f"{field} must be a non-empty string")


def validate(
    review: Any,
    allowed: dict[str, set[int]],
    expected_head: str | None,
) -> list[str]:
    """Return validation errors for one parsed review specification."""
    errors: list[str] = []
    if not isinstance(review, dict):
        return ["review document must be a JSON object"]

    action = review.get("action")
    if action not in VALID_ACTIONS:
        errors.append(f"action must be one of {sorted(VALID_ACTIONS)}")
    require_string(review.get("commit_id"), "commit_id", errors)
    if expected_head and review.get("commit_id") != expected_head:
        errors.append("commit_id does not match --head-sha")
    if action in {"COMMENT", "REQUEST_CHANGES"}:
        require_string(review.get("review"), "review", errors)

    comments = review.get("comments")
    if not isinstance(comments, list):
        return [*errors, "comments must be a JSON array"]

    seen: set[tuple[str, int]] = set()
    for index, comment in enumerate(comments):
        prefix = f"comments[{index}]"
        if not isinstance(comment, dict):
            errors.append(f"{prefix} must be an object")
            continue
        path = comment.get("path")
        line = comment.get("line")
        side = comment.get("side")
        require_string(path, f"{prefix}.path", errors)
        require_string(comment.get("body"), f"{prefix}.body", errors)
        if side != "RIGHT":
            errors.append(f"{prefix}.side must be RIGHT")
        if not isinstance(line, int) or isinstance(line, bool) or line < 1:
            errors.append(f"{prefix}.line must be a positive integer")
            continue
        if not isinstance(path, str):
            continue
        anchor = (path, line)
        if anchor in seen:
            errors.append(f"{prefix} duplicates anchor {path}:{line}")
        seen.add(anchor)
        if path not in allowed:
            errors.append(f"{prefix}.path is not present in the diff: {path}")
        elif line not in allowed[path]:
            errors.append(f"{prefix} is not on an added diff line: {path}:{line}")

    return errors


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--diff", required=True, type=Path)
    parser.add_argument("--review", required=True, type=Path)
    parser.add_argument("--head-sha")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    patch = args.diff.read_text(encoding="utf-8")
    review = json.loads(args.review.read_text(encoding="utf-8"))
    errors = validate(review, added_lines(patch), args.head_sha)
    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        return 1
    print(f"review valid: {len(review['comments'])} inline comment(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

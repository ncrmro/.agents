#!/usr/bin/env -S uv run --script --quiet
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "google-auth>=2.29",
#   "google-auth-oauthlib>=1.2",
#   "google-api-python-client>=2.130",
# ]
# ///
"""Read-only Google Workspace access for agent skills.

Accounts live in ~/.config/google-workspace/<account>/:
  client_secret.json  - OAuth desktop-client secret (from GCP console)
  token.json          - stored user credentials (written by `auth`)

All data commands print JSON to stdout. Errors go to stderr, exit 1.
"""

import argparse
import base64
import json
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

SCOPES = [
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/calendar.readonly",
    "https://www.googleapis.com/auth/contacts.readonly",
]

CONFIG_ROOT = Path.home() / ".config" / "google-workspace"


def die(msg: str) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def account_dir(account: str) -> Path:
    return CONFIG_ROOT / account


def load_creds(account: str):
    from google.auth.transport.requests import Request
    from google.oauth2.credentials import Credentials

    token_path = account_dir(account) / "token.json"
    if not token_path.exists():
        die(f"no token for account '{account}'. Run: gws.py auth {account}")
    creds = Credentials.from_authorized_user_file(str(token_path), SCOPES)
    if creds.expired and creds.refresh_token:
        creds.refresh(Request())
        token_path.write_text(creds.to_json())
    if not creds.valid:
        die(f"credentials for '{account}' are invalid. Run: gws.py auth {account}")
    return creds


def service(account: str, api: str, version: str):
    from googleapiclient.discovery import build

    return build(api, version, credentials=load_creds(account), cache_discovery=False)


def out(data) -> None:
    json.dump(data, sys.stdout, indent=2, ensure_ascii=False)
    print()


# ---------- commands ----------


def cmd_auth(args) -> None:
    from google_auth_oauthlib.flow import InstalledAppFlow

    adir = account_dir(args.account)
    secret = adir / "client_secret.json"
    if not secret.exists():
        die(
            f"missing {secret}. Put the OAuth desktop-client secret there first "
            "(see the google-workspace skill setup reference)."
        )
    flow = InstalledAppFlow.from_client_secrets_file(str(secret), SCOPES)
    # open_browser is off so the flow prints the consent URL instead of trying to
    # launch a GUI browser, which fails on a headless or browserless workstation
    # ("could not locate runnable browser"). Open the printed URL in any browser
    # on THIS machine — the redirect targets localhost, where the local server waits.
    creds = flow.run_local_server(
        port=0,
        open_browser=False,
        authorization_prompt_message="Open this URL in a browser on this machine to authorize:\n\n{url}\n",
    )
    token_path = adir / "token.json"
    token_path.write_text(creds.to_json())
    token_path.chmod(0o600)
    print(f"stored credentials at {token_path}", file=sys.stderr)


def cmd_accounts(_args) -> None:
    accounts = []
    if CONFIG_ROOT.exists():
        for d in sorted(CONFIG_ROOT.iterdir()):
            if d.is_dir():
                accounts.append(
                    {
                        "account": d.name,
                        "has_client_secret": (d / "client_secret.json").exists(),
                        "authenticated": (d / "token.json").exists(),
                    }
                )
    out(accounts)


def _gmail_headers(payload: dict) -> dict:
    wanted = {"from", "to", "cc", "subject", "date", "message-id"}
    return {
        h["name"].lower(): h["value"]
        for h in payload.get("headers", [])
        if h["name"].lower() in wanted
    }


def _gmail_body_text(payload: dict) -> str:
    """Best-effort text/plain extraction from a Gmail message payload."""
    if payload.get("mimeType", "").startswith("text/plain"):
        data = payload.get("body", {}).get("data")
        if data:
            return base64.urlsafe_b64decode(data).decode("utf-8", "replace")
    for part in payload.get("parts", []) or []:
        text = _gmail_body_text(part)
        if text:
            return text
    return ""


def cmd_gmail_list(args) -> None:
    svc = service(args.account, "gmail", "v1")
    resp = (
        svc.users()
        .messages()
        .list(userId="me", q=args.query, maxResults=args.max, labelIds=args.label or None)
        .execute()
    )
    messages = []
    for ref in resp.get("messages", []):
        msg = (
            svc.users()
            .messages()
            .get(userId="me", id=ref["id"], format="metadata")
            .execute()
        )
        messages.append(
            {
                "id": msg["id"],
                "threadId": msg["threadId"],
                "snippet": msg.get("snippet", ""),
                "labels": msg.get("labelIds", []),
                **_gmail_headers(msg.get("payload", {})),
            }
        )
    out(messages)


def cmd_gmail_get(args) -> None:
    svc = service(args.account, "gmail", "v1")
    msg = svc.users().messages().get(userId="me", id=args.id, format="full").execute()
    payload = msg.get("payload", {})
    out(
        {
            "id": msg["id"],
            "threadId": msg["threadId"],
            "labels": msg.get("labelIds", []),
            **_gmail_headers(payload),
            "body": _gmail_body_text(payload),
        }
    )


def cmd_gmail_labels(args) -> None:
    svc = service(args.account, "gmail", "v1")
    labels = svc.users().labels().list(userId="me").execute().get("labels", [])
    out([{"id": l["id"], "name": l["name"], "type": l["type"]} for l in labels])


def cmd_calendar_list(args) -> None:
    svc = service(args.account, "calendar", "v3")
    cals = svc.calendarList().list().execute().get("items", [])
    out(
        [
            {
                "id": c["id"],
                "summary": c.get("summary"),
                "primary": c.get("primary", False),
                "accessRole": c.get("accessRole"),
            }
            for c in cals
        ]
    )


def cmd_calendar_events(args) -> None:
    svc = service(args.account, "calendar", "v3")
    now = datetime.now(timezone.utc)
    time_min = args.time_min or now.isoformat()
    time_max = args.time_max or (now + timedelta(days=args.days)).isoformat()
    resp = (
        svc.events()
        .list(
            calendarId=args.calendar,
            timeMin=time_min,
            timeMax=time_max,
            singleEvents=True,
            orderBy="startTime",
            maxResults=args.max,
        )
        .execute()
    )
    out(
        [
            {
                "id": e["id"],
                "summary": e.get("summary"),
                "start": e.get("start"),
                "end": e.get("end"),
                "location": e.get("location"),
                "attendees": [
                    {"email": a.get("email"), "responseStatus": a.get("responseStatus")}
                    for a in e.get("attendees", [])
                ],
                "description": e.get("description"),
                "status": e.get("status"),
                "hangoutLink": e.get("hangoutLink"),
            }
            for e in resp.get("items", [])
        ]
    )


def cmd_contacts_list(args) -> None:
    svc = service(args.account, "people", "v1")
    people = []
    page_token = None
    while True:
        resp = (
            svc.people()
            .connections()
            .list(
                resourceName="people/me",
                pageSize=min(args.max - len(people), 1000),
                personFields="names,emailAddresses,phoneNumbers,organizations",
                pageToken=page_token,
            )
            .execute()
        )
        for p in resp.get("connections", []):
            people.append(
                {
                    "resourceName": p["resourceName"],
                    "name": (p.get("names") or [{}])[0].get("displayName"),
                    "emails": [e["value"] for e in p.get("emailAddresses", [])],
                    "phones": [n["value"] for n in p.get("phoneNumbers", [])],
                    "organizations": [
                        {"name": o.get("name"), "title": o.get("title")}
                        for o in p.get("organizations", [])
                    ],
                }
            )
        page_token = resp.get("nextPageToken")
        if not page_token or len(people) >= args.max:
            break
    out(people)


def main() -> None:
    p = argparse.ArgumentParser(prog="gws.py", description=__doc__)
    sub = p.add_subparsers(dest="cmd", required=True)

    sp = sub.add_parser("auth", help="run one-time browser OAuth consent for an account")
    sp.add_argument("account")
    sp.set_defaults(fn=cmd_auth)

    sp = sub.add_parser("accounts", help="list configured accounts")
    sp.set_defaults(fn=cmd_accounts)

    sp = sub.add_parser("gmail-list", help="search/list messages (metadata + snippet)")
    sp.add_argument("account")
    sp.add_argument("--query", default="", help="Gmail search query, e.g. 'newer_than:7d'")
    sp.add_argument("--label", action="append", help="label id filter (repeatable)")
    sp.add_argument("--max", type=int, default=25)
    sp.set_defaults(fn=cmd_gmail_list)

    sp = sub.add_parser("gmail-get", help="fetch one message with plain-text body")
    sp.add_argument("account")
    sp.add_argument("id")
    sp.set_defaults(fn=cmd_gmail_get)

    sp = sub.add_parser("gmail-labels", help="list labels")
    sp.add_argument("account")
    sp.set_defaults(fn=cmd_gmail_labels)

    sp = sub.add_parser("calendar-list", help="list calendars")
    sp.add_argument("account")
    sp.set_defaults(fn=cmd_calendar_list)

    sp = sub.add_parser("calendar-events", help="list events in a time window")
    sp.add_argument("account")
    sp.add_argument("--calendar", default="primary")
    sp.add_argument("--days", type=int, default=14, help="window size from now (default 14)")
    sp.add_argument("--time-min", help="RFC3339 start; overrides --days window start")
    sp.add_argument("--time-max", help="RFC3339 end; overrides --days window end")
    sp.add_argument("--max", type=int, default=100)
    sp.set_defaults(fn=cmd_calendar_events)

    sp = sub.add_parser("contacts-list", help="list contacts")
    sp.add_argument("account")
    sp.add_argument("--max", type=int, default=500)
    sp.set_defaults(fn=cmd_contacts_list)

    args = p.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()

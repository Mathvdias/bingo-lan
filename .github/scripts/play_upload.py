#!/usr/bin/env python3
"""Envia um App Bundle para uma trilha da Google Play pela Play Developer API.

Substitui a action de terceiros para que qualquer erro da API apareça inteiro
no log (status HTTP e corpo JSON), em vez de uma mensagem genérica.

Uso:
  PLAY_SERVICE_ACCOUNT_JSON='{...}' python3 play_upload.py \
      --package com.nightstudios.bingo --aab caminho/app.aab \
      --track internal [--mapping mapping.txt] [--symbols build/symbols] \
      [--notes-pt "..."] [--notes-en "..."] [--status completed]

Dependências: google-auth, requests (pip install google-auth requests).
"""
import argparse
import json
import os
import sys
import zipfile
import io

import requests
from google.oauth2 import service_account
from google.auth.transport.requests import AuthorizedSession

API = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications"
UPLOAD = "https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications"
SCOPE = "https://www.googleapis.com/auth/androidpublisher"


def die(msg, resp=None):
    print(f"::error::{msg}")
    if resp is not None:
        print(f"HTTP {resp.status_code}")
        try:
            print(json.dumps(resp.json(), indent=2, ensure_ascii=False))
        except Exception:
            print(resp.text[:4000])
    sys.exit(1)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--package", required=True)
    ap.add_argument("--aab", required=True)
    ap.add_argument("--track", default="internal")
    ap.add_argument("--status", default="completed")
    ap.add_argument("--mapping")
    ap.add_argument("--symbols", help="diretório com os símbolos nativos (--split-debug-info)")
    ap.add_argument("--notes-pt")
    ap.add_argument("--notes-en")
    args = ap.parse_args()

    raw = os.environ.get("PLAY_SERVICE_ACCOUNT_JSON")
    if not raw:
        die("PLAY_SERVICE_ACCOUNT_JSON vazio")
    creds = service_account.Credentials.from_service_account_info(
        json.loads(raw), scopes=[SCOPE]
    )
    s = AuthorizedSession(creds)
    base = f"{API}/{args.package}"

    r = s.post(f"{base}/edits", json={})
    if r.status_code != 200:
        die("Falha ao criar a edição", r)
    edit = r.json()["id"]
    print(f"Edição {edit} criada")

    size = os.path.getsize(args.aab)
    print(f"Enviando {args.aab} ({size / 1e6:.1f} MB) como app bundle…")
    with open(args.aab, "rb") as f:
        r = s.post(
            f"{UPLOAD}/{args.package}/edits/{edit}/bundles?uploadType=media"
            "&ackBundleInstallationWarning=true",
            data=f,
            headers={"Content-Type": "application/octet-stream"},
            timeout=1800,
        )
    if r.status_code != 200:
        die("A Play rejeitou o app bundle", r)
    bundle = r.json()
    vc = bundle["versionCode"]
    print(f"Bundle aceito: versionCode {vc}, sha256 {bundle.get('sha256', '?')}")

    if args.mapping and os.path.exists(args.mapping):
        with open(args.mapping, "rb") as f:
            r = s.post(
                f"{UPLOAD}/{args.package}/edits/{edit}/apks/{vc}/deobfuscationFiles/proguard?uploadType=media",
                data=f, headers={"Content-Type": "application/octet-stream"}, timeout=600,
            )
        print("mapping.txt:", "ok" if r.status_code == 200 else f"falhou ({r.status_code}) {r.text[:300]}")

    if args.symbols and os.path.isdir(args.symbols):
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
            for root, _, files in os.walk(args.symbols):
                for name in files:
                    p = os.path.join(root, name)
                    z.write(p, os.path.relpath(p, args.symbols))
        buf.seek(0)
        r = s.post(
            f"{UPLOAD}/{args.package}/edits/{edit}/apks/{vc}/deobfuscationFiles/nativeCode?uploadType=media",
            data=buf.getvalue(), headers={"Content-Type": "application/octet-stream"}, timeout=600,
        )
        print("símbolos nativos:", "ok" if r.status_code == 200 else f"falhou ({r.status_code}) {r.text[:300]}")

    notes = []
    if args.notes_pt:
        notes.append({"language": "pt-BR", "text": args.notes_pt})
    if args.notes_en:
        notes.append({"language": "en-US", "text": args.notes_en})
    release = {"versionCodes": [str(vc)], "status": args.status}
    if notes:
        release["releaseNotes"] = notes
    r = s.put(f"{base}/edits/{edit}/tracks/{args.track}", json={"track": args.track, "releases": [release]})
    if r.status_code != 200:
        die(f"Falha ao atribuir o bundle à trilha {args.track}", r)
    print(f"Trilha {args.track}: versionCode {vc} com status {args.status}")

    r = s.post(f"{base}/edits/{edit}:commit", params={"changesNotSentForReview": "false"})
    if r.status_code != 200:
        die("Falha ao confirmar a edição", r)
    print("Edição confirmada. Publicado.")


if __name__ == "__main__":
    main()

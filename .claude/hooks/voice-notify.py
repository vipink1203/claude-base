#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyttsx3"]
# ///

"""
TTS voice notifications for SDLC hooks.
Priority: ElevenLabs -> OpenAI -> pyttsx3 -> system say/espeak

Usage:
  python voice-notify.py --say "Hello"        # Direct
  echo '{"message": "Hello"}' | python voice-notify.py  # Hook stdin
"""

import sys, json, os, subprocess, tempfile


def speak_elevenlabs(msg):
    key = os.environ.get("ELEVENLABS_API_KEY")
    if not key: return False
    try:
        import urllib.request
        vid = os.environ.get("ELEVENLABS_VOICE_ID", "21m00Tcm4TlvDq8ikWAM")
        req = urllib.request.Request(
            f"https://api.elevenlabs.io/v1/text-to-speech/{vid}",
            json.dumps({"text": msg, "model_id": "eleven_flash_v2_5",
                        "voice_settings": {"stability": 0.5, "similarity_boost": 0.75}}).encode(),
            {"xi-api-key": key, "Content-Type": "application/json", "Accept": "audio/mpeg"})
        with urllib.request.urlopen(req, timeout=10) as r:
            with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as f:
                f.write(r.read()); tmp = f.name
        subprocess.run(["afplay", tmp] if sys.platform == "darwin"
                       else ["mpv", "--no-video", tmp], check=True, capture_output=True)
        os.unlink(tmp); return True
    except: return False


def speak_openai(msg):
    key = os.environ.get("OPENAI_API_KEY")
    if not key: return False
    try:
        import urllib.request
        req = urllib.request.Request("https://api.openai.com/v1/audio/speech",
            json.dumps({"model": "tts-1", "input": msg, "voice": "nova"}).encode(),
            {"Authorization": f"Bearer {key}", "Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=10) as r:
            with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as f:
                f.write(r.read()); tmp = f.name
        subprocess.run(["afplay", tmp] if sys.platform == "darwin"
                       else ["mpv", "--no-video", tmp], check=True, capture_output=True)
        os.unlink(tmp); return True
    except: return False


def speak_pyttsx3(msg):
    try:
        import pyttsx3; e = pyttsx3.init()
        e.setProperty('rate', e.getProperty('rate') - 30)
        e.say(msg); e.runAndWait(); return True
    except: return False


def speak(msg):
    for fn in [speak_elevenlabs, speak_openai, speak_pyttsx3]:
        if fn(msg): return
    try:
        subprocess.run(["say", msg] if sys.platform == "darwin"
                       else ["espeak", msg], check=True, capture_output=True)
    except: pass


def main():
    if len(sys.argv) > 2 and sys.argv[1] == "--say":
        speak(" ".join(sys.argv[2:])); return
    try:
        data = json.loads(sys.stdin.read().strip())
        msg = data.get("message")
        if not msg:
            evt = data.get("hook_event_name", "")
            if evt == "Stop": msg = "Task complete."
            elif evt == "SubagentStop": msg = "Subagent finished."
            elif evt == "Notification": msg = data.get("message", "Notification.")
            else: return
        speak(msg)
    except: pass

if __name__ == "__main__":
    main()

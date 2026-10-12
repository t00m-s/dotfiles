"""Test-only backend: records commands and never touches hardware."""
import json
from pathlib import Path
import sys
import time

base = Path(__file__).parent
state_file = base / "state.json"
state = json.loads(state_file.read_text()) if state_file.exists() else {
    "cpu": 42, "volume": 30, "muted": False, "brightness": 60,
}
action = sys.argv[1]
if action == "stream":
    print(json.dumps(state), flush=True)
    time.sleep(10)  # No telemetry refresh during the test: check command feedback.
else:
    time.sleep(0.08)  # Exercise coalescing while a prior command is in flight.
    value = int(sys.argv[2])
    with (base / "commands.log").open("a") as log:
        log.write(f"{action}:{value}\n")
    if action == "volume-step":
        state["volume"] += value
    elif action == "volume-set":
        state["volume"] = value
    elif action == "brightness-set":
        state["brightness"] = value
    state_file.write_text(json.dumps(state))
    keys = ("volume", "muted") if action.startswith("volume") else ("brightness",)
    print(json.dumps({key: state[key] for key in keys}), flush=True)

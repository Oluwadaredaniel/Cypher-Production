import os
import socket
import platform
import psutil
import io
import base64
import json
import uuid
import secrets
import random
import time
import zipfile
import threading
import subprocess
import requests
import queue
import re
import mimetypes
from datetime import datetime, timedelta
from pathlib import Path

# Standard imports
from flask import Flask, jsonify, request, send_file, Response, stream_with_context
from flask_cors import CORS
from flask_socketio import SocketIO, emit

# Internal Services
from core.services.logging_service import setup_logging
from core.services.utils import get_config_path, log_event, get_app_data_dir
from core.services.guest_manager import guest_manager
from core.services.discovery import start_discovery_thread, get_discovery_instance
from core.services.recording_overlay import overlay_manager

# Initialize GlitchTip for Production Monitoring (Sentry-compatible)
try:
    import sentry_sdk
    from sentry_sdk.integrations.flask import FlaskIntegration
    sentry_sdk.init(
        dsn="https://011915baf51240f19f98c283a67fece4@app.glitchtip.com/24279",
        integrations=[FlaskIntegration()],
        traces_sample_rate=0.1,
        environment="production",
        release="1.0.0",
    )
except ImportError:
    pass

# OneUptime Heartbeat Logic
def oneuptime_heartbeat():
    """Pings OneUptime every 5 minutes to track install/uptime."""
    while True:
        try:
            requests.get("https://oneuptime.com/heartbeat/e586d700-f543-4184-8764-6529ab707d46", timeout=5)
        except:
            pass
        time.sleep(300)

# Initialize Logging
log = setup_logging('cypher-backend')

# Detect platform
WINDOWS = platform.system() == 'Windows'

# --- LAZY LOADING HELPERS ---
pyautogui = None
pyperclip = None
gw = None
cv2 = None
np = None
mss = None
AudioUtilities = None
IAudioEndpointVolume = None
ctypes = None
CLSCTX_ALL = None
win32gui = None
win32api = None
win32con = None
win32ui = None
Image = None
ImageGrab = None

def _load_automation():
    global pyautogui, pyperclip, gw, win32gui, win32api, win32con, win32ui
    if pyautogui is None and WINDOWS:
        try:
            import pyautogui as pg
            import pyperclip as pc
            import pygetwindow as g
            import win32gui as wg
            import win32api as wa
            import win32con as wc
            import win32ui as wu
            pyautogui = pg
            pyperclip = pc
            gw = g
            win32gui = wg
            win32api = wa
            win32con = wc
            win32ui = wu
            pyautogui.FAILSAFE = False
        except ImportError:
            log.error("Automation libraries missing")

def _load_media_engine():
    global cv2, np, mss, Image
    if cv2 is None:
        try:
            import cv2 as _cv2
            import numpy as _np
            import mss as _mss
            from PIL import Image as _Image
            cv2 = _cv2
            np = _np
            mss = _mss
            Image = _Image
        except ImportError:
            log.error("Media libraries missing")

def _load_audio_engine():
    global AudioUtilities, IAudioEndpointVolume, ctypes, CLSCTX_ALL
    if AudioUtilities is None and WINDOWS:
        try:
            from pycaw.pycaw import AudioUtilities as AU, IAudioEndpointVolume as IAEV
            from comtypes import CLSCTX_ALL as CA
            import ctypes as ct
            AudioUtilities = AU
            IAudioEndpointVolume = IAEV
            CLSCTX_ALL = CA
            ctypes = ct
        except ImportError:
            log.error("Audio libraries missing")

def _load_imaging():
    global Image, ImageGrab
    if Image is None:
        try:
            from PIL import Image as _Image, ImageGrab as _ImageGrab
            Image = _Image
            ImageGrab = _ImageGrab
        except ImportError:
            log.error("Imaging libraries missing")

# --- APP INITIALIZATION ---
app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')

# --- CONSTANTS & SECURITY ---
INTERNAL_TOKEN = "cypher-internal-pc-app-token-2024"
MACROS_FILE = get_config_path("macros.json")
SETTINGS_FILE = get_config_path("settings.json")
SHARED_FOLDERS_FILE = get_config_path("cypher_config.json")
PAIRED_DEVICES_FILE = get_config_path("paired_devices.json")

# --- GLOBAL STORAGE ---
notifications_list = []
command_history = []
system_activity_log = []
active_transfers = {}
cancel_all_transfers = False
phone_clipboard = {"content": "", "timestamp": "", "type": "text"}
paired_devices = {}
valid_tokens = {INTERNAL_TOKEN}
pairing_code = ""

# --- SCREEN RECORDING STATE ---
recording_state = {
    "is_recording": False,
    "is_paused": False,
    "start_time": None,
    "filename": None,
    "filepath": None,
    "source": "fullscreen"
}

# --- HELPERS ---

def add_activity(title, desc, category="Connections", is_urgent=False, attachment=None):
    log_entry = {
        "id": str(uuid.uuid4()),
        "title": title,
        "desc": desc,
        "category": category,
        "time": datetime.now().strftime("%H:%M:%S"),
        "date": "Today",
        "is_urgent": is_urgent,
        "attachment": attachment,
        "timestamp": time.time()
    }
    system_activity_log.insert(0, log_entry)
    if len(system_activity_log) > 200:
        system_activity_log.pop()

    log_event(category.upper(), f"{title}: {desc}")
    socketio.emit('activity_update', log_entry)

def log_to_ui(action, device="Phone"):
    payload = {"action": action, "device": device, "time": datetime.now().strftime("%H:%M")}
    socketio.emit('log_event', payload)

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.settimeout(0)
        s.connect(('10.254.254.254', 1))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

def generate_pairing_code():
    global pairing_code
    pairing_code = str(random.randint(100000, 999999))
    try:
        get_config_path("pairing_code.txt").write_text(pairing_code)
    except: pass
    return pairing_code

def load_persistence():
    global paired_devices
    if PAIRED_DEVICES_FILE.exists():
        try:
            with open(PAIRED_DEVICES_FILE, 'r') as f:
                paired_devices = json.load(f)
                for dev in paired_devices.values():
                    valid_tokens.add(dev["token"])
        except Exception as e:
            log.error(f"Error loading paired devices: {e}")
    generate_pairing_code()

def save_paired_devices():
    try:
        with open(PAIRED_DEVICES_FILE, 'w') as f:
            json.dump(paired_devices, f, indent=4)
    except Exception as e:
        log.error(f"Error saving paired devices: {e}")

def _get_shared_folders():
    try:
        if SHARED_FOLDERS_FILE.exists():
            with open(SHARED_FOLDERS_FILE, 'r') as f:
                data = json.load(f)
                return data.get("shared_folders", [])
    except Exception as e:
        log.error(f"Error loading shared folders: {e}")
    return []

def is_path_safe(path, allowed_roots=None):
    path_low = str(path).lower()
    restricted = ["c:\\windows", "c:\\boot", "c:\\recovery", "c:\\program files"]
    if any(path_low.startswith(r) for r in restricted):
        return False
    return True

# --- MONITORING ---
resource_usage_history = {"cpu": [], "ram": [], "timestamps": []}
current_system_stats = {}

def monitor_resources():
    global current_system_stats
    psutil.cpu_percent(interval=None)
    while True:
        try:
            cpu = psutil.cpu_percent(interval=None)
            vm = psutil.virtual_memory()
            try:
                disk = psutil.disk_usage('/')
                d_percent = disk.percent
            except: d_percent = 0

            battery = None
            try: battery = psutil.sensors_battery()
            except: pass

            current_system_stats = {
                "cpu_percent": cpu,
                "ram_percent": vm.percent,
                "ram_total": round(vm.total / (1024**3), 2),
                "ram_used": round(vm.used / (1024**3), 2),
                "disk_percent": d_percent,
                "battery_percent": battery.percent if battery else 100,
                "battery_plugged": battery.power_plugged if battery else True,
                "timestamp": datetime.now().strftime("%H:%M:%S")
            }

            socketio.emit('system_stats', current_system_stats)

            resource_usage_history["cpu"].append(cpu)
            resource_usage_history["ram"].append(vm.percent)
            resource_usage_history["timestamps"].append(current_system_stats["timestamp"])
            if len(resource_usage_history["cpu"]) > 30:
                for k in resource_usage_history: resource_usage_history[k].pop(0)

            # Battery Alert Logic
            if battery and not battery.power_plugged and battery.percent <= 20: # Example threshold
                socketio.emit('battery_alert', {"percent": battery.percent})

        except Exception as e:
            log.error(f"Stats Error: {e}")
        time.sleep(2)

# --- MIDDLEWARE ---
@app.before_request
def verify_auth():
    public = ['ping', 'get_connect_code', 'pair_device', 'get_status']
    if request.endpoint in public or request.method == 'OPTIONS':
        return None

    token = request.headers.get("X-Auth-Token")
    guest_token = request.args.get("token")

    if token == INTERNAL_TOKEN or token in valid_tokens:
        return None

    if guest_token and (request.path.startswith('/guest/') or request.path == '/guest/access'):
        if guest_manager.validate_token(guest_token):
            return None

    return jsonify({"success": False, "error": "Unauthorized"}), 401

# --- ENDPOINTS ---

@app.route('/ping')
def ping(): return jsonify({"message": "pong", "ip": get_local_ip()})

@app.route('/connect-code', methods=['GET', 'POST'])
def get_connect_code():
    global pairing_code
    if request.method == 'POST':
        pairing_code = generate_pairing_code()
        add_activity("Security", "Pairing code rotated", category="Security")
    return jsonify({"code": pairing_code})

@app.route('/pair_device', methods=['POST'])
def pair_device():
    data = request.json
    if str(data.get("pairing_code")) == pairing_code:
        token = secrets.token_hex(16)
        dev_id = data.get("device_id")
        dev_name = data.get("device_name", "Unknown Device")
        paired_devices[dev_id] = {
            "device_name": dev_name,
            "token": token,
            "paired_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        valid_tokens.add(token)
        save_paired_devices()
        add_activity("Device Paired", f"Linked {dev_name}", category="Connections")
        return jsonify({"success": True, "token": token})
    return jsonify({"success": False, "error": "Invalid code"}), 401

@app.route('/status')
def get_status():
    return jsonify({"pc_name": socket.gethostname(), "status": "online", "platform": platform.system().lower()})

@app.route('/system-stats')
def get_stats(): return jsonify(current_system_stats)

@app.route('/system/activity')
def get_activity(): return jsonify(system_activity_log)

# --- FILE SYSTEM ---

@app.route('/files')
def get_root():
    roots = []
    # Add Logical Drives
    for part in psutil.disk_partitions():
        if 'cdrom' in part.opts or part.fstype == '': continue
        try:
            roots.append({"name": f"Local Disk ({part.mountpoint})", "path": part.mountpoint, "type": "drive"})
        except: pass

    # Quick Access
    home = Path.home()
    for f in ["Downloads", "Documents", "Pictures", "Desktop", "Videos"]:
        if (home / f).exists():
            roots.append({"name": f, "path": str(home / f), "type": "folder"})

    # Shared Folders
    for f in _get_shared_folders():
        if Path(f).exists():
            roots.append({"name": Path(f).name, "path": f, "type": "folder", "is_shared": True})

    return jsonify(roots)

@app.route('/files/browse')
def browse():
    path = request.args.get('path')
    if not path or not Path(path).exists():
        return jsonify({"error": "Not found"}), 404

    items = []
    try:
        for item in Path(path).iterdir():
            if item.name.startswith(('.', '$')): continue
            stat = item.stat()
            items.append({
                "name": item.name,
                "path": str(item.absolute()),
                "type": "file" if item.is_file() else "folder",
                "size": stat.st_size if item.is_file() else 0,
                "modified": datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S")
            })
    except Exception as e: return jsonify({"error": str(e)}), 500
    return jsonify(items)

@app.route('/files/upload', methods=['POST'])
def upload():
    if 'file' not in request.files: return jsonify({"error": "No file"}), 400
    file = request.files['file']
    dest = request.form.get('destination', str(Path.home() / "Downloads"))
    if not is_path_safe(dest): return jsonify({"error": "Access Denied"}), 403

    final_path = Path(dest) / file.filename
    # Handle conflicts
    counter = 1
    while final_path.exists():
        final_path = Path(dest) / f"{Path(file.filename).stem} ({counter}){Path(file.filename).suffix}"
        counter += 1

    try:
        file.save(str(final_path))
        add_activity("File Received", f"Saved {final_path.name}", category="Transfers", attachment=final_path.name)
        log_to_ui(f"Received {final_path.name}")
        return jsonify({"success": True, "path": str(final_path)})
    except Exception as e: return jsonify({"error": str(e)}), 500

# --- REMOTE CONTROL ---

@app.route('/power/<action>', methods=['POST'])
def power(action):
    log_to_ui(f"Power: {action}")
    if action == 'shutdown': os.system("shutdown /s /t 5")
    elif action == 'restart': os.system("shutdown /r /t 5")
    elif action == 'sleep': os.system("rundll32.exe powrprof.dll,SetSuspendState 0,1,0")
    elif action == 'lock':
        _load_audio_engine()
        import ctypes
        ctypes.windll.user32.LockWorkStation()
    return jsonify({"success": True})

@app.route('/processes')
def list_procs():
    procs = []
    for p in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_info']):
        try:
            procs.append({
                "pid": p.info['pid'], "name": p.info['name'],
                "cpu": p.info['cpu_percent'],
                "ram": round(p.info['memory_info'].rss / (1024**2), 2)
            })
        except: continue
    return jsonify(procs)

@app.route('/processes/kill', methods=['POST'])
def kill_proc():
    pid = request.json.get("pid")
    try:
        p = psutil.Process(pid)
        p.terminate()
        return jsonify({"success": True})
    except Exception as e: return jsonify({"error": str(e)}), 500

@app.route('/apps')
def list_apps():
    if not WINDOWS: return jsonify([])
    apps = []
    # Search common start menu paths
    paths = [
        Path(os.environ['ProgramData']) / "Microsoft/Windows/Start Menu/Programs",
        Path(os.environ['AppData']) / "Microsoft/Windows/Start Menu/Programs"
    ]
    for p in paths:
        if p.exists():
            for lnk in p.rglob("*.lnk"):
                apps.append({"name": lnk.stem, "path": str(lnk)})
    return jsonify(apps)

@app.route('/apps/launch', methods=['POST'])
def launch_app():
    path = request.json.get("path")
    if path:
        os.startfile(path)
        add_activity("App Launched", Path(path).stem, category="Commands")
        return jsonify({"success": True})
    return jsonify({"error": "No path"}), 400

# --- CLIPBOARD ---

@app.route('/clipboard', methods=['GET', 'POST'])
def handle_clipboard():
    _load_automation()
    if request.method == 'GET':
        return jsonify({"content": pyperclip.paste() if pyperclip else ""})
    text = request.json.get("text", "")
    if pyperclip: pyperclip.copy(text)
    log_to_ui("Clipboard updated")
    return jsonify({"success": True})

# --- SCREEN RECORDING ---

def recording_worker(path):
    _load_media_engine()
    with mss.mss() as sct:
        mon = sct.monitors[1]
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(path, fourcc, 10.0, (mon["width"], mon["height"]))
        while recording_state["is_recording"]:
            if recording_state["is_paused"]:
                time.sleep(0.1); continue
            img = sct.grab(mon)
            frame = np.array(img)
            frame = cv2.cvtColor(frame, cv2.COLOR_BGRA2BGR)
            out.write(frame)
            time.sleep(0.1)
        out.release()

@app.route('/recording/start', methods=['POST'])
def start_rec():
    if recording_state["is_recording"]: return jsonify({"error": "Already recording"}), 400
    rec_dir = Path.home() / "Videos" / "CYPHER"
    rec_dir.mkdir(parents=True, exist_ok=True)
    filename = f"Rec_{datetime.now().strftime('%Y%m%d_%H%M%S')}.mp4"
    filepath = str(rec_dir / filename)
    recording_state.update({"is_recording": True, "is_paused": False, "filepath": filepath})
    threading.Thread(target=recording_worker, args=(filepath,), daemon=True).start()
    overlay_manager.start()
    return jsonify({"success": True, "file": filename})

@app.route('/recording/stop', methods=['POST'])
def stop_rec():
    recording_state["is_recording"] = False
    overlay_manager.stop()
    return jsonify({"success": True})

# --- GUEST ACCESS ---

@app.route('/guest/create', methods=['POST'])
def create_guest():
    data = request.json
    token = guest_manager.create_session(data['folders'], data.get('duration', 15), "host")
    ip = get_local_ip()
    # Deep link for app users
    qr_data = f"cypher://{ip}:5000/guest?token={token}"
    # Web link for non-app users
    web_link = f"http://{ip}:5000/guest/access?token={token}"
    return jsonify({"success": True, "token": token, "qr_data": qr_data, "web_link": web_link})

@app.route('/guest/access')
def guest_web_landing():
    token = request.args.get('token')
    session = guest_manager.validate_token(token)
    if not session:
        return "<h1>Link Expired or Invalid</h1>", 401

    # Generate list of files for the web UI
    files_html = ""
    for folder in session.allowed_folders:
        p = Path(folder)
        if p.exists():
            for item in p.iterdir():
                if item.name.startswith(('.', '$')): continue
                files_html += f"""
                <div class="file-item">
                    <span>{item.name}</span>
                    <a href="/guest/files/download?token={token}&path={item.absolute()}" class="btn" style="text-decoration:none; font-size:12px;">Download</a>
                </div>
                """

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Cypher Guest Access</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: #0F0F10; color: white; padding: 20px; }}
            .container {{ max-width: 600px; margin: 0 auto; }}
            .card {{ background: #16161A; padding: 20px; border-radius: 12px; margin-bottom: 20px; border: 1px solid #262626; }}
            .btn {{ background: #10B981; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: 600; }}
            .btn-secondary {{ background: #1E1E26; color: #A0A0A0; }}
            .file-item {{ display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #262626; padding: 12px 0; }}
            h1 {{ font-weight: 800; letter-spacing: -1px; }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Cypher <span style="color:#10B981">Guest</span></h1>
            <p style="color:#A0A0A0">Temporary access to shared folders.</p>

            <div class="card">
                <h3 style="margin-top:0">Upload to PC</h3>
                <form action="/guest/files/upload?token={token}" method="post" enctype="multipart/form-data">
                    <input type="file" name="file" style="margin-bottom:10px; display:block;">
                    <button type="submit" class="btn">Send to PC</button>
                </form>
            </div>

            <div class="card">
                <h3 style="margin-top:0">Available Files</h3>
                {files_html if files_html else '<p style="color:#666">No files in shared folders.</p>'}
            </div>

            <p style="text-align:center; font-size:12px; color:#444">Powered by Cypher Local Protocol</p>
        </div>
    </body>
    </html>
    """
    return html

@app.route('/guest/files')
def guest_files():
    token = request.args.get('token')
    path = request.args.get('path')
    session = guest_manager.validate_token(token)
    if not session: return jsonify({"error": "Expired"}), 401

    if not path:
        return jsonify([{"name": Path(f).name, "path": f, "type": "folder"} for f in session.allowed_folders])

    # Check permission
    allowed = False
    for f in session.allowed_folders:
        if path.lower().startswith(f.lower()):
            allowed = True; break
    if not allowed: return jsonify({"error": "Denied"}), 403

    return browse() # Reuse browse logic

@app.route('/guest/files/download')
def guest_download():
    token = request.args.get('token')
    path = request.args.get('path')
    session = guest_manager.validate_token(token)
    if not session or not path: return jsonify({"error": "Unauthorized"}), 401

    # Permission check
    allowed = False
    for f in session.allowed_folders:
        if path.lower().startswith(f.lower()):
            allowed = True; break
    if not allowed: return jsonify({"error": "Denied"}), 403

    return send_file(path, as_attachment=True)

@app.route('/guest/files/upload', methods=['POST'])
def guest_upload():
    token = request.args.get('token')
    session = guest_manager.validate_token(token)
    if not session: return jsonify({"error": "Unauthorized"}), 401

    if 'file' not in request.files: return jsonify({"error": "No file"}), 400
    file = request.files['file']

    dest = session.allowed_folders[0]
    final_path = Path(dest) / file.filename
    try:
        file.save(str(final_path))
        add_activity("Guest Upload", f"Received {file.filename} via guest link", category="Transfers")
        return jsonify({"success": True})
    except Exception as e: return jsonify({"error": str(e)}), 500

# --- NOTIFICATIONS ---

@app.route('/notifications/add', methods=['POST'])
def add_notif():
    data = request.json
    notif = {
        "id": str(uuid.uuid4()),
        "title": data.get("title"),
        "message": data.get("message"),
        "app": data.get("app", "System"),
        "time": datetime.now().strftime("%H:%M")
    }
    notifications_list.insert(0, notif)
    socketio.emit('new_notification', notif)
    return jsonify({"success": True})

# --- STARTUP ---

if __name__ == '__main__':
    load_persistence()
    from core.services.utils import check_for_updates
    threading.Thread(target=check_for_updates, daemon=True).start()
    threading.Thread(target=oneuptime_heartbeat, daemon=True).start()
    threading.Thread(target=monitor_resources, daemon=True).start()
    start_discovery_thread(5000, socket.gethostname())

    log.info(f"CYPHER Backend started on {get_local_ip()}:5000")
    socketio.run(app, host='0.0.0.0', port=5000, debug=False, allow_unsafe_werkzeug=True)

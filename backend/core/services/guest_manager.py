import uuid
import secrets
from datetime import datetime, timedelta
from pathlib import Path

class GuestSession:
    def __init__(self, allowed_folders, duration_minutes, host_token):
        self.token = secrets.token_urlsafe(16)
        self.allowed_folders = [str(Path(f).resolve()) for f in allowed_folders]
        self.created_at = datetime.now()
        self.expires_at = self.created_at + timedelta(minutes=duration_minutes)
        self.host_token = host_token
        self.access_count = 0
        self.is_active = True
        self.access_logs = []

    def is_valid(self):
        if not self.is_active:
            return False
        return datetime.now() < self.expires_at

    def log_access(self, path, action):
        self.access_count += 1
        self.access_logs.append({
            "timestamp": datetime.now().isoformat(),
            "path": path,
            "action": action
        })

class GuestManager:
    def __init__(self):
        self.sessions = {}

    def create_session(self, folders, duration, host_token):
        session = GuestSession(folders, duration, host_token)
        self.sessions[session.token] = session
        return session.token

    def validate_token(self, token):
        if token in self.sessions:
            session = self.sessions[token]
            if session.is_valid():
                return session
            else:
                session.is_active = False
        return None

    def extend_session(self, token, minutes):
        if token in self.sessions:
            self.sessions[token].expires_at += timedelta(minutes=minutes)
            self.sessions[token].is_active = True
            return True
        return False

    def end_session(self, token):
        if token in self.sessions:
            self.sessions[token].is_active = False
            return True
        return False

    def get_all_active_sessions(self, host_device_id=None):
        now = datetime.now()
        active = []
        for token, s in self.sessions.items():
            if s.is_active and now < s.expires_at:
                active.append({
                    "token": token,
                    "folders": s.allowed_folders,
                    "expires_at": s.expires_at.isoformat(),
                    "access_count": s.access_count
                })
        return active

guest_manager = GuestManager()

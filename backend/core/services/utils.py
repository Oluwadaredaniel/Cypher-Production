import os
import platform
import logging
from pathlib import Path

def get_app_data_dir():
    base_dir = Path.home() / ".cypher"
    base_dir.mkdir(exist_ok=True)
    return base_dir

def get_config_path(filename):
    return get_app_data_dir() / filename

def log_event(category, details):
    # This can be used to log specific app events to a separate file or database if needed
    logger = logging.getLogger("CYPHER_EVENTS")
    if not logger.handlers:
        handler = logging.FileHandler(get_app_data_dir() / "events.log")
        handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)

    logger.info(f"[{category}] {details}")

def check_for_updates(current_version="1.0.0"):
    """
    Checks GitHub for the latest release.
    This also acts as an anonymous heartbeat for install analytics.
    """
    try:
        import requests
        repo = "Oluwadaredaniel/Cypher"
        url = f"https://api.github.com/repos/{repo}/releases/latest"
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            latest = data.get("tag_name", "").replace("v", "")
            if latest and latest != current_version:
                logging.getLogger("CYPHER").info(f"NEW VERSION AVAILABLE: {latest}")
                return latest
    except Exception:
        pass
    return None

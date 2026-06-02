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

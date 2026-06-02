import logging
import json
from datetime import datetime
from pathlib import Path

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
        }

        if record.exc_info:
            log_data['exception'] = self.formatException(record.exc_info)

        return json.dumps(log_data)

def setup_logging(app_name='cypher', log_level=logging.INFO):
    log_dir = Path.home() / '.cypher' / 'logs'
    log_dir.mkdir(parents=True, exist_ok=True)

    logger = logging.getLogger(app_name)
    logger.setLevel(log_level)

    # Avoid duplicate handlers if setup_logging is called multiple times
    if not logger.handlers:
        # File handler (JSON)
        fh = logging.FileHandler(log_dir / f'{app_name}.log')
        fh.setFormatter(JSONFormatter())

        # Console handler (human readable)
        ch = logging.StreamHandler()
        ch.setFormatter(logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        ))

        logger.addHandler(fh)
        logger.addHandler(ch)

    return logger

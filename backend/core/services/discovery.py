import socket
import threading
import time
from zeroconf import IPVersion, ServiceInfo, Zeroconf

class DiscoveryService:
    def __init__(self, port=5000, device_name="Cypher PC"):
        self.port = port
        self.device_name = device_name
        self.zeroconf = Zeroconf(ip_version=IPVersion.V4Only)
        self.info = None

    def _get_ip(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return "127.0.0.1"

    def register(self):
        ip = self._get_ip()
        desc = {'version': '1.0.0', 'device': self.device_name}

        self.info = ServiceInfo(
            "_cypher._tcp.local.",
            f"{self.device_name}._cypher._tcp.local.",
            addresses=[socket.inet_aton(ip)],
            port=self.port,
            properties=desc,
            server=f"{socket.gethostname()}.local.",
        )

        self.zeroconf.register_service(self.info)

    def update_name(self, new_name):
        self.unregister()
        self.device_name = new_name
        self.register()

    def unregister(self):
        if self.info:
            self.zeroconf.unregister_service(self.info)
            self.info = None

    def close(self):
        self.unregister()
        self.zeroconf.close()

_discovery_instance = None

def start_discovery_thread(port=5000, device_name="Cypher PC"):
    global _discovery_instance
    if _discovery_instance is None:
        _discovery_instance = DiscoveryService(port, device_name)
        _discovery_instance.register()
    return _discovery_instance

def get_discovery_instance():
    return _discovery_instance

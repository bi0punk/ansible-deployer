#!/usr/bin/env python3
from datetime import datetime
import platform

print(f"[python] host={platform.node()} ts={datetime.utcnow().isoformat()}Z")

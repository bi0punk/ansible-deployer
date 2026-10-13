#!/usr/bin/env python3
import platform
from datetime import UTC, datetime

print(f"[python] host={platform.node()} ts={datetime.now(UTC).isoformat()}Z")

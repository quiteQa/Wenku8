#!/usr/bin/env python3
"""Select the newest installed iOS 26 phone, sharing it across build steps."""
import json
import re
import subprocess

inventory = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', 'available', '--json']))
candidates = []
for runtime, devices in inventory['devices'].items():
    match = re.search(r'iOS-(26(?:-\d+)*)$', runtime)
    if not match:
        continue
    version = tuple(map(int, match[1].split('-')))
    for device in devices:
        if device.get('isAvailable') and device['name'].startswith('iPhone'):
            generation = re.search(r'iPhone (\d+)', device['name'])
            candidates.append((version, int(generation[1]) if generation else 0,
                               'Pro' in device['name'], device['name'], device['udid']))
if not candidates:
    raise SystemExit('No iOS 26 iPhone simulator is installed')
print(max(candidates)[-1])

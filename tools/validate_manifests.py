#!/usr/bin/env python3
"""
Validate a manifest against a JSON Schema.

Usage examples:
  python3 tools/validate_manifests.py --schema schemas/pack_manifest.schema.json --manifest manifests/examples/simple_pack_manifest.json
  python3 tools/validate_manifests.py --type story --manifest manifests/examples/simple_story_manifest.json

Requires: `jsonschema` (pip install jsonschema)
"""
import argparse
import json
import sys
from pathlib import Path

try:
    from jsonschema import Draft7Validator, FormatChecker
except Exception as e:
    print("Missing dependency 'jsonschema'. Install with: pip install jsonschema", file=sys.stderr)
    raise


def load_json(path: Path):
    with path.open('r', encoding='utf-8') as f:
        return json.load(f)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--schema', help='Path to JSON Schema file')
    p.add_argument('--type', choices=['pack', 'story'], help='Use built-in schema by type')
    p.add_argument('--manifest', required=True, help='Path to manifest JSON to validate')
    args = p.parse_args()

    repo_root = Path(__file__).resolve().parents[1]

    if args.schema:
        schema_path = Path(args.schema)
    elif args.type:
        schema_path = repo_root / 'schemas' / (f'{args.type}_manifest.schema.json')
    else:
        print('Either --schema or --type must be provided', file=sys.stderr)
        sys.exit(2)

    if not schema_path.exists():
        print(f'Schema not found: {schema_path}', file=sys.stderr)
        sys.exit(2)

    manifest_path = Path(args.manifest)
    if not manifest_path.exists():
        print(f'Manifest not found: {manifest_path}', file=sys.stderr)
        sys.exit(2)

    schema = load_json(schema_path)
    manifest = load_json(manifest_path)

    validator = Draft7Validator(schema, format_checker=FormatChecker())
    errors = sorted(validator.iter_errors(manifest), key=lambda e: e.path)

    if not errors:
        print(f'OK: {manifest_path} is valid against {schema_path}')
        sys.exit(0)

    print(f'Validation failed: {len(errors)} error(s)')
    for e in errors:
        loc = '.'.join([str(p) for p in e.path]) if e.path else '<root>'
        print(f'- {loc}: {e.message}')
    sys.exit(1)


if __name__ == '__main__':
    main()

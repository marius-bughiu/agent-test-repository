#!/usr/bin/env python3
"""Score an agent's results.json and produce a scorecard.

Usage:
    python scripts/score.py results.json
    python scripts/score.py results.json --scorecard scorecard.json
    python scripts/score.py results.json --verbose
    python scripts/score.py results.json --json-only
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent
sys.path.insert(0, str(HERE))

from lib.scoring import build_scorecard, render_text  # noqa: E402


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("results", type=Path, help="Path to results.json")
    parser.add_argument(
        "--scoring-dir",
        type=Path,
        default=REPO_ROOT / "scoring",
        help="Directory containing rubric.yml and tiers.yml",
    )
    parser.add_argument(
        "--scorecard",
        type=Path,
        default=REPO_ROOT / "scorecard.json",
        help="Where to write the JSON scorecard",
    )
    parser.add_argument("--verbose", action="store_true", help="Include extra breakdowns")
    parser.add_argument("--json-only", action="store_true", help="Suppress human-readable output")
    args = parser.parse_args(argv)

    if not args.results.exists():
        print(f"error: results file not found: {args.results}", file=sys.stderr)
        return 2

    card = build_scorecard(args.results, args.scoring_dir)

    args.scorecard.write_text(json.dumps(card.to_dict(), indent=2), encoding="utf-8")

    if not args.json_only:
        print(render_text(card))
        if args.verbose:
            print()
            print(f"Scorecard written to: {args.scorecard}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

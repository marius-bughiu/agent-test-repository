#!/usr/bin/env python3
"""Validate that the test repository is internally consistent.

Checks (each failure prints a clear reason and contributes to the final exit code):
  - Every test id in scoring/rubric.json has a matching tests/<tier>/<id>.md file.
  - Every tests/<tier>/<id>.md has a matching scripts/verify/<tier>/<id>.sh.
  - Every spec's frontmatter `id` field matches its filename.
  - Every spec's frontmatter `tier` field matches the parent folder.
  - Every rubric entry's tier matches the spec's tier.
  - Every tier slug referenced in the rubric exists in scoring/tiers.json.
  - example_results.json parses and every referenced test id exists.

Exits 0 on success, 1 on any failure. Intended to run both locally and in CI
(.github/workflows/validate-tests.yml).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)


def parse_frontmatter(text: str) -> dict[str, str]:
    m = FRONTMATTER_RE.match(text)
    if not m:
        return {}
    block = m.group(1)
    fm: dict[str, str] = {}
    for line in block.splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            continue
        k, _, v = line.partition(":")
        fm[k.strip()] = v.strip().strip('"')
    return fm


def main() -> int:
    scoring_dir = REPO_ROOT / "scoring"
    tests_dir = REPO_ROOT / "tests"
    verify_dir = REPO_ROOT / "scripts" / "verify"

    rubric = json.loads((scoring_dir / "rubric.json").read_text(encoding="utf-8"))
    tiers_doc = json.loads((scoring_dir / "tiers.json").read_text(encoding="utf-8"))
    tier_slugs = {t["slug"] for t in tiers_doc["tiers"]}

    errors: list[str] = []

    # 1. Every rubric id must have a spec and a verify.
    for test_id, meta in rubric["tests"].items():
        tier = meta["tier"]
        if tier not in tier_slugs:
            errors.append(f"rubric.json: tier {tier!r} for {test_id} not in tiers.json")
        spec = tests_dir / tier / f"{test_id}.md"
        verify = verify_dir / tier / f"{test_id}.sh"
        if not spec.exists():
            errors.append(f"missing spec: {spec.relative_to(REPO_ROOT)}")
        if not verify.exists():
            errors.append(f"missing verify: {verify.relative_to(REPO_ROOT)}")

    # 2. Every spec's frontmatter id must match its filename and tier.
    for spec in tests_dir.glob("**/*.md"):
        stem = spec.stem
        parent = spec.parent.name
        fm = parse_frontmatter(spec.read_text(encoding="utf-8"))
        fm_id = fm.get("id", "")
        fm_tier = fm.get("tier", "")
        if fm_id != stem:
            errors.append(f"{spec.relative_to(REPO_ROOT)}: frontmatter id {fm_id!r} != filename {stem!r}")
        if fm_tier != parent:
            errors.append(f"{spec.relative_to(REPO_ROOT)}: frontmatter tier {fm_tier!r} != folder {parent!r}")
        if stem in rubric["tests"]:
            rubric_tier = rubric["tests"][stem]["tier"]
            if rubric_tier != parent:
                errors.append(
                    f"{spec.relative_to(REPO_ROOT)}: rubric tier {rubric_tier!r} != folder {parent!r}"
                )
        else:
            errors.append(f"{spec.relative_to(REPO_ROOT)}: id {stem!r} not in rubric.json")

    # 3. Every verify script must correspond to a rubric entry.
    for v in verify_dir.glob("**/*.sh"):
        stem = v.stem
        if stem not in rubric["tests"]:
            errors.append(f"{v.relative_to(REPO_ROOT)}: id {stem!r} not in rubric.json")

    # 4. example_results.json references must be valid.
    example_path = scoring_dir / "example_results.json"
    if example_path.exists():
        ex = json.loads(example_path.read_text(encoding="utf-8"))
        for r in ex.get("results", []):
            if r["id"] not in rubric["tests"]:
                errors.append(f"example_results.json references unknown id: {r['id']}")

    if errors:
        print("validate_tests: FAIL")
        for e in errors:
            print(f"  - {e}")
        return 1

    print(f"validate_tests: OK — {len(rubric['tests'])} tests, "
          f"{sum(1 for _ in tests_dir.glob('**/*.md'))} specs, "
          f"{sum(1 for _ in verify_dir.glob('**/*.sh'))} verify scripts")
    return 0


if __name__ == "__main__":
    sys.exit(main())

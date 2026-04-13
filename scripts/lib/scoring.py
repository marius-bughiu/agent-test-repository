"""Scoring library for the agent test repository.

Loads the rubric and tier metadata (JSON), aggregates test results, and
produces a scorecard. Standard-library only — no pyyaml, no jsonschema.

Scoring model
-------------
Every passing test earns `points * tier_multiplier`. The headline percentage
uses a *full* denominator: skipped tests count as 0, so an agent that can't
authenticate to GitHub or install jq is reflected accurately in the score.

The one exception: tests flagged with `"skippable": true` in the rubric are
excluded from the denominator when skipped. That list is intentionally tiny
(currently GPG and SSH commit signing, which need a keyring or key on disk
that's intrusive to require). Everything else is required.

Three numbers always reported:
- **score** — earned / (possible − skippable-skips). Headline.
- **raw**   — earned / possible. What you'd get if nothing was exempt.
- **coverage** — (passed + failed + errored) / (total − skippable-skips).
                 How much of the required suite you actually ran.

Public API:
    load_rubric(scoring_dir) -> (tests_by_id, tiers_by_slug)
    build_scorecard(results_path, scoring_dir) -> Scorecard
    render_text(card) -> str
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class TierScore:
    slug: str
    label: str
    difficulty: str
    multiplier: float
    possible: float = 0.0             # full tier weight
    denom: float = 0.0                # possible minus skippable-skips
    earned: float = 0.0
    passed: int = 0
    failed: int = 0
    skipped: int = 0
    skippable_skipped: int = 0        # subset of skipped that counted as optional
    errored: int = 0
    total: int = 0


@dataclass
class Scorecard:
    agent_name: str
    total_possible: float             # full weight of all tests
    total_denom: float                # full weight minus skippable-skips
    total_earned: float
    percentage: float                 # earned / denom
    raw_percentage: float             # earned / possible
    coverage: float                   # attempted fraction of required tests
    counts: dict[str, int] = field(default_factory=dict)
    tiers: list[TierScore] = field(default_factory=list)
    failed_ids: list[str] = field(default_factory=list)
    skipped_ids: list[str] = field(default_factory=list)
    skipped_required_ids: list[str] = field(default_factory=list)
    errored_ids: list[str] = field(default_factory=list)
    focus_areas: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        d = asdict(self)
        d["tiers"] = [asdict(t) for t in self.tiers]
        return d


def load_rubric(scoring_dir: Path) -> tuple[dict[str, dict], dict[str, dict]]:
    """Return (tests_by_id, tiers_by_slug)."""
    rubric = json.loads((scoring_dir / "rubric.json").read_text(encoding="utf-8"))
    tiers_doc = json.loads((scoring_dir / "tiers.json").read_text(encoding="utf-8"))
    tiers_by_slug = {t["slug"]: t for t in tiers_doc["tiers"]}
    tests_by_id = rubric["tests"]
    return tests_by_id, tiers_by_slug


def build_scorecard(results_path: Path, scoring_dir: Path) -> Scorecard:
    tests_by_id, tiers_by_slug = load_rubric(scoring_dir)
    results_doc = json.loads(results_path.read_text(encoding="utf-8"))

    agent_name = results_doc.get("agent", {}).get("name", "unknown")
    results_by_id = {r["id"]: r for r in results_doc.get("results", [])}

    tier_scores: dict[str, TierScore] = {
        slug: TierScore(
            slug=slug,
            label=t["label"],
            difficulty=t["difficulty"],
            multiplier=float(t["multiplier"]),
        )
        for slug, t in tiers_by_slug.items()
    }

    # Populate possible weights per tier.
    for meta in tests_by_id.values():
        ts = tier_scores.get(meta["tier"])
        if ts is None:
            continue
        ts.possible += float(meta["points"]) * ts.multiplier
        ts.total += 1

    counts = {"passed": 0, "failed": 0, "skipped": 0, "errored": 0, "missing": 0}
    failed_ids: list[str] = []
    skipped_ids: list[str] = []
    skipped_required_ids: list[str] = []
    errored_ids: list[str] = []

    for test_id, meta in tests_by_id.items():
        ts = tier_scores.get(meta["tier"])
        if ts is None:
            continue
        weight = float(meta["points"]) * ts.multiplier
        skippable = bool(meta.get("skippable", False))
        result = results_by_id.get(test_id)
        if result is None:
            # Missing = treat as a skipped-required test: counts against score.
            counts["missing"] += 1
            skipped_required_ids.append(test_id)
            continue
        status = result["status"]
        if status == "passed":
            ts.earned += weight
            ts.passed += 1
            counts["passed"] += 1
        elif status == "failed":
            ts.failed += 1
            counts["failed"] += 1
            failed_ids.append(test_id)
        elif status == "skipped":
            ts.skipped += 1
            counts["skipped"] += 1
            skipped_ids.append(test_id)
            if skippable:
                ts.skippable_skipped += 1
            else:
                skipped_required_ids.append(test_id)
        elif status == "errored":
            ts.errored += 1
            counts["errored"] += 1
            errored_ids.append(test_id)
            failed_ids.append(test_id)  # surfaced in both buckets

    # Compute per-tier denominator (possible minus skippable-skip weight).
    # Since skippable tests all carry the same weight as any other test of the
    # same base points, we subtract the exact weight of each skippable-skip.
    for meta_id, meta in tests_by_id.items():
        ts = tier_scores.get(meta["tier"])
        if ts is None:
            continue
        result = results_by_id.get(meta_id)
        ts.denom = ts.possible  # start with full
    for ts in tier_scores.values():
        ts.denom = ts.possible
    for meta_id, meta in tests_by_id.items():
        if not meta.get("skippable"):
            continue
        result = results_by_id.get(meta_id)
        if result is None or result["status"] != "skipped":
            continue
        ts = tier_scores.get(meta["tier"])
        if ts is None:
            continue
        ts.denom -= float(meta["points"]) * ts.multiplier

    total_possible = sum(t.possible for t in tier_scores.values())
    total_denom = sum(t.denom for t in tier_scores.values())
    total_earned = sum(t.earned for t in tier_scores.values())

    pct = (total_earned / total_denom * 100.0) if total_denom > 0 else 0.0
    raw_pct = (total_earned / total_possible * 100.0) if total_possible > 0 else 0.0

    attempted = counts["passed"] + counts["failed"] + counts["errored"]
    required_total = len(tests_by_id) - sum(
        1 for mid, m in tests_by_id.items()
        if m.get("skippable") and results_by_id.get(mid, {}).get("status") == "skipped"
    )
    coverage = (attempted / required_total * 100.0) if required_total > 0 else 0.0

    return Scorecard(
        agent_name=agent_name,
        total_possible=round(total_possible, 2),
        total_denom=round(total_denom, 2),
        total_earned=round(total_earned, 2),
        percentage=round(pct, 1),
        raw_percentage=round(raw_pct, 1),
        coverage=round(coverage, 1),
        counts=counts,
        tiers=sorted(tier_scores.values(), key=lambda t: t.slug),
        failed_ids=failed_ids,
        skipped_ids=skipped_ids,
        skipped_required_ids=skipped_required_ids,
        errored_ids=errored_ids,
        focus_areas=_derive_focus(tier_scores),
    )


def _derive_focus(tier_scores: dict[str, TierScore]) -> list[str]:
    ranked: list[tuple[float, str]] = []
    for ts in tier_scores.values():
        if ts.denom <= 0:
            continue
        ratio = ts.earned / ts.denom
        ranked.append((ratio, ts.label))
    ranked.sort()
    return [label for _, label in ranked[:3]]


def render_text(card: Scorecard) -> str:
    lines: list[str] = []
    bar = "=" * 72
    lines.append(bar)
    lines.append(f"  Scorecard - {card.agent_name}")
    lines.append(bar)
    lines.append(
        f"  Score:    {card.total_earned:.1f} / {card.total_denom:.1f}  ({card.percentage:.1f}%)"
    )
    lines.append(
        f"  Raw:      {card.total_earned:.1f} / {card.total_possible:.1f}  ({card.raw_percentage:.1f}%)  "
        f"[treats all skips as 0]"
    )
    lines.append(
        f"  Coverage: {card.coverage:.1f}%  [fraction of required tests actually attempted]"
    )
    c = card.counts
    lines.append(
        f"  Tests:    {c['passed']} passed | {c['failed']} failed | "
        f"{c['skipped']} skipped | {c['errored']} errored | {c['missing']} missing"
    )
    lines.append("")
    lines.append("  Tier breakdown (Denom = possible minus optional-skips):")
    lines.append(
        f"  {'Tier':<22} {'Earned':>8} {'Denom':>8} {'Possible':>10} {'Pass':>5} {'Fail':>5} {'Skip':>5}"
    )
    for t in card.tiers:
        lines.append(
            f"  {t.label:<22} {t.earned:>8.1f} {t.denom:>8.1f} {t.possible:>10.1f} "
            f"{t.passed:>5} {t.failed:>5} {t.skipped:>5}"
        )
    if card.failed_ids:
        lines.append("")
        lines.append("  Failed:")
        for tid in card.failed_ids:
            lines.append(f"    - {tid}")
    if card.skipped_required_ids:
        lines.append("")
        lines.append("  Skipped (counts against score):")
        for tid in card.skipped_required_ids:
            lines.append(f"    - {tid}")
    optional_skips = [tid for tid in card.skipped_ids if tid not in card.skipped_required_ids]
    if optional_skips:
        lines.append("")
        lines.append("  Skipped (optional — excluded from denominator):")
        for tid in optional_skips:
            lines.append(f"    - {tid}")
    if card.focus_areas:
        lines.append("")
        lines.append("  Suggested focus areas: " + ", ".join(card.focus_areas))
    lines.append(bar)
    return "\n".join(lines)

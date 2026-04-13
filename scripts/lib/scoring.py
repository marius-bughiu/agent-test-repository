"""Scoring library for the agent test repository.

Loads the rubric and tier metadata (JSON), aggregates test results, and
produces a scorecard. Standard-library only — no pyyaml, no jsonschema.

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
    possible: float = 0.0
    earned: float = 0.0
    passed: int = 0
    failed: int = 0
    skipped: int = 0
    errored: int = 0
    total: int = 0


@dataclass
class Scorecard:
    agent_name: str
    total_possible: float
    total_earned: float
    percentage: float
    counts: dict[str, int] = field(default_factory=dict)
    tiers: list[TierScore] = field(default_factory=list)
    failed_ids: list[str] = field(default_factory=list)
    skipped_ids: list[str] = field(default_factory=list)
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

    # Possible points per tier from the rubric (full set).
    for meta in tests_by_id.values():
        tier = meta["tier"]
        ts = tier_scores.get(tier)
        if ts is None:
            continue
        ts.possible += float(meta["points"]) * ts.multiplier
        ts.total += 1

    counts = {"passed": 0, "failed": 0, "skipped": 0, "errored": 0, "missing": 0}
    failed_ids: list[str] = []
    skipped_ids: list[str] = []
    errored_ids: list[str] = []

    for test_id, meta in tests_by_id.items():
        ts = tier_scores.get(meta["tier"])
        if ts is None:
            continue
        result = results_by_id.get(test_id)
        if result is None:
            counts["missing"] += 1
            continue
        status = result["status"]
        if status == "passed":
            ts.earned += float(meta["points"]) * ts.multiplier
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
        elif status == "errored":
            ts.errored += 1
            counts["errored"] += 1
            errored_ids.append(test_id)

    total_possible = sum(t.possible for t in tier_scores.values())
    adjusted_possible = total_possible
    for ts in tier_scores.values():
        if ts.total > 0 and ts.skipped > 0:
            adjusted_possible -= (ts.skipped / ts.total) * ts.possible

    total_earned = sum(t.earned for t in tier_scores.values())
    pct = (total_earned / adjusted_possible * 100.0) if adjusted_possible > 0 else 0.0

    return Scorecard(
        agent_name=agent_name,
        total_possible=round(adjusted_possible, 2),
        total_earned=round(total_earned, 2),
        percentage=round(pct, 1),
        counts=counts,
        tiers=sorted(tier_scores.values(), key=lambda t: t.slug),
        failed_ids=failed_ids,
        skipped_ids=skipped_ids,
        errored_ids=errored_ids,
        focus_areas=_derive_focus(tier_scores),
    )


def _derive_focus(tier_scores: dict[str, TierScore]) -> list[str]:
    ranked: list[tuple[float, str]] = []
    for ts in tier_scores.values():
        denom = ts.possible - (ts.skipped / ts.total * ts.possible if ts.total else 0)
        if denom <= 0:
            continue
        ratio = ts.earned / denom
        ranked.append((ratio, ts.label))
    ranked.sort()
    return [label for _, label in ranked[:3]]


def render_text(card: Scorecard) -> str:
    lines: list[str] = []
    bar = "=" * 64
    lines.append(bar)
    lines.append(f"  Scorecard - {card.agent_name}")
    lines.append(bar)
    lines.append(
        f"  Score: {card.total_earned:.1f} / {card.total_possible:.1f}  ({card.percentage:.1f}%)"
    )
    c = card.counts
    lines.append(
        f"  Tests: {c['passed']} passed | {c['failed']} failed | "
        f"{c['skipped']} skipped | {c['errored']} errored | {c['missing']} missing"
    )
    lines.append("")
    lines.append("  Tier breakdown:")
    lines.append(f"  {'Tier':<22} {'Earned':>8} {'Possible':>10} {'Pass':>5} {'Fail':>5} {'Skip':>5}")
    for t in card.tiers:
        lines.append(
            f"  {t.label:<22} {t.earned:>8.1f} {t.possible:>10.1f} "
            f"{t.passed:>5} {t.failed:>5} {t.skipped:>5}"
        )
    if card.failed_ids:
        lines.append("")
        lines.append("  Failed:")
        for tid in card.failed_ids:
            lines.append(f"    - {tid}")
    if card.skipped_ids:
        lines.append("")
        lines.append("  Skipped:")
        for tid in card.skipped_ids:
            lines.append(f"    - {tid}")
    if card.focus_areas:
        lines.append("")
        lines.append("  Suggested focus areas: " + ", ".join(card.focus_areas))
    lines.append(bar)
    return "\n".join(lines)

"""Draw unity-feedback block diagram (Chapter 3 intro, Figure A)."""

from __future__ import annotations

import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch, Rectangle


def _setup_fonts() -> None:
    plt.rcParams["font.family"] = ["MS Gothic", "Yu Gothic", "Meiryo", "sans-serif"]
    plt.rcParams["axes.unicode_minus"] = False
    plt.rcParams["mathtext.fontset"] = "cm"


def _arrow_head(ax, x0: float, y0: float, x1: float, y1: float) -> None:
    ax.add_patch(
        FancyArrowPatch(
            (x0, y0),
            (x1, y1),
            arrowstyle="-|>",
            mutation_scale=9,
            lw=0,
            color="black",
            shrinkA=0,
            shrinkB=0,
            zorder=2,
        )
    )


def _wire_h(ax, x0: float, x1: float, y: float) -> None:
    ax.plot([x0, x1], [y, y], color="black", lw=1.8, solid_capstyle="butt", zorder=1)


def _wire_v(ax, x: float, y0: float, y1: float) -> None:
    ax.plot([x, x], [y0, y1], color="black", lw=1.8, solid_capstyle="butt", zorder=1)


def _wire_h_arrow(ax, x0: float, x1: float, y: float) -> None:
    if x1 >= x0:
        _wire_h(ax, x0, x1, y)
        _arrow_head(ax, x1 - 0.05, y, x1, y)
    else:
        _wire_h(ax, x0, x1, y)
        _arrow_head(ax, x1 + 0.05, y, x1, y)


def _wire_v_arrow(ax, x: float, y0: float, y1: float) -> None:
    if y1 >= y0:
        _wire_v(ax, x, y0, y1)
        _arrow_head(ax, x, y1 - 0.05, x, y1)
    else:
        _wire_v(ax, x, y0, y1)
        _arrow_head(ax, x, y1 + 0.05, x, y1)


def _junction_dot(ax, x: float, y: float, r: float = 0.045) -> None:
    ax.add_patch(Circle((x, y), r, fill=True, facecolor="black", edgecolor="black", lw=0, zorder=5))


def _block(ax, cx: float, cy: float, w: float, h: float, label: str) -> tuple[float, float, float, float]:
    left = cx - w / 2
    bottom = cy - h / 2
    ax.add_patch(
        Rectangle((left, bottom), w, h, fill=True, facecolor="white", edgecolor="black", lw=1.8, zorder=3)
    )
    ax.text(cx, cy, label, ha="center", va="center", fontsize=13, zorder=4)
    return left, bottom, w, h


def draw(output_path: str) -> None:
    """Render unity-feedback diagram and save to output_path (PNG)."""
    _setup_fonts()

    fig, ax = plt.subplots(figsize=(5.6, 2.2), dpi=160)
    ax.axis("off")
    fig.patch.set_facecolor("white")

    y = 2.0
    fb_y = 1.05
    sum_r = 0.11
    gap = 0.28
    bw, bh = 0.92, 0.52

    sx = 1.25
    c_left = sx + sum_r + gap
    cx_c = c_left + bw / 2
    g_left = c_left + bw + gap
    cx_g = g_left + bw / 2
    g_right = g_left + bw
    x_tap = g_right + 0.32
    x_y = x_tap + 0.38
    x_right = x_y + 0.22
    x_left = 0.18

    c_left, _, _, _ = _block(ax, cx_c, y, bw, bh, r"$C(s)$")
    g_left, _, g_w, _ = _block(ax, cx_g, y, bw, bh, r"$G(s)$")
    c_right = c_left + bw
    g_right = g_left + g_w

    ax.add_patch(Circle((sx, y), sum_r, fill=True, facecolor="white", edgecolor="black", lw=1.8, zorder=3))
    ax.text(sx - sum_r - 0.04, y + 0.22, "+", ha="center", va="center", fontsize=11, zorder=4)
    ax.text(sx + 0.22, y - sum_r - 0.12, "−", ha="center", va="center", fontsize=11, zorder=4)

    # Forward path
    _wire_h_arrow(ax, x_left + 0.12, sx - sum_r, y)
    _wire_h_arrow(ax, sx + sum_r, c_left, y)
    _wire_h_arrow(ax, c_right, g_left, y)
    _wire_h(ax, g_right, x_y, y)
    _arrow_head(ax, x_y - 0.05, y, x_y, y)
    _junction_dot(ax, x_tap, y)

    # Feedback: tap → down → left → up into Σ (arrow at minus input only)
    _wire_v(ax, x_tap, y, fb_y)
    _wire_h(ax, x_tap, sx, fb_y)
    _wire_v_arrow(ax, sx, fb_y, y - sum_r)

    ax.text(x_left + 0.12, y + 0.13, r"$r$", ha="left", va="bottom", fontsize=12)
    ax.text((sx + sum_r + c_left) / 2, y + 0.13, r"$e$", ha="center", va="bottom", fontsize=11)
    ax.text(x_y, y + 0.13, r"$y$", ha="right", va="bottom", fontsize=12)

    ax.text((c_right + g_left) / 2, y + 0.48, r"$L(s)=C(s)G(s)$", ha="center", va="bottom", fontsize=11)
    ax.text(cx_c, y - bh / 2 - 0.18, "制御器", ha="center", va="top", fontsize=9, color="0.35")
    ax.text(cx_g, y - bh / 2 - 0.18, "プラント", ha="center", va="top", fontsize=9, color="0.35")

    ax.set_xlim(x_left, x_right)
    ax.set_ylim(fb_y - 0.18, y + 0.72)

    fig.savefig(output_path, bbox_inches="tight", pad_inches=0.04, facecolor="white", transparent=False)
    plt.close(fig)


if __name__ == "__main__":
    import pathlib

    out = pathlib.Path(__file__).resolve().parent / "unity_feedback.png"
    draw(str(out))
    print(f"saved: {out}")

"""Draw linear translational motion diagram (section 1.5)."""

from __future__ import annotations

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Rectangle


def _setup_fonts() -> None:
    plt.rcParams["font.family"] = ["MS Gothic", "Yu Gothic", "Meiryo", "sans-serif"]
    plt.rcParams["axes.unicode_minus"] = False
    plt.rcParams["mathtext.fontset"] = "cm"


def _arrow(
    ax,
    x0: float,
    y0: float,
    x1: float,
    y1: float,
    *,
    lw: float = 1.8,
    color: str = "black",
) -> None:
    ax.add_patch(
        FancyArrowPatch(
            (x0, y0),
            (x1, y1),
            arrowstyle="-|>",
            mutation_scale=12,
            lw=lw,
            color=color,
            shrinkA=0,
            shrinkB=0,
            zorder=4,
        )
    )


def _junction_dot(ax, x: float, y: float, pt: float = 6.5) -> None:
    ax.scatter(
        [x],
        [y],
        s=pt**2,
        marker="o",
        facecolors="black",
        edgecolors="black",
        linewidths=0,
        zorder=6,
        clip_on=False,
    )


def _ground_hatch(ax, x0: float, x1: float, y: float) -> None:
    step = 0.18
    x = x0
    while x <= x1 + 1e-9:
        ax.plot([x, x - 0.12], [y, y - 0.16], color="black", lw=1.0, zorder=1)
        x += step


def draw(output_path: str) -> None:
    """Render block on a plane: F and F_L from mass center; c·v at ground height."""
    _setup_fonts()

    fig, ax = plt.subplots(figsize=(6.8, 2.6), dpi=160)
    ax.axis("off")
    fig.patch.set_facecolor("white")

    y_ground = 0.55
    x_left, x_right = 0.25, 6.55

    block_w, block_h = 1.55, 0.95
    block_left = 2.95
    block_bottom = y_ground
    block_cx = block_left + block_w / 2
    block_cy = block_bottom + block_h / 2

    ax.set_xlim(x_left, x_right)
    ax.set_ylim(-0.05, 2.35)

    # Ground: 1 pt line (full width; c·v arrow sits on this line)
    ax.plot([x_left, x_right], [y_ground, y_ground], color="black", lw=1.0, solid_capstyle="butt", zorder=1)
    _ground_hatch(ax, x_left, x_right, y_ground)

    ax.add_patch(
        Rectangle(
            (block_left, block_bottom),
            block_w,
            block_h,
            fill=True,
            facecolor="white",
            edgecolor="black",
            lw=2.0,
            zorder=3,
        )
    )
    block_top = block_bottom + block_h
    ax.text(block_cx, block_top + 0.07, r"$m$", ha="center", va="bottom", fontsize=16, zorder=5)

    ox, oy = block_cx, block_cy
    f_len = 1.12
    fl_len = 0.46

    label_dy = 0.11

    # F, F_L from the mass center (horizontal)
    _arrow(ax, ox, oy, ox + f_len, oy)
    ax.text((ox + ox + f_len) / 2, oy + label_dy, r"$F$", ha="center", va="bottom", fontsize=13)

    flx1 = ox - fl_len
    _arrow(ax, ox, oy, flx1, oy)
    ax.text((ox + flx1) / 2, oy + label_dy, r"$F_L$", ha="center", va="bottom", fontsize=13)

    _junction_dot(ax, ox, oy)

    # c·v on the ground at the block–surface contact (leftward, shaft on ground line)
    cv_y = y_ground
    cv_x0 = block_left
    cv_x1 = block_left - 0.78
    _arrow(ax, cv_x0, cv_y, cv_x1, cv_y)
    ax.text((cv_x0 + cv_x1) / 2, cv_y + label_dy, r"$c\,v$", ha="center", va="bottom", fontsize=12)

    # Velocity v above the block
    v_y = block_bottom + block_h + 0.42
    v_x0 = block_cx - 0.35
    v_x1 = block_cx + 0.55
    _arrow(ax, v_x0, v_y, v_x1, v_y)
    ax.text((v_x0 + v_x1) / 2, v_y + label_dy, r"$v$", ha="center", va="bottom", fontsize=12)

    fig.savefig(output_path, bbox_inches="tight", pad_inches=0.05, facecolor="white", transparent=False)
    plt.close(fig)


if __name__ == "__main__":
    import pathlib

    out = pathlib.Path(__file__).resolve().parent / "linear_motion.png"
    draw(str(out))
    print(f"saved: {out}")

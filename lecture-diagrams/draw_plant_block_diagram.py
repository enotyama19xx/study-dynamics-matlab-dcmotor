"""Draw DC motor plant block diagram (section 3.1, Figure B)."""

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


def _pt_dx_to_data(ax, pt: float) -> float:
    fig = ax.figure
    fig.canvas.draw()
    p0 = ax.transData.transform((0.0, 0.0))
    p1 = (p0[0] + pt * fig.dpi / 72.0, p0[1])
    x1, _ = ax.transData.inverted().transform(p1)
    return x1


def _junction_dot(ax, x: float, y: float, r: float = 0.045) -> None:
    ax.add_patch(Circle((x, y), r, fill=True, facecolor="black", edgecolor="black", lw=0, zorder=5))


def _sum_junction(ax, sx: float, y: float, sum_pt: float = 13.0) -> None:
    ax.scatter(
        [sx],
        [y],
        s=sum_pt**2,
        facecolors="white",
        edgecolors="black",
        linewidths=1.8,
        zorder=3,
        clip_on=False,
    )


def _sum_sign(ax, sx: float, y: float, sign: str, dx_pt: float, dy_pt: float) -> None:
    ax.annotate(
        sign,
        xy=(sx, y),
        xytext=(dx_pt, dy_pt),
        textcoords="offset points",
        ha="center",
        va="center",
        fontsize=11,
        zorder=6,
        annotation_clip=False,
    )


def _block(ax, cx: float, cy: float, w: float, h: float, label: str, fontsize: float = 10.5) -> tuple[float, float, float, float]:
    left = cx - w / 2
    bottom = cy - h / 2
    ax.add_patch(
        Rectangle((left, bottom), w, h, fill=True, facecolor="white", edgecolor="black", lw=1.8, zorder=3)
    )
    ax.text(cx, cy, label, ha="center", va="center", fontsize=fontsize, zorder=4)
    return left, bottom, w, h


def draw(output_path: str) -> None:
    """Render plant block diagram: V -> 1/(Ls+R) -> i -> K_t -> T_m -> 1/(Js+B) -> omega, Ke feedback."""
    _setup_fonts()

    fig, ax = plt.subplots(figsize=(7.6, 2.35), dpi=160)
    ax.axis("off")
    fig.patch.set_facecolor("white")

    y = 2.0
    fb_y = 1.0
    sum_pt = 13.0
    gap = 0.20
    bw_elec, bh = 0.76, 0.54
    bw_kt, bh_kt = 0.46, 0.50
    bw_mech = 0.76
    ke_w, ke_h = 0.52, 0.44

    x_left = 0.18
    sx = 1.05
    sum_r_layout = 0.11

    gi_left = sx + sum_r_layout + gap
    gi_right = gi_left + bw_elec
    kt_left = gi_right + gap
    kt_right = kt_left + bw_kt
    jm_left = kt_right + gap
    jm_right = jm_left + bw_mech
    x_tap = jm_right + 0.24
    x_omega = x_tap + 0.32
    x_right = x_omega + 0.18

    cx_gi = gi_left + bw_elec / 2
    cx_kt = kt_left + bw_kt / 2
    cx_jm = jm_left + bw_mech / 2
    cx_ke = (x_tap + sx) / 2

    ax.set_xlim(x_left, x_right)
    ax.set_ylim(fb_y - 0.22, y + 0.52)
    sum_r = _pt_dx_to_data(ax, sum_pt / 2)

    _block(ax, cx_gi, y, bw_elec, bh, r"$\dfrac{1}{Ls+R}$")
    _block(ax, cx_kt, y, bw_kt, bh_kt, r"$K_t$", fontsize=12)
    _block(ax, cx_jm, y, bw_mech, bh, r"$\dfrac{1}{Js+B}$")
    ke_left, _, ke_w, _ = _block(ax, cx_ke, fb_y, ke_w, ke_h, r"$K_e$", fontsize=12)
    ke_right = ke_left + ke_w

    _sum_junction(ax, sx, y, sum_pt)

    # Forward path: V -> Σ -> 1/(Ls+R) -> i -> K_t -> T_m -> 1/(Js+B) -> ω
    _wire_h_arrow(ax, x_left + 0.1, sx - sum_r, y)
    _wire_h_arrow(ax, sx + sum_r, gi_left, y)
    _wire_h_arrow(ax, gi_right, kt_left, y)
    _wire_h_arrow(ax, kt_right, jm_left, y)
    _wire_h(ax, jm_right, x_omega, y)
    _arrow_head(ax, x_omega - 0.05, y, x_omega, y)
    _junction_dot(ax, x_tap, y)

    # Back-EMF feedback: ω -> down -> Ke -> left -> up into Σ
    _wire_v(ax, x_tap, y, fb_y)
    _wire_h(ax, x_tap, ke_right, fb_y)
    _wire_h(ax, ke_left, sx, fb_y)
    _wire_v_arrow(ax, sx, fb_y, y - sum_r)

    _sum_sign(ax, sx, y, "+", -17, 4)
    _sum_sign(ax, sx, y, "−", 8, -9)

    ax.text(x_left + 0.1, y + 0.13, r"$V$", ha="left", va="bottom", fontsize=12)
    ax.text((gi_right + kt_left) / 2, y + 0.14, r"$i$", ha="center", va="bottom", fontsize=11)
    ax.text((kt_right + jm_left) / 2, y + 0.14, r"$T_m$", ha="center", va="bottom", fontsize=11)
    ax.text(x_omega, y + 0.13, r"$\omega$", ha="right", va="bottom", fontsize=12)
    ax.text(cx_gi, y - bh / 2 - 0.18, "電気側", ha="center", va="top", fontsize=9, color="0.35")
    ax.text(cx_jm, y - bh / 2 - 0.18, "機械側", ha="center", va="top", fontsize=9, color="0.35")

    ax.set_xlim(x_left, x_right)
    ax.set_ylim(fb_y - 0.22, y + 0.52)

    fig.savefig(output_path, bbox_inches="tight", pad_inches=0.04, facecolor="white", transparent=False)
    plt.close(fig)


if __name__ == "__main__":
    import pathlib

    out = pathlib.Path(__file__).resolve().parent / "plant_block_diagram.png"
    draw(str(out))
    print(f"saved: {out}")

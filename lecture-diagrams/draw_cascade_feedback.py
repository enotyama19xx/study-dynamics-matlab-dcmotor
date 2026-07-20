"""Draw cascade speed/current feedback block diagram (section 3.4)."""

from __future__ import annotations

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Rectangle


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


def _junction_dot(ax, x: float, y: float, pt: float = 6.0) -> None:
    """Tap node drawn in point units so it stays circular when axes are stretched."""
    ax.scatter(
        [x],
        [y],
        s=pt**2,
        marker="o",
        facecolors="black",
        edgecolors="black",
        linewidths=0,
        zorder=5,
        clip_on=False,
    )


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


def _block(
    ax, cx: float, cy: float, w: float, h: float, label: str, fontsize: float = 10.5
) -> tuple[float, float, float, float]:
    left = cx - w / 2
    bottom = cy - h / 2
    ax.add_patch(
        Rectangle((left, bottom), w, h, fill=True, facecolor="white", edgecolor="black", lw=1.8, zorder=3)
    )
    ax.text(cx, cy, label, ha="center", va="center", fontsize=fontsize, zorder=4)
    return left, bottom, w, h


def draw(output_path: str) -> None:
    """Render cascade feedback: outer speed loop, inner current loop, Ke disturbance."""
    _setup_fonts()

    fig, ax = plt.subplots(figsize=(10.2, 2.85), dpi=160)
    ax.axis("off")
    fig.patch.set_facecolor("white")

    y = 2.55
    fb_i_y = 1.78
    fb_ke_y = 1.08
    fb_w_y = 0.48
    sum_pt = 13.0
    gap = 0.18
    bw_ctrl = 0.86
    bw_gi = 0.74
    bw_gw = 0.80
    bh = 0.50
    ke_w, ke_h = 0.50, 0.42

    x_left = 0.12
    sx_w = 0.95

    ax.set_xlim(x_left, 7.35)
    ax.set_ylim(fb_w_y - 0.16, y + 0.55)
    sum_r = _pt_dx_to_data(ax, sum_pt / 2)

    # Block positions (left edges computed from forward path)
    csp_left = sx_w + sum_r + gap
    csp_right = csp_left + bw_ctrl
    cx_csp = csp_left + bw_ctrl / 2

    sx_i = csp_right + gap + sum_r
    ccur_left = sx_i + sum_r + gap
    ccur_right = ccur_left + bw_ctrl
    cx_ccur = ccur_left + bw_ctrl / 2

    sx_v = ccur_right + gap + sum_r
    gi_left = sx_v + sum_r + gap
    gi_right = gi_left + bw_gi
    cx_gi = gi_left + bw_gi / 2

    gw_left = gi_right + gap
    gw_right = gw_left + bw_gw
    cx_gw = gw_left + bw_gw / 2

    x_tap = gw_right + 0.18
    x_omega = x_tap + 0.28
    x_right = x_omega + 0.14

    cx_ke = (x_tap + sx_v) / 2

    _block(ax, cx_csp, y, bw_ctrl, bh, r"$C_{\mathrm{speed}}(s)$")
    _block(ax, cx_ccur, y, bw_ctrl, bh, r"$C_{\mathrm{curr}}(s)$")
    _block(ax, cx_gi, y, bw_gi, bh, r"$\dfrac{1}{Ls+R}$")
    _block(ax, cx_gw, y, bw_gw, bh, r"$\dfrac{K_t}{Js+B}$")
    ke_left, _, _, _ = _block(ax, cx_ke, fb_ke_y, ke_w, ke_h, r"$K_e$", fontsize=12)
    ke_right = ke_left + ke_w

    for sx in (sx_w, sx_i, sx_v):
        _sum_junction(ax, sx, y, sum_pt)

    # Forward path
    _wire_h_arrow(ax, x_left + 0.08, sx_w - sum_r, y)
    _wire_h_arrow(ax, sx_w + sum_r, csp_left, y)
    _wire_h_arrow(ax, csp_right, sx_i - sum_r, y)
    _wire_h_arrow(ax, sx_i + sum_r, ccur_left, y)
    _wire_h_arrow(ax, ccur_right, sx_v - sum_r, y)
    _wire_h_arrow(ax, sx_v + sum_r, gi_left, y)
    _wire_h_arrow(ax, gi_right, gw_left, y)
    _wire_h(ax, gw_right, x_omega, y)
    _arrow_head(ax, x_omega - 0.05, y, x_omega, y)
    _junction_dot(ax, x_tap, y)

    # Inner current feedback: i tap between G_i and G_omega
    x_i_tap = (gi_right + gw_left) / 2
    _junction_dot(ax, x_i_tap, y)
    _wire_v(ax, x_i_tap, y, fb_i_y)
    _wire_h(ax, x_i_tap, sx_i, fb_i_y)
    _wire_v_arrow(ax, sx_i, fb_i_y, y - sum_r)

    # Back-EMF disturbance into voltage sum
    _wire_v(ax, x_tap, y, fb_ke_y)
    _wire_h(ax, x_tap, ke_right, fb_ke_y)
    _wire_h(ax, ke_left, sx_v, fb_ke_y)
    _wire_v_arrow(ax, sx_v, fb_ke_y, y - sum_r)

    # Outer speed feedback
    _wire_v(ax, x_tap, y, fb_w_y)
    _wire_h(ax, x_tap, sx_w, fb_w_y)
    _wire_v_arrow(ax, sx_w, fb_w_y, y - sum_r)

    # Summing junction signs
    _sum_sign(ax, sx_w, y, "+", -17, 4)
    _sum_sign(ax, sx_w, y, "−", 8, -9)
    _sum_sign(ax, sx_i, y, "+", -17, 4)
    _sum_sign(ax, sx_i, y, "−", 8, -9)
    _sum_sign(ax, sx_v, y, "+", -17, 4)
    _sum_sign(ax, sx_v, y, "−", 8, -9)

    # Signal labels
    ax.text(x_left + 0.08, y + 0.13, r"$\omega_{\mathrm{ref}}$", ha="left", va="bottom", fontsize=11)
    ax.text((csp_right + sx_i - sum_r) / 2, y + 0.13, r"$i_{\mathrm{ref}}$", ha="center", va="bottom", fontsize=10)
    ax.text((ccur_right + sx_v - sum_r) / 2, y + 0.13, r"$V$", ha="center", va="bottom", fontsize=11)
    ax.text(x_i_tap, y + 0.13, r"$i$", ha="center", va="bottom", fontsize=11)
    ax.text(x_omega, y + 0.13, r"$\omega$", ha="right", va="bottom", fontsize=12)

    # Role labels
    ax.text(cx_csp, y - bh / 2 - 0.17, "速度制御器（外側）", ha="center", va="top", fontsize=9, color="0.35")
    ax.text(cx_ccur, y - bh / 2 - 0.17, "電流制御器（内側）", ha="center", va="top", fontsize=9, color="0.35")
    ax.text(cx_gi, y - bh / 2 - 0.17, "電気側", ha="center", va="top", fontsize=9, color="0.35")
    ax.text(cx_gw, y - bh / 2 - 0.17, "機械側", ha="center", va="top", fontsize=9, color="0.35")

    ax.set_xlim(x_left, x_right)
    ax.set_ylim(fb_w_y - 0.16, y + 0.55)

    fig.savefig(output_path, bbox_inches="tight", pad_inches=0.04, facecolor="white", transparent=False)
    plt.close(fig)


if __name__ == "__main__":
    import pathlib

    out = pathlib.Path(__file__).resolve().parent / "cascade_block_diagram.png"
    draw(str(out))
    print(f"saved: {out}")

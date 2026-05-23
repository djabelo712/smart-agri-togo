#!/usr/bin/env python3
"""Génère des icônes launcher placeholder (vert #1B6B3A) pour SmartFarm Togo."""

from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Installer Pillow : pip install Pillow")
    raise SystemExit(1)

ROOT = Path(__file__).resolve().parent.parent / "assets" / "icon"
GREEN = (0x1B, 0x6B, 0x3A, 0xFF)
WHITE = (0xFF, 0xFF, 0xFF, 0xFF)


def draw_leaf(draw: ImageDraw.ImageDraw, cx: int, cy: int, size: int) -> None:
    """Feuille simple (Material eco style, pas d'icône IA)."""
    w, h = size // 3, size // 2
    draw.ellipse(
        [cx - w, cy - h, cx + w, cy + h],
        fill=WHITE,
    )
    draw.rectangle(
        [cx - 2, cy, cx + 2, cy + h],
        fill=WHITE,
    )


def make_icon(path: Path, px: int, with_leaf: bool = True) -> None:
    img = Image.new("RGBA", (px, px), GREEN)
    if with_leaf:
        draw = ImageDraw.Draw(img)
        draw_leaf(draw, px // 2, px // 2 - px // 16, px)
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, "PNG")
    print(f"Créé : {path}")


def main() -> None:
    make_icon(ROOT / "icon_512.png", 512)
    make_icon(ROOT / "icon_foreground.png", 432)
    print("Exécuter : dart run flutter_launcher_icons")


if __name__ == "__main__":
    main()

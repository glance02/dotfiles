"""Build Soft Blue 18 assets and a configuration-based preview.

Requires Python 3.10+, Pillow, fonttools and PyYAML. No Android screenshot is
fabricated: previews use the actual YAML, bundled font and source nine-patches.

First build (Nunito sources: https://github.com/google/fonts/tree/main/ofl/nunito):
  python soft_blue_18.py --font-source Nunito.ttf --font-license OFL.txt
Subsequent builds reuse fonts/SoftBlue18.ttf:
  python soft_blue_18.py
Installation uses Git synchronization; this script does not package Rime data
or generate device-specific default configuration files.
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path
import shutil
import sys

from PIL import Image, ImageDraw, ImageFont
import yaml

ROOT = Path(__file__).resolve().parents[3]
THEME = ROOT / "soft_blue_18.trime.yaml"
ASSETS = ROOT / "backgrounds/soft_blue_18"
FONTS = ROOT / "fonts"
OUTPUT = ROOT / "others/themes/soft_blue_18"
FONT = FONTS / "SoftBlue18.ttf"


def build_font(source: Path, license_file: Path) -> None:
    """Add original outline icons to a static, renamed OFL Nunito derivative."""
    from fontTools.ttLib import TTFont
    from fontTools.pens.ttGlyphPen import TTGlyphPen
    from fontTools.pens.transformPen import TransformPen
    from fontTools.varLib.instancer import instantiateVariableFont

    font = TTFont(source)
    if "fvar" in font:
        font = instantiateVariableFont(font, {"wght": 650}, inplace=True)
    upm = font["head"].unitsPerEm
    order = font.getGlyphOrder()
    names = font["name"]
    replacements = {
        1: "Soft Blue 18", 2: "Regular", 3: "SoftBlue18-1.0",
        4: "Soft Blue 18 Regular", 6: "SoftBlue18-Regular",
        16: "Soft Blue 18", 17: "Regular",
    }
    for record in names.names:
        if record.nameID in replacements:
            record.string = replacements[record.nameID].encode(record.getEncoding())

    # All coordinates below are original geometric artwork, not copied icons.
    for icon in range(12):
        pen = TTGlyphPen(None)
        p = TransformPen(pen, (upm / 1000, 0, 0, upm / 1000, 0, 0))

        def polygon(points, reverse=False):
            points = [(500 + (x - 500) * .9, (y - 100) * .85) for x, y in points]
            if reverse:
                points.reverse()
            p.moveTo(points[0])
            for point in points[1:]:
                p.lineTo(point)
            p.closePath()

        def circle(x, y, radius, reverse=False):
            polygon([(x + radius * math.cos(i * math.tau / 48),
                      y + radius * math.sin(i * math.tau / 48)) for i in range(48)], reverse)

        def line(points, width=55):
            for (x1, y1), (x2, y2) in zip(points, points[1:]):
                distance = math.hypot(x2 - x1, y2 - y1)
                if not distance:
                    continue
                dx, dy = -(y2 - y1) * width / (2 * distance), (x2 - x1) * width / (2 * distance)
                polygon([(x1 + dx, y1 + dy), (x1 - dx, y1 - dy),
                         (x2 - dx, y2 - dy), (x2 + dx, y2 + dy)])
            for x, y in points:
                circle(x, y, width / 2)

        def arc(x, y, radius, start, end, width=55):
            line([(x + radius * math.cos(a), y + radius * math.sin(a))
                  for a in [start + (end - start) * i / 40 for i in range(41)]], width)

        if icon == 0:  # settings
            polygon([(500 + (360 if i % 4 in (0, 1) else 300) * math.cos(i * math.tau / 32),
                      500 + (360 if i % 4 in (0, 1) else 300) * math.sin(i * math.tau / 32))
                     for i in range(32)])
            circle(500, 500, 165, reverse=True)
        elif icon == 1:  # tag
            line([(210, 220), (520, 220), (820, 520), (520, 820),
                  (210, 510), (210, 220)])
            circle(360, 390, 45)
        elif icon == 2:  # schemes / cards
            line([(330, 200), (760, 200), (760, 750), (330, 750), (330, 200)])
            line([(200, 310), (200, 860), (630, 860)])
            line([(430, 430), (650, 430)])
        elif icon == 3:  # clipboard
            line([(310, 740), (210, 740), (210, 180), (790, 180), (790, 740), (690, 740)])
            line([(350, 680), (350, 840), (650, 840), (650, 680), (350, 680)])
        elif icon == 4:  # crescent
            arc(500, 500, 340, math.pi * .65, math.pi * 1.9)
            arc(690, 700, 340, math.pi * 1.05, math.pi * 1.70)
            line([(780, 790), (780, 940)], 38)
            line([(705, 865), (855, 865)], 38)
        elif icon == 5:  # undo
            arc(500, 490, 310, -math.pi * .15, math.pi * .95)
            line([(190, 660), (190, 470), (380, 470)])
        elif icon == 6:  # hide
            line([(220, 650), (500, 370), (780, 650)], 65)
        elif icon == 7:  # symbols
            line([(260, 300), (430, 650)], 120)
            line([(580, 250), (750, 600)], 120)
        elif icon == 8:  # space
            line([(130, 480), (190, 340), (290, 300), (710, 300), (810, 340), (870, 480)], 44)
        elif icon == 9:  # return
            line([(830, 750), (830, 430), (730, 290), (200, 290)], 58)
            line([(290, 430), (160, 290), (300, 160)], 58)
        elif icon == 10:  # backspace
            line([(170, 480), (370, 740), (820, 740), (820, 220), (370, 220), (170, 480)])
            line([(460, 350), (680, 600)])
            line([(460, 600), (680, 350)])
        elif icon == 11:  # shift
            line([(180, 520), (500, 840), (820, 520), (660, 520),
                  (660, 200), (340, 200), (340, 520), (180, 520)])

        glyph_name = f"softblue.icon{icon}"
        order.append(glyph_name)
        glyph = pen.glyph()
        font["glyf"][glyph_name] = glyph
        glyph.recalcBounds(font["glyf"])
        font["hmtx"][glyph_name] = (upm, glyph.xMin)
        for table in font["cmap"].tables:
            if table.isUnicode() and table.format in (4, 12):
                table.cmap[0xE000 + icon] = glyph_name
    font.setGlyphOrder(order)
    font.save(FONT)
    shutil.copyfile(license_file, FONTS / "SoftBlue18-OFL.txt")


def nine_patch(name, face, shadow, rim, panel=False):
    """Write source .9.png with one stretch run and padding markers per axis."""
    size, scale, radius = 194, 3, 38
    image = Image.new("RGBA", (size * scale, size * scale))
    draw = ImageDraw.Draw(image)

    def rounded(bounds, fill):
        draw.rounded_rectangle(tuple(int(v * scale) for v in bounds), radius * scale, fill=fill)

    if panel:
        rounded((1, 1, 192, 193), face)
        draw.rectangle((scale, 90 * scale, 193 * scale - 1, 193 * scale - 1), fill=face)
    else:
        rounded((1, 4, 192, 192), shadow)
        rounded((1, 1, 192, 187), rim)
        rounded((2, 3, 191, 186), face)
    image = image.resize((size, size), Image.Resampling.LANCZOS)
    # The border must contain ONLY transparent/black pixels, with no AA remnants.
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, size - 1, 0), fill=(0, 0, 0, 0))
    draw.rectangle((0, size - 1, size - 1, size - 1), fill=(0, 0, 0, 0))
    draw.rectangle((0, 0, 0, size - 1), fill=(0, 0, 0, 0))
    draw.rectangle((size - 1, 0, size - 1, size - 1), fill=(0, 0, 0, 0))
    for axis in ("x", "y"):
        # Keep rounded corners and keycap bottom edge intact when stretching.
        draw.line((80, 0, 113, 0) if axis == "x" else (0, 80, 0, 113), fill="black")
        draw.line((20, 193, 173, 193) if axis == "x" else (193, 16, 193, 173), fill="black")
    image.save(ASSETS / name)


def build_backgrounds():
    for suffix, face, shadow, rim in [
        ("light", "#F8F8FA", "#BAC0CC", "#FFFFFF"),
        ("light_pressed", "#DEE7FB", "#A9B9D8", "#E8EFFF"),
        ("function", "#CBD2E1", "#B3BCCA", "#D3DAE9"),
        ("function_pressed", "#B6C6E6", "#9CAECC", "#C7D5EF"),
        ("blue", "#1260FF", "#A8B5D0", "#7EABFF"),
        ("blue_pressed", "#094BD1", "#8B9DBD", "#5184ED"),
        ("dark", "#343C4B", "#151B26", "#454F60"),
        ("dark_pressed", "#465B80", "#182237", "#596E96"),
        ("function_dark", "#454F63", "#151B26", "#535F74"),
        ("function_dark_pressed", "#52688D", "#182237", "#657EA5"),
        ("blue_dark", "#80ABFF", "#151B26", "#B3CCFF"),
        ("blue_dark_pressed", "#608FE5", "#151B26", "#90B5FC"),
    ]:
        nine_patch(f"key_{suffix}.9.png", face, shadow, rim)
    nine_patch("panel_light.9.png", "#DDE1ED", "#DDE1ED", "#DDE1ED", panel=True)
    nine_patch("panel_dark.9.png", "#202632", "#202632", "#202632", panel=True)


def stretch_nine_patch(path, width, height):
    """Render the exact source nine-patch grid, including fixed rounded corners."""
    image = Image.open(path).convert("RGBA")
    black = (0, 0, 0, 255)
    xs = [x for x in range(1, image.width - 1) if image.getpixel((x, 0)) == black]
    ys = [y for y in range(1, image.height - 1) if image.getpixel((0, y)) == black]
    assert xs and ys, f"Missing stretch markers: {path}"
    source_x = [1, xs[0], xs[-1] + 1, image.width - 1]
    source_y = [1, ys[0], ys[-1] + 1, image.height - 1]

    def target_edges(source, length):
        left, right = source[1] - 1, source[-1] - source[-2]
        if left + right >= length:
            ratio = (length - 1) / (left + right)
            left, right = int(left * ratio), int(right * ratio)
        return [0, left, length - right, length]

    target_x, target_y = target_edges(source_x, width), target_edges(source_y, height)
    result = Image.new("RGBA", (width, height))
    for row in range(3):
        for col in range(3):
            crop = image.crop((source_x[col], source_y[row], source_x[col + 1], source_y[row + 1]))
            bounds = (target_x[col], target_y[row], target_x[col + 1], target_y[row + 1])
            if bounds[2] > bounds[0] and bounds[3] > bounds[1]:
                result.paste(crop.resize((bounds[2] - bounds[0], bounds[3] - bounds[1])), bounds[:2])
    return result


def resolve_keyboard(theme, name):
    keyboard = theme["preset_keyboards"][name]
    if "import_preset" in keyboard:
        return resolve_keyboard(theme, keyboard["import_preset"])
    return keyboard


def rows_of(keyboard):
    rows, row, total = [], [], 0
    for key in keyboard["keys"]:
        width = key.get("width", keyboard.get("width", 12.5))
        if row and total + width > 100.01:
            assert abs(total - 100) < .01, f"Incomplete row: {total}"
            rows.append(row)
            row, total = [], 0
        row.append((key, width))
        total += width
    assert abs(total - 100) < .01, f"Incomplete final row: {total}"
    rows.append(row)
    return rows


def label_of(theme, token):
    return str(theme["preset_keys"].get(str(token), {}).get("label", token or ""))


def preview(theme, keyboard_name, scheme_name, filename, width=1080, landscape=False):
    """Configuration rendering; not an Android capture or exact font metrics model."""
    style = theme["style"]
    keyboard = resolve_keyboard(theme, keyboard_name)
    scheme = theme["preset_color_schemes"][scheme_name]
    rows = rows_of(keyboard)
    density = 2.75
    toolbar_height = round(style["candidate_view_height"] * density)
    pad = round(style["keyboard_padding_land" if landscape else "keyboard_padding"] * density)
    bottom = round(style["keyboard_padding_bottom"] * density)
    height = round(style["keyboard_height_land" if landscape else "keyboard_height"] * density)
    image = Image.new("RGBA", (width, toolbar_height + height + bottom), scheme["back_color"])
    draw = ImageDraw.Draw(image)
    image.alpha_composite(stretch_nine_patch(ASSETS / scheme["keyboard_back_color"], width, height + bottom), (0, toolbar_height))
    from fontTools.ttLib import TTFont
    font_cmap = TTFont(FONT).getBestCmap()
    system_font = next((p for p in [Path("C:/Windows/Fonts/msyh.ttc"),
                       Path("/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc")]
                       if p.exists()), None)

    def font_for(text, size):
        path = FONT if all(ord(c) in font_cmap for c in text) else system_font
        if path is None:
            raise RuntimeError("Preview needs a CJK font (Microsoft YaHei or Noto Sans CJK).")
        return ImageFont.truetype(str(path), max(1, round(size)))

    def text_at(text, cx, cy, size, color):
        font = font_for(text, size)
        box = draw.textbbox((0, 0), text, font=font)
        draw.text((cx - (box[2] + box[0]) / 2, cy - (box[3] + box[1]) / 2), text, font=font, fill=color)

    toolbar = theme["tool_bar"]
    buttons = [toolbar["primary_button"], *toolbar["buttons"]]
    for index, button in enumerate(buttons):
        cx, cy = width * (index + .5) / len(buttons), toolbar_height / 2
        if index == 0:
            r = round(11 * density)
            draw.rounded_rectangle((cx-r, cy-r, cx+r, cy+r), radius=r*.42, fill=scheme["toolbar_accent"])
        fg = button["foreground"]
        text_at(fg["style"], cx, cy, fg["font_size"] * density, scheme[fg["normal"]])

    row_height = height / len(rows)
    available = width - 2 * pad
    gap_x, gap_y = style["horizontal_gap"] * density, style["vertical_gap"] * density
    for ri, row in enumerate(rows):
        cumulative = 0
        for key, weight in row:
            x1 = pad + round(available * cumulative / 100)
            cumulative += weight
            x2 = pad + round(available * cumulative / 100)
            if "click" not in key:
                continue
            x, y = round(x1 + gap_x / 2), round(toolbar_height + ri * row_height + gap_y / 2)
            w, h = round(x2 - x1 - gap_x), round(row_height - gap_y)
            background = scheme[key.get("key_back_color", "key_back_color")]
            image.alpha_composite(stretch_nine_patch(ASSETS / background, w, h), (x, y))
            label = str(key.get("label", label_of(theme, key["click"])))
            if keyboard.get("label_transform") == "uppercase":
                label = label.upper()
            color = scheme[key.get("key_text_color", "key_text_color")]
            size = key.get("key_text_size", style["key_text_size"]) * density
            text_at(label, x + w / 2, y + h / 2 + keyboard.get("key_text_offset_y", 0) * density, size, color)
            small = key.get("symbol_text_size", style["symbol_text_size"]) * density
            if "long_click" in key:
                symbol = key.get("label_symbol", label_of(theme, key["long_click"]))
                offset_x = key.get("key_symbol_offset_x", keyboard.get("key_symbol_offset_x", 0)) * density
                offset_y = key.get("key_symbol_offset_y", keyboard.get("key_symbol_offset_y", 0)) * density
                text_at(symbol, x + w / 2 + offset_x, y + small * .6 + offset_y, small, scheme["key_symbol_color"])
            if key.get("hint"):
                offset_x = key.get("key_hint_offset_x", keyboard.get("key_hint_offset_x", 0)) * density
                offset_y = key.get("key_hint_offset_y", keyboard.get("key_hint_offset_y", 0)) * density
                text_at(key["hint"], x + w / 2 + offset_x, y + h - small * .6 + offset_y, small, scheme["key_symbol_color"])
    image.convert("RGB").save(OUTPUT / filename)


def verify(theme):
    from fontTools.ttLib import TTFont

    cmap = TTFont(FONT).getBestCmap()
    assert all(code in cmap for code in range(0xE000, 0xE00C)), "Missing icon glyph"
    assert all(ord(c) in cmap for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
    presets = theme["preset_keyboards"]
    for name in presets:
        keyboard = resolve_keyboard(theme, name)
        rows = rows_of(keyboard)
        assert len(rows) == 4, f"{name} needs four full rows"
        for key in keyboard["keys"]:
            for behavior in ("click", "long_click", "swipe_up", "swipe_left", "swipe_right"):
                action = key.get(behavior)
                if action and str(action).startswith("SB_"):
                    assert action in theme["preset_keys"], f"Missing action {action}"
    for action in theme["preset_keys"].values():
        target = action.get("select", "")
        assert not target or target.startswith(".") or target in presets, target
    for scheme in theme["preset_color_schemes"].values():
        for value in scheme.values():
            if str(value).endswith(".png"):
                assert (ASSETS / value).is_file(), f"Missing asset: {value}"
    letters = [(k["label"], k["click"]) for k in presets["default"]["keys"]
               if len(str(k.get("click", ""))) == 1 and str(k["click"]).isalpha()]
    assert letters == list(zip(["Q", "W E", "R T", "Y", "U", "I O", "P", "A", "S D", "F G", "H", "J K", "L", "Z", "X C", "V", "B N", "M"], "qwryuipasfhjlzxvbm")), letters
    print("PASS: 18-key mapping, all page widths, keyboard navigation, fonts and assets")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--font-source", type=Path)
    parser.add_argument("--font-license", type=Path)
    args = parser.parse_args()
    for folder in (ASSETS, FONTS, OUTPUT):
        folder.mkdir(parents=True, exist_ok=True)
    if args.font_source:
        if not args.font_license:
            parser.error("--font-license is required with --font-source")
        build_font(args.font_source, args.font_license)
    if not FONT.is_file():
        parser.error("Need the bundled font, or --font-source and --font-license")
    build_backgrounds()
    theme = yaml.safe_load(THEME.read_text(encoding="utf-8"))
    verify(theme)
    preview(theme, "default", "soft_blue_18_light", "preview-default.png")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()

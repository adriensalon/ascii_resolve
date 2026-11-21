# ASCII Art for DaVinci Resolve

Fusion effect inspired by [ASCII Art Archive image converter](https://www.asciiart.eu/image-to-ascii) that renders as a grid of ASCII characters. It includes a custom bitmap font and can render glyphs from fonts installed on the system through Fusion's font picker.

## Install on Windows

Copy `ASCIIArt.fuse` to `%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Fuses`, or run `InstallASCIIArt.ps1` from this folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\InstallASCIIArt.ps1
```

Restart Resolve to load the Fuse.

## Use in Fusion

1. Select a clip in the timeline and open the **Fusion** page.
2. Select **MediaIn**, press **Shift+Space**, search for **ASCII Art**, and add it. Connect the nodes as `MediaIn → ASCII Art → MediaOut`.
3. Set **Characters Across** to control detail. Pick an **ASCII Gradient** or select **Custom** and enter printable ASCII characters in order from sparsest to densest. A leading space gives the ramp a blank character.
4. Set **Style** to white on black, black on white, or source color. Enable **Transparent Background** to composite only the glyphs, or set **Transparent Frame** to add a transparent margin.
5. Use the **Image** tab to adjust brightness, contrast, color, sharpness, edges, or threshold. **Ordered Dither** distributes neighboring glyph densities across cells. **Crisp Pixels** displays the bitmap with hard edges.
6. The **Font** tab defaults to **Embedded Bitmap**. Set **Font Source** to **Installed Font** and choose a family and style from Fusion's font picker. Proportional glyphs are centered in the same fixed grid. If the selected font is unavailable, the effect uses the embedded font.

The node outputs RGBA frames. Render video through **Deliver**, or use a Fusion Saver for PNG frames. The effect uses a CPU rasterizer, so dense grids can take longer to preview.

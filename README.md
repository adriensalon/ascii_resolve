# ASCII Art and ASCII Text for DaVinci Resolve

**ASCII Art** is a fusion effect inspired by [ASCII Art Archive image converter](https://www.asciiart.eu/image-to-ascii) that renders as a grid of ASCII characters. It includes a custom bitmap font and can render glyphs from fonts installed on the system through Fusion's font picker.

**ASCII Text** is a Fusion title that turns typed text into a banner made of ASCII characters. It is inspired by the [ASCII Art Archive text converter](https://www.asciiart.eu/text-to-ascii-art).

https://github.com/user-attachments/assets/447d23aa-b808-4862-b47c-61fc037a1e8e

## Install on Windows

Run the installer from this folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\InstallASCII.ps1
```

The installer copies both Fuses to `%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Fuses` and packages both Edit page templates in `ASCIIArt.drfx` under the adjacent `Templates` folder. On first install it downloads the catalog in `ASCIITextFonts.txt` from ASCII Art Archive and caches the original font files in `ASCIITextFonts.zip` in Resolve's `Fusion` folder. Reinstalls reuse that archive, and Resolve renders the titles offline. Restart Resolve after installation.

## Use ASCII Text

1. On the Edit page, open **Effects Library → Toolbox → Titles** and drag **ASCII Text** onto a track above your footage. In Fusion, you can add **ASCII Text** directly and connect it to **MediaOut** or use it as a Merge foreground.
2. Enter **Styled Text** in the Inspector. Pick from **279 Banner Fonts** and set **Letter Spacing** to **Fitted** or **Full**. Use **Characters Across** to wrap long lines, or set it to `0` to wrap only at line breaks you typed. The banner accepts up to 512 characters. Characters outside printable ASCII and line breaks appear as `?`. Tabs become spaces.
3. Leave **Font Source** on **Embedded Bitmap**, or select **Installed Font** and choose a font family and style from Fusion's font picker. The characters stay in a fixed grid in both modes. If the selected family is unavailable, the title uses the embedded font.
4. Adjust **Alignment**, **Center**, **Size**, and **Color** in the Inspector. The title renders over a transparent background.

The [ASCII Art Archive font catalog](https://www.asciiart.eu/text-to-ascii-art) includes FIGlet and TOIlet fonts. The cached files retain their original font notices. The embedded display font includes ANSI box-drawing, block, and shading glyphs from [font8x8](https://github.com/dhepper/font8x8).

## Use ASCII Art

1. Open **Effects Library → Toolbox → Effects** and drag **ASCII Art** onto a clip.
2. Select the clip and open **Inspector → Effects** to adjust the grid, gradient, styling, image, and font controls.
3. Set **Characters Across** to control detail. Pick an **ASCII Gradient** or select **Custom** and enter printable ASCII characters in order from sparsest to densest. A leading space gives the ramp a blank character.
4. Set **Style** to white on black, black on white, or source color. Enable **Transparent Background** to composite only the glyphs, or set **Transparent Frame** to add a transparent margin.
5. Use the **Image** tab to adjust brightness, contrast, color, sharpness, edges, or threshold. **Ordered Dither** distributes neighboring glyph densities across cells. **Crisp Pixels** displays the bitmap with hard edges.
6. The **Font** tab defaults to **Embedded Bitmap**. Set **Font Source** to **Installed Font** and choose a family and style from Fusion's font picker. Proportional glyphs are centered in the same fixed grid. If the selected font is unavailable, the effect uses the embedded font.

The node outputs RGBA frames. Render video through **Deliver**, or use a Fusion Saver for PNG frames. The effect uses a CPU rasterizer, so dense grids can take longer to preview.

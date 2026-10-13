// Génère les icônes de l'app (mini-plateau 3×4) : `pnpm tsx scripts/generate-icons.tsx`.
import { mkdirSync, writeFileSync } from "node:fs";
import { ImageResponse } from "next/og";

const BORDEAUX = "#5B0000";
const CREME = "#FFF8E7";

/**
 * @param inset marge laissée autour du plateau, en fraction de la taille
 *   (zone sûre : les icônes « maskable » sont découpées en cercle par Android)
 * @param radius arrondi du fond, en fraction de la taille (0 = carré plein, que l'iPhone arrondit lui-même)
 */
function Plateau({ size, inset, radius }: { size: number; inset: number; radius: number }) {
  const tile = (size * (1 - 2 * inset)) / 4.54;
  const gap = tile * 0.18;
  return (
    <div style={{ width: size, height: size, display: "flex", alignItems: "center", justifyContent: "center", background: BORDEAUX, borderRadius: size * radius }}>
      <div style={{ display: "flex", flexDirection: "column" }}>
        {[0, 1, 2, 3].map((row) => (
          <div key={row} style={{ display: "flex", marginTop: row === 0 ? 0 : gap }}>
            {[0, 1, 2].map((col) => (
              <div key={col} style={{ width: tile, height: tile, marginLeft: col === 0 ? 0 : gap, borderRadius: tile * 0.3, background: CREME }} />
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}

const ICONS = [
  { file: "public/icons/icon-192.png", size: 192, inset: 0.12, radius: 0.22 },
  { file: "public/icons/icon-512.png", size: 512, inset: 0.12, radius: 0.22 },
  { file: "public/icons/maskable-512.png", size: 512, inset: 0.2, radius: 0 },
  { file: "app/apple-icon.png", size: 180, inset: 0.12, radius: 0 },
  { file: "app/icon.png", size: 64, inset: 0.08, radius: 0.22 },
];

async function main() {
  mkdirSync("public/icons", { recursive: true });
  for (const { file, size, inset, radius } of ICONS) {
    const image = new ImageResponse(<Plateau size={size} inset={inset} radius={radius} />, { width: size, height: size });
    writeFileSync(file, Buffer.from(await image.arrayBuffer()));
    console.log(file);
  }
}

main();

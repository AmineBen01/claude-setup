"use client";

import { Share, Smartphone, X } from "lucide-react";
import { useState, useSyncExternalStore } from "react";
import { Button } from "@/components/ui/button";
import {
  getInstallState,
  getServerInstallState,
  isAppleMobile,
  isStandalone,
  promptInstall,
  subscribeInstall,
} from "@/lib/install-prompt";
import { useIsClient } from "@/lib/use-is-client";

// Fermé d'une croix, le bandeau revient une semaine plus tard tant que l'app n'est pas installée.
const DISMISSED_KEY = "ciao:installation-masquee-jusqua";
const DISMISS_DAYS = 7;

function readDismissedUntil(): number {
  try {
    return Number(localStorage.getItem(DISMISSED_KEY)) || 0;
  } catch {
    return 0;
  }
}

/** Bandeau « Installer l'app », affiché sous l'en-tête sur Saisie et Données. */
export function InstallBanner() {
  if (!useIsClient()) return null;
  return <Banner />;
}

function Banner() {
  const install = useSyncExternalStore(subscribeInstall, getInstallState, getServerInstallState);
  const [dismissedUntil, setDismissedUntil] = useState(readDismissedUntil);
  const [now] = useState(() => Date.now());
  const apple = isAppleMobile();

  if (isStandalone() || install.installed || now < dismissedUntil) return null;
  // Ailleurs que sur iPhone/iPad, on ne propose l'installation que si le navigateur la permet.
  if (!apple && !install.promptEvent) return null;

  function dismiss() {
    const until = Date.now() + DISMISS_DAYS * 24 * 60 * 60 * 1000;
    try {
      localStorage.setItem(DISMISSED_KEY, String(until));
    } catch {}
    setDismissedUntil(until);
  }

  return (
    <aside
      aria-label="Installer l'app"
      className="flex items-center gap-3 rounded-2xl border-2 border-rose bg-secondary py-2 pr-1 pl-3 text-base"
    >
      <Smartphone className="size-6 shrink-0 text-bordeaux" />
      {apple ? (
        <p className="min-w-0 flex-1 py-1">
          <span className="font-bold">Installez l&apos;app sur cet {apple}</span> : touchez{" "}
          <Share className="inline size-5 align-text-bottom text-bordeaux" aria-label="Partager" /> puis « Sur l&apos;écran
          d&apos;accueil ».
        </p>
      ) : (
        <>
          <p className="min-w-0 flex-1 py-1 font-bold">Installez l&apos;app sur cet appareil</p>
          <Button onClick={() => void promptInstall()}>Installer</Button>
        </>
      )}
      <button
        type="button"
        onClick={dismiss}
        aria-label="Masquer pour 7 jours"
        className="flex size-11 shrink-0 items-center justify-center rounded-full text-muted-foreground hover:bg-accent hover:text-accent-foreground focus-visible:ring-3 focus-visible:ring-ring/50 focus-visible:outline-none"
      >
        <X className="size-5" />
      </button>
    </aside>
  );
}

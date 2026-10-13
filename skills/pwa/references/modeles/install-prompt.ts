// État de l'installation de l'app, partagé par les bandeaux.
// Le signal « installable » de Chrome/Android (beforeinstallprompt) peut arriver avant
// l'affichage du bandeau : on l'écoute dès le chargement de ce module.

type InstallPromptEvent = Event & { prompt: () => Promise<void> };

type InstallState = { promptEvent: InstallPromptEvent | null; installed: boolean };

const INSTALLED_KEY = "ciao:app-installee";

let state: InstallState = { promptEvent: null, installed: false };
const listeners = new Set<() => void>();

function setState(patch: Partial<InstallState>) {
  state = { ...state, ...patch };
  for (const listener of listeners) listener();
}

if (typeof window !== "undefined") {
  try {
    state.installed = localStorage.getItem(INSTALLED_KEY) === "1";
  } catch {
    // Stockage indisponible : on le saura via l'événement d'installation.
  }
  window.addEventListener("beforeinstallprompt", (event) => {
    event.preventDefault(); // le bandeau propose lui-même l'installation
    setState({ promptEvent: event as InstallPromptEvent });
  });
  window.addEventListener("appinstalled", () => {
    try {
      localStorage.setItem(INSTALLED_KEY, "1");
    } catch {}
    setState({ promptEvent: null, installed: true });
  });
}

export function subscribeInstall(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function getInstallState(): InstallState {
  return state;
}

const SERVER_STATE: InstallState = { promptEvent: null, installed: false };
export function getServerInstallState(): InstallState {
  return SERVER_STATE;
}

/** Ouvre la fenêtre d'installation de Chrome/Android. */
export async function promptInstall() {
  const event = state.promptEvent;
  if (!event) return;
  setState({ promptEvent: null }); // utilisable une seule fois
  await event.prompt();
}

/** L'app tourne-t-elle déjà en mode installé (écran d'accueil) ? */
export function isStandalone(): boolean {
  return (
    window.matchMedia("(display-mode: standalone)").matches ||
    (navigator as Navigator & { standalone?: boolean }).standalone === true
  );
}

/** iPhone ou iPad (l'iPad se présente comme un Mac tactile). */
export function isAppleMobile(): "iPhone" | "iPad" | null {
  const ua = navigator.userAgent;
  if (/iPhone|iPod/.test(ua)) return "iPhone";
  if (/iPad/.test(ua) || (/Macintosh/.test(ua) && navigator.maxTouchPoints > 1)) return "iPad";
  return null;
}

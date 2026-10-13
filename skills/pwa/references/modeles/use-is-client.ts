import { useSyncExternalStore } from "react";

const subscribe = () => () => {};

/** Vrai seulement côté navigateur, après l'hydratation : pour lire localStorage sans décalage serveur/client. */
export function useIsClient(): boolean {
  return useSyncExternalStore(
    subscribe,
    () => true,
    () => false,
  );
}

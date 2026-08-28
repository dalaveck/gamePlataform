// Inicializacao do Firebase (Firestore + Auth anonima) — ver IAcontext.md
// secao 2 (decisao: Firebase, sem servidor proprio).
//
// As credenciais vem de variaveis de ambiente VITE_FIREBASE_* (arquivo
// .env.local, nao commitado — ver .env.example na raiz do projeto). Config
// do Firebase de app cliente nao e segredo (a seguranca vem das regras do
// Firestore, nao de esconder essas chaves), mas ainda assim fica fora do
// repositorio para poder trocar de projeto Firebase sem mexer em codigo.

import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth, signInAnonymously, onAuthStateChanged } from "firebase/auth";

const config = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

export const firebaseConfigurado = Boolean(config.apiKey && config.projectId);

let app = null;
let db = null;
let auth = null;

if (firebaseConfigurado) {
  app = initializeApp(config);
  db = getFirestore(app);
  auth = getAuth(app);
} else if (import.meta.env.DEV) {
  console.warn(
    "[firebase] Variaveis VITE_FIREBASE_* ausentes — sessao multiplayer desativada. Ver .env.example."
  );
}

export { app, db, auth };

let promessaUid = null;

/** Garante um usuario anonimo autenticado e devolve o uid (estavel por navegador/dispositivo). */
export function garantirUsuarioAnonimo() {
  if (!firebaseConfigurado) return Promise.reject(new Error("Firebase nao configurado."));
  if (promessaUid) return promessaUid;

  promessaUid = new Promise((resolve, reject) => {
    const cancelar = onAuthStateChanged(
      auth,
      (usuario) => {
        if (usuario) {
          cancelar();
          resolve(usuario.uid);
        }
      },
      reject
    );
    signInAnonymously(auth).catch((erro) => {
      cancelar();
      reject(erro);
    });
  });

  return promessaUid;
}

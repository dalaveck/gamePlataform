// Criar/entrar/sincronizar uma sessao de jogo (sala) no Firestore.
// Modelo de dados (ROADMAP.md Fase 2):
//   sessoes/{codigo} = { codigo, variante, estado, jogadores[], log[], criadoEm, atualizadoEm }
//   jogador = { id (uid anonimo), nome, personagem (resumo), pronto }
//
// Camada fina sobre o SDK do Firestore — sem regra de jogo aqui (isso e
// engine/), so leitura/escrita/observacao do documento da sessao.

import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  onSnapshot,
  arrayUnion,
  arrayRemove,
  serverTimestamp,
} from "firebase/firestore";
import { db, firebaseConfigurado, garantirUsuarioAnonimo } from "./firebase.js";
import { VARIANTE_PADRAO } from "../data/regras.js";

export const ESTADOS_SESSAO = Object.freeze({
  LOBBY: "lobby",
  EM_JOGO: "em_jogo",
  FINALIZADA: "finalizada",
});

const CARACTERES_CODIGO = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // sem 0/O/1/I, pra evitar confusão ao ditar o código

function gerarCodigoSala() {
  let codigo = "";
  for (let i = 0; i < 6; i++) {
    codigo += CARACTERES_CODIGO[Math.floor(Math.random() * CARACTERES_CODIGO.length)];
  }
  return codigo;
}

function exigirFirebase() {
  if (!firebaseConfigurado) {
    throw new Error(
      "Firebase não configurado — defina as variáveis VITE_FIREBASE_* (ver .env.example) para usar sessões multiplayer."
    );
  }
}

function refSessao(codigo) {
  return doc(db, "sessoes", codigo);
}

/** Cria uma sala nova com um código curto único e devolve o código. */
export async function criarSessao({ variante = VARIANTE_PADRAO } = {}) {
  exigirFirebase();
  let codigo;
  let tentativas = 0;
  do {
    codigo = gerarCodigoSala();
    tentativas += 1;
    // eslint-disable-next-line no-await-in-loop
    const existente = await getDoc(refSessao(codigo));
    if (!existente.exists()) break;
  } while (tentativas < 5);

  await setDoc(refSessao(codigo), {
    codigo,
    variante,
    estado: ESTADOS_SESSAO.LOBBY,
    jogadores: [],
    log: [],
    criadoEm: serverTimestamp(),
    atualizadoEm: serverTimestamp(),
  });

  return codigo;
}

/** Confere se a sala existe antes de tentar entrar (evita criar um jogador numa sala inexistente). */
export async function salaExiste(codigo) {
  exigirFirebase();
  const snap = await getDoc(refSessao(codigo));
  return snap.exists();
}

/** Entra (ou reentra) numa sala como jogador. Idempotente pelo uid do jogador. */
export async function entrarSessao(codigo, { nome, personagemResumo = null }) {
  exigirFirebase();
  const uid = await garantirUsuarioAnonimo();
  const referencia = refSessao(codigo);
  const snap = await getDoc(referencia);
  if (!snap.exists()) {
    throw new Error(`Sala ${codigo} não existe.`);
  }

  const jogadores = snap.data().jogadores ?? [];
  const jaEntrou = jogadores.some((j) => j.id === uid);
  const jogador = { id: uid, nome, personagemResumo, pronto: false };

  if (jaEntrou) {
    await updateDoc(referencia, {
      jogadores: jogadores.map((j) => (j.id === uid ? { ...j, nome, personagemResumo } : j)),
      atualizadoEm: serverTimestamp(),
    });
  } else {
    await updateDoc(referencia, {
      jogadores: arrayUnion(jogador),
      atualizadoEm: serverTimestamp(),
    });
  }

  return uid;
}

export async function sairDaSessao(codigo, jogador) {
  exigirFirebase();
  await updateDoc(refSessao(codigo), {
    jogadores: arrayRemove(jogador),
    atualizadoEm: serverTimestamp(),
  });
}

export async function definirProntidao(codigo, jogadorAtual, pronto) {
  exigirFirebase();
  const referencia = refSessao(codigo);
  const snap = await getDoc(referencia);
  if (!snap.exists()) return;
  const jogadores = (snap.data().jogadores ?? []).map((j) =>
    j.id === jogadorAtual.id ? { ...j, pronto } : j
  );
  await updateDoc(referencia, { jogadores, atualizadoEm: serverTimestamp() });
}

export async function adicionarLog(codigo, texto) {
  exigirFirebase();
  await updateDoc(refSessao(codigo), {
    log: arrayUnion({ texto, em: Date.now() }),
    atualizadoEm: serverTimestamp(),
  });
}

/** Assina mudanças em tempo real na sessão. Devolve a função de cancelar a assinatura. */
export function observarSessao(codigo, aoAtualizar, aoErrar) {
  exigirFirebase();
  return onSnapshot(
    refSessao(codigo),
    (snap) => aoAtualizar(snap.exists() ? snap.data() : null),
    aoErrar
  );
}

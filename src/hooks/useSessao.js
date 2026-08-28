import { useCallback, useEffect, useRef, useState } from "react";
import {
  criarSessao,
  entrarSessao,
  sairDaSessao,
  definirProntidao,
  observarSessao,
} from "../services/sessaoService.js";
import { firebaseConfigurado } from "../services/firebase.js";

/**
 * Estado de uma sessao (sala) multiplayer: cria ou entra numa sala, mantem
 * o documento sincronizado em tempo real (onSnapshot) enquanto o hook
 * estiver montado com um codigo ativo, e cancela a assinatura ao sair.
 */
export function useSessao() {
  const [codigo, setCodigo] = useState(null);
  const [sessao, setSessao] = useState(null);
  const [jogadorId, setJogadorId] = useState(null);
  const [carregando, setCarregando] = useState(false);
  const [erro, setErro] = useState(null);
  const cancelarAssinaturaRef = useRef(null);

  const assinar = useCallback((codigoSala) => {
    cancelarAssinaturaRef.current?.();
    cancelarAssinaturaRef.current = observarSessao(
      codigoSala,
      (dados) => setSessao(dados),
      (err) => setErro(err.message)
    );
  }, []);

  useEffect(() => () => cancelarAssinaturaRef.current?.(), []);

  const criar = useCallback(
    async ({ variante, nome, personagemResumo }) => {
      setCarregando(true);
      setErro(null);
      try {
        const novoCodigo = await criarSessao({ variante });
        const uid = await entrarSessao(novoCodigo, { nome, personagemResumo });
        setCodigo(novoCodigo);
        setJogadorId(uid);
        assinar(novoCodigo);
        return novoCodigo;
      } catch (err) {
        setErro(err.message);
        throw err;
      } finally {
        setCarregando(false);
      }
    },
    [assinar]
  );

  const entrar = useCallback(
    async ({ codigo: codigoSala, nome, personagemResumo }) => {
      setCarregando(true);
      setErro(null);
      try {
        const codigoNormalizado = codigoSala.trim().toUpperCase();
        const uid = await entrarSessao(codigoNormalizado, { nome, personagemResumo });
        setCodigo(codigoNormalizado);
        setJogadorId(uid);
        assinar(codigoNormalizado);
      } catch (err) {
        setErro(err.message);
        throw err;
      } finally {
        setCarregando(false);
      }
    },
    [assinar]
  );

  const marcarPronto = useCallback(
    async (pronto) => {
      if (!codigo || !jogadorId || !sessao) return;
      const jogadorAtual = sessao.jogadores?.find((j) => j.id === jogadorId);
      if (!jogadorAtual) return;
      await definirProntidao(codigo, jogadorAtual, pronto);
    },
    [codigo, jogadorId, sessao]
  );

  const sair = useCallback(async () => {
    cancelarAssinaturaRef.current?.();
    cancelarAssinaturaRef.current = null;
    if (codigo && jogadorId && sessao) {
      const jogadorAtual = sessao.jogadores?.find((j) => j.id === jogadorId);
      if (jogadorAtual) {
        try {
          await sairDaSessao(codigo, jogadorAtual);
        } catch {
          // sala pode já ter sido encerrada — sair localmente de qualquer forma
        }
      }
    }
    setCodigo(null);
    setSessao(null);
    setJogadorId(null);
  }, [codigo, jogadorId, sessao]);

  return {
    disponivel: firebaseConfigurado,
    codigo,
    sessao,
    jogadorId,
    carregando,
    erro,
    criar,
    entrar,
    marcarPronto,
    sair,
  };
}

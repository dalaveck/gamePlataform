// Resolucao generica das habilidades especiais do catalogo (src/data/habilidades.js):
// custo em PA, se a habilidade e ativavel ou passiva, e se o personagem tem
// PA suficiente para pagar o custo. O efeito narrativo/mecanico especifico
// de cada habilidade fica descrito nos dados (campo `efeito`) e e resolvido
// pela narracao/mestre — este modulo so garante a contabilidade de custo.

import { buscarHabilidade } from "../data/habilidades.js";

export function ehAtivavel(habilidade) {
  return habilidade?.custoPA != null && habilidade.custoPA > 0;
}

/**
 * Verifica se um personagem pode ativar a habilidade `habilidadeId` dado o
 * PA atual, e devolve o PA restante caso ative.
 */
export function podeAtivar(habilidadeId, paAtual) {
  const habilidade = buscarHabilidade(habilidadeId);
  if (!habilidade) {
    throw new Error(`habilidade desconhecida: ${habilidadeId}`);
  }
  if (!ehAtivavel(habilidade)) {
    return { podeAtivar: true, custoPA: 0, paRestante: paAtual, habilidade };
  }
  const podeAtivarResultado = paAtual >= habilidade.custoPA;
  return {
    podeAtivar: podeAtivarResultado,
    custoPA: habilidade.custoPA,
    paRestante: podeAtivarResultado ? paAtual - habilidade.custoPA : paAtual,
    habilidade,
  };
}

/** Ativa a habilidade e devolve o novo total de PA (lanca erro se nao houver PA suficiente). */
export function ativar(habilidadeId, paAtual) {
  const resultado = podeAtivar(habilidadeId, paAtual);
  if (!resultado.podeAtivar) {
    throw new Error(
      `PA insuficiente para ativar ${habilidadeId}: precisa de ${resultado.custoPA}, tem ${paAtual}.`
    );
  }
  return resultado.paRestante;
}

// Motor de combate — puro, sem UI. Calcula FA, FD, PV/PM/PA respeitando a
// flag de variante da sessao (ver src/data/regras.js e IAcontext.md 5.2).

import { rolar1d6 } from "./dice.js";
import {
  VARIANTES,
  VARIANTE_PADRAO,
  MULTIPLICADOR_PV,
  MULTIPLICADOR_PM,
  MULTIPLICADOR_PA,
  RESISTENCIA_ZERO_MINIMO,
} from "../data/regras.js";

function validarVariante(variante) {
  if (!Object.values(VARIANTES).includes(variante)) {
    throw new Error(`variante desconhecida: ${variante}`);
  }
}

/**
 * Forca de Ataque, sem o 1d6 — mesma convencao de src/data/npcs.js ("FA/FD
 * ja somadas, sem o 1d6 — role o dado e some"). Usado para mostrar totais
 * ao vivo (ex.: na ficha) sem simular uma rolagem.
 * Alpha:      Forca (ou PdF, a distancia) + Habilidade
 * Cyberpunk:  Habilidade + Forca (ou PdF, a distancia) + Equipamento
 */
export function calcularForcaAtaqueBase({
  habilidade = 0,
  forca = 0,
  poderDeFogo = 0,
  aDistancia = false,
  equipamento = 0,
  variante = VARIANTE_PADRAO,
} = {}) {
  validarVariante(variante);
  const atributoPrincipal = aDistancia ? poderDeFogo : forca;
  const bonusEquipamento = variante === VARIANTES.CYBERPUNK ? equipamento : 0;
  return habilidade + atributoPrincipal + bonusEquipamento;
}

/**
 * Forca de Ataque.
 * Alpha:      Forca (ou PdF, a distancia) + Habilidade + 1d
 * Cyberpunk:  Habilidade + Forca (ou PdF, a distancia) + Equipamento + 1d
 */
export function calcularForcaAtaque({ aleatorio = Math.random, ...opcoes } = {}) {
  const dado = rolar1d6(aleatorio);
  const total = calcularForcaAtaqueBase(opcoes) + dado;
  return { total, dado, variante: opcoes.variante ?? VARIANTE_PADRAO };
}

/**
 * Forca de Defesa, sem o 1d6 — ver calcularForcaAtaqueBase.
 * Alpha:      Armadura + Habilidade
 * Cyberpunk:  Resistencia + Habilidade + Equipamento
 */
export function calcularForcaDefesaBase({
  habilidade = 0,
  armadura = 0,
  resistencia = 0,
  equipamento = 0,
  variante = VARIANTE_PADRAO,
} = {}) {
  validarVariante(variante);
  if (variante === VARIANTES.CYBERPUNK) {
    return resistencia + habilidade + equipamento;
  }
  return armadura + habilidade;
}

/**
 * Forca de Defesa.
 * Alpha:      Armadura + Habilidade + 1d
 * Cyberpunk:  Resistencia + Habilidade + Equipamento + 1d
 */
export function calcularForcaDefesa({ aleatorio = Math.random, ...opcoes } = {}) {
  const dado = rolar1d6(aleatorio);
  const total = calcularForcaDefesaBase(opcoes) + dado;
  return { total, dado, variante: opcoes.variante ?? VARIANTE_PADRAO };
}

/**
 * Resolve um ataque: rola FA e FD e devolve o resultado bruto.
 * Quem chama decide o dano a partir da diferenca (regra de mesa/manual).
 */
export function resolverAtaque(ataque, defesa) {
  const fa = calcularForcaAtaque(ataque);
  const fd = calcularForcaDefesa(defesa);
  return {
    fa,
    fd,
    acertou: fa.total > fd.total,
    margem: fa.total - fd.total,
  };
}

/** PV = Resistencia x 5 (minimo 1 quando Resistencia e 0), nas duas variantes. */
export function calcularPVMax(resistencia, variante = VARIANTE_PADRAO) {
  validarVariante(variante);
  if (resistencia <= 0) return RESISTENCIA_ZERO_MINIMO;
  return resistencia * MULTIPLICADOR_PV[variante];
}

/** PM = Resistencia x 5 — so existe na variante Alpha (cyberpunk nao tem magia). */
export function calcularPMMax(resistencia, variante = VARIANTE_PADRAO) {
  validarVariante(variante);
  if (variante === VARIANTES.CYBERPUNK) return 0;
  if (resistencia <= 0) return RESISTENCIA_ZERO_MINIMO;
  return resistencia * MULTIPLICADOR_PM;
}

/** PA = Habilidade x 5 — so existe na variante cyberpunk (substitui a magia). */
export function calcularPAMax(habilidade, variante = VARIANTE_PADRAO) {
  validarVariante(variante);
  if (variante === VARIANTES.ALPHA) return 0;
  return Math.max(0, habilidade) * MULTIPLICADOR_PA;
}

/** "Perto da Morte": PV atual <= Resistencia (e ainda > 0). */
export function estaPertoDaMorte(pvAtual, resistencia) {
  return pvAtual > 0 && pvAtual <= resistencia;
}

export function estaDerrotado(pvAtual) {
  return pvAtual <= 0;
}

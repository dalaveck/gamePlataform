// Constantes de regras do 3D&T — Cyberpunk Protocol.
// Ver IAcontext.md secao 5.2 para a tabela comparativa Alpha vs. cyberpunk.

export const VARIANTES = Object.freeze({
  ALPHA: "alpha",
  CYBERPUNK: "cyberpunk",
});

export const VARIANTE_PADRAO = VARIANTES.CYBERPUNK;

export const PONTOS_CRIACAO = Object.freeze({
  [VARIANTES.ALPHA]: { min: 5, max: 20 },
  [VARIANTES.CYBERPUNK]: { min: 9, max: 9 },
});

export const TETO_PONTOS_DESVANTAGENS = Object.freeze({
  [VARIANTES.ALPHA]: Infinity,
  [VARIANTES.CYBERPUNK]: 3,
});

export const CUSTO_PERICIA = Object.freeze({
  AREA_COMPLETA: 2,
  // Ate 3 especializacoes soltas de uma area, por 1 ponto total (nao por
  // especializacao) — ver IAcontext.md secao 4.
  ESPECIALIZACOES: 1,
  ESPECIALIZACOES_MAX: 3,
});

export const TOTAL_PERICIAS = 11;

export const MULTIPLICADOR_PV = Object.freeze({
  [VARIANTES.ALPHA]: 5,
  [VARIANTES.CYBERPUNK]: 5,
});

export const MULTIPLICADOR_PM = 5;
export const MULTIPLICADOR_PA = 5;

export const EQUIPAMENTO_BONUS_MIN = 1;
export const EQUIPAMENTO_BONUS_MAX = 3;

/**
 * PV/PM/PA sao Resistencia (ou Habilidade, para PA) x 5, exceto quando o
 * atributo base e 0 — nesse caso o Alpha oficial garante 1 PV/PM minimo.
 */
export const RESISTENCIA_ZERO_MINIMO = 1;

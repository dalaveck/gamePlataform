// Funcoes puras para validar e recalcular uma ficha de personagem, na
// variante cyberpunk (9 pontos, sem raca/vantagem unica, teto de 3 pontos
// em desvantagens). Ver IAcontext.md 5.2 e material/README.md.

import {
  VARIANTES,
  VARIANTE_PADRAO,
  PONTOS_CRIACAO,
  TETO_PONTOS_DESVANTAGENS,
  CUSTO_PERICIA,
} from "../data/regras.js";
import { calcularPVMax, calcularPMMax, calcularPAMax } from "./combate.js";

export const CARACTERISTICAS = Object.freeze([
  "forca",
  "habilidade",
  "resistencia",
  "armadura",
  "poderDeFogo",
]);

function somarCaracteristicas(personagem) {
  return CARACTERISTICAS.reduce((soma, chave) => soma + (personagem[chave] ?? 0), 0);
}

function somarCustoHabilidades(personagem) {
  return (personagem.habilidadesEspeciais ?? []).reduce((soma, h) => soma + (h.custoPontos ?? 0), 0);
}

function somarCustoVantagens(personagem) {
  return (personagem.vantagens ?? []).reduce((soma, v) => soma + (v.custoPontos ?? 0), 0);
}

/**
 * Cada entrada de personagem.pericias e { area, completa, especializacoes }.
 * Area completa custa CUSTO_PERICIA.AREA_COMPLETA; ate
 * CUSTO_PERICIA.ESPECIALIZACOES_MAX especializacoes soltas da mesma area
 * custam CUSTO_PERICIA.ESPECIALIZACOES no total (nao por especializacao).
 */
function somarCustoPericias(personagem) {
  return (personagem.pericias ?? []).reduce((soma, p) => {
    if (p.completa) return soma + CUSTO_PERICIA.AREA_COMPLETA;
    if ((p.especializacoes ?? []).length > 0) return soma + CUSTO_PERICIA.ESPECIALIZACOES;
    return soma;
  }, 0);
}

function somarPontosDesvantagens(personagem, variante) {
  const bruto = (personagem.desvantagens ?? []).reduce((soma, d) => soma + (d.custoPontos ?? 0), 0);
  const teto = TETO_PONTOS_DESVANTAGENS[variante];
  return Number.isFinite(teto) ? Math.min(bruto, teto) : bruto;
}

/**
 * Calcula o saldo de pontos de criacao: orcamento + pontos devolvidos por
 * desvantagens (ate o teto) - características - habilidades - vantagens.
 */
export function calcularSaldoPontos(personagem, variante = VARIANTE_PADRAO) {
  const { max: orcamento } = PONTOS_CRIACAO[variante];
  const gastoCaracteristicas = somarCaracteristicas(personagem);
  const gastoHabilidades = somarCustoHabilidades(personagem);
  const gastoVantagens = somarCustoVantagens(personagem);
  const gastoPericias = somarCustoPericias(personagem);
  const pontosDesvantagens = somarPontosDesvantagens(personagem, variante);

  return (
    orcamento +
    pontosDesvantagens -
    gastoCaracteristicas -
    gastoHabilidades -
    gastoVantagens -
    gastoPericias
  );
}

export function validarPersonagem(personagem, variante = VARIANTE_PADRAO) {
  const erros = [];

  if (variante === VARIANTES.CYBERPUNK && personagem.raca) {
    erros.push("Variante cyberpunk nao usa raca/vantagem unica.");
  }

  for (const chave of CARACTERISTICAS) {
    const valor = personagem[chave] ?? 0;
    if (valor < 0 || valor > 5) {
      erros.push(`Caracteristica ${chave} fora da faixa 0-5: ${valor}.`);
    }
  }

  for (const p of personagem.pericias ?? []) {
    if (p.completa && (p.especializacoes ?? []).length > 0) {
      erros.push(`Pericia ${p.area}: area completa nao combina com especializacoes soltas.`);
    }
    if ((p.especializacoes ?? []).length > CUSTO_PERICIA.ESPECIALIZACOES_MAX) {
      erros.push(`Pericia ${p.area}: no maximo ${CUSTO_PERICIA.ESPECIALIZACOES_MAX} especializacoes soltas.`);
    }
  }

  const saldo = calcularSaldoPontos(personagem, variante);
  if (saldo < 0) {
    erros.push(`Pontos de criacao excedidos em ${-saldo}.`);
  }

  return { valido: erros.length === 0, erros, saldo };
}

/** Recalcula os recursos derivados (PV/PM/PA max) a partir das caracteristicas. */
export function recalcularRecursos(personagem, variante = VARIANTE_PADRAO) {
  const resistencia = personagem.resistencia ?? 0;
  const habilidade = personagem.habilidade ?? 0;
  return {
    pvMax: calcularPVMax(resistencia, variante),
    pmMax: calcularPMMax(resistencia, variante),
    paMax: calcularPAMax(habilidade, variante),
  };
}

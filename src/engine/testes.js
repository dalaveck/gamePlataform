// Testes de caracteristica/pericia: valor base + bonus/redutores + 1d6
// contra uma dificuldade (numero-alvo definido pelo mestre/motor).

import { rolar1d6 } from "./dice.js";

export function testar({ valorBase = 0, bonus = 0, dificuldade = 0, aleatorio = Math.random } = {}) {
  const dado = rolar1d6(aleatorio);
  const total = valorBase + bonus + dado;
  return { total, dado, passou: total >= dificuldade, dificuldade };
}

export function testarCaracteristica(personagem, caracteristica, opcoes = {}) {
  const valorBase = personagem?.[caracteristica] ?? 0;
  return testar({ ...opcoes, valorBase });
}

/**
 * Testa uma pericia de uma area. `especializacao` e opcional: quando
 * informada, tambem conta como acerto se estiver entre as especializacoes
 * soltas compradas naquela area (mesmo sem a area completa).
 */
export function testarPericia(personagem, area, especializacao = null, opcoes = {}) {
  const entrada = personagem?.pericias?.find((p) => p.area === area);
  const temBonus =
    !!entrada?.completa ||
    (especializacao != null && (entrada?.especializacoes ?? []).includes(especializacao));
  const habilidade = personagem?.habilidade ?? 0;
  const bonusPericia = temBonus ? 2 : 0;
  return testar({ ...opcoes, valorBase: habilidade, bonus: (opcoes.bonus ?? 0) + bonusPericia });
}

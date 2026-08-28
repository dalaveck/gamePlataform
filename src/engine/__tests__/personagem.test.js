import { describe, it, expect } from "vitest";
import { calcularSaldoPontos, validarPersonagem, recalcularRecursos } from "../personagem.js";
import { VARIANTES } from "../../data/regras.js";

describe("calcularSaldoPontos (cyberpunk, 9 pontos)", () => {
  it("personagem so em caracteristicas gasta ponto a ponto", () => {
    const personagem = { forca: 2, habilidade: 2, resistencia: 2, armadura: 1, poderDeFogo: 0 };
    expect(calcularSaldoPontos(personagem, VARIANTES.CYBERPUNK)).toBe(9 - 7);
  });

  it("desvantagens devolvem pontos ate o teto de 3", () => {
    const personagem = {
      forca: 2,
      habilidade: 2,
      resistencia: 2,
      armadura: 0,
      poderDeFogo: 0,
      desvantagens: [
        { custoPontos: 1 },
        { custoPontos: 1 },
        { custoPontos: 1 },
        { custoPontos: 2 }, // excede o teto de 3, deve ser ignorado
      ],
    };
    // gasto = 6, devolvido = min(1+1+1+2, 3) = 3 -> saldo = 9 + 3 - 6 = 6
    expect(calcularSaldoPontos(personagem, VARIANTES.CYBERPUNK)).toBe(6);
  });

  it("habilidades e vantagens tambem consomem pontos", () => {
    const personagem = {
      forca: 0,
      habilidade: 0,
      resistencia: 0,
      armadura: 0,
      poderDeFogo: 0,
      habilidadesEspeciais: [{ custoPontos: 2 }],
      vantagens: [{ custoPontos: 1 }],
    };
    expect(calcularSaldoPontos(personagem, VARIANTES.CYBERPUNK)).toBe(9 - 2 - 1);
  });

  it("pericias custam 2 pts (area completa) ou 1 pt (especializacoes soltas)", () => {
    const personagem = {
      forca: 0,
      habilidade: 0,
      resistencia: 0,
      armadura: 0,
      poderDeFogo: 0,
      pericias: [
        { area: "Crime", completa: true },
        { area: "Máquinas", completa: false, especializacoes: ["netrunning", "eletrônica"] },
        { area: "Arte", completa: false, especializacoes: [] }, // nao comprada, custo 0
      ],
    };
    expect(calcularSaldoPontos(personagem, VARIANTES.CYBERPUNK)).toBe(9 - 2 - 1);
  });
});

describe("validarPersonagem", () => {
  it("aceita um personagem valido dentro do orcamento", () => {
    const personagem = { forca: 2, habilidade: 2, resistencia: 2, armadura: 1, poderDeFogo: 0 };
    const resultado = validarPersonagem(personagem, VARIANTES.CYBERPUNK);
    expect(resultado.valido).toBe(true);
    expect(resultado.erros).toEqual([]);
  });

  it("rejeita caracteristica fora da faixa 0-5", () => {
    const personagem = { forca: 6, habilidade: 0, resistencia: 0, armadura: 0, poderDeFogo: 0 };
    const resultado = validarPersonagem(personagem, VARIANTES.CYBERPUNK);
    expect(resultado.valido).toBe(false);
    expect(resultado.erros.some((e) => e.includes("forca"))).toBe(true);
  });

  it("rejeita gasto acima do orcamento de pontos", () => {
    const personagem = { forca: 5, habilidade: 5, resistencia: 5, armadura: 0, poderDeFogo: 0 };
    const resultado = validarPersonagem(personagem, VARIANTES.CYBERPUNK);
    expect(resultado.valido).toBe(false);
    expect(resultado.saldo).toBeLessThan(0);
  });

  it("rejeita raca/vantagem unica na variante cyberpunk", () => {
    const personagem = { forca: 0, habilidade: 0, resistencia: 0, armadura: 0, poderDeFogo: 0, raca: "humano-variante" };
    const resultado = validarPersonagem(personagem, VARIANTES.CYBERPUNK);
    expect(resultado.valido).toBe(false);
  });

  it("rejeita area completa combinada com especializacoes soltas", () => {
    const personagem = {
      forca: 0,
      habilidade: 0,
      resistencia: 0,
      armadura: 0,
      poderDeFogo: 0,
      pericias: [{ area: "Crime", completa: true, especializacoes: ["furto"] }],
    };
    const resultado = validarPersonagem(personagem, VARIANTES.CYBERPUNK);
    expect(resultado.valido).toBe(false);
  });

  it("rejeita mais de 3 especializacoes soltas na mesma area", () => {
    const personagem = {
      forca: 0,
      habilidade: 0,
      resistencia: 0,
      armadura: 0,
      poderDeFogo: 0,
      pericias: [{ area: "Crime", completa: false, especializacoes: ["a", "b", "c", "d"] }],
    };
    const resultado = validarPersonagem(personagem, VARIANTES.CYBERPUNK);
    expect(resultado.valido).toBe(false);
  });
});

describe("recalcularRecursos", () => {
  it("deriva PV/PM/PA a partir das caracteristicas, na variante cyberpunk", () => {
    const personagem = { resistencia: 2, habilidade: 3 };
    expect(recalcularRecursos(personagem, VARIANTES.CYBERPUNK)).toEqual({
      pvMax: 10,
      pmMax: 0,
      paMax: 15,
    });
  });
});

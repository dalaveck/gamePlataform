import { describe, it, expect } from "vitest";
import { testar, testarPericia } from "../testes.js";

describe("testar", () => {
  it("passa quando total >= dificuldade", () => {
    const resultado = testar({ valorBase: 2, bonus: 1, dificuldade: 6, aleatorio: () => (3 - 1) / 6 });
    expect(resultado.total).toBe(6);
    expect(resultado.passou).toBe(true);
  });

  it("falha quando total < dificuldade", () => {
    const resultado = testar({ valorBase: 0, bonus: 0, dificuldade: 6, aleatorio: () => 0 });
    expect(resultado.total).toBe(1);
    expect(resultado.passou).toBe(false);
  });
});

describe("testarPericia", () => {
  it("soma +2 quando a area foi comprada completa", () => {
    const personagem = { habilidade: 1, pericias: [{ area: "Crime", completa: true }] };
    const resultado = testarPericia(personagem, "Crime", null, { dificuldade: 0, aleatorio: () => 0 });
    expect(resultado.total).toBe(1 + 2 + 1);
  });

  it("soma +2 quando a especializacao solta foi comprada, mesmo sem a area completa", () => {
    const personagem = {
      habilidade: 1,
      pericias: [{ area: "Máquinas", completa: false, especializacoes: ["netrunning"] }],
    };
    const resultado = testarPericia(personagem, "Máquinas", "netrunning", {
      dificuldade: 0,
      aleatorio: () => 0,
    });
    expect(resultado.total).toBe(1 + 2 + 1);
  });

  it("nao soma bonus quando a especializacao testada nao foi comprada", () => {
    const personagem = {
      habilidade: 1,
      pericias: [{ area: "Máquinas", completa: false, especializacoes: ["netrunning"] }],
    };
    const resultado = testarPericia(personagem, "Máquinas", "eletrônica", {
      dificuldade: 0,
      aleatorio: () => 0,
    });
    expect(resultado.total).toBe(1 + 1);
  });

  it("nao soma bonus quando o personagem nao tem a pericia", () => {
    const personagem = { habilidade: 1, pericias: [] };
    const resultado = testarPericia(personagem, "Crime", null, { dificuldade: 0, aleatorio: () => 0 });
    expect(resultado.total).toBe(1 + 1);
  });
});

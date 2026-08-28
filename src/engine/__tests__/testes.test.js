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
  it("soma +2 quando o personagem tem a pericia", () => {
    const personagem = { habilidade: 1, pericias: ["Crime"] };
    const resultado = testarPericia(personagem, "Crime", { dificuldade: 0, aleatorio: () => 0 });
    expect(resultado.total).toBe(1 + 2 + 1);
  });

  it("nao soma bonus de pericia quando o personagem nao tem", () => {
    const personagem = { habilidade: 1, pericias: [] };
    const resultado = testarPericia(personagem, "Crime", { dificuldade: 0, aleatorio: () => 0 });
    expect(resultado.total).toBe(1 + 1);
  });
});

import { describe, it, expect } from "vitest";
import { podeAtivar, ativar } from "../habilidades.js";

describe("podeAtivar", () => {
  it("habilidade passiva (sem custo em PA) sempre pode ser usada", () => {
    const resultado = podeAtivar("reflexos-rapidos", 0);
    expect(resultado.podeAtivar).toBe(true);
    expect(resultado.custoPA).toBe(0);
  });

  it("habilidade ativavel exige PA suficiente", () => {
    const semPA = podeAtivar("intrusao-remota", 1);
    expect(semPA.podeAtivar).toBe(false);

    const comPA = podeAtivar("intrusao-remota", 2);
    expect(comPA.podeAtivar).toBe(true);
    expect(comPA.paRestante).toBe(0);
  });

  it("lanca erro para habilidade desconhecida", () => {
    expect(() => podeAtivar("nao-existe", 10)).toThrow();
  });
});

describe("ativar", () => {
  it("desconta o PA e retorna o restante", () => {
    expect(ativar("intrusao-remota", 5)).toBe(3);
  });

  it("lanca erro quando falta PA", () => {
    expect(() => ativar("intrusao-remota", 1)).toThrow();
  });
});

import { describe, it, expect } from "vitest";
import { rolar1d6, rolarMultiplos, somarDados } from "../dice.js";

describe("rolar1d6", () => {
  it("fica sempre entre 1 e 6", () => {
    for (let i = 0; i < 200; i++) {
      const valor = rolar1d6();
      expect(valor).toBeGreaterThanOrEqual(1);
      expect(valor).toBeLessThanOrEqual(6);
    }
  });

  it("respeita um gerador aleatorio injetado", () => {
    expect(rolar1d6(() => 0)).toBe(1);
    expect(rolar1d6(() => 0.999999)).toBe(6);
  });
});

describe("rolarMultiplos / somarDados", () => {
  it("rola a quantidade pedida", () => {
    expect(rolarMultiplos(3, () => 0.5)).toEqual([4, 4, 4]);
  });

  it("soma corretamente", () => {
    expect(somarDados(3, () => 0.5)).toBe(12);
  });

  it("rejeita quantidade menor que 1", () => {
    expect(() => rolarMultiplos(0)).toThrow();
  });
});

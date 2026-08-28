import { describe, it, expect } from "vitest";
import {
  calcularForcaAtaque,
  calcularForcaAtaqueBase,
  calcularForcaDefesa,
  calcularForcaDefesaBase,
  calcularPVMax,
  calcularPMMax,
  calcularPAMax,
  estaPertoDaMorte,
  estaDerrotado,
} from "../combate.js";
import { VARIANTES } from "../../data/regras.js";

const dadoFixo = (valor) => () => (valor - 1) / 6; // rolar1d6 = floor(x*6)+1

describe("calcularForcaAtaque", () => {
  it("alpha: Forca + Habilidade + 1d, ignora equipamento", () => {
    const { total } = calcularForcaAtaque({
      habilidade: 2,
      forca: 3,
      equipamento: 5,
      variante: VARIANTES.ALPHA,
      aleatorio: dadoFixo(4),
    });
    expect(total).toBe(2 + 3 + 4);
  });

  it("cyberpunk: Habilidade + Forca + Equipamento + 1d", () => {
    const { total } = calcularForcaAtaque({
      habilidade: 2,
      forca: 3,
      equipamento: 1,
      variante: VARIANTES.CYBERPUNK,
      aleatorio: dadoFixo(4),
    });
    expect(total).toBe(2 + 3 + 1 + 4);
  });

  it("a distancia usa Poder de Fogo em vez de Forca", () => {
    const { total } = calcularForcaAtaque({
      habilidade: 1,
      forca: 10,
      poderDeFogo: 3,
      aDistancia: true,
      equipamento: 1,
      variante: VARIANTES.CYBERPUNK,
      aleatorio: dadoFixo(6),
    });
    expect(total).toBe(1 + 3 + 1 + 6);
  });
});

describe("calcularForcaAtaqueBase / calcularForcaDefesaBase (sem 1d6)", () => {
  it("bate com calcularForcaAtaque menos o dado", () => {
    const base = calcularForcaAtaqueBase({
      habilidade: 2,
      forca: 3,
      equipamento: 1,
      variante: VARIANTES.CYBERPUNK,
    });
    const { total, dado } = calcularForcaAtaque({
      habilidade: 2,
      forca: 3,
      equipamento: 1,
      variante: VARIANTES.CYBERPUNK,
      aleatorio: dadoFixo(5),
    });
    expect(total - dado).toBe(base);
  });

  it("bate com calcularForcaDefesa menos o dado", () => {
    const base = calcularForcaDefesaBase({
      habilidade: 1,
      resistencia: 2,
      equipamento: 1,
      variante: VARIANTES.CYBERPUNK,
    });
    const { total, dado } = calcularForcaDefesa({
      habilidade: 1,
      resistencia: 2,
      equipamento: 1,
      variante: VARIANTES.CYBERPUNK,
      aleatorio: dadoFixo(5),
    });
    expect(total - dado).toBe(base);
  });
});

describe("calcularForcaDefesa", () => {
  it("alpha: Armadura + Habilidade + 1d, ignora equipamento e resistencia", () => {
    const { total } = calcularForcaDefesa({
      habilidade: 1,
      armadura: 2,
      resistencia: 9,
      equipamento: 9,
      variante: VARIANTES.ALPHA,
      aleatorio: dadoFixo(3),
    });
    expect(total).toBe(2 + 1 + 3);
  });

  it("cyberpunk: Resistencia + Habilidade + Equipamento + 1d, ignora armadura", () => {
    const { total } = calcularForcaDefesa({
      habilidade: 1,
      armadura: 9,
      resistencia: 2,
      equipamento: 1,
      variante: VARIANTES.CYBERPUNK,
      aleatorio: dadoFixo(3),
    });
    expect(total).toBe(2 + 1 + 1 + 3);
  });
});

describe("recursos (PV/PM/PA)", () => {
  it("PV = Resistencia x 5 nas duas variantes", () => {
    expect(calcularPVMax(3, VARIANTES.ALPHA)).toBe(15);
    expect(calcularPVMax(3, VARIANTES.CYBERPUNK)).toBe(15);
  });

  it("Resistencia 0 da o minimo de 1 PV", () => {
    expect(calcularPVMax(0, VARIANTES.CYBERPUNK)).toBe(1);
  });

  it("PM so existe no alpha (cyberpunk nao tem magia)", () => {
    expect(calcularPMMax(3, VARIANTES.ALPHA)).toBe(15);
    expect(calcularPMMax(3, VARIANTES.CYBERPUNK)).toBe(0);
  });

  it("PA (Habilidade x 5) so existe no cyberpunk", () => {
    expect(calcularPAMax(3, VARIANTES.CYBERPUNK)).toBe(15);
    expect(calcularPAMax(3, VARIANTES.ALPHA)).toBe(0);
  });
});

describe("condicoes de PV", () => {
  it("Perto da Morte quando 0 < PV <= Resistencia", () => {
    expect(estaPertoDaMorte(2, 3)).toBe(true);
    expect(estaPertoDaMorte(4, 3)).toBe(false);
    expect(estaPertoDaMorte(0, 3)).toBe(false);
  });

  it("derrotado quando PV <= 0", () => {
    expect(estaDerrotado(0)).toBe(true);
    expect(estaDerrotado(-1)).toBe(true);
    expect(estaDerrotado(1)).toBe(false);
  });
});

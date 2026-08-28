// Rolagem de dados — padrao do 3D&T e 1d6.

export function rolar1d6(aleatorio = Math.random) {
  return Math.floor(aleatorio() * 6) + 1;
}

export function rolarMultiplos(quantidade, aleatorio = Math.random) {
  if (quantidade < 1) {
    throw new Error("quantidade deve ser ao menos 1");
  }
  return Array.from({ length: quantidade }, () => rolar1d6(aleatorio));
}

export function somarDados(quantidade, aleatorio = Math.random) {
  return rolarMultiplos(quantidade, aleatorio).reduce((soma, valor) => soma + valor, 0);
}

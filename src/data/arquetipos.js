// Arquetipos da campanha cyberpunk: vampiro, hacker, atleta, meio androide.
// Cada um define quais habilidades especiais estao disponiveis e (quando
// houver) a desvantagem obrigatoria do conceito.

import { ARQUETIPOS_HABILIDADE, habilidadesPorArquetipo } from "./habilidades.js";
import { desvantagensObrigatorias } from "./desvantagens.js";

export const arquetipos = [
  {
    id: ARQUETIPOS_HABILIDADE.VAMPIRO,
    nome: "Vampiro",
    descricao:
      "Sem magia: e um retrovirus de engenharia que reescreve o metabolismo. Regenera tecido rapido demais, e cobra a conta em sangue alheio.",
    desvantagemObrigatoria: desvantagensObrigatorias.vampiro,
  },
  {
    id: ARQUETIPOS_HABILIDADE.HACKER,
    nome: "Hacker",
    descricao: "Netrunner. Metade do trabalho e feito antes de a porta abrir. Quase tudo depende de Maquinas.",
    desvantagemObrigatoria: null,
  },
  {
    id: ARQUETIPOS_HABILIDADE.ATLETA,
    nome: "Atleta",
    descricao:
      "Corpo treinado, sem implante nenhum. O unico que nao depende de bateria nem de sangue.",
    desvantagemObrigatoria: null,
  },
  {
    id: ARQUETIPOS_HABILIDADE.ANDROIDE,
    nome: "Meio androide",
    descricao: "Chassi sob a pele. Metade do corpo e fabricado — ganha vantagens de maquina e herda seus problemas.",
    desvantagemObrigatoria: desvantagensObrigatorias.androide,
  },
];

export function habilidadesDoArquetipo(arquetipoId) {
  return habilidadesPorArquetipo(arquetipoId);
}

export function buscarArquetipo(id) {
  return arquetipos.find((a) => a.id === id) ?? null;
}

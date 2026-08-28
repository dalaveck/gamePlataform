import { useMemo, useState } from "react";
import { VARIANTE_PADRAO } from "../data/regras.js";
import { calcularSaldoPontos, validarPersonagem, recalcularRecursos, CARACTERISTICAS } from "../engine/personagem.js";
import { buscarHabilidade } from "../data/habilidades.js";
import { buscarVantagem } from "../data/vantagens.js";
import { buscarDesvantagem } from "../data/desvantagens.js";

let proximoId = 1;
export function novoId() {
  return proximoId++;
}

export function personagemVazio() {
  return {
    codinome: "",
    pontosExperiencia: 0,
    forca: 0,
    habilidade: 0,
    resistencia: 0,
    armadura: 0,
    poderDeFogo: 0,
    buffs: { forca: 0, habilidade: 0, resistencia: 0, armadura: 0, poderDeFogo: 0 },
    paAtual: 0,
    pvAtual: 0,
    contaBancaria: "",
    dinheiroEspecie: "",
    equipamentoTexto: "",
    ataques: [],
    defesas: [],
    arquetipo: null,
    habilidadesEspeciais: [],
    vantagens: [],
    desvantagens: [],
    pericias: [],
    anotacoes: "",
  };
}

/**
 * Estado de uma ficha de personagem em edicao, com validacao e recursos
 * derivados recalculados a cada mudanca via o motor de regras puro
 * (src/engine). Nao persiste nada sozinho — export/import de .json ficam
 * a cargo de quem usa o hook (ver FichaPersonagem.jsx).
 */
export function usePersonagem(variante = VARIANTE_PADRAO) {
  const [personagem, setPersonagem] = useState(personagemVazio);

  function definirCampo(campo, valor) {
    setPersonagem((atual) => ({ ...atual, [campo]: valor }));
  }

  function definirCaracteristica(chave, valor) {
    const numero = Math.max(0, Math.min(5, Number(valor) || 0));
    setPersonagem((atual) => ({ ...atual, [chave]: numero }));
  }

  function definirBuff(chave, valor) {
    setPersonagem((atual) => ({ ...atual, buffs: { ...atual.buffs, [chave]: Number(valor) || 0 } }));
  }

  function definirArquetipo(arquetipoId) {
    setPersonagem((atual) => ({ ...atual, arquetipo: arquetipoId || null }));
  }

  function alternarHabilidade(habilidadeId, nivel = 1) {
    setPersonagem((atual) => {
      const jaTem = atual.habilidadesEspeciais.some((h) => h.id === habilidadeId);
      if (jaTem) {
        return { ...atual, habilidadesEspeciais: atual.habilidadesEspeciais.filter((h) => h.id !== habilidadeId) };
      }
      const catalogo = buscarHabilidade(habilidadeId);
      if (!catalogo) return atual;
      const custoPontos = catalogo.custoPorNivel ? catalogo.custoPontos * nivel : catalogo.custoPontos;
      const entrada = {
        id: catalogo.id,
        nome: catalogo.nome,
        custoPontos,
        custoPA: catalogo.custoPA,
        ...(catalogo.custoPorNivel ? { nivel } : {}),
      };
      return { ...atual, habilidadesEspeciais: [...atual.habilidadesEspeciais, entrada] };
    });
  }

  function alternarVantagem(vantagemId) {
    setPersonagem((atual) => {
      const jaTem = atual.vantagens.some((v) => v.id === vantagemId);
      if (jaTem) return { ...atual, vantagens: atual.vantagens.filter((v) => v.id !== vantagemId) };
      const catalogo = buscarVantagem(vantagemId);
      if (!catalogo) return atual;
      return {
        ...atual,
        vantagens: [...atual.vantagens, { id: catalogo.id, nome: catalogo.nome, custoPontos: catalogo.custoPontos }],
      };
    });
  }

  function alternarDesvantagem(desvantagemId) {
    setPersonagem((atual) => {
      const jaTem = atual.desvantagens.some((d) => d.id === desvantagemId);
      if (jaTem) return { ...atual, desvantagens: atual.desvantagens.filter((d) => d.id !== desvantagemId) };
      const catalogo = buscarDesvantagem(desvantagemId);
      if (!catalogo) return atual;
      return {
        ...atual,
        desvantagens: [...atual.desvantagens, { id: catalogo.id, nome: catalogo.nome, custoPontos: catalogo.custoPontos }],
      };
    });
  }

  function definirPericiaCompleta(area, completa) {
    setPersonagem((atual) => {
      const outras = atual.pericias.filter((p) => p.area !== area);
      if (!completa) {
        const existente = atual.pericias.find((p) => p.area === area);
        if (existente) return { ...atual, pericias: [...outras, { ...existente, completa: false }] };
        return atual;
      }
      return { ...atual, pericias: [...outras, { area, completa: true, especializacoes: [] }] };
    });
  }

  function definirEspecializacoes(area, especializacoesTexto) {
    const especializacoes = especializacoesTexto
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean)
      .slice(0, 3);
    setPersonagem((atual) => {
      const outras = atual.pericias.filter((p) => p.area !== area);
      return { ...atual, pericias: [...outras, { area, completa: false, especializacoes }] };
    });
  }

  function adicionarAtaque() {
    setPersonagem((atual) => ({
      ...atual,
      ataques: [...atual.ataques, { id: novoId(), nome: "", tipoDano: "", aDistancia: false, equipamento: 0 }],
    }));
  }

  function atualizarAtaque(id, patch) {
    setPersonagem((atual) => ({
      ...atual,
      ataques: atual.ataques.map((a) => (a.id === id ? { ...a, ...patch } : a)),
    }));
  }

  function removerAtaque(id) {
    setPersonagem((atual) => ({ ...atual, ataques: atual.ataques.filter((a) => a.id !== id) }));
  }

  function adicionarDefesa() {
    setPersonagem((atual) => ({
      ...atual,
      defesas: [...atual.defesas, { id: novoId(), nome: "", equipamento: 0 }],
    }));
  }

  function atualizarDefesa(id, patch) {
    setPersonagem((atual) => ({
      ...atual,
      defesas: atual.defesas.map((d) => (d.id === id ? { ...d, ...patch } : d)),
    }));
  }

  function removerDefesa(id) {
    setPersonagem((atual) => ({ ...atual, defesas: atual.defesas.filter((d) => d.id !== id) }));
  }

  function substituirPersonagem(novoPersonagem) {
    setPersonagem({ ...personagemVazio(), ...novoPersonagem });
  }

  function limparPersonagem() {
    setPersonagem(personagemVazio());
  }

  const saldo = useMemo(() => calcularSaldoPontos(personagem, variante), [personagem, variante]);
  const validacao = useMemo(() => validarPersonagem(personagem, variante), [personagem, variante]);
  const recursos = useMemo(() => recalcularRecursos(personagem, variante), [personagem, variante]);

  return {
    personagem,
    variante,
    saldo,
    validacao,
    recursos,
    caracteristicas: CARACTERISTICAS,
    definirCampo,
    definirCaracteristica,
    definirBuff,
    definirArquetipo,
    alternarHabilidade,
    alternarVantagem,
    alternarDesvantagem,
    definirPericiaCompleta,
    definirEspecializacoes,
    adicionarAtaque,
    atualizarAtaque,
    removerAtaque,
    adicionarDefesa,
    atualizarDefesa,
    removerDefesa,
    substituirPersonagem,
    limparPersonagem,
  };
}

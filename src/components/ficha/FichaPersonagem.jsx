import { useRef } from "react";
import styles from "./Ficha.module.css";
import { usePersonagem } from "../../hooks/usePersonagem.js";
import { PONTOS_CRIACAO } from "../../data/regras.js";
import SecaoCaracteristicas from "./SecaoCaracteristicas.jsx";
import SecaoRecursos from "./SecaoRecursos.jsx";
import SecaoCombate from "./SecaoCombate.jsx";
import SecaoArquetipoHabilidades from "./SecaoArquetipoHabilidades.jsx";
import SecaoPericias from "./SecaoPericias.jsx";
import SecaoVantagensDesvantagens from "./SecaoVantagensDesvantagens.jsx";
import SecaoDinheiroAnotacoes from "./SecaoDinheiroAnotacoes.jsx";

export default function FichaPersonagem({ variante }) {
  const ficha = usePersonagem(variante);
  const inputArquivoRef = useRef(null);
  const orcamento = PONTOS_CRIACAO[ficha.variante].max;

  function exportarJSON() {
    const conteudo = JSON.stringify({ v: 1, variante: ficha.variante, personagem: ficha.personagem }, null, 2);
    const blob = new Blob([conteudo], { type: "application/json" });
    const a = document.createElement("a");
    const nome = (ficha.personagem.codinome || "ficha").trim().replace(/[^\w-]+/g, "-").toLowerCase();
    a.href = URL.createObjectURL(blob);
    a.download = `${nome}-3dt.json`;
    a.click();
    URL.revokeObjectURL(a.href);
  }

  function importarJSON(event) {
    const arquivo = event.target.files[0];
    if (!arquivo) return;
    const leitor = new FileReader();
    leitor.onload = () => {
      try {
        const dados = JSON.parse(leitor.result);
        if (!dados.personagem) throw new Error("formato inesperado");
        ficha.substituirPersonagem(dados.personagem);
      } catch {
        window.alert("Não consegui ler esse arquivo — confira se é um .json exportado por esta ficha.");
      }
    };
    leitor.readAsText(arquivo);
    event.target.value = "";
  }

  return (
    <div className={styles.pagina}>
      <div className={styles.toolbar}>
        <button type="button" className={styles.botao} onClick={exportarJSON}>
          Salvar ficha
        </button>
        <button type="button" className={styles.botao} onClick={() => inputArquivoRef.current.click()}>
          Carregar ficha
        </button>
        <input
          ref={inputArquivoRef}
          type="file"
          accept=".json,application/json"
          hidden
          onChange={importarJSON}
        />
        <button
          type="button"
          className={styles.botaoFantasma}
          onClick={() => {
            if (window.confirm("Apagar tudo que está preenchido nesta ficha?")) ficha.limparPersonagem();
          }}
        >
          Limpar
        </button>
      </div>

      <div className={styles.folha}>
        <div className={styles.topo}>
          <div className={styles.marca}>
            <h1>3D&amp;T</h1>
            <div className={styles.sub}>// CYBERPUNK PROTOCOL</div>
            <div className={styles.etiqueta}>Ficha de runner — sem magia</div>
          </div>

          <div className={`${styles.linha} ${styles.tres}`} style={{ flex: 1 }}>
            <div className={styles.campo} style={{ gridColumn: "span 2" }}>
              <input
                type="text"
                value={ficha.personagem.codinome}
                onChange={(e) => ficha.definirCampo("codinome", e.target.value)}
              />
              <label>Codinome / runner</label>
            </div>
            <div className={styles.campo}>
              <input
                type="number"
                value={ficha.personagem.pontosExperiencia}
                onChange={(e) => ficha.definirCampo("pontosExperiencia", Number(e.target.value) || 0)}
              />
              <label>Pontos de experiência</label>
            </div>
          </div>

          <div className={ficha.validacao.valido ? styles.saldoOk : styles.saldoErro}>
            Saldo: {ficha.saldo} / {orcamento} pts
          </div>
        </div>

        {!ficha.validacao.valido && (
          <div className={styles.erros}>
            <b>Pendências:</b>
            <ul>
              {ficha.validacao.erros.map((erro) => (
                <li key={erro}>{erro}</li>
              ))}
            </ul>
          </div>
        )}

        <SecaoCaracteristicas
          personagem={ficha.personagem}
          caracteristicas={ficha.caracteristicas}
          onMudarValor={ficha.definirCaracteristica}
          onMudarBuff={ficha.definirBuff}
        />

        <SecaoRecursos personagem={ficha.personagem} recursos={ficha.recursos} onMudarCampo={ficha.definirCampo} />

        <SecaoDinheiroAnotacoes personagem={ficha.personagem} onMudarCampo={ficha.definirCampo} />

        <SecaoCombate
          personagem={ficha.personagem}
          variante={ficha.variante}
          onMudarCampo={ficha.definirCampo}
          onAdicionarAtaque={ficha.adicionarAtaque}
          onAtualizarAtaque={ficha.atualizarAtaque}
          onRemoverAtaque={ficha.removerAtaque}
          onAdicionarDefesa={ficha.adicionarDefesa}
          onAtualizarDefesa={ficha.atualizarDefesa}
          onRemoverDefesa={ficha.removerDefesa}
        />

        <SecaoArquetipoHabilidades
          personagem={ficha.personagem}
          onDefinirArquetipo={ficha.definirArquetipo}
          onAlternarHabilidade={ficha.alternarHabilidade}
        />

        <SecaoPericias
          personagem={ficha.personagem}
          onDefinirCompleta={ficha.definirPericiaCompleta}
          onDefinirEspecializacoes={ficha.definirEspecializacoes}
        />

        <SecaoVantagensDesvantagens
          personagem={ficha.personagem}
          variante={ficha.variante}
          onAlternarVantagem={ficha.alternarVantagem}
          onAlternarDesvantagem={ficha.alternarDesvantagem}
        />
      </div>
    </div>
  );
}

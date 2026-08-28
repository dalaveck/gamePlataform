import styles from "./Ficha.module.css";
import { arquetipos } from "../../data/arquetipos.js";
import { habilidades, ARQUETIPOS_HABILIDADE } from "../../data/habilidades.js";

export default function SecaoArquetipoHabilidades({ personagem, onDefinirArquetipo, onAlternarHabilidade }) {
  const disponiveis = habilidades.filter(
    (h) => h.arquetipo === ARQUETIPOS_HABILIDADE.GERAL || h.arquetipo === personagem.arquetipo
  );
  const idsEscolhidos = new Set(personagem.habilidadesEspeciais.map((h) => h.id));

  return (
    <section className={`${styles.secao} ${styles.cCyan}`}>
      <h2>
        Arquétipo &amp; habilidades
        <span className={styles.nota}>implantes, ciberware, técnicas</span>
      </h2>

      <div className={styles.campo} style={{ maxWidth: 320, marginBottom: 12 }}>
        <select value={personagem.arquetipo ?? ""} onChange={(e) => onDefinirArquetipo(e.target.value)}>
          <option value="">— nenhum (só gerais) —</option>
          {arquetipos.map((a) => (
            <option key={a.id} value={a.id}>
              {a.nome}
            </option>
          ))}
        </select>
        <label>Arquétipo (define quais habilidades além das gerais ficam disponíveis)</label>
      </div>

      {personagem.arquetipo && (
        <p className={styles.itemEfeito} style={{ marginBottom: 12 }}>
          {arquetipos.find((a) => a.id === personagem.arquetipo)?.descricao}
          {arquetipos.find((a) => a.id === personagem.arquetipo)?.desvantagemObrigatoria && (
            <>
              {" "}
              <b>Desvantagem obrigatória do conceito:</b>{" "}
              {arquetipos.find((a) => a.id === personagem.arquetipo).desvantagemObrigatoria.nome} (não conta
              para o teto de 3 pontos de desvantagens escolhidas).
            </>
          )}
        </p>
      )}

      <div className={styles.catalogo}>
        {disponiveis.map((h) => (
          <label key={h.id} className={styles.item}>
            <input type="checkbox" checked={idsEscolhidos.has(h.id)} onChange={() => onAlternarHabilidade(h.id)} />
            <span>
              <span className={styles.itemNome}>{h.nome}</span>
              {" — "}
              <span className={styles.itemEfeito}>{h.efeito}</span>
            </span>
            <span className={styles.preco}>
              {h.custoPontos} pt{h.custoPontos > 1 ? "s" : ""}
              {h.custoPorNivel ? "/nível" : ""}
              {h.custoPA ? ` · ${h.custoPA} PA` : ""}
            </span>
          </label>
        ))}
      </div>
    </section>
  );
}

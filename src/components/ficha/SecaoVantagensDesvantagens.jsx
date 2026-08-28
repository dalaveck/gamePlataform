import styles from "./Ficha.module.css";
import { vantagens } from "../../data/vantagens.js";
import { desvantagens } from "../../data/desvantagens.js";
import { TETO_PONTOS_DESVANTAGENS } from "../../data/regras.js";

export default function SecaoVantagensDesvantagens({
  personagem,
  variante,
  onAlternarVantagem,
  onAlternarDesvantagem,
}) {
  const idsVantagens = new Set(personagem.vantagens.map((v) => v.id));
  const idsDesvantagens = new Set(personagem.desvantagens.map((d) => d.id));
  const pontosDesvantagensEscolhidos = personagem.desvantagens.reduce((s, d) => s + d.custoPontos, 0);
  const teto = TETO_PONTOS_DESVANTAGENS[variante];

  return (
    <div className={`${styles.linha} ${styles.duas}`} style={{ marginTop: 18 }}>
      <section className={`${styles.secao} ${styles.cMagenta}`} style={{ marginTop: 0 }}>
        <h2>Vantagens</h2>
        <div className={styles.catalogo}>
          {vantagens.map((v) => (
            <label key={v.id} className={styles.item}>
              <input
                type="checkbox"
                checked={idsVantagens.has(v.id)}
                onChange={() => onAlternarVantagem(v.id)}
              />
              <span>
                <span className={styles.itemNome}>{v.nome}</span>
                {" — "}
                <span className={styles.itemEfeito}>{v.efeito}</span>
              </span>
              <span className={styles.preco}>{v.custoPontos} pt{v.custoPontos > 1 ? "s" : ""}</span>
            </label>
          ))}
        </div>
      </section>

      <section className={`${styles.secao} ${styles.cMagenta}`} style={{ marginTop: 0 }}>
        <h2>
          Desvantagens
          <span className={styles.nota}>
            {Number.isFinite(teto)
              ? `devolvem até ${teto} pts — hoje: ${pontosDesvantagensEscolhidos}${
                  pontosDesvantagensEscolhidos > teto ? " (excedente não conta)" : ""
                }`
              : "sem teto nesta variante"}
          </span>
        </h2>
        <div className={styles.catalogo}>
          {desvantagens.map((d) => (
            <label key={d.id} className={styles.item}>
              <input
                type="checkbox"
                checked={idsDesvantagens.has(d.id)}
                onChange={() => onAlternarDesvantagem(d.id)}
              />
              <span className={styles.itemNome}>{d.nome}</span>
              <span className={styles.itemEfeito}>{d.descricao}</span>
              <span className={styles.preco}>+{d.custoPontos} pt{d.custoPontos > 1 ? "s" : ""}</span>
            </label>
          ))}
        </div>
      </section>
    </div>
  );
}

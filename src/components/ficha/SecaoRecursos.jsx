import styles from "./Ficha.module.css";

export default function SecaoRecursos({ personagem, recursos, onMudarCampo }) {
  return (
    <section className={`${styles.secao} ${styles.cCyan}`}>
      <h2>Recursos &amp; combate</h2>
      <div className={`${styles.linha} ${styles.quatro}`}>
        <div className={styles.campo}>
          <input type="number" value={recursos.pvMax} readOnly />
          <label>PV máx. (Resistência × 5)</label>
        </div>
        <div className={styles.campo}>
          <input
            type="number"
            value={personagem.pvAtual}
            onChange={(e) => onMudarCampo("pvAtual", Number(e.target.value) || 0)}
          />
          <label>PV atuais</label>
        </div>
        <div className={styles.campo}>
          <input type="number" value={recursos.paMax} readOnly />
          <label>PA máx. (Habilidade × 5)</label>
        </div>
        <div className={styles.campo}>
          <input
            type="number"
            value={personagem.paAtual}
            onChange={(e) => onMudarCampo("paAtual", Number(e.target.value) || 0)}
          />
          <label>PA atuais</label>
        </div>
      </div>
      <p className={styles.itemEfeito} style={{ marginTop: 10 }}>
        Iniciativa = Habilidade + 1d6 (role na hora do combate).
      </p>
    </section>
  );
}

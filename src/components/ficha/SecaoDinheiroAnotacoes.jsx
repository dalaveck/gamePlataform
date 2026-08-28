import styles from "./Ficha.module.css";

export default function SecaoDinheiroAnotacoes({ personagem, onMudarCampo }) {
  return (
    <>
      <section className={`${styles.secao} ${styles.cGreen}`}>
        <h2>Dinheiro</h2>
        <div className={`${styles.linha} ${styles.duas}`}>
          <div className={styles.campo}>
            <input
              type="text"
              value={personagem.contaBancaria}
              onChange={(e) => onMudarCampo("contaBancaria", e.target.value)}
            />
            <label>Saldo em conta</label>
          </div>
          <div className={styles.campo}>
            <input
              type="text"
              value={personagem.dinheiroEspecie}
              onChange={(e) => onMudarCampo("dinheiroEspecie", e.target.value)}
            />
            <label>Dinheiro em espécie</label>
          </div>
        </div>
      </section>

      <section className={styles.secao}>
        <h2>Anotações</h2>
        <div className={styles.campo}>
          <textarea
            rows={5}
            value={personagem.anotacoes}
            onChange={(e) => onMudarCampo("anotacoes", e.target.value)}
          />
          <label>Contatos, contratos em aberto, história</label>
        </div>
      </section>
    </>
  );
}

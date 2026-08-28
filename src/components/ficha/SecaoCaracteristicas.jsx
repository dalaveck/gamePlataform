import styles from "./Ficha.module.css";

const ROTULOS = {
  forca: "Força (F)",
  habilidade: "Habilidade (H)",
  resistencia: "Resistência (R)",
  armadura: "Armadura (A)",
  poderDeFogo: "Poder de fogo (PdF)",
};

export default function SecaoCaracteristicas({ personagem, caracteristicas, onMudarValor, onMudarBuff }) {
  return (
    <section className={`${styles.secao} ${styles.cCyan}`}>
      <h2>Características</h2>
      <table className={styles.tabela}>
        <thead>
          <tr>
            <th style={{ width: "60%" }}>Característica</th>
            <th style={{ width: "20%" }}>Valor (0-5)</th>
            <th style={{ width: "20%" }}>Buff</th>
          </tr>
        </thead>
        <tbody>
          {caracteristicas.map((chave) => (
            <tr key={chave}>
              <td>{ROTULOS[chave]}</td>
              <td className={styles.numCel}>
                <input
                  type="number"
                  min={0}
                  max={5}
                  value={personagem[chave]}
                  onChange={(e) => onMudarValor(chave, e.target.value)}
                />
              </td>
              <td className={styles.numCel}>
                <input
                  type="number"
                  value={personagem.buffs[chave]}
                  onChange={(e) => onMudarBuff(chave, e.target.value)}
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </section>
  );
}

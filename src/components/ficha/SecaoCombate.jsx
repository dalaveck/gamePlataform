import styles from "./Ficha.module.css";
import { calcularForcaAtaqueBase, calcularForcaDefesaBase } from "../../engine/combate.js";

export default function SecaoCombate({
  personagem,
  variante,
  onMudarCampo,
  onAdicionarAtaque,
  onAtualizarAtaque,
  onRemoverAtaque,
  onAdicionarDefesa,
  onAtualizarDefesa,
  onRemoverDefesa,
}) {
  return (
    <>
      <section className={`${styles.secao} ${styles.cCyan}`}>
        <h2>Equipamento</h2>
        <div className={styles.campo}>
          <textarea
            rows={3}
            value={personagem.equipamentoTexto}
            onChange={(e) => onMudarCampo("equipamentoTexto", e.target.value)}
          />
          <label>Armas, ciberware instalado, itens</label>
        </div>
      </section>

      <section className={`${styles.secao} ${styles.cAmber}`}>
        <h2>
          Tipos de ataque
          <span className={styles.formula}>Habilidade + Força (ou PdF) + Equipamento</span>
        </h2>
        <table className={styles.tabela}>
          <thead>
            <tr>
              <th>Ataque / arma</th>
              <th>Tipo de dano</th>
              <th className={styles.numCel}>À dist.</th>
              <th className={styles.numCel}>Equip.</th>
              <th className={styles.numCel}>Total (sem 1d6)</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {personagem.ataques.map((ataque) => {
              const total = calcularForcaAtaqueBase({
                habilidade: personagem.habilidade,
                forca: personagem.forca,
                poderDeFogo: personagem.poderDeFogo,
                aDistancia: ataque.aDistancia,
                equipamento: ataque.equipamento,
                variante,
              });
              return (
                <tr key={ataque.id}>
                  <td>
                    <input
                      type="text"
                      value={ataque.nome}
                      onChange={(e) => onAtualizarAtaque(ataque.id, { nome: e.target.value })}
                    />
                  </td>
                  <td>
                    <input
                      type="text"
                      value={ataque.tipoDano}
                      onChange={(e) => onAtualizarAtaque(ataque.id, { tipoDano: e.target.value })}
                    />
                  </td>
                  <td className={styles.numCel}>
                    <input
                      type="checkbox"
                      checked={ataque.aDistancia}
                      onChange={(e) => onAtualizarAtaque(ataque.id, { aDistancia: e.target.checked })}
                    />
                  </td>
                  <td className={styles.numCel}>
                    <input
                      type="number"
                      value={ataque.equipamento}
                      onChange={(e) => onAtualizarAtaque(ataque.id, { equipamento: Number(e.target.value) || 0 })}
                    />
                  </td>
                  <td className={`${styles.numCel} ${styles.total}`}>{total}</td>
                  <td>
                    <button type="button" className={styles.botaoFantasma} onClick={() => onRemoverAtaque(ataque.id)}>
                      Remover
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
        <button type="button" className={styles.botaoFantasma} style={{ marginTop: 8 }} onClick={onAdicionarAtaque}>
          + Ataque
        </button>
      </section>

      <section className={`${styles.secao} ${styles.cAmber}`}>
        <h2>
          Defesa
          <span className={styles.formula}>Resistência + Habilidade + Equipamento</span>
        </h2>
        <table className={styles.tabela}>
          <thead>
            <tr>
              <th>Proteção / equipamento</th>
              <th className={styles.numCel}>Equip.</th>
              <th className={styles.numCel}>Total (sem 1d6)</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {personagem.defesas.map((defesa) => {
              const total = calcularForcaDefesaBase({
                habilidade: personagem.habilidade,
                armadura: personagem.armadura,
                resistencia: personagem.resistencia,
                equipamento: defesa.equipamento,
                variante,
              });
              return (
                <tr key={defesa.id}>
                  <td>
                    <input
                      type="text"
                      value={defesa.nome}
                      onChange={(e) => onAtualizarDefesa(defesa.id, { nome: e.target.value })}
                    />
                  </td>
                  <td className={styles.numCel}>
                    <input
                      type="number"
                      value={defesa.equipamento}
                      onChange={(e) => onAtualizarDefesa(defesa.id, { equipamento: Number(e.target.value) || 0 })}
                    />
                  </td>
                  <td className={`${styles.numCel} ${styles.total}`}>{total}</td>
                  <td>
                    <button type="button" className={styles.botaoFantasma} onClick={() => onRemoverDefesa(defesa.id)}>
                      Remover
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
        <button type="button" className={styles.botaoFantasma} style={{ marginTop: 8 }} onClick={onAdicionarDefesa}>
          + Proteção
        </button>
      </section>
    </>
  );
}

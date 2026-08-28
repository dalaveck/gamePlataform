import styles from "./Ficha.module.css";
import { AREAS_PERICIA } from "../../data/pericias.js";
import { CUSTO_PERICIA } from "../../data/regras.js";

export default function SecaoPericias({ personagem, onDefinirCompleta, onDefinirEspecializacoes }) {
  return (
    <section className={`${styles.secao} ${styles.cCyan}`}>
      <h2>
        Perícias
        <span className={styles.nota}>
          área completa ({CUSTO_PERICIA.AREA_COMPLETA} pts) ou até {CUSTO_PERICIA.ESPECIALIZACOES_MAX}{" "}
          especializações soltas ({CUSTO_PERICIA.ESPECIALIZACOES} pt)
        </span>
      </h2>
      {AREAS_PERICIA.map((area) => {
        const entrada = personagem.pericias.find((p) => p.area === area);
        const completa = !!entrada?.completa;
        const especializacoes = (entrada?.especializacoes ?? []).join(", ");
        return (
          <div key={area} className={styles.periciaLinha}>
            <span>{area}</span>
            <label style={{ display: "flex", alignItems: "center", gap: 4, fontSize: 11 }}>
              <input
                type="checkbox"
                checked={completa}
                onChange={(e) => onDefinirCompleta(area, e.target.checked)}
              />
              completa
            </label>
            <input
              type="text"
              placeholder="especializações soltas, separadas por vírgula"
              value={especializacoes}
              disabled={completa}
              onChange={(e) => onDefinirEspecializacoes(area, e.target.value)}
            />
          </div>
        );
      })}
    </section>
  );
}

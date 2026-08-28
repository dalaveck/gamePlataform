import { useState } from "react";
import fichaStyles from "../ficha/Ficha.module.css";
import styles from "./Sessao.module.css";

export default function EntrarOuCriar({ personagemResumo, onCriar, onEntrar, carregando, erro }) {
  const [aba, setAba] = useState("criar");
  const [nome, setNome] = useState("");
  const [codigo, setCodigo] = useState("");

  const nomeValido = nome.trim().length > 0;

  function aoSubmeter(e) {
    e.preventDefault();
    if (!nomeValido) return;
    if (aba === "criar") {
      onCriar({ nome: nome.trim(), personagemResumo });
    } else {
      if (!codigo.trim()) return;
      onEntrar({ codigo: codigo.trim(), nome: nome.trim(), personagemResumo });
    }
  }

  return (
    <div className={styles.pagina}>
      <div className={fichaStyles.folha}>
        <div className={fichaStyles.topo}>
          <div className={fichaStyles.marca}>
            <h1>Mesa</h1>
            <div className={fichaStyles.sub}>// CYBERPUNK PROTOCOL</div>
            <div className={fichaStyles.etiqueta}>Criar ou entrar numa sala</div>
          </div>
        </div>

        {erro && <div className={styles.erro}>{erro}</div>}

        <div className={styles.abas} style={{ marginTop: 18 }}>
          <button
            type="button"
            className={aba === "criar" ? styles.abaAtiva : styles.aba}
            onClick={() => setAba("criar")}
          >
            Criar sala
          </button>
          <button
            type="button"
            className={aba === "entrar" ? styles.abaAtiva : styles.aba}
            onClick={() => setAba("entrar")}
          >
            Entrar com código
          </button>
        </div>

        <form onSubmit={aoSubmeter}>
          <div className={fichaStyles.campo} style={{ marginBottom: 14 }}>
            <input type="text" value={nome} onChange={(e) => setNome(e.target.value)} autoFocus />
            <label>Seu nome</label>
          </div>

          {aba === "entrar" && (
            <div className={fichaStyles.campo} style={{ marginBottom: 14 }}>
              <input
                type="text"
                value={codigo}
                onChange={(e) => setCodigo(e.target.value.toUpperCase())}
                maxLength={6}
                style={{ letterSpacing: 4, fontFamily: "ui-monospace, Menlo, monospace" }}
              />
              <label>Código da sala (6 caracteres)</label>
            </div>
          )}

          {personagemResumo && (
            <p className={styles.aviso}>
              Entrando com a ficha <b>{personagemResumo.codinome}</b> (PV {personagemResumo.pvMax}, PA{" "}
              {personagemResumo.paMax}).
            </p>
          )}

          <button type="submit" className={fichaStyles.botao} disabled={!nomeValido || carregando}>
            {carregando ? "Aguarde…" : aba === "criar" ? "Criar sala" : "Entrar"}
          </button>
        </form>
      </div>
    </div>
  );
}

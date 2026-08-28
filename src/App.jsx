import { lazy, Suspense, useState } from "react";
import FichaPersonagem from "./components/ficha/FichaPersonagem.jsx";
import { VARIANTE_PADRAO } from "./data/regras.js";
import { usePersonagem } from "./hooks/usePersonagem.js";

// Carregado sob demanda: o SDK do Firebase é pesado e só é necessário quando
// o jogador realmente abre a aba de sessão multiplayer.
const SessaoTela = lazy(() => import("./components/sessao/SessaoTela.jsx"));

export default function App() {
  const [tela, setTela] = useState("ficha");
  const ficha = usePersonagem(VARIANTE_PADRAO);

  return (
    <div>
      <nav
        style={{
          display: "flex",
          gap: 8,
          padding: "10px 16px",
          borderBottom: "1px solid var(--hair)",
          background: "var(--paper)",
        }}
      >
        <button
          type="button"
          onClick={() => setTela("ficha")}
          style={{
            fontWeight: tela === "ficha" ? 700 : 400,
            border: "none",
            background: "none",
            cursor: "pointer",
            fontFamily: "ui-monospace, Menlo, monospace",
            fontSize: 12,
            textTransform: "uppercase",
            letterSpacing: 0.6,
          }}
        >
          Ficha
        </button>
        <button
          type="button"
          onClick={() => setTela("sessao")}
          style={{
            fontWeight: tela === "sessao" ? 700 : 400,
            border: "none",
            background: "none",
            cursor: "pointer",
            fontFamily: "ui-monospace, Menlo, monospace",
            fontSize: 12,
            textTransform: "uppercase",
            letterSpacing: 0.6,
          }}
        >
          Mesa / Sessão
        </button>
      </nav>

      {tela === "ficha" ? (
        <FichaPersonagem ficha={ficha} />
      ) : (
        <Suspense fallback={<p style={{ padding: 16 }}>Carregando…</p>}>
          <SessaoTela ficha={ficha} />
        </Suspense>
      )}
    </div>
  );
}

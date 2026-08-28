// Fase 1 do ROADMAP.md: so o motor de regras (src/engine) esta pronto ate
// aqui. Ainda nao ha UI de sessao/ficha/combate (ver Fases 2-5) — esta tela
// e um placeholder que so confirma que o motor esta acessivel ao app.

import { VARIANTE_PADRAO } from "./data/regras.js";
import { calcularPVMax, calcularPAMax } from "./engine/combate.js";

export default function App() {
  const resistenciaExemplo = 2;
  const habilidadeExemplo = 2;

  return (
    <main style={{ fontFamily: "monospace", padding: "2rem", maxWidth: 640, margin: "0 auto" }}>
      <h1>Cyberpunk Protocol — 3D&amp;T</h1>
      <p>
        Motor de regras (<code>src/engine</code>) e dados (<code>src/data</code>) da Fase 1 estao
        prontos. UI de ficha, sessao e combate ainda nao foram implementadas — ver{" "}
        <code>ROADMAP.md</code>.
      </p>
      <p>
        Exemplo: personagem com Resistencia {resistenciaExemplo} e Habilidade {habilidadeExemplo} na
        variante <code>{VARIANTE_PADRAO}</code> tem PV max {calcularPVMax(resistenciaExemplo, VARIANTE_PADRAO)}{" "}
        e PA max {calcularPAMax(habilidadeExemplo, VARIANTE_PADRAO)}.
      </p>
    </main>
  );
}

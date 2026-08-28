import fichaStyles from "../ficha/Ficha.module.css";
import styles from "./Sessao.module.css";
import { useSessao } from "../../hooks/useSessao.js";
import { resumirPersonagem } from "../../hooks/usePersonagem.js";
import EntrarOuCriar from "./EntrarOuCriar.jsx";
import LobbySessao from "./LobbySessao.jsx";

export default function SessaoTela({ ficha }) {
  const sessaoHook = useSessao();
  const personagemResumo = resumirPersonagem(ficha.personagem, ficha.recursos);

  if (!sessaoHook.disponivel) {
    return (
      <div className={styles.pagina}>
        <div className={fichaStyles.folha}>
          <p className={styles.erro}>
            Sessão multiplayer desativada: faltam as variáveis <code>VITE_FIREBASE_*</code> (ver{" "}
            <code>.env.example</code> na raiz do projeto). Configure um projeto Firebase e reinicie o
            app para usar salas.
          </p>
        </div>
      </div>
    );
  }

  if (!sessaoHook.codigo) {
    return (
      <EntrarOuCriar
        personagemResumo={personagemResumo}
        carregando={sessaoHook.carregando}
        erro={sessaoHook.erro}
        onCriar={({ nome, personagemResumo: resumo }) =>
          sessaoHook.criar({ variante: ficha.variante, nome, personagemResumo: resumo })
        }
        onEntrar={sessaoHook.entrar}
      />
    );
  }

  return (
    <LobbySessao
      codigo={sessaoHook.codigo}
      sessao={sessaoHook.sessao}
      jogadorId={sessaoHook.jogadorId}
      onMarcarPronto={sessaoHook.marcarPronto}
      onSair={sessaoHook.sair}
    />
  );
}

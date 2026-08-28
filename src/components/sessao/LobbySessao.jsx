import fichaStyles from "../ficha/Ficha.module.css";
import styles from "./Sessao.module.css";

export default function LobbySessao({ codigo, sessao, jogadorId, onMarcarPronto, onSair }) {
  if (!sessao) {
    return (
      <div className={styles.pagina}>
        <p className={styles.aviso}>Conectando à sala {codigo}…</p>
      </div>
    );
  }

  const jogadores = sessao.jogadores ?? [];
  const jogadorAtual = jogadores.find((j) => j.id === jogadorId);

  return (
    <div className={styles.pagina}>
      <div className={fichaStyles.folha}>
        <div className={fichaStyles.topo}>
          <div className={fichaStyles.marca}>
            <h1>Lobby</h1>
            <div className={fichaStyles.sub}>// CYBERPUNK PROTOCOL</div>
            <div className={fichaStyles.etiqueta}>Variante: {sessao.variante}</div>
          </div>
        </div>

        <div className={styles.codigoGrande}>{codigo}</div>
        <p className={styles.aviso}>Compartilhe esse código com o resto do grupo para eles entrarem na mesma sala.</p>

        <div className={styles.listaJogadores} style={{ marginTop: 18 }}>
          {jogadores.length === 0 && <p className={fichaStyles.itemEfeito}>Ninguém entrou ainda.</p>}
          {jogadores.map((j) => (
            <div key={j.id} className={styles.jogador}>
              <div className={styles.jogadorInfo}>
                <b>
                  {j.nome} {j.id === jogadorId && "(você)"}
                </b>
                {j.personagemResumo && (
                  <span>
                    {j.personagemResumo.codinome} · PV {j.personagemResumo.pvMax} · PA{" "}
                    {j.personagemResumo.paMax}
                  </span>
                )}
              </div>
              <span className={j.pronto ? styles.seloPronto : styles.selo}>
                {j.pronto ? "pronto" : "aguardando"}
              </span>
            </div>
          ))}
        </div>

        <div className={fichaStyles.toolbar}>
          <button
            type="button"
            className={fichaStyles.botao}
            onClick={() => onMarcarPronto(!jogadorAtual?.pronto)}
          >
            {jogadorAtual?.pronto ? "Marcar como não pronto" : "Marcar como pronto"}
          </button>
          <button type="button" className={fichaStyles.botaoFantasma} onClick={onSair}>
            Sair da sala
          </button>
        </div>
      </div>
    </div>
  );
}

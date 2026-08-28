import FichaPersonagem from "./components/ficha/FichaPersonagem.jsx";
import { VARIANTE_PADRAO } from "./data/regras.js";

export default function App() {
  return <FichaPersonagem variante={VARIANTE_PADRAO} />;
}

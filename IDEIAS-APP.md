# App de gestão — Ideias para o futuro

> Ideias registadas para retomar mais tarde. Não são prioridade agora.
> Prioridade atual: fechar o widget + sincronização com Supabase.
> Última atualização: 2026-06-17.

---

## 1. Vista desktop / app responsiva (IDEIA APROVADA, para depois)

**O quê:** fazer a app atual (`index.html`, v51) adaptar-se ao tamanho do ecrã —
**uma única app, dois layouts automáticos**.

- **No telemóvel** → fica **igual ao que existe hoje** (mobile-first, sem mudanças).
- **No portátil/PC** → a mesma app deteta o ecrã grande e reorganiza-se em **formato
  dashboard** (várias colunas, tabelas largas, aproveitar a largura). Inspiração no
  look da antiga `Desktop/VapeTrack.html` (que o Vasco gostou no PC).

**Importante:**
- **Mesmos dados, mesma lógica, mesmas secções** — vindos do **mesmo Supabase**.
  NÃO é cópia nem app separada; é o mesmo ficheiro a "vestir-se" conforme o ecrã.
- Comportamento: ao abrir no portátil aparece **logo a dashboard**; no telemóvel aparece
  **logo a app**. Automático, sem o utilizador escolher nada.
- O critério é a **largura da janela** (não o aparelho). Definir um ponto de corte
  (breakpoint) — ex.: acima de ~1000px = dashboard; abaixo = mobile.

**Porquê abordagem responsiva (A) e não app separada (B):**
- A) Um só código → uma só fonte de verdade. Mudas algo uma vez, vale nos dois. ✅
- B) Dashboard separado → duas apps para manter, trabalho a dobrar em cada mudança. ⚠️

**Estado:** por fazer. Retomar depois do widget + Supabase.

---

## Notas relacionadas
- `WIDGET-BACKEND-NOTAS.md` — regras e tarefas do widget para a fase live.

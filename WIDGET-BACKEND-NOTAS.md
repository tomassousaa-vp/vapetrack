# Widget — Regras & decisões para a fase de backend (link live)

> Documento de memória. O widget (`widget-H-pro.html` e variantes) é hoje **só visual**.
> Estas regras NÃO estão implementadas — devem ser construídas quando ligarmos o widget ao
> Supabase (tabela de pedidos, RLS, ligação à base de clientes). Última atualização: 2026-06-17.

---

## 1. Identificação do cliente por telemóvel (REGRA CONFIRMADA)

Quando um pedido entra pelo widget, cruza-se o **telemóvel** com a base de clientes da app de gestão:

| Situação | Comportamento |
|---|---|
| Telemóvel **novo** | Cria/regista cliente novo; pedido entra normal. |
| Telemóvel **existente + mesmo nome** | Associa ao cliente existente, sem aviso. |
| Telemóvel **existente + NOME DIFERENTE** | Pedido entra **marcado com AVISO** na app de gestão → o Vasco confirma se é a mesma pessoa (mudou de nome/alcunha) ou alguém diferente a usar o mesmo número. |

**Objetivo:** evitar clientes duplicados e apanhar casos como "Bruno" vs "Brunão", ou número
reutilizado por outra pessoa.

**Decisão por fechar:** no caso "mesmo número + nome diferente", o pedido deve ficar
**em espera até confirmação** OU **entrar na mesma mas com etiqueta de aviso**? → A CONFIRMAR.

---

## 2. Estado atual (o que existe hoje)

- Widget = mockup visual, sem ligação a Supabase. Nome + telemóvel na Entrada **não são gravados
  nem comparados**.
- App de gestão (`index.html`): clientes têm `nome` + `telefone (opcional)`. Identidade gerida
  **pelo nome** (venda usa nome via datalist). NÃO há deteção de número duplicado nem avisos.

---

## 3. Por construir (fase de backend do widget)

- [ ] Tabela `pedidos` no Supabase (+ RLS, anti-spam).
- [ ] Ligar Entrada do widget (nome + telemóvel) ao registo do pedido.
- [ ] Cruzamento por telemóvel + lógica de aviso da secção 1.
- [ ] Sincronizar catálogo/stock reais (hoje os sabores no mockup são fixos, NÃO ligados à app).
- [ ] Fluxo de resposta: análise → aprovado/recusado refletido no link do cliente.

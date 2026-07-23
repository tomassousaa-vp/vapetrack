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
| Telemóvel **existente + NOME DIFERENTE** | Pedido entra **marcado com AVISO** (não bloqueia a entrada). O telemóvel é o identificador fiável — NÃO se pergunta o número ao cliente, já está na base. Mostra os DOIS nomes (o registado vs. o que o cliente escreveu). O gestor tem de **CONFIRMAR a identidade PRIMEIRO** e só depois é que os botões Aprovar/Recusar ficam disponíveis. |

**Objetivo:** evitar clientes duplicados e apanhar casos como "Bruno" vs "Brunão", ou número
reutilizado por outra pessoa.

**Decisão FECHADA (2026-07-23):**
- No caso "mesmo número + nome diferente", o pedido **entra com etiqueta de aviso**
  (não fica em espera invisível) — porque o telemóvel já está na base e é ele que
  identifica o cliente; o gestor nunca tem de pedir o número ao cliente.
- Fluxo obrigatório: **primeiro CONFIRMAÇÃO da identidade, depois Aprovar/Recusar.**
  Ou seja, enquanto o aviso não for resolvido (é o mesmo cliente? / é outra pessoa?),
  as ações Aprovar/Recusar ficam bloqueadas nesse pedido.
  - "É o mesmo cliente" → associa ao cliente existente (mantém o registo/telemóvel);
    fica registado o nome alternativo/alcunha. Depois pode aprovar/recusar.
  - "É outra pessoa" → tratar como cliente distinto (mesmo número partilhado). Depois pode aprovar/recusar.

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

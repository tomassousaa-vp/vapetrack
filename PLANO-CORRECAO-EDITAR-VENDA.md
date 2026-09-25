# Plano — Corrigir preço ao EDITAR uma venda já gravada

> Estado: **POR APROVAR / POR FAZER.** Nenhum código foi alterado.
> Regra combinada: antes de mexer, confirmar contigo. Mexer só no necessário e preservar o resto.

## 1. O problema (confirmado com testes)

| Situação | Hoje | Devia dar |
|---|---|---|
| Criar venda do zero, 5 vapes c/ promo | 57 ✓ | 57 |
| **Editar** venda gravada (manter 5) + "Aplicar promoção" | **0** ❌ | 57 |
| **Editar** venda gravada e subir para 6 | **57** ❌ | ~70 |
| **Editar** venda de 5 sabores (1 de cada) | **4 a €11 = 44** ❌ | 5 a €11 = 55 |

Criar do zero está sempre certo. **O erro só acontece ao editar.**

## 2. A causa

Ao editar, a app **conta os vapes da venda duas vezes**:

1. Trata-os como já vendidos (já saíram da encomenda).
2. Depois tenta "vendê-los" outra vez para calcular o preço.

Os vapes que não cabem nessa segunda contagem ficam **fora do preço (€0)**. Por isso o resultado varia: às vezes €0, às vezes "4 em vez de 5".

No código, a função `distributeItemsAcrossHaulsFIFO(items)` **ignora a venda que está a ser editada**, apesar de `calcSaleTotalFromItems` e `calcSaleBreakdown` já receberem o id dela (`excludeSaleId`). O id simplesmente não é passado nem usado.

## 3. A correção (cirúrgica)

Fazer a app contar a venda que estamos a editar **uma vez só**, como numa venda nova.

1. **`computeHaulStats`**: no ciclo que desconta as vendas das encomendas, **registar quanto cada venda tirou de cada encomenda** (`stat.takenBySale[vendaId][sabor|modelo]`). É só um registo; não muda nenhum cálculo.
2. **`distributeItemsAcrossHaulsFIFO(items, excludeSaleId)`**: novo parâmetro opcional. Se vier um id, **devolver às encomendas os vapes que essa venda tinha tirado** antes de distribuir. Sem id, o comportamento fica igual ao de hoje.
3. **`calcSaleTotalFromItems`** e **`calcSaleBreakdown`**: passar o `excludeSaleId` que já recebem para a função acima.

Não mexe em mais nada:
- Criar do zero não é tocado (o caminho sem id fica igual).
- O preço manual continua livre (campo "Valor total" editável).
- O botão "Aplicar promoção" continua a forçar o recálculo, como antes.
- Vendas gravadas, stock e dinheiro recebido não mudam.

## 4. Efeitos secundários a verificar

- `priceSale(venda)` já chama `calcSaleBreakdown(..., venda.id)`. Com a correção, o detalhe de preço das vendas gravadas passa a bater certo mais vezes. Consequências:
  - O cartão da venda mostra mais vezes o detalhe (ex.: "5 a €11").
  - O **lucro por encomenda** pode mudar ligeiramente (fica mais correto).
  - O **dinheiro recebido** (Dinheiro / MB Way) **não muda**, porque vem dos pagamentos.
- Desempenho: é só somar/devolver números já calculados, sem custo relevante.

## 5. Testes antes de publicar

**Novos (os teus exemplos):**
- Editar e manter 5 com promo → **57** (hoje 0)
- Editar e subir para 6 → **~70** (hoje 57)
- Editar venda de 5 sabores → **5 a €11 = 55** (hoje 44)
- Criar do zero continua **57** e **55**

**Regressão (os que já existiam):** pagamento por venda, painel financeiro, detalhe da encomenda, KPIs de dinheiro (1 e 2 encomendas).

Comparar também o **lucro por encomenda** antes e depois, e mostrar-te a diferença.

## 6. Publicação

Só depois do teu OK:
1. Implementar os passos 1 a 3.
2. Correr todos os testes e mostrar-te os números.
3. Bump de versão para **v75**, commit, PR e merge.
4. Tu testas na app: editar uma venda gravada e carregar em "Aplicar promoção".

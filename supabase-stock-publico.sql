-- ══════════════════════════════════════════════════════════════════════════
-- VapeTrack · Stock público para o widget (trancar quantidades)
-- Corre uma vez no Supabase:  Dashboard → SQL Editor → New query → colar → Run
--
-- Expõe SÓ "quantos há de cada sabor" (comprado − vendido), agregado.
-- NÃO expõe vendas, clientes, preços nem as linhas dos hauls — só os totais.
-- É SECURITY DEFINER: corre com permissões do dono e devolve apenas os números.
-- ══════════════════════════════════════════════════════════════════════════

create or replace function public.stock_publico()
returns table(flavor text, model text, disponivel int)
language sql
stable
security definer
set search_path = public
as $$
  select f, m, sum(q)::int as disponivel
  from (
    -- comprado: caixas × 10 por (sabor, modelo)
    select it->>'flavor' as f, it->>'model' as m,
           (coalesce((it->>'boxes')::numeric, 0) * 10) as q
      from public.hauls h,
           lateral jsonb_array_elements(coalesce(h.items, '[]'::jsonb)) it
    union all
    -- vendido: unidades por (sabor, modelo) — subtrai
    select it->>'flavor', it->>'model',
           -coalesce((it->>'units')::numeric, 0)
      from public.sales s,
           lateral jsonb_array_elements(coalesce(s.items, '[]'::jsonb)) it
  ) t
  where f is not null and m is not null
  group by f, m
  having sum(q) > 0;   -- só sabores com stock positivo
$$;

-- O widget (anónimo) e a app (autenticada) podem chamar a função.
grant execute on function public.stock_publico() to anon, authenticated;

-- Nota: app de um único vendedor — a função soma todos os hauls/sales (que são
-- todos teus). Devolve só sabor/modelo/quantidade disponível.

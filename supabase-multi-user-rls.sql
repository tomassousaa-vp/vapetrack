-- ══════════════════════════════════════════════════════════════════════════
-- VapeTrack · Isolamento por utilizador (conta separada p/ o Bruce)
-- Corre UMA vez no Supabase:  Dashboard → SQL Editor → New query → colar → Run
--
-- O QUE FAZ:
--   Garante que cada conta (tu, o Bruce, …) só vê e só mexe nas SUAS linhas.
--   A app lê com  select('*')  e confia no RLS para separar os dados — este SQL
--   é o que torna essa separação REAL e segura.
--
--   Para cada tabela (hauls, sales, customers, pricing):
--     1) liga o RLS
--     2) apaga TODAS as políticas antigas (sejam quais forem os nomes) para não
--        ficar nenhuma permissiva (ex.: using(true)) a deixar ver tudo
--     3) cria políticas novas: só o dono da linha (auth.uid() = user_id)
--
-- NÃO toca na tabela `pedidos` (o widget anónimo precisa de inserir lá) nem na
-- função stock_publico().
--
-- Nota: todas as linhas existentes já têm user_id (a app grava-o sempre), por
-- isso continuas a ver os teus dados. Se alguma linha antiga tiver user_id NULL,
-- ficaria invisível — corre a verificação no fim para confirmar (deve dar 0).
-- ══════════════════════════════════════════════════════════════════════════

do $$
declare
  t    text;
  pol  record;
  tables text[] := array['hauls', 'sales', 'customers', 'pricing'];
begin
  foreach t in array tables loop
    -- 1) ligar RLS
    execute format('alter table public.%I enable row level security', t);

    -- 2) apagar todas as políticas existentes desta tabela
    for pol in
      select policyname from pg_policies
      where schemaname = 'public' and tablename = t
    loop
      execute format('drop policy %I on public.%I', pol.policyname, t);
    end loop;

    -- 3) criar políticas por dono (só linhas onde auth.uid() = user_id)
    execute format($f$
      create policy "own_select" on public.%I
        for select to authenticated
        using (auth.uid() = user_id)
    $f$, t);

    execute format($f$
      create policy "own_insert" on public.%I
        for insert to authenticated
        with check (auth.uid() = user_id)
    $f$, t);

    execute format($f$
      create policy "own_update" on public.%I
        for update to authenticated
        using (auth.uid() = user_id)
        with check (auth.uid() = user_id)
    $f$, t);

    execute format($f$
      create policy "own_delete" on public.%I
        for delete to authenticated
        using (auth.uid() = user_id)
    $f$, t);
  end loop;
end $$;

-- ── Verificação (opcional) ────────────────────────────────────────────────
-- Deve devolver 0 em todas. Se alguma > 0, essas linhas têm user_id NULL e
-- ficariam invisíveis — avisa-me que ajudo a corrigir antes de dares o login.
select 'hauls'     as tabela, count(*) as linhas_sem_dono from public.hauls     where user_id is null
union all
select 'sales',     count(*) from public.sales     where user_id is null
union all
select 'customers', count(*) from public.customers where user_id is null
union all
select 'pricing',   count(*) from public.pricing   where user_id is null;

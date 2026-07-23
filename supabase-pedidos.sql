-- ══════════════════════════════════════════════════════════════════════════
-- VapeTrack · Fase 2 do widget — tabela de PEDIDOS
-- Correr uma vez no Supabase:  Dashboard → SQL Editor → New query → colar → Run
-- ══════════════════════════════════════════════════════════════════════════

create table if not exists public.pedidos (
  id         uuid primary key default gen_random_uuid(),
  name       text  not null,
  phone      text,
  items      jsonb not null default '[]'::jsonb,   -- [{ flavor, model, units, emo }]
  status     text  not null default 'analise',     -- analise | aprovado | recusado
  confirmado boolean not null default false,       -- aviso "mesmo nº, nome diferente" já resolvido?
  created_at timestamptz not null default now()
);

alter table public.pedidos enable row level security;

-- O widget é PÚBLICO (anónimo): SÓ pode criar pedidos novos (status 'analise').
-- Não pode ler, alterar nem apagar nada — a RLS não tem policies de leitura para 'anon'.
drop policy if exists "anon cria pedidos" on public.pedidos;
create policy "anon cria pedidos" on public.pedidos
  for insert to anon
  with check (status = 'analise' and confirmado = false);

-- A conta autenticada (o dono da app) lê e gere os pedidos.
-- App de um único vendedor: qualquer sessão autenticada vê os pedidos.
drop policy if exists "dono le pedidos" on public.pedidos;
create policy "dono le pedidos" on public.pedidos
  for select to authenticated using (true);

drop policy if exists "dono atualiza pedidos" on public.pedidos;
create policy "dono atualiza pedidos" on public.pedidos
  for update to authenticated using (true);

drop policy if exists "dono apaga pedidos" on public.pedidos;
create policy "dono apaga pedidos" on public.pedidos
  for delete to authenticated using (true);

-- Nota de segurança: 'anon' consegue INSERIR (é assim que o widget funciona).
-- Risco = spam de pedidos falsos. Mitigações futuras: rate-limit / captcha /
-- validação. O link é pouco divulgado, por isso o risco imediato é baixo.

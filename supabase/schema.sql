-- ==========================================================
-- AtelierPro — schéma de référence (reflète la base réelle
-- "atelier pro niger" observée le 29/08/2026).
-- Sans danger à rejouer : create table/policy if not exists,
-- et drop policy if exists avant chaque create policy.
-- Ne PAS exécuter en pensant "réparer" quelque chose : ce
-- fichier sert de documentation / à recréer un projet vierge.
-- ==========================================================

create extension if not exists "uuid-ossp" schema extensions;

do $$
begin
  create type public.statut_commande as enum ('en_attente', 'en_cours', 'termine', 'livre');
exception
  when duplicate_object then null;
end $$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ==========================================================
-- ateliers
-- ==========================================================
create table if not exists public.ateliers (
  id uuid not null default extensions.uuid_generate_v4(),
  user_id uuid not null,
  nom_atelier text not null,
  telephone text null,
  ville text null,
  specialite text null,
  logo_url text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint ateliers_pkey primary key (id),
  constraint ateliers_user_id_key unique (user_id),
  constraint ateliers_user_id_fkey foreign key (user_id) references auth.users (id) on delete cascade
);

drop trigger if exists trg_ateliers_updated on public.ateliers;
create trigger trg_ateliers_updated before update on public.ateliers
for each row execute function public.set_updated_at();

alter table public.ateliers enable row level security;

drop policy if exists "Users manage their own atelier" on public.ateliers;
create policy "Users manage their own atelier"
  on public.ateliers for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ==========================================================
-- clients
-- ==========================================================
create table if not exists public.clients (
  id uuid not null default extensions.uuid_generate_v4(),
  user_id uuid not null,
  nom_complet text not null,
  telephone text null,
  adresse text null,
  notes text null,
  photo_url text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint clients_pkey primary key (id),
  constraint clients_user_id_fkey foreign key (user_id) references auth.users (id) on delete cascade
);

create index if not exists idx_clients_user on public.clients using btree (user_id);

drop trigger if exists trg_clients_updated on public.clients;
create trigger trg_clients_updated before update on public.clients
for each row execute function public.set_updated_at();

alter table public.clients enable row level security;

drop policy if exists "Users manage their own clients" on public.clients;
create policy "Users manage their own clients"
  on public.clients for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ==========================================================
-- fiches_mesures
-- ==========================================================
create table if not exists public.fiches_mesures (
  id uuid not null default extensions.uuid_generate_v4(),
  user_id uuid not null,
  client_id uuid not null,
  titre text not null default 'Mesures',
  mesures jsonb not null default '{}'::jsonb,
  notes text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint fiches_mesures_pkey primary key (id),
  constraint fiches_mesures_client_id_fkey foreign key (client_id) references public.clients (id) on delete cascade,
  constraint fiches_mesures_user_id_fkey foreign key (user_id) references auth.users (id) on delete cascade
);

create index if not exists idx_fiches_client on public.fiches_mesures using btree (client_id);
create index if not exists idx_fiches_user on public.fiches_mesures using btree (user_id);

drop trigger if exists trg_fiches_updated on public.fiches_mesures;
create trigger trg_fiches_updated before update on public.fiches_mesures
for each row execute function public.set_updated_at();

alter table public.fiches_mesures enable row level security;

drop policy if exists "Users manage their own fiches" on public.fiches_mesures;
create policy "Users manage their own fiches"
  on public.fiches_mesures for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ==========================================================
-- commandes
-- ==========================================================
create table if not exists public.commandes (
  id uuid not null default extensions.uuid_generate_v4(),
  user_id uuid not null,
  client_id uuid not null,
  fiche_mesure_id uuid null,
  description text not null,
  statut public.statut_commande not null default 'en_attente'::public.statut_commande,
  date_commande date not null default current_date,
  date_echeance date null,
  prix_total numeric(12, 2) not null default 0,
  acompte numeric(12, 2) not null default 0,
  solde numeric generated always as (prix_total - acompte) stored,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint commandes_pkey primary key (id),
  constraint commandes_client_id_fkey foreign key (client_id) references public.clients (id) on delete cascade,
  constraint commandes_fiche_mesure_id_fkey foreign key (fiche_mesure_id) references public.fiches_mesures (id) on delete set null,
  constraint commandes_user_id_fkey foreign key (user_id) references auth.users (id) on delete cascade
);

create index if not exists idx_commandes_user on public.commandes using btree (user_id);
create index if not exists idx_commandes_client on public.commandes using btree (client_id);
create index if not exists idx_commandes_statut on public.commandes using btree (statut);
create index if not exists idx_commandes_echeance on public.commandes using btree (date_echeance);

drop trigger if exists trg_commandes_updated on public.commandes;
create trigger trg_commandes_updated before update on public.commandes
for each row execute function public.set_updated_at();

alter table public.commandes enable row level security;

drop policy if exists "Users manage their own commandes" on public.commandes;
create policy "Users manage their own commandes"
  on public.commandes for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ==========================================================
-- paiements
-- ==========================================================
create table if not exists public.paiements (
  id uuid not null default extensions.uuid_generate_v4(),
  user_id uuid not null,
  commande_id uuid not null,
  montant numeric(12, 2) not null,
  mode text null default 'especes'::text,
  date_paiement date not null default current_date,
  created_at timestamp with time zone not null default now(),
  constraint paiements_pkey primary key (id),
  constraint paiements_commande_id_fkey foreign key (commande_id) references public.commandes (id) on delete cascade,
  constraint paiements_user_id_fkey foreign key (user_id) references auth.users (id) on delete cascade
);

create index if not exists idx_paiements_commande on public.paiements using btree (commande_id);

alter table public.paiements enable row level security;

drop policy if exists "Users manage their own paiements" on public.paiements;
create policy "Users manage their own paiements"
  on public.paiements for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ==========================================================
-- v_commandes_en_retard (vue)
-- ==========================================================
create or replace view public.v_commandes_en_retard
with (security_invoker = true) as
select
  id, user_id, client_id, fiche_mesure_id, description, statut,
  date_commande, date_echeance, prix_total, acompte, solde,
  created_at, updated_at
from public.commandes c
where date_echeance < current_date
  and statut <> 'livre'::public.statut_commande;

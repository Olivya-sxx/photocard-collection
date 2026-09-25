create table public.cards (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  member text not null,
  album text not null default '',
  source text not null default '',
  source_detail text not null default '',
  market_price numeric,
  purchase_price numeric,
  order_date date,
  status text not null default '已到手',
  like_level integer not null default 5,
  quantity integer not null default 1,
  look_name text not null default '',
  note text not null default '',
  image_path text,
  created_at bigint not null,
  updated_at timestamptz not null default now()
);

create table public.layouts (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  cards jsonb not null default '[]'::jsonb,
  created_at bigint not null,
  updated_at timestamptz not null default now()
);

alter table public.cards enable row level security;
alter table public.layouts enable row level security;

create policy "cards are private" on public.cards
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "layouts are private" on public.layouts
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

insert into storage.buckets (id, name, public)
values ('card-images', 'card-images', false);

create policy "card images are private" on storage.objects
  for select to authenticated
  using (bucket_id = 'card-images' and (select auth.uid()::text) = (storage.foldername(name))[1]);

create policy "upload own card images" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'card-images' and (select auth.uid()::text) = (storage.foldername(name))[1]);

create policy "update own card images" on storage.objects
  for update to authenticated
  using (bucket_id = 'card-images' and (select auth.uid()::text) = (storage.foldername(name))[1]);

create policy "delete own card images" on storage.objects
  for delete to authenticated
  using (bucket_id = 'card-images' and (select auth.uid()::text) = (storage.foldername(name))[1]);

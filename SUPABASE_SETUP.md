# Guia de Configuração do Supabase

## 1. Criar Projeto no Supabase

1. Acesse https://supabase.com
2. Clique em "New Project"
3. Preencha:
   - **Name**: bingo-lucca (ou nome de sua preferência)
   - **Database Password**: Crie uma senha forte
   - **Region**: Escolha a região mais próxima do Brasil (ex: South America - São Paulo)
4. Clique em "Create new project" e aguarde ~2 minutos

## 2. Obter Credenciais

Após o projeto ser criado:

1. No menu lateral, clique em **"Project Settings"** (ícone de engrenagem)
2. Clique em **"API"**
3. Copie:
   - **Project URL**: `https://REDACTED.supabase.co`
   - **anon/public key**: `eyJhbG...` (chave longa)

## 3. Executar SQL Migrations

1. No menu lateral, clique em **"SQL Editor"**
2. Clique em **"New query"**
3. Cole o SQL abaixo e clique em **"Run"**:

\`\`\`sql
-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Users table
create table public.users (
  id uuid primary key default uuid_generate_v4(),
  firebase_uid text unique not null,
  email text,
  display_name text,
  photo_url text,
  provider text, -- 'google.com', 'apple.com', 'email'
  revenuecat_user_id text unique,
  created_at timestamp with time zone default now(),
  last_seen timestamp with time zone default now()
);

-- Purchases table
create table public.purchases (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  product_id text not null,
  subscription_type text, -- 'weekly', 'annual', 'lifetime'
  purchase_date timestamp with time zone default now(),
  expiry_date timestamp with time zone,
  is_active boolean default true,
  revenuecat_transaction_id text unique,
  revenuecat_metadata jsonb,
  created_at timestamp with time zone default now()
);

-- Preferences table  
create table public.preferences (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade unique,
  notifications_enabled boolean default true,
  notifications_per_day integer default 2,
  notification_start_time time,
  notification_end_time time,
  theme_settings jsonb,
  game_settings jsonb,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Onboarding responses
create table public.onboarding_responses (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade unique,
  name text not null,
  age integer,
  sex text,
  mental_health_method text,
  streak_goal integer,
  categories jsonb,
  notifications_enabled boolean default true,
  notifications_per_day integer,
  notification_start_time time,
  notification_end_time time,
  widget_installed boolean default false,
  premium_trial_start_date timestamp with time zone,
  premium_paywall_action text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Analytics events
create table public.analytics_events (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete set null,
  event_name text not null,
  event_params jsonb,
  screen_name text,
  created_at timestamp with time zone default now()
);

create index idx_analytics_events_user on public.analytics_events(user_id);
create index idx_analytics_events_name on public.analytics_events(event_name);
create index idx_analytics_events_created on public.analytics_events(created_at desc);

-- Game history
create table public.game_history (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  room_id text not null,
  role text, -- 'host' or 'player'
  started_at timestamp with time zone default now(),
  ended_at timestamp with time zone,
  players_count integer,
  completed boolean default false
);

-- Enable Row Level Security
alter table public.users enable row level security;
alter table public.purchases enable row level security;
alter table public.preferences enable row level security;
alter table public.onboarding_responses enable row level security;
alter table public.analytics_events enable row level security;
alter table public.game_history enable row level security;

-- RLS Policies
-- Users can view and update their own data
create policy "Users can view own data" on public.users
  for select using (true); -- Allow all users to view (for now)

create policy "Users can insert own data" on public.users
  for insert with check (true);

create policy "Users can update own data" on public.users
  for update using (true);

-- Similar policies for other tables
create policy "Users can view own purchases" on public.purchases
  for select using (true);

create policy "Users can insert purchases" on public.purchases
  for insert with check (true);

create policy "Users can view own preferences" on public.preferences
  for all using (true);

create policy "Users can manage analytics" on public.analytics_events
  for all using (true);

create policy "Users can view own game history" on public.game_history
  for all using (true);

create policy "Users can manage onboarding" on public.onboarding_responses
  for all using (true);
\`\`\`

## 4. Configurar no App

No arquivo `main_common.dart`, adicione após a inicialização do Firebase:

\`\`\`dart
// Initialize Supabase
await SupabaseService.initialize(
  supabaseUrl: 'https://XXXXX.supabase.co', // Sua URL
  supabaseAnonKey: 'eyJhbG...', // Sua anon key
);
\`\`\`

## 5. Testar Conexão

Execute o app e tente fazer login. Verifique no Supabase:
1. **Table Editor** → **users** → Deve aparecer seu usuário
2. **Logs** → **Postgres Logs** → Verifique por erros

## 6. Segurança (Importante!)

⚠️ **NUNCA commite as credenciais no código!**

Crie um arquivo `.env` (já deve estar no `.gitignore`):

\`\`\`
SUPABASE_URL=https://REDACTED.supabase.co
SUPABASE_ANON_KEY=eyJhbG...
\`\`\`

Use o package `flutter_dotenv` para carregar as variáveis de ambiente.

## Pronto! 🎉

Agora o Supabase está configurado e pronto para sincronizar dados de autenticação e analytics.

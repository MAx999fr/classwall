-- ClassWall 匿名問答牆 schema
-- 在 Supabase Dashboard → SQL Editor 貼上整段執行一次即可。

-- 1. questions 表
create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  content text not null check (char_length(content) between 1 and 500),
  likes integer not null default 0 check (likes >= 0),
  created_at timestamptz not null default now()
);

create index if not exists questions_likes_created_idx
  on public.questions (likes desc, created_at desc);

-- 2. answers 表（一對多：一個 question 有多個 answers）
create table if not exists public.answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions (id) on delete cascade,
  content text not null check (char_length(content) between 1 and 500),
  created_at timestamptz not null default now()
);

create index if not exists answers_question_id_idx
  on public.answers (question_id);

-- 3. 開啟 Realtime（讓前端 subscribe 變動）
alter publication supabase_realtime add table public.questions;
alter publication supabase_realtime add table public.answers;

-- 4. RLS：匿名使用者可讀、可發問、可按讚（incrementing likes）
alter table public.questions enable row level security;
alter table public.answers enable row level security;

drop policy if exists "anyone can read questions" on public.questions;
create policy "anyone can read questions"
  on public.questions for select
  using (true);

drop policy if exists "anyone can insert questions" on public.questions;
create policy "anyone can insert questions"
  on public.questions for insert
  with check (true);

drop policy if exists "anyone can like questions" on public.questions;
create policy "anyone can like questions"
  on public.questions for update
  using (true)
  with check (true);

drop policy if exists "anyone can read answers" on public.answers;
create policy "anyone can read answers"
  on public.answers for select
  using (true);

drop policy if exists "anyone can insert answers" on public.answers;
create policy "anyone can insert answers"
  on public.answers for insert
  with check (true);

-- 5. seed：一筆示範資料
insert into public.questions (content, likes)
values ('歡迎來到 ClassWall！按下「我也想問 +1」試試看 🎉', 0)
on conflict do nothing;

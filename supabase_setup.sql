-- 建立 members（研究成員）資料表
create table members (
  id bigint generated always as identity primary key,
  name text not null,
  title text not null,
  field text not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- 建立 topics（研究主題）資料表
create table topics (
  id bigint generated always as identity primary key,
  icon text not null default 'default',
  title text not null,
  description text not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- 建立 news（最新消息）資料表
create table news (
  id bigint generated always as identity primary key,
  title text not null,
  description text not null,
  published_date date not null default current_date,
  created_at timestamptz not null default now()
);

-- 啟用 RLS（Row Level Security）：之後即使 anon key 外流，外人也只能讀、不能寫
alter table members enable row level security;
alter table topics enable row level security;
alter table news enable row level security;

-- 只允許「讀取」，不允許新增/修改/刪除
create policy "Public can read members" on members
  for select using (true);

create policy "Public can read topics" on topics
  for select using (true);

create policy "Public can read news" on news
  for select using (true);

-- 匯入目前 data.json 裡的資料當預設內容
insert into members (name, title, field, sort_order) values
  ('謝景岳 教授', '研究室主持人', '智慧感測系統、訊號處理', 1),
  ('王婉霽', '學士生', '穿戴式生理感測、機器學習', 2),
  ('陳柏宏', '碩士生', '嵌入式系統、物聯網應用', 3);

insert into topics (icon, title, description, sort_order) values
  ('pulse', '穿戴式智慧醫療感測', '開發低功耗生理訊號感測模組，結合演算法即時監測心率、血氧與運動狀態，應用於遠距健康照護。', 1),
  ('globe', '環境感測與物聯網系統', '建構分散式環境監測網路，整合空氣品質、溫濕度等多元感測資料，提供即時環境決策支援。', 2),
  ('chip', '感測資料智慧分析', '運用機器學習與深度學習技術，從大量感測資料中挖掘特徵模式，提升系統預測與異常偵測能力。', 3);

insert into news (title, description, published_date) values
  ('實驗室論文獲國際感測器期刊接受刊登', '本實驗室研究成果於穿戴式生理感測領域之最新論文，已正式獲國際期刊接受刊登。', '2026-06-01'),
  ('誠摘招募碩博士新生加入研究團隊', '歡迎對感測技術、訊號處理與人工智慧有興趣之同學加入，詳情請洽研究室主持人。', '2026-04-01'),
  ('研究團隊參與國際學術研討會發表成果', '實驗室成員前往國際研討會進行口頭報告，與各國學者交流智慧感測相關研究進展。', '2026-02-01');

-- ============================================================
-- 後台管理頁（admin.html）用：只允許指定管理者 Email 寫入
-- 沒有符合這個條件的人（包含沒登入、登入別的帳號），insert/update/delete 一律被拒絕
-- ============================================================

 create policy "Admin can insert members" on members
  for insert with check (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can update members" on members
  for update using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com')
  with check (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can delete members" on members
  for delete using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');

create policy "Admin can insert topics" on topics
  for insert with check (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can update topics" on topics
  for update using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com')
  with check (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can delete topics" on topics
  for delete using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');

create policy "Admin can insert news" on news
  for insert with check (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can update news" on news
  for update using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com')
  with check (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can delete news" on news
  for delete using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');

-- ============================================================
-- 甜點預購頁（dessert.html）用：orders（預購單）資料表
-- 任何人都可以「新增」預購單（顧客送出表單），
-- 但只有管理者帳號可以「讀取／修改／刪除」，避免顧客個資外洩
-- ============================================================

create table orders (
  id bigint generated always as identity primary key,
  items jsonb not null,
  pickup_date date not null,
  pickup_time text not null,
  customer_name text not null,
  phone text not null,
  email text,
  customization_note text,
  allergy_note text not null,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

alter table orders enable row level security;

create policy "Anyone can submit an order" on orders
  for insert with check (true);

create policy "Admin can read orders" on orders
  for select using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can update orders" on orders
  for update using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com')
  with check (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can delete orders" on orders
  for delete using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');

-- ============================================================
-- 甜點預購頁（dessert.html／dessert_admin.html）用：products（甜點品項）資料表
-- 任何人都可以「讀取」品項（顧客瀏覽網頁），
-- 只有管理者帳號可以「新增／修改／刪除」品項（後台管理）
-- ============================================================

create table products (
  id bigint generated always as identity primary key,
  category text not null check (category in ('signature', 'classic', 'seasonal', 'custom')),
  name text not null,
  price numeric not null,
  unit text not null default '個',
  description text not null,
  icon text not null default '🍰',
  tag text,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

alter table products enable row level security;

create policy "Public can read products" on products
  for select using (true);

create policy "Admin can insert products" on products
  for insert with check (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can update products" on products
  for update using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com')
  with check (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');
create policy "Admin can delete products" on products
  for delete using (auth.jwt() ->> 'email' = 'taigiendio@gmail.com');

-- 匯入目前 dessert.html 裡的品項當預設內容
insert into products (category, name, price, unit, description, icon, tag, sort_order) values
  ('signature', '莓果田園生乳酪蛋糕', 420, '6吋', '紐西蘭奶油乳酪佐當季莓果，濃郁中帶著清爽果香。', '🍓', null, 1),
  ('signature', '玫瑰荔枝馬卡龍塔', 380, '個', '法式馬卡龍殼搭配玫瑰荔枝奶餡，少女心爆棚的夢幻滋味。', '🌹', null, 2),
  ('signature', '蜂蜜檸檬塔', 320, '個', '手工塔皮包覆酸甜檸檬餡，淋上天然蜂蜜提升尾韻香氣。', '🍋', null, 3),
  ('classic', '法式可麗露', 60, '個', '外脆內軟，蘭姆酒香氣迷人，經典不敗的法式小點。', '🥐', null, 1),
  ('classic', '經典提拉米蘇', 180, '個', '濃縮咖啡浸潤手指餅乾，馬斯卡彭起司綿密滑順。', '☕', null, 2),
  ('classic', '香草戚風蛋糕', 280, '6吋', '柔軟蓬鬆如雲朵，淡雅香草香氣，老少咸宜的療癒甜點。', '🍰', null, 3),
  ('classic', '焦糖布丁', 90, '個', '古早味手工布丁，焦糖苦甜恰到好處，口感綿滑。', '🍮', null, 4),
  ('seasonal', '夏日水蜜桃慕斯', 350, '個', '當季水蜜桃製成的清爽慕斯，僅夏季限定供應。', '🍑', '夏季限定', 1),
  ('seasonal', '草莓奶油蛋糕', 420, '6吋', '整顆鮮採草莓堆疊，搭配輕盈鮮奶油，春季限定登場。', '🍓', '春季限定', 2),
  ('seasonal', '栗子蒙布朗', 360, '個', '秋栗泥細細擠製，內藏香草鮮奶油與蛋白餅，秋冬限定。', '🌰', '秋冬限定', 3),
  ('custom', '客製化生日蛋糕', 800, '起', '可選擇蛋糕口味、夾餡與裝飾風格，打造專屬於你的生日驚喜。', '🎂', '需提前7天預訂', 1),
  ('custom', '客製化手工餅乾禮盒', 450, '盒起', '可印製文字或圖案造型，是送禮自用兩相宜的甜蜜心意。', '🍪', '需提前5天預訂', 2),
  ('custom', '客製化翻糖造型蛋糕', 1200, '起', '手工翻糖塑形，可依主題客製造型，適合婚禮、滿月等重要場合。', '👰', '需提前14天預訂', 3);

-- Schema
create table if not exists users (
  id serial primary key,
  username varchar(40) unique not null,
  email varchar(120) unique not null,
  password_hash text not null,
  wallet_balance numeric(12,2) default 0,
  role varchar(10) default 'user',
  created_at timestamp default now()
);
create table if not exists challenges (
  id serial primary key,
  creator_id int references users(id) on delete set null,
  opponent_id int references users(id) on delete set null,
  title varchar(200),
  description text,
  media_url text,
  status varchar(20) default 'active',
  created_at timestamp default now()
);
create table if not exists votes (
  id serial primary key,
  user_id int references users(id) on delete cascade,
  challenge_id int references challenges(id) on delete cascade,
  created_at timestamp default now(),
  unique (user_id, challenge_id)
);
create table if not exists comments (
  id serial primary key,
  challenge_id int references challenges(id) on delete cascade,
  user_id int references users(id) on delete cascade,
  text text not null,
  created_at timestamp default now()
);
create table if not exists wallet_requests (
  id serial primary key,
  user_id int references users(id) on delete cascade,
  type varchar(20) not null check (type in ('deposit','withdraw')),
  amount numeric(12,2) not null,
  utr_or_upi varchar(120) not null,
  status varchar(20) default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamp default now()
);
create table if not exists follows (
  follower_id int references users(id) on delete cascade,
  followee_id int references users(id) on delete cascade,
  created_at timestamp default now(),
  primary key (follower_id, followee_id)
);
create table if not exists stories (
  id serial primary key,
  user_id int references users(id) on delete cascade,
  media_url text,
  created_at timestamp default now(),
  expires_at timestamp not null
);
create table if not exists app_settings (
  key varchar(50) primary key,
  value text
);

-- Sample data (simple demo users with password 'password')
-- Note: Replace hashes if you like; these are bcrypt for 'password'
insert into users (username, email, password_hash, wallet_balance, role) values
  ('admin', 'admin@example.com', '$2a$10$k0mVq8eUlv9cM1y2gI2GFuTBuBW2Q4pW7Wk2h1b0m3S.3o2Lq2nma', 500.00, 'admin')
on conflict do nothing;
insert into users (username, email, password_hash, wallet_balance) values
  ('alice', 'alice@example.com', '$2a$10$k0mVq8eUlv9cM1y2gI2GFuTBuBW2Q4pW7Wk2h1b0m3S.3o2Lq2nma', 50.00),
  ('bob', 'bob@example.com', '$2a$10$k0mVq8eUlv9cM1y2gI2GFuTBuBW2Q4pW7Wk2h1b0m3S.3o2Lq2nma', 20.00),
  ('carol', 'carol@example.com', '$2a$10$k0mVq8eUlv9cM1y2gI2GFuTBuBW2Q4pW7Wk2h1b0m3S.3o2Lq2nma', 10.00)
on conflict do nothing;

-- Alice creates challenges vs Bob & random
insert into challenges (creator_id, opponent_id, title, description, status) values
  ((select id from users where username='alice'), (select id from users where username='bob'), 'Push-up contest', '50 push-ups in 1 minute', 'active'),
  ((select id from users where username='alice'), null, 'Cold shower challenge', '3 minutes cold shower', 'active');

-- A few votes and comments
insert into votes (user_id, challenge_id) values
  ((select id from users where username='bob'), (select min(id) from challenges)),
  ((select id from users where username='carol'), (select min(id) from challenges))
on conflict do nothing;

insert into comments (challenge_id, user_id, text) values
  ((select min(id) from challenges), (select id from users where username='bob'), 'Let''s go!'),
  ((select min(id) from challenges), (select id from users where username='carol'), 'Rooting for you!');

-- Follows
insert into follows (follower_id, followee_id) values
  ((select id from users where username='alice'), (select id from users where username='bob')),
  ((select id from users where username='bob'), (select id from users where username='alice'))
on conflict do nothing;

-- App setting: default QR (placeholder)
insert into app_settings(key, value) values ('deposit_qr_url','https://via.placeholder.com/200x200.png?text=QR') 
on conflict (key) do update set value=excluded.value;

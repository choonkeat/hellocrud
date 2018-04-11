create schema app;

create table app.post (
  id         serial primary key,
  title      text not null check (char_length(title) < 80),
  author     text not null check (char_length(author) < 80),
  body       text not null,
  notes      text,
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);

create table app.comment (
  id         serial primary key,
  post_id    integer not null references app.post(id),
  author     text not null check (char_length(author) < 80),
  body       text not null,
  notes      text,
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);

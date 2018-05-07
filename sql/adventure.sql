create table adventure(
id             integer     primary key autoincrement,
chapter_id     integer     not null                 ,
adventure_id   integer     not null                 ,
adventure_name varchar(50) not null                 ,
value          text        not null
);

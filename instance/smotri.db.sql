BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "actor" (
	"id"	INTEGER NOT NULL,
	"slug"	VARCHAR(120) NOT NULL,
	"name"	VARCHAR(100) NOT NULL,
	"surname"	VARCHAR(100) NOT NULL,
	"big_photo_url"	VARCHAR(300),
	"small_photo_url"	VARCHAR(300),
	"birth_date"	VARCHAR(50),
	"birth_place"	VARCHAR(200),
	"height"	VARCHAR(20),
	"full_name"	VARCHAR(200),
	"citizenship"	VARCHAR(200),
	"spouse"	VARCHAR(200),
	"children"	TEXT,
	"biography"	TEXT,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "award" (
	"id"	INTEGER NOT NULL,
	"category"	VARCHAR(200) NOT NULL,
	"description"	TEXT,
	"image_url"	VARCHAR(300),
	"event_id"	INTEGER NOT NULL,
	"winner_type"	VARCHAR(20),
	"winner_movie_id"	INTEGER,
	"winner_series_id"	INTEGER,
	"winner_actor_id"	INTEGER,
	PRIMARY KEY("id"),
	FOREIGN KEY("event_id") REFERENCES "event"("id"),
	FOREIGN KEY("winner_actor_id") REFERENCES "actor"("id"),
	FOREIGN KEY("winner_movie_id") REFERENCES "movie"("id"),
	FOREIGN KEY("winner_series_id") REFERENCES "series"("id")
);
CREATE TABLE IF NOT EXISTS "award_nominees_actors" (
	"award_id"	INTEGER NOT NULL,
	"actor_id"	INTEGER NOT NULL,
	PRIMARY KEY("award_id","actor_id"),
	FOREIGN KEY("actor_id") REFERENCES "actor"("id"),
	FOREIGN KEY("award_id") REFERENCES "award"("id")
);
CREATE TABLE IF NOT EXISTS "award_nominees_movies" (
	"award_id"	INTEGER NOT NULL,
	"movie_id"	INTEGER NOT NULL,
	PRIMARY KEY("award_id","movie_id"),
	FOREIGN KEY("award_id") REFERENCES "award"("id"),
	FOREIGN KEY("movie_id") REFERENCES "movie"("id")
);
CREATE TABLE IF NOT EXISTS "award_nominees_series" (
	"award_id"	INTEGER NOT NULL,
	"series_id"	INTEGER NOT NULL,
	PRIMARY KEY("award_id","series_id"),
	FOREIGN KEY("award_id") REFERENCES "award"("id"),
	FOREIGN KEY("series_id") REFERENCES "series"("id")
);
CREATE TABLE IF NOT EXISTS "event" (
	"id"	INTEGER NOT NULL,
	"slug"	VARCHAR(120) NOT NULL,
	"title_ru"	VARCHAR(200) NOT NULL,
	"title_en"	VARCHAR(200),
	"description"	TEXT,
	"image_main"	VARCHAR(300),
	"photo1"	VARCHAR(300),
	"photo2"	VARCHAR(300),
	"photo3"	VARCHAR(300),
	"photo4"	VARCHAR(300),
	"photo5"	VARCHAR(300),
	"photo6"	VARCHAR(300),
	"nominations"	JSON,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "media" (
	"id"	INTEGER NOT NULL,
	"poster_url"	VARCHAR(300),
	"photo_1_url"	VARCHAR(300),
	"photo_2_url"	VARCHAR(300),
	"photo_3_url"	VARCHAR(300),
	"photo_4_url"	VARCHAR(300),
	"photo_5_url"	VARCHAR(300),
	"trailer_url"	VARCHAR(300),
	"trailer_preview_url"	VARCHAR(300),
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "movie" (
	"id"	INTEGER NOT NULL,
	"slug"	VARCHAR(120) NOT NULL,
	"title_ru"	VARCHAR(200) NOT NULL,
	"title_en"	VARCHAR(200),
	"year"	INTEGER,
	"franchise"	VARCHAR(200),
	"duration"	INTEGER,
	"age_rating"	VARCHAR(10),
	"description"	TEXT,
	"director"	VARCHAR(200),
	"screenplay"	VARCHAR(200),
	"producer"	VARCHAR(200),
	"operator"	VARCHAR(200),
	"composer"	VARCHAR(200),
	"artist"	VARCHAR(200),
	"editing"	VARCHAR(200),
	"rating_avg"	FLOAT,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	"media_id"	INTEGER,
	PRIMARY KEY("id"),
	UNIQUE("media_id"),
	FOREIGN KEY("media_id") REFERENCES "media"("id")
);
CREATE TABLE IF NOT EXISTS "movie_actors" (
	"movie_id"	INTEGER NOT NULL,
	"actor_id"	INTEGER NOT NULL,
	PRIMARY KEY("movie_id","actor_id"),
	FOREIGN KEY("actor_id") REFERENCES "actor"("id"),
	FOREIGN KEY("movie_id") REFERENCES "movie"("id")
);
CREATE TABLE IF NOT EXISTS "movie_rating" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"movie_id"	INTEGER NOT NULL,
	"rating"	INTEGER NOT NULL,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_user_movie_rating" UNIQUE("user_id","movie_id"),
	FOREIGN KEY("movie_id") REFERENCES "movie"("id"),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
CREATE TABLE IF NOT EXISTS "movie_tags" (
	"movie_id"	INTEGER NOT NULL,
	"tag_id"	INTEGER NOT NULL,
	PRIMARY KEY("movie_id","tag_id"),
	FOREIGN KEY("movie_id") REFERENCES "movie"("id"),
	FOREIGN KEY("tag_id") REFERENCES "tag"("id")
);
CREATE TABLE IF NOT EXISTS "news" (
	"id"	INTEGER NOT NULL,
	"slug"	VARCHAR(120) NOT NULL,
	"title"	VARCHAR(200) NOT NULL,
	"subtitle"	VARCHAR(300),
	"blocks"	JSON,
	"image_main"	VARCHAR(300),
	"author_name"	VARCHAR(100),
	"author_surname"	VARCHAR(100),
	"author_photo"	VARCHAR(300),
	"author_description"	TEXT,
	"published_at"	DATETIME,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "news_movies" (
	"news_id"	INTEGER NOT NULL,
	"movie_id"	INTEGER NOT NULL,
	PRIMARY KEY("news_id","movie_id"),
	FOREIGN KEY("movie_id") REFERENCES "movie"("id"),
	FOREIGN KEY("news_id") REFERENCES "news"("id")
);
CREATE TABLE IF NOT EXISTS "news_series" (
	"news_id"	INTEGER NOT NULL,
	"series_id"	INTEGER NOT NULL,
	PRIMARY KEY("news_id","series_id"),
	FOREIGN KEY("news_id") REFERENCES "news"("id"),
	FOREIGN KEY("series_id") REFERENCES "series"("id")
);
CREATE TABLE IF NOT EXISTS "series" (
	"id"	INTEGER NOT NULL,
	"slug"	VARCHAR(120) NOT NULL,
	"title_ru"	VARCHAR(200) NOT NULL,
	"title_en"	VARCHAR(200),
	"year_start"	INTEGER,
	"year_end"	INTEGER,
	"seasons"	INTEGER,
	"screenplay"	VARCHAR(200),
	"duration"	INTEGER,
	"franchise"	VARCHAR(200),
	"age_rating"	VARCHAR(10),
	"description"	TEXT,
	"director"	VARCHAR(200),
	"producer"	VARCHAR(200),
	"composer"	VARCHAR(200),
	"rating_avg"	FLOAT,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	"media_id"	INTEGER,
	PRIMARY KEY("id"),
	UNIQUE("media_id"),
	FOREIGN KEY("media_id") REFERENCES "media"("id")
);
CREATE TABLE IF NOT EXISTS "series_actors" (
	"series_id"	INTEGER NOT NULL,
	"actor_id"	INTEGER NOT NULL,
	PRIMARY KEY("series_id","actor_id"),
	FOREIGN KEY("actor_id") REFERENCES "actor"("id"),
	FOREIGN KEY("series_id") REFERENCES "series"("id")
);
CREATE TABLE IF NOT EXISTS "series_rating" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"series_id"	INTEGER NOT NULL,
	"rating"	INTEGER NOT NULL,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_user_series_rating" UNIQUE("user_id","series_id"),
	FOREIGN KEY("series_id") REFERENCES "series"("id"),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
CREATE TABLE IF NOT EXISTS "series_tags" (
	"series_id"	INTEGER NOT NULL,
	"tag_id"	INTEGER NOT NULL,
	PRIMARY KEY("series_id","tag_id"),
	FOREIGN KEY("series_id") REFERENCES "series"("id"),
	FOREIGN KEY("tag_id") REFERENCES "tag"("id")
);
CREATE TABLE IF NOT EXISTS "tag" (
	"id"	INTEGER NOT NULL,
	"name"	VARCHAR(50) NOT NULL,
	PRIMARY KEY("id"),
	UNIQUE("name")
);
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"username"	VARCHAR(80) NOT NULL,
	"email"	VARCHAR(120) NOT NULL,
	"password_hash"	VARCHAR(200) NOT NULL,
	"full_name"	VARCHAR(200),
	"bio"	TEXT,
	"photo_url"	VARCHAR(300),
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "user_favorite_tags" (
	"user_id"	INTEGER NOT NULL,
	"tag_id"	INTEGER NOT NULL,
	PRIMARY KEY("user_id","tag_id"),
	FOREIGN KEY("tag_id") REFERENCES "tag"("id"),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
INSERT INTO "actor" VALUES (1,'arnold-schwarzenegger','Арнольд','Шварценеггер','actor-poster-arnold.png','actor-image-arnold.png','30 июля 1947','Таль, Австрия','188 см','Арнольд Алоис Шварценеггер','Австрия, США','Мария Шрайвер (1986-2021)','Кэтрин, Кристина, Патрик, Кристофер, Йозеф','Арнольд Алоис Шварценеггер родился 30 июля 1947 года в маленьком австрийском городе Таль. Легендарный актёр, политик и культурист.','2026-06-19 23:31:58.345576','2026-06-19 23:31:58.345576');
INSERT INTO "actor" VALUES (2,'emilia-clark','Эмилия','Кларк','actor-poster-emilia.png','actor-image-clark.png','23 октября 1986','Лондон, Англия','157 см','Эмилия Изабель Юфимия Роуз Кларк','Великобритания','Нет','Нет','Британская актриса, известная по роли Дейенерис Таргариен в сериале «Игра престолов».','2026-06-19 23:31:58.347131','2026-06-19 23:31:58.347131');
INSERT INTO "actor" VALUES (3,'ana-de-armas','Ана','Де Армас','actor-poster-ana.png','actor-image-de-armas.png','30 апреля 1988','Гавана, Куба','168 см','Ана Селия Де Армас Касо','Куба, Испания','Нет','Нет','Кубинская актриса, известная по фильмам «Бегущий по лезвию 2049», «Достать ножи» и «Не время умирать».','2026-06-19 23:31:58.347148','2026-06-19 23:31:58.347148');
INSERT INTO "actor" VALUES (4,'peter-dinklage','Питер','Динклейдж','actor-poster-dinklage.png','actor-image-dinklage.png','11 июня 1969','Морристаун, США','135 см','Питер Хейден Динклейдж','США','Эрика Шмидт','2','Американский актёр, известный по роли Тириона Ланнистера в сериале «Игра престолов».','2026-06-19 23:31:58.347657','2026-06-19 23:31:58.347657');
INSERT INTO "actor" VALUES (5,'ryan-gosling','Райан','Гослинг','actor-poster-gosling.png','actor-image-gosling.png','12 ноября 1980','Лондон, Канада','184 см','Райан Томас Гослинг','Канада','Ева Мендес','2','Канадский актёр, известный по фильмам «Драйв», «Ла-Ла Ленд» и «Бегущий по лезвию 2049».','2026-06-19 23:31:58.347657','2026-06-19 23:31:58.347657');
INSERT INTO "actor" VALUES (6,'kit-harington','Кит','Харрингтон','actor-poster-harington.png','actor-image-harrington.png','26 декабря 1986','Лондон, Англия','173 см','Кристофер Китсли Харрингтон','Великобритания','Роуз Лесли','1','Британский актёр, известный по роли Джона Сноу в сериале «Игра престолов».','2026-06-19 23:31:58.348658','2026-06-19 23:31:58.348658');
INSERT INTO "actor" VALUES (7,'harrison-ford','Харрисон','Форд','actor-poster-harrison.png','actor-image-harrison-ford.png','13 июля 1942','Чикаго, США','185 см','Харрисон Форд','США','Калиста Флокхарт','5','Легендарный актёр, известный по ролям Хана Соло и Индианы Джонса.','2026-06-19 23:31:58.348658','2026-06-19 23:31:58.348658');
INSERT INTO "actor" VALUES (8,'jared-leto','Джаред','Лето','actor-poster-leto.png','actor-image-leto.png','26 декабря 1971','Боссье-Сити, США','175 см','Джаред Джозеф Лето','США','Нет','Нет','Американский актёр и музыкант, известный по фильмам «Бегущий по лезвию 2049», «Отряд самоубийц» и «Далласский клуб покупателей».','2026-06-19 23:31:58.349659','2026-06-19 23:31:58.349659');
INSERT INTO "actor" VALUES (9,'nikolaj-waldau','Николай','Костер-Вальдау','actor-poster-waldau.png','actor-image-waldau.png','27 июля 1970','Рудкёбинг, Дания','188 см','Николай Костер-Вальдау','Дания','Нукака Костер-Вальдау','2','Датский актёр, известный по роли Джейме Ланнистера в сериале «Игра престолов».','2026-06-19 23:31:58.349659','2026-06-19 23:31:58.349659');
INSERT INTO "award" VALUES (1,'ЛУЧШИЙ ФИЛЬМ','Награда за лучший фильм','award-image-OSCAR.png',2,'movie',1,NULL,NULL);
INSERT INTO "award" VALUES (2,'ЛУЧШИЙ СЕРИАЛ','Награда за лучший сериал','award-image-OSCAR.png',2,'series',NULL,1,NULL);
INSERT INTO "award" VALUES (3,'ЛУЧШИЙ АКТЁР','Награда за лучшую мужскую роль','award-image-OSCAR.png',2,'actor',NULL,NULL,5);
INSERT INTO "award_nominees_actors" VALUES (3,7);
INSERT INTO "award_nominees_actors" VALUES (3,4);
INSERT INTO "award_nominees_actors" VALUES (3,2);
INSERT INTO "award_nominees_actors" VALUES (3,1);
INSERT INTO "award_nominees_movies" VALUES (1,2);
INSERT INTO "award_nominees_movies" VALUES (1,3);
INSERT INTO "award_nominees_movies" VALUES (1,4);
INSERT INTO "award_nominees_movies" VALUES (1,5);
INSERT INTO "award_nominees_series" VALUES (2,2);
INSERT INTO "award_nominees_series" VALUES (2,3);
INSERT INTO "award_nominees_series" VALUES (2,4);
INSERT INTO "award_nominees_series" VALUES (2,6);
INSERT INTO "event" VALUES (1,'golden-globe-2025','Золотой глобус 2025','Golden Globe 2025','82-я церемония вручения премии «Золотой глобус».','event-GoldenGlobus2026-image-main.png','event-GoldenGlobus2026-image-1.png','event-GoldenGlobus2026-image-2.png','event-GoldenGlobus2026-image-3.png','event-GoldenGlobus2026-image-4.png','event-GoldenGlobus2026-image-5.png','event-GoldenGlobus2026-image-6.png',NULL,'2026-06-19 23:31:58.475316','2026-06-19 23:31:58.475316');
INSERT INTO "event" VALUES (2,'golden-globe-2026','Золотой глобус 2026','Golden Globe 2026','83-я церемония вручения премии «Золотой глобус».','event-GoldenGlobus2026-image-main.png','event-GoldenGlobus2026-image-1.png','event-GoldenGlobus2026-image-2.png','event-GoldenGlobus2026-image-3.png','event-GoldenGlobus2026-image-4.png','event-GoldenGlobus2026-image-5.png','event-GoldenGlobus2026-image-6.png',NULL,'2026-06-19 23:31:58.479454','2026-06-19 23:31:58.479454');
INSERT INTO "media" VALUES (1,'Bladerunner2049-poster.png','Bladerunner2049-image-1.png','Bladerunner2049-image-2.png','Bladerunner2049-image-3.png','Bladerunner2049-image-4.png','Bladerunner2049-image-5.png','Бегущий по лезвию 2049 - трейлер.mp4','Bladerunner2049-Trailer.png','2026-06-19 23:31:58.356847','2026-06-19 23:31:58.356847');
INSERT INTO "media" VALUES (2,'film-card-image-bladerunner_classic.png','','','','','','','','2026-06-19 23:31:58.373057','2026-06-19 23:31:58.373057');
INSERT INTO "media" VALUES (3,'film-card-image-bladerunner_blackout.png','','','','','','','','2026-06-19 23:31:58.380057','2026-06-19 23:31:58.380057');
INSERT INTO "media" VALUES (4,'film-card-image-bladerunner_nexus_res.png','','','','','','','','2026-06-19 23:31:58.387081','2026-06-19 23:31:58.387081');
INSERT INTO "media" VALUES (5,'placeholder.png','','','','','','','','2026-06-19 23:31:58.393092','2026-06-19 23:31:58.393092');
INSERT INTO "media" VALUES (6,'placeholder.png','','','','','','','','2026-06-19 23:31:58.400878','2026-06-19 23:31:58.400878');
INSERT INTO "media" VALUES (7,'GOT-poster.png','GOT-image-1.png','GOT-image-2.png','GOT-image-3.png','GOT-image-4.png','GOT-image-5.png','GAME OF THRONES - TRAILER.mp4','GOT-Trailer.png','2026-06-19 23:31:58.411862','2026-06-19 23:31:58.411862');
INSERT INTO "media" VALUES (8,'film-card-image-houseofthedragon.png','','','','','','','','2026-06-19 23:31:58.427812','2026-06-19 23:31:58.427812');
INSERT INTO "media" VALUES (9,'film-card-image-vikings.png','','','','','','','','2026-06-19 23:31:58.434097','2026-06-19 23:31:58.434097');
INSERT INTO "media" VALUES (10,'film-card-image-rome.png','','','','','','','','2026-06-19 23:31:58.441338','2026-06-19 23:31:58.441338');
INSERT INTO "media" VALUES (11,'film-card-image-bladerunner_lotos.png','','','','','','','','2026-06-19 23:31:58.448089','2026-06-19 23:31:58.448089');
INSERT INTO "media" VALUES (12,'film-card-image-7knight.png','','','','','','','','2026-06-19 23:31:58.454676','2026-06-19 23:31:58.454676');
INSERT INTO "movie" VALUES (1,'blade-runner-2049','Бегущий по лезвию 2049','Blade Runner 2049',2017,'blade-runner',164,'18+','Спустя тридцать лет после событий «Бегущего по лезвию» (1982) новый бегущий по лезвию, офицер полиции Лос-Анджелеса по прозвищу «К» (Райан Гослинг), раскрывает давно похороненный секрет.','Дени Вильнёв','Майкл Грин, Хэмптон Фанчер, Филип К. Дик','Йель Бадик, Дэна Белкастро, Билл Карраро','Роджер Дикинс','Бенджамин Уоллфиш, Ханс Циммер','Деннис Гасснер, Дэвид Доран, Бенце Эрдейи','Джо Уокер',7.8,'2026-06-19 23:31:58.357865','2026-06-19 23:31:58.357865',1);
INSERT INTO "movie" VALUES (2,'blade-runner','Бегущий по лезвию','Blade Runner',1982,'blade-runner',117,'16+','В недалёком будущем специальные полицейские — «бегущие по лезвию» — охотятся на людей-роботов, которые бежали из космических колоний.','Ридли Скотт','Хэмптон Фанчер, Дэвид Уэбб Пиплз','Майкл Дили, Ридли Скотт','Джордан Кроненвет','Вангелис','Лоуренс Г. Полл, Дэвид Л. Снайдер','Терри Роулингс, Марша Накашима',8.0,'2026-06-19 23:31:58.373057','2026-06-19 23:31:58.373057',2);
INSERT INTO "movie" VALUES (3,'blade-runner-blackout-2022','Бегущий по лезвию: Блэкаут 2022','Blade Runner: Blackout 2022',2017,'blade-runner',15,'16+','Аниме-короткометражка, действие которой происходит между событиями первого и второго фильмов.','Синъитиро Ватанабэ','Синъитиро Ватанабэ',NULL,NULL,NULL,NULL,NULL,7.5,'2026-06-19 23:31:58.381057','2026-06-19 23:31:58.381057',3);
INSERT INTO "movie" VALUES (4,'blade-runner-2036-nexus','2036: Возрождение Nexus','2036: Nexus Resurrection',2017,'blade-runner',6,'16+','Короткометражный фильм о создании нового репликанта.','Люк Скотт','Люк Скотт',NULL,NULL,NULL,NULL,NULL,7.0,'2026-06-19 23:31:58.388091','2026-06-19 23:31:58.388091',4);
INSERT INTO "movie" VALUES (5,'game-of-thrones-conquest','Игра престолов: Завоевание','Game of Thrones: Conquest',2023,'game-of-thrones',120,'18+','Фильм о завоевании Вестероса Эйгоном Завоевателем.','Дэвид Наттер','Джордж Р.Р. Мартин','Джордж Р.Р. Мартин',NULL,'Рамин Джавади',NULL,NULL,7.5,'2026-06-19 23:31:58.394092','2026-06-19 23:31:58.394092',5);
INSERT INTO "movie" VALUES (6,'game-of-thrones-rebellion','Игра престолов: Восстание','Game of Thrones: Rebellion',2024,'game-of-thrones',130,'18+','Фильм о восстании Роберта Баратеона против Таргариенов.','Мигель Сапочник','Джордж Р.Р. Мартин','Джордж Р.Р. Мартин',NULL,'Рамин Джавади',NULL,NULL,7.8,'2026-06-19 23:31:58.401408','2026-06-19 23:31:58.401408',6);
INSERT INTO "movie_actors" VALUES (1,7);
INSERT INTO "movie_actors" VALUES (1,5);
INSERT INTO "movie_actors" VALUES (1,3);
INSERT INTO "movie_actors" VALUES (1,8);
INSERT INTO "movie_actors" VALUES (2,7);
INSERT INTO "movie_rating" VALUES (1,1,1,8,'2026-06-19 23:38:12.046673','2026-06-19 23:38:12.046673');
INSERT INTO "movie_tags" VALUES (1,2);
INSERT INTO "movie_tags" VALUES (1,6);
INSERT INTO "movie_tags" VALUES (1,4);
INSERT INTO "movie_tags" VALUES (1,7);
INSERT INTO "movie_tags" VALUES (1,8);
INSERT INTO "movie_tags" VALUES (1,9);
INSERT INTO "movie_tags" VALUES (1,11);
INSERT INTO "movie_tags" VALUES (1,5);
INSERT INTO "movie_tags" VALUES (2,2);
INSERT INTO "movie_tags" VALUES (2,6);
INSERT INTO "movie_tags" VALUES (2,7);
INSERT INTO "movie_tags" VALUES (3,2);
INSERT INTO "movie_tags" VALUES (3,6);
INSERT INTO "movie_tags" VALUES (3,15);
INSERT INTO "movie_tags" VALUES (4,2);
INSERT INTO "movie_tags" VALUES (4,6);
INSERT INTO "movie_tags" VALUES (5,3);
INSERT INTO "movie_tags" VALUES (5,4);
INSERT INTO "movie_tags" VALUES (5,16);
INSERT INTO "movie_tags" VALUES (5,17);
INSERT INTO "movie_tags" VALUES (6,3);
INSERT INTO "movie_tags" VALUES (6,4);
INSERT INTO "movie_tags" VALUES (6,16);
INSERT INTO "movie_tags" VALUES (6,17);
INSERT INTO "news" VALUES (1,'mandalorian-and-grogu-review','«Мандалорец и Грогу»: космический блокбастер, похожий на расширенный эпизод сериала','В мировой прокат вышел фильм «Мандалорец и Грогу» — полнометражное продолжение приключений закованного в броню охотника за головами.','[{"type": "paragraph", "content": "\u041c\u0430\u043d\u0434\u0430\u043b\u043e\u0440\u0435\u0446 \u0414\u0438\u043d \u0414\u0436\u0430\u0440\u0438\u043d (\u041f\u0435\u0434\u0440\u043e \u041f\u0430\u0441\u043a\u0430\u043b\u044c) \u0442\u0435\u043f\u0435\u0440\u044c \u0440\u0430\u0431\u043e\u0442\u0430\u0435\u0442 \u043d\u0430 \u041d\u043e\u0432\u0443\u044e \u0420\u0435\u0441\u043f\u0443\u0431\u043b\u0438\u043a\u0443, \u0432\u044b\u0441\u043b\u0435\u0436\u0438\u0432\u0430\u044f \u043f\u0440\u044f\u0447\u0443\u0449\u0438\u0445\u0441\u044f \u043f\u043e \u0437\u0430\u043a\u043e\u0443\u043b\u043a\u0430\u043c \u0434\u0430\u043b\u0435\u043a\u043e\u0439-\u0434\u0430\u043b\u0435\u043a\u043e\u0439 \u0433\u0430\u043b\u0430\u043a\u0442\u0438\u043a\u0438 \u043f\u0440\u0438\u0441\u043f\u0435\u0448\u043d\u0438\u043a\u043e\u0432 \u0418\u043c\u043f\u0435\u0440\u0438\u0438. \u0420\u044f\u0434\u043e\u043c \u0441 \u043d\u0438\u043c \u0435\u0433\u043e \u0443\u0448\u0430\u0441\u0442\u044b\u0439 \u0432\u043e\u0441\u043f\u0438\u0442\u0430\u043d\u043d\u0438\u043a \u0413\u0440\u043e\u0433\u0443, \u043a\u043e\u0442\u043e\u0440\u044b\u0439 \u043e\u0444\u0438\u0446\u0438\u0430\u043b\u044c\u043d\u043e \u0441\u043c\u0435\u043d\u0438\u043b \u0441\u0442\u0430\u0442\u0443\u0441 \u043d\u0430\u0439\u0434\u0435\u043d\u044b\u0448\u0430 \u043d\u0430 \u043f\u043e\u0447\u0435\u0442\u043d\u043e\u0435 \u0437\u0432\u0430\u043d\u0438\u0435 \u043c\u0430\u043d\u0434\u0430\u043b\u043e\u0440\u0441\u043a\u043e\u0433\u043e \u0443\u0447\u0435\u043d\u0438\u043a\u0430."}, {"type": "image", "url": "news-image-1.png", "alt": "\u041a\u0430\u0434\u0440 \u0438\u0437 \u0444\u0438\u043b\u044c\u043c\u0430 \u041c\u0430\u043d\u0434\u0430\u043b\u043e\u0440\u0435\u0446 \u0438 \u0413\u0440\u043e\u0433\u0443"}, {"type": "paragraph", "content": "\u0422\u0440\u0435\u0442\u0438\u0439 \u0441\u0435\u0437\u043e\u043d \u0441\u0435\u0440\u0438\u0430\u043b\u0430 \u00ab\u041c\u0430\u043d\u0434\u0430\u043b\u043e\u0440\u0435\u0446\u00bb, \u0432\u044b\u0448\u0435\u0434\u0448\u0438\u0439 \u0432\u0435\u0441\u043d\u043e\u0439 2023-\u0433\u043e, \u0437\u0430\u0432\u0435\u0440\u0448\u0438\u043b\u0441\u044f \u043d\u0430 \u043e\u043f\u0442\u0438\u043c\u0438\u0441\u0442\u0438\u0447\u0435\u0441\u043a\u043e\u0439 \u043d\u043e\u0442\u0435. \u041e\u0445\u043e\u0442\u043d\u0438\u043a \u0437\u0430 \u0433\u043e\u043b\u043e\u0432\u0430\u043c\u0438 \u0414\u0438\u043d \u0414\u0436\u0430\u0440\u0438\u043d \u043e\u0431\u0437\u0430\u0432\u0435\u043b\u0441\u044f \u0434\u0438\u0437\u0430\u0439\u043d\u0435\u0440\u0441\u043a\u043e\u0439 \u0434\u0430\u0447\u0435\u0439 \u043d\u0430 \u043f\u043b\u0430\u043d\u0435\u0442\u0435 \u041d\u0435\u0432\u0430\u0440\u0440\u043e \u0438 \u0443\u0441\u044b\u043d\u043e\u0432\u0438\u043b \u0413\u0440\u043e\u0433\u0443."}, {"type": "paragraph", "content": "\u0424\u0438\u043b\u044c\u043c \u00ab\u041c\u0430\u043d\u0434\u0430\u043b\u043e\u0440\u0435\u0446 \u0438 \u0413\u0440\u043e\u0433\u0443\u00bb \u0443\u0442\u0432\u0435\u0440\u0434\u0438\u0432\u0448\u0438\u0439\u0441\u044f \u0432 \u0441\u0435\u0440\u0438\u0430\u043b\u0435 \u043f\u043e\u0434\u0445\u043e\u0434 \u043d\u0435 \u043c\u0435\u043d\u044f\u0435\u0442, \u043f\u043e\u044d\u0442\u043e\u043c\u0443 \u0432\u0440\u0435\u043c\u0435\u043d\u0430\u043c\u0438 \u0432\u044b\u0433\u043b\u044f\u0434\u0438\u0442 \u043d\u0435 \u043f\u043e\u043b\u043d\u043e\u0446\u0435\u043d\u043d\u043e\u0439 \u043a\u0430\u0440\u0442\u0438\u043d\u043e\u0439, \u0430 \u043f\u0435\u0440\u0432\u044b\u043c \u044d\u043f\u0438\u0437\u043e\u0434\u043e\u043c \u0447\u0435\u0442\u0432\u0435\u0440\u0442\u043e\u0433\u043e \u0441\u0435\u0437\u043e\u043d\u0430."}, {"type": "image", "url": "news-image-2.png", "alt": "\u041a\u0430\u0434\u0440 \u0438\u0437 \u0444\u0438\u043b\u044c\u043c\u0430 \u041c\u0430\u043d\u0434\u0430\u043b\u043e\u0440\u0435\u0446 \u0438 \u0413\u0440\u043e\u0433\u0443"}, {"type": "paragraph", "content": "\u0412 \u043e\u0431\u0449\u0435\u043c, \u0432\u0441\u0442\u0440\u0435\u0447\u0430 \u0441 \u0433\u0435\u0440\u043e\u044f\u043c\u0438 \u043f\u043e\u043b\u0443\u0447\u0438\u043b\u0430\u0441\u044c \u0440\u0430\u0434\u043e\u0441\u0442\u043d\u043e\u0439, \u043d\u043e \u0431\u0435\u0441\u0441\u043c\u044b\u0441\u043b\u0435\u043d\u043d\u043e\u0439. \u0414\u043b\u044f \u044f\u0440\u044b\u0445 \u0444\u0430\u043d\u0430\u0442\u043e\u0432 \u00ab\u0417\u0432\u0435\u0437\u0434\u043d\u044b\u0445 \u0432\u043e\u0439\u043d\u00bb \u0442\u0443\u0442 \u0431\u0443\u0434\u0435\u0442 \u0441\u043b\u0438\u0448\u043a\u043e\u043c \u043c\u0430\u043b\u043e \u0434\u0435\u0442\u0430\u043b\u0435\u0439 \u0438\u0437 \u043e\u0440\u0438\u0433\u0438\u043d\u0430\u043b\u044c\u043d\u043e\u0433\u043e \u043c\u0438\u0440\u0430."}, {"type": "image", "url": "news-image-3.png", "alt": "\u041a\u0430\u0434\u0440 \u0438\u0437 \u0444\u0438\u043b\u044c\u043c\u0430 \u041c\u0430\u043d\u0434\u0430\u043b\u043e\u0440\u0435\u0446 \u0438 \u0413\u0440\u043e\u0433\u0443"}, {"type": "paragraph", "content": "\u042d\u0442\u0443 \u0441\u044e\u0436\u0435\u0442\u043d\u0443\u044e \u043b\u0438\u043d\u0438\u044e, \u043a\u0441\u0442\u0430\u0442\u0438, \u0436\u0434\u0443\u0442 \u043b\u044e\u0431\u043e\u043f\u044b\u0442\u043d\u044b\u0435 \u043f\u0435\u0440\u0435\u043c\u0435\u043d\u044b. \u0412 \u043a\u0430\u043a\u043e\u0439-\u0442\u043e \u043c\u043e\u043c\u0435\u043d\u0442 \u0432 \u0444\u0438\u043b\u044c\u043c\u0435 \u041c\u0430\u043d\u0434\u043e \u0438 \u0413\u0440\u043e\u0433\u0443 \u043f\u043e\u043c\u0435\u043d\u044f\u044e\u0442\u0441\u044f \u043c\u0435\u0441\u0442\u0430\u043c\u0438."}]','news-image-main.png','Николай','Арнольдович','actor-image-arnold.png','Журналист, кинокритик и просто хороший мужик :D','2026-06-19 23:31:58.464676','2026-06-19 23:31:58.464676','2026-06-19 23:31:58.464676');
INSERT INTO "series" VALUES (1,'game-of-thrones','Игра престолов','Game of Thrones',2011,2019,8,'Дэвид Бениофф, Джордж Р.Р. Мартин, Д.Б. Уайсс',60,'game-of-thrones','18+','На мифическом континенте Вестерос несколько могущественных семейств сражаются за контроль над Семью Королевствами.','Дэвид Наттер, Алан Тейлор, Алекс Грейвз','Дэвид Бениофф, Д.Б. Уайсс, Джордж Р.Р. Мартин','Рамин Джавади',9.2,'2026-06-19 23:31:58.413185','2026-06-19 23:31:58.413185',7);
INSERT INTO "series" VALUES (2,'house-of-dragon','Дом Дракона','House of the Dragon',2022,NULL,2,'Райан Кондал, Джордж Р.Р. Мартин',60,'game-of-thrones','18+','Приквел «Игры престолов» о династии Таргариенов и гражданской войне за Железный трон.','Мигель Сапочник, Грег Яйтанс','Райан Кондал, Джордж Р.Р. Мартин','Рамин Джавади',8.5,'2026-06-19 23:31:58.428333','2026-06-19 23:31:58.428333',8);
INSERT INTO "series" VALUES (3,'vikings-series','Викинги','Vikings',2013,2020,6,'Майкл Херст',45,'','18+','Исторический сериал о викингах.','Майкл Херст','Майкл Херст','Тревор Моррис',8.5,'2026-06-19 23:31:58.434614','2026-06-19 23:31:58.434614',9);
INSERT INTO "series" VALUES (4,'rome-series','Рим','Rome',2005,2007,2,'Бруно Хеллер',60,'','18+','Исторический сериал о Древнем Риме.','Бруно Хеллер','Бруно Хеллер','Джефф Бил',8.7,'2026-06-19 23:31:58.442382','2026-06-19 23:31:58.442382',10);
INSERT INTO "series" VALUES (5,'blade-runner-black-lotus','Бегущий по лезвию: Чёрный лотос','Blade Runner: Black Lotus',2021,2022,1,'Синъитиро Ватанабэ',22,'blade-runner','18+','Аниме-сериал по вселенной Бегущего по лезвию.','Синъитиро Ватанабэ',NULL,NULL,6.8,'2026-06-19 23:31:58.449128','2026-06-19 23:31:58.449128',11);
INSERT INTO "series" VALUES (6,'knight-of-seven-kingdoms','Рыцарь Семи Королевств','Knight of the Seven Kingdoms',2026,NULL,1,'Джордж Р.Р. Мартин',60,'game-of-thrones','18+','Приквел «Игры престолов» о приключениях Дункана Высокого и Эгга.','Алекс Грейвз','Джордж Р.Р. Мартин','Рамин Джавади',8.0,'2026-06-19 23:31:58.455674','2026-06-19 23:31:58.455674',12);
INSERT INTO "series_actors" VALUES (1,2);
INSERT INTO "series_actors" VALUES (1,4);
INSERT INTO "series_actors" VALUES (1,6);
INSERT INTO "series_actors" VALUES (1,9);
INSERT INTO "series_rating" VALUES (1,1,1,10,'2026-06-19 23:38:16.365637','2026-06-19 23:38:16.365637');
INSERT INTO "series_rating" VALUES (2,1,2,3,'2026-06-19 23:38:22.092096','2026-06-19 23:38:22.092096');
INSERT INTO "series_rating" VALUES (3,1,6,7,'2026-06-19 23:38:26.451132','2026-06-19 23:38:26.451132');
INSERT INTO "series_rating" VALUES (4,1,4,9,'2026-06-19 23:38:36.882859','2026-06-19 23:38:36.882859');
INSERT INTO "series_tags" VALUES (1,3);
INSERT INTO "series_tags" VALUES (1,4);
INSERT INTO "series_tags" VALUES (1,5);
INSERT INTO "series_tags" VALUES (1,16);
INSERT INTO "series_tags" VALUES (1,17);
INSERT INTO "series_tags" VALUES (1,21);
INSERT INTO "series_tags" VALUES (1,22);
INSERT INTO "series_tags" VALUES (1,23);
INSERT INTO "series_tags" VALUES (2,3);
INSERT INTO "series_tags" VALUES (2,4);
INSERT INTO "series_tags" VALUES (3,16);
INSERT INTO "series_tags" VALUES (3,4);
INSERT INTO "series_tags" VALUES (3,17);
INSERT INTO "series_tags" VALUES (3,5);
INSERT INTO "series_tags" VALUES (4,16);
INSERT INTO "series_tags" VALUES (4,4);
INSERT INTO "series_tags" VALUES (4,17);
INSERT INTO "series_tags" VALUES (5,2);
INSERT INTO "series_tags" VALUES (5,6);
INSERT INTO "series_tags" VALUES (5,15);
INSERT INTO "series_tags" VALUES (6,3);
INSERT INTO "series_tags" VALUES (6,4);
INSERT INTO "series_tags" VALUES (6,5);
INSERT INTO "tag" VALUES (1,'Боевик');
INSERT INTO "tag" VALUES (2,'Sci-Fi');
INSERT INTO "tag" VALUES (3,'Фэнтези');
INSERT INTO "tag" VALUES (4,'Драма');
INSERT INTO "tag" VALUES (5,'Приключения');
INSERT INTO "tag" VALUES (6,'Киберпанк');
INSERT INTO "tag" VALUES (7,'Неонуар');
INSERT INTO "tag" VALUES (8,'Детектив');
INSERT INTO "tag" VALUES (9,'Фантастика');
INSERT INTO "tag" VALUES (10,'Комедия');
INSERT INTO "tag" VALUES (11,'Триллер');
INSERT INTO "tag" VALUES (12,'Ужасы');
INSERT INTO "tag" VALUES (13,'Романтика');
INSERT INTO "tag" VALUES (14,'Документальный');
INSERT INTO "tag" VALUES (15,'Анимация');
INSERT INTO "tag" VALUES (16,'Исторический');
INSERT INTO "tag" VALUES (17,'Военный');
INSERT INTO "tag" VALUES (18,'Музыкальный');
INSERT INTO "tag" VALUES (19,'Спортивный');
INSERT INTO "tag" VALUES (20,'Криминал');
INSERT INTO "tag" VALUES (21,'Политика');
INSERT INTO "tag" VALUES (22,'Интриги');
INSERT INTO "tag" VALUES (23,'Эпический');
INSERT INTO "user" VALUES (1,'user','user@example.com','scrypt:32768:8:1$Olc34VGFaxF4WjL7$76db069595216874f6ed278a0f258b88f767dd1d9188b77f4991ee582a8c1bc9d00028116de3ce2ea2da010990a9f515041593e82e5f3f78dadf1cefdb640486','Арнольдо','Люблю пиццу и кино','profiles/user_1_20260620_023757.png','2026-06-19 23:31:51.953941','2026-06-19 23:37:57.484248');
INSERT INTO "user_favorite_tags" VALUES (1,1);
INSERT INTO "user_favorite_tags" VALUES (1,3);
INSERT INTO "user_favorite_tags" VALUES (1,9);
INSERT INTO "user_favorite_tags" VALUES (1,10);
INSERT INTO "user_favorite_tags" VALUES (1,13);
INSERT INTO "user_favorite_tags" VALUES (1,14);
INSERT INTO "user_favorite_tags" VALUES (1,18);
INSERT INTO "user_favorite_tags" VALUES (1,23);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_actor_slug" ON "actor" (
	"slug"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_event_slug" ON "event" (
	"slug"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_movie_slug" ON "movie" (
	"slug"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_news_slug" ON "news" (
	"slug"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_series_slug" ON "series" (
	"slug"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_user_email" ON "user" (
	"email"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_user_username" ON "user" (
	"username"
);
COMMIT;

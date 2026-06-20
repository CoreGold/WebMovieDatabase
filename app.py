from flask import Flask, render_template, abort, request, redirect, url_for, flash, session, jsonify
from flask_sqlalchemy import SQLAlchemy
from models import db, Movie, Series, Actor, News, Event, Award, Tag, User, MovieRating, SeriesRating
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import random
import os
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'dontlookatplease'


app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///instance/smotri.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


UPLOAD_FOLDER = 'static/assets/img/profiles'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

db.init_app(app)


def create_default_user():
    with app.app_context():
        user = User.query.filter_by(username='user').first()
        if not user:
            user = User(
                username='user',
                email='user@example.com',
                password_hash=generate_password_hash('user'),
                full_name='Пользователь',
                bio='Обычный пользователь'
            )
            db.session.add(user)
            db.session.commit()


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def get_current_user():
    user_id = session.get('user_id')
    if user_id:
        return User.query.get(user_id)
    return None


def group_awards_by_event(awards):
    grouped = {}
    for award in awards:
        event_id = award.event_id
        if event_id not in grouped:
            grouped[event_id] = {
                'event': award.event,
                'wins': [],
                'nominations': []
            }

        is_win = False
        if award.winner_type == 'movie' and award.winner_movie_id:
            is_win = True
        elif award.winner_type == 'series' and award.winner_series_id:
            is_win = True
        elif award.winner_type == 'actor' and award.winner_actor_id:
            is_win = True

        if is_win:
            if award.category not in grouped[event_id]['wins']:
                grouped[event_id]['wins'].append(award.category)
        else:
            if award.category not in grouped[event_id]['nominations']:
                grouped[event_id]['nominations'].append(award.category)

    return list(grouped.values())


def get_similar_movies(item, limit=24):
    tag_ids = [tag.id for tag in item.tags]
    if not tag_ids:
        return []

    similar_movies = Movie.query \
        .options(db.joinedload(Movie.media)) \
        .filter(Movie.slug != item.slug) \
        .filter(Movie.tags.any(Tag.id.in_(tag_ids))) \
        .all()

    similar_series = Series.query \
        .options(db.joinedload(Series.media)) \
        .filter(Series.slug != item.slug) \
        .filter(Series.tags.any(Tag.id.in_(tag_ids))) \
        .all()

    combined = list(similar_movies) + list(similar_series)

    def count_common_tags(obj):
        obj_tag_ids = [tag.id for tag in obj.tags]
        return len(set(tag_ids) & set(obj_tag_ids))

    combined.sort(key=count_common_tags, reverse=True)

    if limit is not None:
        return combined[:limit]
    return combined


def get_connected_movies(item, limit=24):
    if not item.franchise:
        return []

    connected_movies = Movie.query \
        .options(db.joinedload(Movie.media)) \
        .filter(Movie.slug != item.slug) \
        .filter(Movie.franchise == item.franchise) \
        .all()

    connected_series = Series.query \
        .options(db.joinedload(Series.media)) \
        .filter(Series.slug != item.slug) \
        .filter(Series.franchise == item.franchise) \
        .all()

    combined = list(connected_movies) + list(connected_series)

    def get_year(obj):
        if hasattr(obj, 'year'):
            return obj.year or 0
        elif hasattr(obj, 'year_start'):
            return obj.year_start or 0
        return 0

    combined.sort(key=get_year)

    if limit is not None:
        return combined[:limit]
    return combined


def get_actor_all_items(actor):
    movies = actor.movies
    series = actor.series
    combined = list(movies) + list(series)

    def get_year(item):
        if item.__class__.__name__ == 'Movie':
            return item.year or 0
        else:
            return item.year_start or 0

    combined.sort(key=get_year, reverse=True)
    return combined



@app.route('/')
def index():
    news = News.query.all()
    events = Event.query.all()

    combined = []
    for n in news:
        combined.append({
            'type': 'news',
            'slug': n.slug,
            'title': n.title,
            'subtitle': n.subtitle or 'Подробнее...',
            'image_main': n.image_main,
            'published_at': n.published_at or n.created_at
        })
    for e in events:
        combined.append({
            'type': 'event',
            'slug': e.slug,
            'title': e.title_ru,
            'subtitle': e.description[:100] + '...' if e.description else 'Подробнее...',
            'image_main': e.image_main,
            'published_at': e.created_at
        })

    combined.sort(key=lambda x: x['published_at'], reverse=True)
    news_items = combined[:3]

    movies_with_rating = Movie.query.filter(Movie.rating_avg > 5.0).all()
    random_movies = random.sample(movies_with_rating, min(4, len(movies_with_rating)))

    series_with_rating = Series.query.filter(Series.rating_avg > 5.0).all()
    random_series = random.sample(series_with_rating, min(4, len(series_with_rating)))

    all_actors = Actor.query.all()
    random_actors = random.sample(all_actors, min(4, len(all_actors)))

    total_movies = Movie.query.count()
    total_series = Series.query.count()
    total_actors = Actor.query.count()

    user = get_current_user()

    return render_template('index.html',
                           news_items=news_items,
                           random_movies=random_movies,
                           random_series=random_series,
                           random_actors=random_actors,
                           total_movies=total_movies,
                           total_series=total_series,
                           total_actors=total_actors,
                           user=user)



@app.route('/movies')
def movies_list():
    movies = Movie.query.options(db.joinedload(Movie.media)).all()
    user = get_current_user()
    return render_template('more.html', items=movies, title='Все фильмы', type='movie', user=user)


@app.route('/series')
def series_list():
    series = Series.query.options(db.joinedload(Series.media)).all()
    user = get_current_user()
    return render_template('more.html', items=series, title='Все сериалы', type='series', user=user)


@app.route('/actors')
def actors_list():
    actors = Actor.query.all()
    user = get_current_user()
    return render_template('more.html', items=actors, title='Все актёры', type='actor', user=user)



@app.route('/movies/<slug>/connected')
def movie_connected_all(slug):
    movie = Movie.query.filter_by(slug=slug).first()
    if not movie:
        abort(404)
    items = get_connected_movies(movie, limit=None)
    user = get_current_user()
    return render_template('more.html', items=items, title=f'{movie.title_ru} / Связанное', type='movie_series',
                           user=user)


@app.route('/movies/<slug>/similar')
def movie_similar_all(slug):
    movie = Movie.query.filter_by(slug=slug).first()
    if not movie:
        abort(404)
    items = get_similar_movies(movie, limit=None)
    user = get_current_user()
    return render_template('more.html', items=items, title=f'{movie.title_ru} / Похожее', type='movie_series',
                           user=user)


@app.route('/movies/<slug>/actors')
def movie_actors_all(slug):
    movie = Movie.query.filter_by(slug=slug).first()
    if not movie:
        abort(404)
    actors = movie.actors
    user = get_current_user()
    return render_template('more.html', items=actors, title=f'Актёры фильма "{movie.title_ru}"', type='actor',
                           user=user)


@app.route('/series/<slug>/connected')
def series_connected_all(slug):
    series = Series.query.filter_by(slug=slug).first()
    if not series:
        abort(404)
    items = get_connected_movies(series, limit=None)
    user = get_current_user()
    return render_template('more.html', items=items, title=f'{series.title_ru} / Связанное', type='movie_series',
                           user=user)


@app.route('/series/<slug>/similar')
def series_similar_all(slug):
    series = Series.query.filter_by(slug=slug).first()
    if not series:
        abort(404)
    items = get_similar_movies(series, limit=None)
    user = get_current_user()
    return render_template('more.html', items=items, title=f'{series.title_ru} / Похожее', type='movie_series',
                           user=user)


@app.route('/series/<slug>/actors')
def series_actors_all(slug):
    series = Series.query.filter_by(slug=slug).first()
    if not series:
        abort(404)
    actors = series.actors
    user = get_current_user()
    return render_template('more.html', items=actors, title=f'Актёры сериала "{series.title_ru}"', type='actor',
                           user=user)


@app.route('/actor/<slug>/all')
def actor_all(slug):
    actor = Actor.query.filter_by(slug=slug).first()
    if not actor:
        abort(404)
    items = get_actor_all_items(actor)
    user = get_current_user()
    return render_template('more.html', items=items, title=f'Все фильмы и сериалы с {actor.name} {actor.surname}',
                           type='movie_series', user=user)



@app.route('/movies/<slug>/awards')
def movie_awards_all(slug):
    movie = Movie.query.filter_by(slug=slug).first()
    if not movie:
        abort(404)
    awards = list(movie.won_awards) + list(movie.nominated_in_awards)
    grouped = group_awards_by_event(awards)
    user = get_current_user()
    return render_template('more.html', grouped_awards=grouped, title=f'Награды: {movie.title_ru}', type='awards',
                           user=user)


@app.route('/series/<slug>/awards')
def series_awards_all(slug):
    series = Series.query.filter_by(slug=slug).first()
    if not series:
        abort(404)
    awards = list(series.won_awards) + list(series.nominated_in_awards)
    grouped = group_awards_by_event(awards)
    user = get_current_user()
    return render_template('more.html', grouped_awards=grouped, title=f'Награды: {series.title_ru}', type='awards',
                           user=user)


@app.route('/actor/<slug>/awards')
def actor_awards_all(slug):
    actor = Actor.query.filter_by(slug=slug).first()
    if not actor:
        abort(404)
    awards = list(actor.won_awards) + list(actor.nominated_in_awards)
    grouped = group_awards_by_event(awards)
    user = get_current_user()
    return render_template('more.html', grouped_awards=grouped, title=f'Награды: {actor.name} {actor.surname}',
                           type='awards', user=user)



@app.route('/movies/<slug>')
def movie_detail(slug):
    movie = Movie.query \
        .options(
        db.joinedload(Movie.actors),
        db.joinedload(Movie.tags),
        db.joinedload(Movie.media),
        db.joinedload(Movie.won_awards).joinedload(Award.event),
        db.joinedload(Movie.nominated_in_awards).joinedload(Award.event)
    ) \
        .filter_by(slug=slug).first()
    if not movie:
        abort(404)

    all_awards = list(movie.won_awards) + list(movie.nominated_in_awards)
    grouped_awards = group_awards_by_event(all_awards)

    similar = get_similar_movies(movie)
    connected = get_connected_movies(movie)

    user = get_current_user()
    user_rating = None
    if user:
        movie_rating = MovieRating.query.filter_by(user_id=user.id, movie_id=movie.id).first()
        if movie_rating:
            user_rating = movie_rating.rating

    return render_template('film.html', movie=movie, similar=similar, connected=connected,
                           grouped_awards=grouped_awards, user_rating=user_rating, user=user)



@app.route('/series/<slug>')
def series_detail(slug):
    series = Series.query \
        .options(
        db.joinedload(Series.actors),
        db.joinedload(Series.tags),
        db.joinedload(Series.media),
        db.joinedload(Series.won_awards).joinedload(Award.event),
        db.joinedload(Series.nominated_in_awards).joinedload(Award.event)
    ) \
        .filter_by(slug=slug).first()
    if not series:
        abort(404)

    all_awards = list(series.won_awards) + list(series.nominated_in_awards)
    grouped_awards = group_awards_by_event(all_awards)

    similar = get_similar_movies(series)
    connected = get_connected_movies(series)

    user = get_current_user()
    user_rating = None
    if user:
        series_rating = SeriesRating.query.filter_by(user_id=user.id, series_id=series.id).first()
        if series_rating:
            user_rating = series_rating.rating

    return render_template('series.html', series=series, similar=similar, connected=connected,
                           grouped_awards=grouped_awards, user_rating=user_rating, user=user)



@app.route('/actor/<slug>')
def actor_detail(slug):
    actor = Actor.query \
        .options(
        db.joinedload(Actor.won_awards).joinedload(Award.event),
        db.joinedload(Actor.nominated_in_awards).joinedload(Award.event)
    ) \
        .filter_by(slug=slug).first()
    if not actor:
        abort(404)

    all_awards = list(actor.won_awards) + list(actor.nominated_in_awards)
    grouped_awards = group_awards_by_event(all_awards)

    movies = actor.movies
    series = actor.series
    combined = list(movies) + list(series)

    def get_year(item):
        if item.__class__.__name__ == 'Movie':
            return item.year or 0
        else:
            return item.year_start or item.year_end or 0

    best_movies = sorted(combined, key=lambda m: m.rating_avg or 0, reverse=True)[:4]
    all_movies = sorted(combined, key=get_year, reverse=True)

    user = get_current_user()
    return render_template('actor.html', actor=actor, best_movies=best_movies, all_movies=all_movies, series=series,
                           grouped_awards=grouped_awards, user=user)



@app.route('/news/<slug>')
def news_detail(slug):
    news = News.query \
        .options(
        db.joinedload(News.movies).joinedload(Movie.media),
        db.joinedload(News.series).joinedload(Series.media)
    ) \
        .filter_by(slug=slug).first()
    if not news:
        abort(404)

    connected = list(news.movies) + list(news.series)

    def get_year(item):
        if item.__class__.__name__ == 'Movie':
            return item.year or 0
        else:
            return item.year_start or 0

    connected.sort(key=get_year, reverse=True)

    user = get_current_user()
    return render_template('news.html', news=news, connected=connected, user=user)



@app.route('/events/<slug>')
def event_detail(slug):
    event = Event.query.filter_by(slug=slug).first()
    if not event:
        abort(404)

    awards = Award.query \
        .options(
        db.joinedload(Award.winner_movie).joinedload(Movie.media),
        db.joinedload(Award.winner_series).joinedload(Series.media),
        db.joinedload(Award.winner_actor),
        db.joinedload(Award.nominee_movies).joinedload(Movie.media),
        db.joinedload(Award.nominee_series).joinedload(Series.media),
        db.joinedload(Award.nominee_actors)
    ) \
        .filter_by(event_id=event.id) \
        .all()

    user = get_current_user()
    return render_template('event.html', event=event, awards=awards, user=user)



@app.route('/faq')
def faq():
    user = get_current_user()
    return render_template('FAQ.html', user=user)


@app.route('/contacts')
def contacts():
    user = get_current_user()
    return render_template('contacts.html', user=user)


@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404


@app.route('/login')
def login():
    user = User.query.filter_by(username='user').first()
    if user:
        session['user_id'] = user.id
    return redirect(request.referrer or url_for('index'))


@app.route('/logout')
def logout():
    session.pop('user_id', None)
    return redirect(request.referrer or url_for('index'))



@app.route('/profile', methods=['GET', 'POST'])
def profile():
    user = get_current_user()
    if not user:
        return redirect(url_for('index'))

    if request.method == 'POST':
        full_name = request.form.get('full_name')
        bio = request.form.get('bio')
        favorite_tags = request.form.getlist('favorite_tags')

        user.full_name = full_name
        user.bio = bio

        user.favorite_tags.clear()
        for tag_name in favorite_tags:
            tag = Tag.query.filter_by(name=tag_name).first()
            if tag:
                user.favorite_tags.append(tag)

        if 'photo' in request.files:
            file = request.files['photo']
            if file and file.filename and allowed_file(file.filename):
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = secure_filename(f'user_{user.id}_{datetime.now().strftime("%Y%m%d_%H%M%S")}.{ext}')
                file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                user.photo_url = f'profiles/{filename}'

        db.session.commit()
        return redirect(url_for('profile'))

    all_tags = Tag.query.all()

    movie_ratings = MovieRating.query.filter_by(user_id=user.id).all()
    series_ratings = SeriesRating.query.filter_by(user_id=user.id).all()

    rated_items = []
    for mr in movie_ratings:
        rated_items.append({
            'item': mr.movie,
            'rating': mr.rating,
            'type': 'movie'
        })
    for sr in series_ratings:
        rated_items.append({
            'item': sr.series,
            'rating': sr.rating,
            'type': 'series'
        })

    rated_items.sort(key=lambda x: x['rating'], reverse=True)

    return render_template('profile.html',
                           user=user,
                           all_tags=all_tags,
                           rated_items=rated_items)



@app.route('/rate', methods=['POST'])
def rate():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Необходимо войти в аккаунт'}), 401

    data = request.get_json()
    item_type = data.get('type')
    item_id = data.get('id')
    rating = data.get('rating')

    if not item_type or not item_id or not rating:
        return jsonify({'error': 'Недостаточно данных'}), 400

    if rating < 1 or rating > 10:
        return jsonify({'error': 'Оценка должна быть от 1 до 10'}), 400

    try:
        if item_type == 'movie':
            movie = Movie.query.get(item_id)
            if not movie:
                return jsonify({'error': 'Фильм не найден'}), 404

            existing = MovieRating.query.filter_by(user_id=user.id, movie_id=item_id).first()
            if existing:
                existing.rating = rating
                existing.updated_at = datetime.utcnow()
            else:
                new_rating = MovieRating(user_id=user.id, movie_id=item_id, rating=rating)
                db.session.add(new_rating)

        elif item_type == 'series':
            series = Series.query.get(item_id)
            if not series:
                return jsonify({'error': 'Сериал не найден'}), 404

            existing = SeriesRating.query.filter_by(user_id=user.id, series_id=item_id).first()
            if existing:
                existing.rating = rating
                existing.updated_at = datetime.utcnow()
            else:
                new_rating = SeriesRating(user_id=user.id, series_id=item_id, rating=rating)
                db.session.add(new_rating)

        else:
            return jsonify({'error': 'Некорректный тип'}), 400

        db.session.commit()
        return jsonify({'success': True, 'rating': rating})

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@app.route('/events')
def events_list():
    user = get_current_user()
    return render_template('more.html', items=[], title='События', type='event', user=user)


@app.route('/news')
def news_list():
    user = get_current_user()
    return render_template('more.html', items=[], title='Новости', type='news', user=user)


@app.route('/search')
def search():
    q = request.args.get('q', '').strip()
    user = get_current_user()

    if not q:
        return render_template('more.html', items=[], title='Поиск', type='movie_series', user=user)

    movies = Movie.query.filter(
        db.or_(
            Movie.title_ru.ilike(f'%{q}%'),
            Movie.title_en.ilike(f'%{q}%'),
            Movie.tags.any(Tag.name.ilike(f'%{q}%'))
        )
    ).options(db.joinedload(Movie.media)).all()

    series = Series.query.filter(
        db.or_(
            Series.title_ru.ilike(f'%{q}%'),
            Series.title_en.ilike(f'%{q}%'),
            Series.tags.any(Tag.name.ilike(f'%{q}%'))
        )
    ).options(db.joinedload(Series.media)).all()

    items = movies + series
    items.sort(key=lambda x: x.rating_avg or 0, reverse=True)

    title = f'Результаты поиска: "{q}"'
    return render_template('more.html', items=items, title=title, type='movie_series', user=user)


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    create_default_user()
    app.run(debug=True, use_reloader=False)
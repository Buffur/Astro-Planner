# RA.R2a — Рынок и ожидания пользователей (landscape)

> **Статус:** исследование, шаг R2a утверждённой RA.R2 (`prompts/RA_R2_RESEARCH_PLAN.md` §3).
> Решений не содержит; варианты в §5 — вход для R2e и RA.D.
> **Дата обращения ко всем источникам:** 2026-10-17.
> **Базис:** находки Phase A — `research/RA_R1_PHASE_A_ASSESSMENT.md` (RA-A01…RA-H03, K4, K14).
> Код повторно не аудировался.
> **Метки:** **[F]** FACT — видно в первоисточнике (официальный сайт, документация, карточка в
> сторе, опубликованный отзыв). **[D]** DESCRIBED — маркетинг, сторонний пересказ или выдача
> поисковика без доступа к странице. **[I]** INFERENCE — вывод автора этого документа.
> Ссылки вида [n] ведут в §6.

## 1. Метод и ограничения

**Метод.**
- Официальные сайты и документация: Telescopius (форум разработчика), Astrospheric, Clear Outside,
  PhotoPills User Guide, Stellarium Labs, SkySafari, AstroPlanner (iLanga), Deep-Sky Planner,
  SkyTools, документация N.I.N.A., руководства ZWO ASIAIR (PDF).
- Карточки Google Play читались целиком (заголовок, рейтинг, число отзывов, установки, описание,
  видимые отзывы). Карточки App Store — через iTunes Search/Lookup API. Последние отзывы App Store —
  через публичный RSS (`itunes.apple.com/us/rss/customerreviews/...`). Отзывы считались вручную по
  темам.
- Пользовательские обсуждения: форум Telescopius (запросы функций 2025 г.) и форум AstroBin (треды
  о журналах и об опросе по многоночным данным).
- Пакет `com.twtapp` из референса владельца опознан по карточке Google Play и сайту разработчика
  (§2, примечание 1).

**Ограничения и пробелы (записаны, не скрыты).**
- **Reddit** (r/astrophotography, r/AskAstrophotography) **недоступен**. Инструмент поиска
  отклоняет домен reddit.com, а прямой запрос к JSON API вернул 403. Ни одного утверждения из Reddit
  в отчёте нет.
- **Cloudy Nights** закрыт Cloudflare: 403 через WebFetch и curl. Доступна только поисковая выдача
  по тредам [41]. Всё, что из неё взято, помечено [D] и считается вторичным.
- Страницы **telescopius.com** — SPA и без JavaScript отдают пустую страницу. Функции Telescopius
  подтверждены через карточку App Store [1] и ответы разработчика на форуме [2]–[5].
- **photopills.com/articles** отдаёт 403. User Guide читался через curl [14].
- Цены SkySafari взяты со страницы сайта [20]. Модель оплаты (разовая покупка или подписка)
  там не указана.
- Полные тексты отзывов Google Play недоступны: Play показывает 3 отзыва. Темы отзывов по Play
  поэтому опираются на малые выборки и помечены как анекдоты.
- Счёт отзывов App Store идёт по последним 30–50 записям RSS. Это не репрезентативная выборка всей
  базы, а «свежий срез».
- Сторонние ИИ-сводки поисковика (например, о DarkScout и Telescopius) использованы только как
  указатель на первоисточник. Если первоисточник не открылся, утверждение помечено [D].

## 2. Матрица «продукт × задача»

Сокращения: «—» означает, что в источнике функции нет; «н/д» — что данных не найдено.
**Capture** — планирование съёмки и интеграции. **SNR/экспоз.** — калькулятор SNR или экспозиции.
**Объём** — оценка места для хранения.

| Продукт | Capture / интеграция | SNR / экспоз. | Объём | Погода | Луна | Онбординг | Home | Записи / списки | Платформа | Цена |
|---|---|---|---|---|---|---|---|---|---|---|
| **Telescopius** [1]–[5] | Цели под телескоп, симулятор кадра, мозаики [F 1]; «Imaging Opportunities» как помощь планированию (что считает, не описано) [F 5] | — | — | Погодная страница — только по пересказу [D] | н/д | Аккаунт; жалобы на вход — 4 из 8 свежих отзывов App Store [F 42] | Блок «Targets for your telescope» [F 2] | Списки целей с заметками; журнала сессий **нет**, разработчик признаёт [F 2][F 3][F 4] | Web, iOS, Android | Бесплатно; Patreon и реклама [F 1][D 6] |
| **Astrospheric** [7]–[9] | — | — | — | Почасовая сетка на 84 ч: облака, transparency (со смогом), seeing, ветер, T, точка росы; в Pro — ансамбль моделей [F 7][F 8] | Карточка Moon Details (фаза, высота, освещённость, возраст, следующая фаза); линии восхода и захода на почасовой сетке [F 7] | н/д | Прогноз по месту [F 7] | Избранные места: 5 бесплатно, без ограничения в Pro [F 7] | Web, iOS, Android | Freemium, подписка Pro; реклама во free [F 8] |
| **Clear Outside** [10]–[12] | — | — | — | 7 дней по часам: облачность low/mid/high/total, затем обычная погода; «без мультяшной графики» [F 10][F 11] | Восход и заход, фаза; периоды сумерек и темноты [F 10] | Прогноз для текущего места автоматически [F 10] | Прогноз по месту [F 10] | Избранные места [F 10] | iOS (новая версия 12.2025), Android (обновление в Play — 05.2015), web [F 11][F 12] | Бесплатно [F 10] |
| **PhotoPills** [13]–[15] | Planner (карта и время) для Солнца, Луны и Млечного Пути; сохранённые Plans, виджет «5 ближайших планов» [F 13][F 14] | Калькуляторы Spot Stars, Long Exposure, Star Trails, Timelapse [F 13][F 14] | — | — | Moon Calendar, восход и заход, суперлуния [F 13] | Гайд: включить виджеты, «поставить цель», «боль → таблетка» [F 14] | Три меню: Pills, My Stuff, Academy [F 14] | Plans и POI, бэкап, синхронизация (только iOS) [F 14] | iOS, Android | Разовая покупка (на iOS $10.99) [F 44] |
| **Stellarium Mobile** [16][17] | Plus: инструменты наблюдаемости и времени кульминации [F 16] | — | — | — | В изображении неба [I] | Сразу карта неба («навести телефон») [F 17] | Карта неба [F 17] | н/д | iOS, Android; 10M+ установок, 4,8★ [F 17] | Freemium (Plus — встроенная покупка) [F 17] |
| **Sky Tonight** [18][19] | Visible Tonight, Time Machine [F 18] | — | — | Stargazing Index (Луна, засветка, видимость) [F 18] | Календарь фаз и событий [F 18] | н/д | Карта неба и нижняя навигация [F 18] | н/д | iOS, Android; 5M+, 4,7★ [F 18] | Freemium, подписка или пожизненная покупка; реклама [F 18][F 19] |
| **SkySafari 8** [20][21] | Несколько полей зрения, Event Finder, «Tonight at a Glance» [F 20] | — | — | Premium: Observing Conditions (окна, seeing index) [F 21] | Блок Sun/Moon в Tonight at a Glance [F 20] | н/д | Tonight at a Glance [F 20] | Списки, заметки, оборудование, сессии через LiveSky [F 20] | iOS, Android | Basic, Plus, Pro + Premium [F 20] |
| **AstroPlanner** (iLanga, P. Rodman) [22] | Списки объектов, видимость в сессии, поле зрения сенсора [F 22] | — | — | В меню есть, детали не раскрыты [F 22] | н/д | Пользователь пишет: «сначала пугает» [F 36] | — | Журнал наблюдений в сессиях, менеджер оборудования, свои поля [F 22][F 36] | macOS, Windows | Shareware, около $50 по словам пользователя [F 22][D 36] |
| **DarkScout** (iOS) [23] | Tonight go/no-go, план до 14 ночей, сравнение мест [F 23] | — | — | Облачные карты на 72 ч и на 12 ч; **Astro Score** и почасовые решения [F 23] | «Moon conditions» [F 23] | Старт с Tonight по текущему месту; PRO показывается в онбординге [F 23] | Tonight [F 23] | Сохранённые места, события сообщества [F 23] | iOS 26+ | С 10.2026 всё бесплатно (раньше PRO) [F 23] |
| **Stargazing Hub** (`com.twtapp`) [24]–[26] | Видоискатель и мозаики, калькуляторы [F 24] | Калькуляторы для ночной съёмки и гидирования [F 24] | — | **Индекс 0–100 %** с порогами; вкладки моделей (Clear Sky Chart, почасовой на основе ECMWF, 15 дней OpenWeather) [F 25] | Фаза, восход и заход; **периоды «безлунной ночи»** под индексом [F 25] | н/д | Индекс, затем вкладки прогнозов [F 25] | н/д | Android, iOS, WeChat; 10K+, 4,5★ (242) [F 24] | Freemium, реклама и подписка [F 24] |
| **N.I.N.A.** (модель плана) [27]–[29] | Строки: Total #, Time, Type (LIGHT/DARK/FLAT/BIAS), Filter, Binning, Dither every N, Gain, Offset; **новая строка наследует предыдущую**; **Estimated Finish Time** с учётом скачивания [F 27] | — | — | — | — | — | — | Наборы последовательностей по целям [F 27] | Windows (управление) | Бесплатно (open source) [I] |
| **ZWO ASIAIR** (модель плана) [30][31] | Autorun: последовательности, «Group by Slot», Plan mode для нескольких целей; калибровку рекомендуют включать в план [F 30][F 31] | — | **«Estimated size»** вместе с «Estimated time», чтобы «проверить выполнимость» [F 30] | — | — | — | — | — | Устройство и приложение | С железом |
| **Scope Nights** (iOS) [32] | — | — | — | «Smart stargazing ratings», свои пороги (Луна, ветер, влажность, T), до 7 ночей и 7 мест [F 32] | Фаза, восход и заход [F 32] | н/д | Лучшие места сегодня (бейдж) [F 32] | Избранные места [F 32] | iOS | Платное ($6.99) [F 44] |
| **Deep-Sky Planner 9** [33] | Observing Plans [F 33] | — | — | н/д | н/д | — | — | Журнал наблюдений, обмен по OpenAstronomyLog, бэкап [F 33] | Windows (+ Mobile) | Платное [F 33] |
| **SkyTools** [34] | Планировщик под оборудование и условия [D 34] | **Моделирует «detector signal-to-noise»** [D 34] | н/д | н/д | н/д | — | — | Журнал и проекты по отзыву пользователя [F 36] | Desktop | Платное [I] |
| **AstroPlan (iOS, Project 2022 Ltd)** [40] | Ранжированные цели на ночь, календарь [F 40] | — | — | Дашборд: облачность, ветер, темнота; Open-Meteo [F 40] | Фаза на дашборде [F 40] | Без аккаунта [F 40] | «Home dashboard» [F 40] | Риги с FOV (Pro) [F 40] | iOS | Freemium, AI-чат [F 40] |

**Примечание 1 — `com.twtapp`.** Карточка `play.google.com/store/apps/details?id=com.twtapp` — это
**«Stargazing Hub: Astro Guide»**, разработчик KnockDream Technology. В Play указаны 4,5★ по 242
отзывам, 10K+ установок, «Contains ads», встроенные покупки, обновление 16.10.2026 [F 24]. Сайт
разработчика (Fuzhou Knock Dream Technology, кит. 天文通, «Tianwentong») указывает адрес twtapp.com
[F 26]. Руководство по Stargazing Index описывает три вида прогноза под индексом:
- «Clear Sky Chart» (晴天钟) доктора Е Цюаньчжи: обновления 4 раза в сутки, шаг 3 ч, облачность,
  seeing, transparency;
- почасовой прогноз на основе ECMWF;
- прогноз на 15 дней от OpenWeather, который в индекс не входит [F 25].

Вкладки на скриншоте владельца — ICON / 7Timer / 15 Days / Climate / Clear Outside. Что «7Timer»
соответствует Clear Sky Chart (автор 7Timer! — тот же Е Цюаньчжи), а ICON, Climate и Clear Outside
появились в версии приложения новее руководства, — это **[I]**. В открытых источниках таких вкладок
нет.

**Примечание 2 — коллизия имён (вход для R2d, без вывода).** Найдены:
- iOS-приложение **«AstroPlan»** (Project 2022 Ltd, выпущено 13.06.2026) [F 40];
- **«Astro Planner: DarkScout»** — прежнее название DarkScout в выдаче поиска [D 23];
- настольный **AstroPlanner** (iLanga) [F 22];
- веб-инструмент «Astro Planner» на форуме AstroBin [D 41].

## 3. Темы отзывов пользователей

«Источник» — независимое место (продукт, тред, форум). «n» — число отзывов или постов в просмотренном
срезе. Темы с поддержкой меньше чем из 2 независимых источников помечены **анекдот**.

| # | Тема | Поддержка | Сила |
|---|---|---|---|
| T1 | **Сводные данные по цели за несколько ночей и журнал сессий.** Пользователи хотят видеть, сколько снято по цели, и сейчас ведут это в таблицах | Тред AstroBin о журнале (стр. 1 из 3, 52 ответа): 4 ведут таблицу, ещё 3 собираются начать; остальные — бумага (2), Access (1), Apple Notes (1), SkyTools (1), AstroPlanner (1), AstroBin как журнал (1). Поля: цель, дата, число кадров, длина кадра, итог за сессию, фильтры, панель мозаики, калибровочные наборы, угол поворота, погода [F 36]. Опрос AstroBin: 45 голосов, 71 % вносят каждую ночь отдельно, 27 % сводят в одну дату; автор жалуется, что вносить 12+ ночей «слишком тяжело» [F 37]. Три независимых запроса на форуме Telescopius в 2025 г. (журнал, Imaging Tracker, отслеживание снятого); разработчик подтверждает, что функции нет [F 2][F 3][F 4]. Существует self-hosted Nova DSO Tracker (проекты, сумма интеграции, импорт логов ASIAIR и N.I.N.A.) [F 39] | **Повторяющаяся**: ≥4 независимых источника |
| T2 | **Когда провайдер прогноза падает, приложение становится бесполезным** | Scope Nights: около 20 из 40 свежих отзывов — «forecast unavailable», ошибки, «abandoned» [F 32]. Astrospheric: 4 из 40 — «network error», перестало работать, нет данных на Гавайях, не проходит экран разрешения геолокации [F 9]. По пересказу поиска, 7Timer ASTRO в одном каталоге данных помечен «deprecated» [D] | **Повторяющаяся**: 2 продукта, ≥24 отзыва |
| T3 | **Точности прогноза облаков не доверяют, данные сверяют по нескольким источникам** | Astrospheric: 4 отзыва против точности, около 6 за [F 9]. Руководство Stargazing Hub само советует комбинировать модели [F 25]. Cloudy Nights (вторично): консенсус «ни одно приложение не надёжно везде», сверка с Windy и спутником [D 41]. Стратегия Astrospheric Pro — ансамбль моделей [F 7] | **Повторяющаяся**: 3 источника (один вторичный) |
| T4 | **Читаемость «с одного взгляда» против перегруженности и загадочных значков** | Похвала Clear Outside «без мультяшных картинок, организовано» — 2 из 3 видимых отзывов Play [F 11]. Scope Nights: «quick glance» — 3 отзыва [F 32]. Astrospheric: «too hard to look at… cryptic icons», «gripe — layout and UI» — 2 [F 9]. Astroweather (клиент 7Timer): «нет легенды, непонятно», «grey and blue lines» — 2 из 3 [F 35]. Sky Tonight: «cluttered» — 1 [F 19] | **Повторяющаяся**: 5 продуктов, ≥10 отзывов |
| T5 | **Крутая кривая обучения у мощных планировщиков** | PhotoPills: 5 из 30 свежих отзывов («steep learning curve», «confusing», «difficult to learn»); в 4 других хвалят обучающие видео [F 15]. AstroPlanner: «сначала пугает» [F 36]. PhotoPills сам строит вход через «поставь цель» и «боль → таблетка» [F 14] | **Повторяющаяся**: 2 продукта |
| T6 | **Аккаунт и вход как барьер** | Telescopius: 4 из 8 свежих отзывов — не удаётся войти, «loses your lists» [F 42]. Astrospheric: «оплатил, но не могу восстановить Pro» — 1 [F 9]. Положительный контраст: AstroPlan (iOS) рекламирует «No account required» [F 40] | **Повторяющаяся**: 2 продукта |
| T7 | **Неприятие подписки, предпочтение разовой покупки** | Astrospheric: 2 в App Store и 1 в Play [F 9][F 8]. Sky Tonight: «рад пожизненной опции» — 1 [F 18]. PhotoPills: «платить второй раз при смене устройства» — 2 [F 13][F 15] | **Повторяющаяся**: 3 продукта (для AstroPlan неприменимо: бесплатно, GPL) |
| T8 | **Ценят «всё в одном»** | Stargazing Hub: «replaces about 5 separate apps» — 2 из 3 видимых отзывов [F 24]. Astrospheric: «All In One», «everything I need in one place» — 2 [F 9]. Sky Tonight: «Complete! all in one place» — 1 [F 19] | **Повторяющаяся**, но в пользу комбайнов. В противоречии с K4 — см. §4 RA-A |
| T9 | **Свои пороги и настройки отображения** | Astrospheric: нельзя полностью отключить смог в transparency — 1 [F 9]. Clear Outside: «no settings anywhere», место по умолчанию — Англия — 1 [F 11]. Astroweather: «zero customization» — 1 [F 35]. Scope Nights продаёт «custom thresholds» [F 32]; DarkScout — «choose your own thresholds» для оповещений [F 23] | **Повторяющаяся** (3 жалобы, 2 продукта с функцией), но каждая жалоба — анекдот |
| T10 | Виджеты | Astrospheric: «Please add widgets» — 1 [F 9]. PhotoPills: виджеты — первый шаг гайда, включая виджет «5 ближайших планов» [F 14] | **Анекдот** по отзывам; функция есть у 1 продукта |
| T11 | Калибровка в плане ломается или забывается | ASIAIR: пользователь пишет, что bias не снимались в Autorun (по пересказу поиска) [D]. Руководство ZWO рекомендует включать dark, flat и bias в план [F 31]. В AstroBin-журналах калибровку записывают рядом с сессией [F 36] | **Анекдот**, с одним первоисточником-рекомендацией |
| T12 | Запрос на «время интеграции» и «сколько нужно снять» | AstroBin: демо ИИ-чата для «dithering and total integration time needed» — 0 ответов [F 45]. Пользователь Telescopius ссылается на тред о поиске целей, «которые позволяют набрать достаточно субкадров» [F 2]. Поиск называет ещё SkyPlanner и веб-«Astro Planner» с оценкой интеграции [D 41] | **Анекдот / слабая**: прямых отзывов мало |

## 4. По областям RA

### RA-A — Охват продукта (Phase A: RA-A01, A02, A03, A04, A05, A06, A07, A08, A09; K4)

**Что ожидают пользователи.**
- Сводку «что снято по цели» за много ночей и простой журнал. Сейчас это делают таблицами
  (T1) [F 36][F 37][F 2]–[F 4].
- Прогноз, которому можно доверять, со сверкой нескольких источников (T3), и ясную подачу (T4).
- Часть пользователей хочет «всё в одном» (T8) [F 24][F 9]. Это прямо противоречит направлению
  владельца «не повторять погоду и положения объектов» (K4, RA-A06). Противоречие фиксируется,
  но не решается здесь.

**Как делают лучшие.**
- Рынок разделён по задачам [I]:
  - «когда и где» — Clear Outside, Astrospheric, Scope Nights, DarkScout, Stargazing Hub
    [F 10][F 7][F 32][F 23][F 25];
  - «что и как в кадре» — Stellarium, Sky Tonight, SkySafari, Telescopius [F 17][F 18][F 20][F 1];
  - «как снимать», то есть исполнение плана у телескопа, — N.I.N.A. и ASIAIR [F 27][F 30];
  - «что снято» — таблицы, AstroBin, desktop-планировщики с журналом (AstroPlanner, Deep-Sky Planner,
    SkyTools) [F 36][F 22][F 33].
- Модель «план съёмки → оценка времени → оценка объёма → проверка выполнимости» существует, но
  внутри управляющего ПО и у телескопа. ASIAIR показывает «Estimated time» и «Estimated size»,
  чтобы проверить выполнимость [F 30]. N.I.N.A. показывает «Estimated Finish Time» [F 27].
- В просмотренных мобильных планировщиках (Telescopius, DarkScout, Sky Tonight, SkySafari,
  AstroPlan iOS) нет экрана «план кадров × выдержек → интеграция, объём, вместится ли в ночь»
  [F 1][F 23][F 18][F 20][F 40] — **[I]** по их описаниям; отсутствие функции по маркетинговому
  тексту не доказано.
- Абсолютный SNR: из найденных продуктов только SkyTools (desktop, платный) заявляет моделирование
  «detector signal-to-noise» [D 34]. Мобильного аналога не найдено [I].

**Что AstroPlan делает иначе или дублирует.**
- Ядро AstroPlan (RA-A02 Capture Plan, RA-A04 объём, RA-A05 записи) попадает в **малоосвоенную
  связку**: «план до выезда, без управления железом» плюс «журнал и сводка по цели» [I по T1 и
  матрице]. ASIAIR и N.I.N.A. считают то же самое, но в момент исполнения и с железом [F 30][F 27].
- Дублирование: детальный экран погоды (RA-A06, RA-E02/E03) пересекается с Clear Outside и
  Astrospheric. «What can I image tonight?» (RA-D06) пересекается с Telescopius, Sky Tonight и
  DarkScout [F 1][F 18][F 23]. У специализированных аналогов эти функции глубже: ансамбль моделей,
  seeing, FOV-симулятор [F 7][F 1] — [I].
- √N как относительный выигрыш (RA-A03) не имеет прямого аналога в мобильных продуктах [I]. Риск
  неправильного прочтения «примерного SNR» остаётся в R2b.

**Что разумно НЕ делать.**
- Не строить планетарий, AR-карту неба или фрейминг-симулятор с мозаиками. Это закрыто приложениями
  с миллионами установок (Stellarium 10M+, Sky Tonight 5M+) и Telescopius [F 17][F 18][F 1]. Мозаики
  и sky map и так за пределами утверждённого охвата (CLAUDE.md).
- Не строить свою модель seeing и transparency, ансамбль облачных моделей или карты засветки:
  [F 7][F 25]; ссылка на lightpollutionmap уже решена (M2).
- Не добавлять сообщество, ISS, ИИ-чат: [F 23][F 10][F 40] — вне задачи продукта [I].
- Не вводить «чёрный ящик» Astro Score или индекс 0–100 % (§4 RA-E): это запрещено CLAUDE.md
  и ADR-012, хотя у конкурентов это норма [F 23][F 25][F 18][F 32].

### RA-B — Онбординг (Phase A: RA-B01…B06)

**Что ожидают пользователи.**
- Сразу полезный экран без барьера. Аккаунт — частый источник жалоб (T6: Telescopius 4 из 8) [F 42].
- Падение на экране разрешения геолокации делает приложение непригодным (Astrospheric,
  Lockdown mode — анекдот) [F 9].
- Жалобы на сложность (T5) показывают, что мощный инструмент без входной точки отпугивает [F 15].

**Как делают лучшие.**
- DarkScout: «Start with Tonight at your current location: go/no-go guidance»; PRO показывается
  внутри онбординга [F 23].
- Clear Outside: «Location search automatically provides a forecast for your location» — без
  мастера [F 11].
- Stellarium: ценность сразу — навести телефон на небо [F 17].
- PhotoPills: первым шагом советует включить виджеты, затем «поставить цель», и даёт таблицу
  «боль → нужный инструмент» [F 14]. Это вход через задачу, а не через ввод данных.
- AstroPlan (iOS) подчёркивает «No account required» [F 40].

**Что AstroPlan делает иначе или дублирует.**
- AstroPlan уже без аккаунта, данные локальные. Это совпадает с лучшими практиками [I].
- Отличие: Welcome — отдельный экран с 3 необязательными шагами (сайт, риг, цель); RA-B04 и B05
  отмечают громоздкие описания. Перед Welcome на мгновение видна Home (RA-B01).
- Лучшие аналоги не просят риг или цель до первой ценности: DarkScout и Clear Outside начинают
  с места [F 23][F 11] — [I].
- Риг-зависимая ценность AstroPlan (интеграция, объём) требует хотя бы класса камеры. Поэтому
  «старт только с места» может отложить ядро продукта [I].

**Что разумно НЕ делать.**
- Не вводить аккаунт или вход [F 42].
- Не делать онбординг, который нельзя пропустить; не ставить пэйвол в онбординг (у DarkScout
  PRO в онбординге убран с переходом на всё бесплатное [F 23]) — [I].

### RA-D — Home (Phase A: RA-D01…D06)

**Что ожидают пользователи.**
- Быстрый ответ «стоит ли сегодня» и «что с моим планом»: T4, похвалы «quick glance» и «at a
  glance» [F 32][F 11].
- Виджеты как продолжение Home вне приложения (T10, анекдот) [F 9][F 14].

**Как делают лучшие.**
- DarkScout: Home = «Tonight», go/no-go и условия [F 23].
- SkySafari: «Tonight at a Glance» — Солнце и Луна, события месяца, лучшие DSO вечера [F 20].
- AstroPlan iOS: «Home dashboard with moon, Bortle, cloud, wind, and darkness» плюс ранжированные
  цели [F 40].
- Stargazing Hub: индекс наверху, под ним вкладки прогноза, безлунные окна, AQI, засветка [F 25].
- PhotoPills: Home — меню инструментов; ближайшие планы вынесены в виджет «5 upcoming plans» [F 14].

**Что AstroPlan делает иначе или дублирует.**
- Home AstroPlan ставит план выше ночной карточки (ADR-019 §6, порядок S6.16); погода сжата до
  облачности (RA-D03).
- Владелец хочет погоду наверх, затем вход в планировщик (RA-D03, D05). Ни один из
  «планировщиков» среди аналогов не ставит на Home собственный capture plan [I]. Ближайший образец —
  PhotoPills с «ближайшими планами» в виджете [F 14].
- Кнопка «New plan» внизу (RA-D04) аналогов не имеет. У PhotoPills новый план создаётся из
  Planner (Load/Save) [F 14] — [I].
- Контекст «Site · night» первым блоком (RA-D02) повторяет то, что погодные аналоги показывают
  заголовком места [F 10][F 7] — [I].

**Что разумно НЕ делать.**
- Не превращать Home в погодный дашборд уровня Astrospheric [F 7].
- Не ставить на Home «оценку ночи» в виде одного числа (ADR-012) — [I].

### RA-E — Погода и Луна (Phase A: RA-E01…E06, D03)

**Что ожидают пользователи.**
- Облачность прежде всего, с разбивкой по ярусам (Clear Outside, «emphasis on cloud cover») [F 10].
- Для части аудитории — seeing и transparency, включая смог [F 7][F 25]. Есть запрос на детализацию
  seeing и jet stream (анекдот) [F 9].
- Сверка моделей (T3) и честность о недоступности данных (T2).
- Ясная легенда и цвета: по Astroweather — жалоба на отсутствие ключа (анекдот) и просьба «green to
  red» [F 35].
- Луна: фаза, освещённость, восход и заход — у всех [F 10][F 7][F 13]. «Безлунные окна» —
  у Stargazing Hub [F 25]. Календарь фаз — у Sky Tonight и PhotoPills [F 18][F 13].

**Как делают лучшие.**
- **Погода.**
  - Clear Outside: 7 суток по часам, 4 строки облачности, затем обычная погода «без cutesy
    graphics» [F 10].
  - Astrospheric: почасовая сетка на 84 ч, слои облачности, transparency (со смогом) и seeing, ветер,
    температура, точка росы, линии Солнца и Луны на сетке; ансамбль моделей в Pro [F 7][F 8].
  - Stargazing Hub: индекс 0–100 % с порогами (<40 % — очень плохо, ≥85 % — отлично; советуют ≥70 %),
    горизонт 3 дня, вкладки моделей, 15 дней вне индекса [F 25].
  - DarkScout: Astro Score и почасовые решения с учётом осадков [F 23].
  - Scope Nights: рейтинги с пользовательскими порогами [F 32].
- **Покрытие.** Модель RDPS у Astrospheric по выдаче покрывает Канаду, США и часть Мексики [D 43].
  Это подкрепляет отзыв «No data available in Hawaii» [F 9].
- **Луна.**
  - Astrospheric: отдельная карточка (фаза, высота, освещённость, возраст, следующая фаза) [F 7].
  - Clear Outside: восход, заход и фаза рядом с периодами темноты [F 10].
  - Stargazing Hub: «Moonless Night» прямо под индексом [F 25].

**Что AstroPlan делает иначе или дублирует.**
- AstroPlan показывает 11 почасовых переменных Open-Meteo без seeing и transparency (RA-E02/E03).
  Состояния свежести и «нет прогноза» уже есть (RA-E05, ADR-012).
- Отказ от оценки и от раскраски «хорошо/плохо» — осознанное отличие от DarkScout, Stargazing Hub,
  Scope Nights и Sky Tonight [F 23][F 25][F 32][F 18]. Отзывы T4 показывают, что ценят ясность
  и легенду, а не обязательно оценку [I].
- Луна в AstroPlan — «MoonDuringDark» без названия фазы и без календаря (RA-E01). Аналоги всегда
  показывают фазу и процент [F 7][F 10]. Окна «тёмного без Луны» явно показывает Stargazing Hub [F 25].
- Прогноз, сохранённый в снимке плана, нигде не показывается (RA-E06). У аналогов связки «прогноз
  ↔ запись» не найдено [I].

**Что разумно НЕ делать.**
- Не гнаться за ансамблем моделей и собственным seeing (Astrospheric — профильный продукт со
  своими моделями) [F 7].
- Не делать погоду, которая без провайдера ломает приложение (T2) [F 32]. Офлайн-ядро AstroPlan —
  преимущество; его стоит сохранить [I].
- Не вводить число-индекс (ADR-012).
- Источники seeing и transparency (7Timer и другие), их лицензии и отказы — предмет R2c, а не R2a.

### RA-F — Планировщик и Capture Plan (Phase A: RA-F01…F11)

**Что ожидают пользователи.**
- Знать заранее, сколько субкадров реально набрать по цели [F 2] и итог по цели за несколько
  ночей (T1).
- Калибровку держат рядом с лайтами [F 36][F 31].
- Прямых массовых отзывов о «калькуляторе интеграции» нет (T12 — слабая тема).

**Как делают лучшие (модель плана).**
- **N.I.N.A., Sequence.** Строки содержат Total #, Time, Type (BIAS/DARK/LIGHT/FLAT), Filter,
  Binning, Dither и Dither every #, Gain, Offset (только если камера поддерживает) [F 27].
  - Новая строка «defaulted to the previous one» [F 27].
  - Режимы «One after another» и «Loop» (чередование фильтров) [F 27].
  - «Estimated Finish Time» учитывает число и длину кадров плюс время скачивания [F 27].
  - Продвинутый секвенсор: контейнеры начала, цели и конца; условия вида «Loop Until Time»
    (например, до навигационного рассвета); один dither на цикл фильтров [F 28][F 29].
- **ASIAIR.**
  - Autorun хранит имя цели, «Group by Slot», «Estimated time» и «Estimated size», которые «help you
    check the feasibility» [F 30].
  - Руководство Plus рекомендует включать в план dark, flat, bias и light [F 31].
  - Plan mode — несколько целей подряд [F 31].
- **PhotoPills.** Калькуляторы (Spot Stars и другие) отделены от Planner; сохранённые планы живут
  в «My Stuff» [F 14].

**Что AstroPlan делает иначе или дублирует.**
- Модель блоков AstroPlan (тип, фильтр, выдержка × кол-во, ISO/gain, биннинг, накладные расходы,
  объём, вместимость в ночь) по структуре совпадает с N.I.N.A. и ASIAIR. Это подтверждает
  выбранную модель (RA-A02, RA-F01) — [I].
- Совпадение с отраслевым образцом: предзаполнение нового light-блока из предыдущего (RA-F05,
  ADR-020 P2) делает и N.I.N.A. [F 27]. Это не довод «за» или «против» жалобы владельца, но
  прецедент.
- Наследование калибровки от лайтов (RA-F08) соответствует рекомендации ZWO держать калибровку
  в плане [F 31].
- Оценка объёма (RA-A04) есть у ASIAIR [F 30]. Среди мобильных планировщиков такой оценки не
  найдено [I].
- Binning и ISO/Gain для класса Unknown (RA-F06): N.I.N.A. показывает Gain и Offset только при
  поддержке камерой [F 27]. Принцип «показывать по возможностям камеры» общий — [I].
- Накладные расходы и Assumptions (RA-F09, H02): N.I.N.A. берёт время скачивания из измерений
  [F 27]; AstroPlan берёт его из настроек. Пользователь AstroPlan вводит допущения сам — [I].
- Пример плана (RA-F04): аналога «вставить пример плана» не найдено [I].

**Что разумно НЕ делать.**
- Не повторять секвенсор: условия, триггеры, автофокус, dither как команду, слежение за высотой
  в реальном времени. Это управление железом [F 28], а AstroPlan — не контроллер (RA-F11).
- Не обещать абсолютный SNR без модели уровня SkyTools [D 34]. Выбор варианта — за R2b.
- Сделать WB или фокус «про-режима» полем ввода — вопрос R2b (RA-F07). Аналоги-планировщики
  таких полей не имеют [I].

### RA-G — Записи, журнал и списки (Phase A: RA-G01…G05)

**Что ожидают пользователи.**
- Сумма интеграции по цели за все ночи; связь калибровочных наборов с сессиями; список «хочу
  снять» отдельно от «снято»; фильтр по цели или фильтру [F 36].
- Простота многоночного учёта (опрос AstroBin) [F 37].
- Возможность выгрузить данные: таблица, AstroBin [F 36][F 38].

**Как делают лучшие.**
- В таблицах пользователей (AstroBin): две вкладки «сессии» и «будущие цели»; авто-сумма «Total
  Exposure / Integrated Exposure»; список оборудования как справочник [F 36].
- Telescopius: списки целей с заметками; фильтр «Exclude objects on these lists», чтобы скрыть
  уже снятое. Лимит заметки разработчик называет то 300, то 1000 символов [F 2][F 3][F 4].
- AstroPlanner и Deep-Sky Planner: сессии → наблюдения, менеджер оборудования; у DSP — обмен по
  **OpenAstronomyLog** и бэкап [F 22][F 36][F 33].
- Nova DSO Tracker: «Projects» со статусами (In Progress / On Hold / Completed / Abandoned),
  авто-сумма интеграции, импорт логов ASIAIR, PHD2 и N.I.N.A. [F 39].
- AstroBin принимает CSV приобретения: date, filter (ID), number, duration, iso, binning, gain,
  sensorCooling, darks, flats, flatDarks, bias, bortle, meanSqm, meanFwhm, temperature [F 38].

**Что AstroPlan делает иначе или дублирует.**
- Logbook (Upcoming/Past, фильтры, Plan vs actual) и Progress by target (RA-G01) закрывают T1
  ближе, чем любой просмотренный мобильный аналог [I].
- Пробелы относительно ожиданий:
  - экспорт одной записи и Copy спрятаны в детали (RA-G04);
  - формата «AstroBin CSV» или OAL нет — по Phase A есть свой экспорт v2 [I];
  - в Library «Plan this target» спрятан (RA-G02); у Telescopius путь «из списка в планирование»
    прямой [F 4] — [I].

**Что разумно НЕ делать.**
- Не строить сообщество или галерею (AstroBin, Telescopius) [F 1].
- Не повторять разбор логов N.I.N.A. и ASIAIR в первом релизе. Существует отдельный инструмент
  [F 39]; эта работа требует отдельного решения об охвате [I].

### RA-H — Настройки (Phase A: RA-H01…H03)

**Что ожидают пользователи.**
- Единицы измерения (PhotoPills: Settings > Units) [F 14].
- Свои пороги «хорошей ночи» (Scope Nights, DarkScout) [F 32][F 23].
- Возможность отключить ненужный слой данных (смог у Astrospheric — анекдот) [F 9].
- Место по умолчанию (Clear Outside: «defaults to England», «no settings» — анекдот) [F 11].
- Тёмный или ночной режим: красный режим есть у Stellarium, Sky Tonight, DarkScout и
  Stargazing Hub [F 17][F 18][F 23][F 24].

**Как делают лучшие.**
- Настройки обычно короткие: единицы, бэкап и синхронизация, уведомления [F 14].
- Сложность переносится в объекты, а не в глобальные настройки: пороги — к месту или к
  оповещению [F 23][F 32] — [I].

**Что AstroPlan делает иначе или дублирует.**
- 17 строк, большая часть — накладные расходы и пороги окна съёмки (RA-H01). Владелец и Phase A
  отмечают, что часть зависит от рига или монтировки (RA-H02). У аналогов-исполнителей это свойства
  профиля или последовательности: Gain и Offset в строке, время скачивания измеряется [F 27] — [I].
- Нет выбора темы и единиц (RA-H03). У аналогов единицы — стандартная настройка [F 14].
- Красный режим в AstroPlan есть (TASK 12.4, по памяти проекта; в Phase A отдельно не проверялся).

**Что разумно НЕ делать.**
- Не превращать настройки в хранилище научных допущений, которые пользователь не понимает (T5) —
  [I].

## 5. Следствия для пакета решений (только варианты, без решений)

1. **Позиционирование (RA-A06, K4).**
   - Вариант A: «capture plan + журнал» как ядро; погода и Луна — короткая сводка со ссылкой на
     внешние приложения.
   - Вариант B: оставить текущий объём погоды и кандидатов, но понизить их в иерархии.
   - Вариант C: двигаться к «всё в одном» (T8).
   Довод за A — незанятая ниша [I] и прямое направление владельца. Довод за C — отзывы T8. Риск C —
   конкуренция с продуктами на миллионы установок [F 17][F 18].
2. **Погода на Home (RA-D03, E02).**
   - Вариант W1: облачность по ярусам и окно темноты в стиле Clear Outside, без оценки.
   - Вариант W2: то же плюс обзор на несколько ночей. Многоночный прогноз есть у всех погодных
     аналогов [F 10][F 32][F 23].
   - Вариант W3: только ссылка или «Open in…».
   Индекс 0–100 % в стиле Stargazing Hub или DarkScout требует пересмотра ADR-012. Это отдельный
   вопрос владельцу; по CLAUDE.md он скорее закрыт.
3. **Луна (RA-E01).**
   - Вариант L1: фаза, процент освещённости, восход и заход (стандарт) [F 7][F 10].
   - Вариант L2: плюс «безлунное тёмное окно» сегодня [F 25].
   - Вариант L3: плюс месячный календарь [F 18][F 13].
   Научная часть и стоимость расчёта — в R2b и R2c.
4. **Онбординг (RA-B01…B06).**
   - Вариант O1: старт сразу на Home по месту, остальное — по требованию (DarkScout, Clear Outside)
     [F 23][F 11].
   - Вариант O2: текущие 3 шага, но короче и с одной кнопкой.
   - Вариант O3: вход через «задачу», как в PhotoPills [F 14].
   Во всех вариантах — без аккаунта (T6).
5. **Планировщик (RA-F05, F06, F09).** Отраслевые прецеденты: наследование предыдущей строки
   [F 27]; поля по возможностям камеры [F 27]; оценка времени и объёма для проверки выполнимости
   [F 30]; калибровка в плане [F 31]. Варианты для RA-F05: оставить P2 (как N.I.N.A.), сделать
   предзаполнение визуально «предложенным» или убрать его. Выбор — R2b и R2e.
6. **Записи (RA-G01, G02, G04).**
   - Вариант R1: усилить «итог по цели» и связь калибровки с сессией (T1).
   - Вариант R2: добавить экспорт в формате AstroBin CSV [F 38] или OpenAstronomyLog [F 33]
     (переиспользование стандарта, RA-A09). Требует проверки соответствия полей и решения о
     формате экспорта (`docs/EXPORT_MANIFEST.md` версионируется).
   - Вариант R3: оставить как есть.
7. **Настройки (RA-H02, H03).**
   - Вариант S1: перенести накладные расходы, зависящие от рига, в риг или монтировку.
   - Вариант S2: добавить единицы и тему.
   - Вариант S3: пороги окна держать рядом с местом.
   Каждый меняет модель данных (вход для R2b, R2e).
8. **Чего не делать (сводно):** планетарий и AR; фрейминг и мозаики; собственный seeing и
   ансамбль моделей; карты засветки; сообщество; ИИ-чат; управление железом; индекс-оценка.
   Обоснования — §4.
9. **Риск названия (для R2d, без вывода):** коллизии «AstroPlan» (iOS, 2026), «AstroPlanner»
   (iLanga), «Astro Planner» (DarkScout, AstroBin) — §2, примечание 2.
10. **Пробел доказательств (K14):** темы отзывов не заменяют проверку UX самого AstroPlan живыми
    людьми. Reddit и Cloudy Nights не прочитаны (§1).

## 6. Источники (дата обращения для всех: 2026-10-17)

1. Telescopius — App Store (описание через Lookup API): https://apps.apple.com/us/app/telescopius/id6479415751 ; https://itunes.apple.com/lookup?id=6479415751&country=us
2. Telescopius Forum, «I want to See Enhanced Planning Tools for Astrophotography Sessions» (07–08.2025): https://forum.telescopius.com/t/i-want-to-see-enhanced-planning-tools-for-astrophotography-sessions/1847
3. Telescopius Forum, «Imaging Tracker» (08.2025): https://forum.telescopius.com/t/imaging-tracker/1863
4. Telescopius Forum, «Catalog / Shooting tracking» (10.2025): https://forum.telescopius.com/t/catalog-shooting-tracking/1894
5. Telescopius Forum, «Imaging Opportunities» (08–11.2025): https://forum.telescopius.com/t/imaging-opportunities/1864
6. Patreon разработчика Telescopius (только через поисковую выдачу, [D]): https://www.patreon.com/sebagr/about
7. Astrospheric — официальный сайт: https://www.astrospheric.com/ ; https://www.astrospheric.com/help
8. Astrospheric — Google Play: https://play.google.com/store/apps/details?id=com.astrospheric.dfior.astrospheric
9. Astrospheric — отзывы App Store (RSS, последние 50): https://itunes.apple.com/us/rss/customerreviews/page=1/id=1166046863/sortby=mostrecent/json
10. Clear Outside — страница приложения: https://clearoutside.com/page/app/
11. Clear Outside — Google Play: https://play.google.com/store/apps/details?id=com.firstlightoptics.clearoutside
12. Clear Outside — App Store (Lookup и RSS): https://itunes.apple.com/lookup?id=6755946435&country=us ; https://itunes.apple.com/us/rss/customerreviews/page=1/id=6755946435/sortby=mostrecent/json
13. PhotoPills — Google Play: https://play.google.com/store/apps/details?id=com.photopills.android.photopills
14. PhotoPills User Guide: https://www.photopills.com/user-guide
15. PhotoPills — отзывы App Store (RSS): https://itunes.apple.com/us/rss/customerreviews/page=1/id=596026805/sortby=mostrecent/json
16. Stellarium Mobile Plus — Stellarium Labs: https://stellarium-labs.com/stellarium-mobile-plus/
17. Stellarium — Google Play: https://play.google.com/store/apps/details?id=com.noctuasoftware.stellarium_free
18. Sky Tonight — Google Play: https://play.google.com/store/apps/details?id=com.vitotechnology.sky.tonight.map.star.walk
19. Sky Tonight — отзывы App Store (RSS): https://itunes.apple.com/us/rss/customerreviews/page=1/id=1570594940/sortby=mostrecent/json
20. SkySafari — официальный сайт: https://skysafariastronomy.com/
21. SkySafari 8 Pro — Google Play: https://play.google.com/store/apps/details?id=com.simulationcurriculum.skysafari8pro
22. AstroPlanner (iLanga, Inc.): https://www.astroplanner.net/ ; https://www.astroplanner.net/about.html ; https://www.astroplanner.net/purchase.html (цена не отображается — шаблон не заполнен)
23. DarkScout — App Store (описание, история версий): https://apps.apple.com/us/app/darkscout/id6760223860
24. Stargazing Hub: Astro Guide (`com.twtapp`) — Google Play: https://play.google.com/store/apps/details?id=com.twtapp ; App Store: https://itunes.apple.com/lookup?id=1478601599&country=us
25. Stargazing Hub — руководство по Stargazing Index (EN и CN): https://laysky.com/en/guide/miniapp/stargazing-index.html ; https://laysky.com/guide/miniapp/stargazing-index.html
26. Stargazing Hub / 天文通 — сайт разработчика: https://laysky.com/en/
27. N.I.N.A. Documentation — Sequence tab: https://nighttime-imaging.eu/docs/master/site/tabs/sequence/
28. N.I.N.A. Documentation — Advanced Sequencer: https://nighttime-imaging.eu/docs/master/site/sequencer/advanced/advanced/
29. N.I.N.A. Documentation — Simple to Advanced: https://nighttime-imaging.eu/docs/master/site/sequencer/advanced/simpletoadvanced
30. ZWO ASIAIR User Manual (раздел 4.9 Autorun): https://i.zwoastro.com/zwo-website/manuals/ZWO_ASIAIR_User_Manual.pdf
31. ZWO ASIAIR Plus User Manual V1.3 (разделы 3.3.6–3.3.9): https://i.zwoastro.com/wp-content/uploads/2026/03/65dcf5cda6be810ffda56fcaed20a573.pdf
32. Scope Nights Astronomy Weather — App Store (Lookup и RSS): https://itunes.apple.com/lookup?id=540120977&country=us ; https://itunes.apple.com/us/rss/customerreviews/page=1/id=540120977/sortby=mostrecent/json
33. Deep-Sky Planner 9 (Knightware): https://www.knightware.biz/dsp/index.htm
34. SkyTools (Skyhound): https://skyhound.com/skytools.html
35. Astroweather (клиент 7Timer) — Google Play: https://play.google.com/store/apps/details?id=cc.meowssage.astroweather
36. AstroBin Forum, «Do you keep a logbook of your imaging?» (03.2023, стр. 1 из 3): https://app.astrobin.com/forum/topic/66070
37. AstroBin Forum, «Poll: How do you enter all of your acquisition details when captured across multiple nights?» (10.2024): https://app.astrobin.com/forum/topic/143290
38. AstroBin — «Importing acquisitions from CSV»: https://welcome.astrobin.com/importing-acquisitions-from-csv
39. Nova DSO Tracker — Docker Hub: https://hub.docker.com/r/mrantonsg/nova-dso-tracker
40. AstroPlan (iOS, Project 2022 Ltd) — App Store: https://apps.apple.com/us/app/astroplan/id6774190371 ; https://itunes.apple.com/lookup?id=6774190371&country=us
41. Cloudy Nights — треды о погодных приложениях (**недоступны**, 403 Cloudflare; использована только поисковая выдача, [D]): https://www.cloudynights.com/forums/topic/887387-how-reliable-are-weather-apps/ ; https://www.cloudynights.com/forums/topic/876926-reliable-cloud-forecast/ ; https://www.cloudynights.com/forums/topic/973095-weather-apps-for-observation/ ; https://www.cloudynights.com/forums/topic/873149-what-weather-app-would-you-recommend/ ; веб-инструмент «Astro Planner» на AstroBin (не открылся): https://app.astrobin.com/forum/topic/216286
42. Telescopius — отзывы App Store (RSS, 8 шт.): https://itunes.apple.com/us/rss/customerreviews/page=1/id=6479415751/sortby=mostrecent/json
43. Покрытие модели RDPS у Astrospheric (по поисковой выдаче, [D]); на сайте Astrospheric: «Forecast data provided by the Canadian Meteorological Centre»: https://www.astrospheric.com/DynamicContent/astrospheric.php
44. iTunes Search API (цены, рейтинги, даты версий): https://itunes.apple.com/search?term=photopills&entity=software&country=us (аналогично для остальных названий)
45. AstroBin Forum, «Astrophotography App for dithering and integration time needed» (09.2024, 0 ответов): https://app.astrobin.com/forum/topic/137614

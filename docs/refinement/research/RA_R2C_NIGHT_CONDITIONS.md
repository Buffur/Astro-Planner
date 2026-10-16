# RA.R2c — Ночные условия: погода и Луна (R2, R3 — подача)

> Исследование для RA.R2, шаг R2c ([план](../prompts/RA_R2_RESEARCH_PLAN.md) §3 «R2c»), 2026-10-17.
> Охват: RA-E01, E02, E03, E05, E06 и погодная часть RA-D03 ([Phase A](RA_R1_PHASE_A_ASSESSMENT.md)).
> **Только исследование.** Ничего здесь не решено. Каждый вариант в §7 — вход для RA.D. Новый
> провайдер возможен только как вариант для решения владельца (ADR-012 §2, trap 22).
> Метки: **FACT** — проверено по первичному источнику или замеру (URL или `file:line`, дата
> обращения 2026-10-17); **INFERENCE** — вывод агента; **ПО ОПИСАНИЮ** — вторичный источник или
> форум, не подтверждено.

## 1. Метод

- **Базовая линия кода не перепроверялась целиком.** Взяты строки Phase A RA-E01…E06 и D03.
  Выборочно прочитаны только места, нужные для оценок:
  - `lib/data/repositories/open_meteo_weather_repository.dart` — запрос (`start_hour..end_hour`
    одной ночи, `models=best_match`, горизонт 16 дней);
  - `lib/data/services/open_meteo_forecast_parser.dart:15-27` — 11 часовых переменных;
  - `lib/domain/repositories/weather_snapshot_store.dart` — ключ кэша: сайт, модель и ночь;
  - `lib/domain/models/night_weather.dart:17-27` — `WeatherFreshness` 3 ч / 12 ч;
  - `lib/domain/services/moon_calculator.dart:410-470` — сетка 5 мин, rise/set, `conditionsForNight`;
  - `lib/domain/services/moon_calculator.dart:385-390` — `phaseLongitudeDeg` уже есть;
  - `lib/domain/models/moon_conditions.dart:80-148` — `MoonDuringDark`, CALC-43;
  - `lib/domain/services/visibility_calculator.dart:171` — `sampleStep` 5 мин;
  - `lib/domain/models/session_night.dart:37` — длина ночи 24 ч;
  - `lib/presentation/viewmodels/night_conditions_viewmodel.dart:180-192` — Луна считается
    синхронно в ViewModel и кэшируется по ключу;
  - `lib/presentation/viewmodels/candidates_viewmodel.dart:40` — образец `Isolate.run`.
- **Решения:** ADR-010, ADR-012 и ADR-013 (`docs/DECISIONS.md`). CALC-32 и CALC-43, а также запись
  S1.13 / SCI-03 (`docs/SCIENTIFIC_INTEGRITY.md`). Privacy и COMPLIANCE. Trap 22
  (`docs/ENGINEERING_GUARDRAILS.md`).
- **Замеры у провайдеров (FACT, 2026-10-17):** выполнено несколько ручных HTTP-запросов `curl`
  к публичным API. Координаты — нейтральная точка Гринвич (51.48, 0.0), не данные пользователя.
  Ответы хранились во временном каталоге сессии, в репозиторий не попали. Сборка, тесты и код
  приложения не запускались.
- **Moonlit:** читались только `README.md`, `index.html`, фрагменты `app.js` и `astronomy.js`,
  перечень `vendor/`. Ничего не исполнялось. Файла лицензии в корне нет (FACT: `ls` корня; есть
  только `vendor/*-LICENSE.txt`). Переносится **только концепт**.
- **Веб:** WebSearch и WebFetch. Цитаты короче 15 слов. Отзывы и форумы помечены как анекдот.

## 2. Значимые параметры ночи

| Параметр | Почему важен для съёмки | Источник | Есть в AstroPlan сейчас |
| --- | --- | --- | --- |
| **Облачность общая** | Главный фактор «можно ли снимать». Модельная доля площади, а не вид неба. Точность падает с упреждением: у CMC при «в основном ясно» ≈80 % верных прогнозов до 12 ч и ≈76 % на 36–48 ч; дальше 48 ч точность неизвестна (FACT, Clear Sky Chart key) | [CSC key](https://www.cleardarksky.com/c/WAkey.html); [Open-Meteo docs](https://open-meteo.com/en/docs) | Да; на Home — диапазон и возраст |
| **Облачность по ярусам** (low < 3 км, mid 3–8 км, high > 8 км) | Тонкие высокие облака портят снимок даже при малой общей облачности (ADR-012 §3). Частичная облачность в двух ярусах может закрыть всё небо (FACT, meteoblue) | [Open-Meteo docs](https://open-meteo.com/en/docs); [meteoblue seeing help](https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing) | Да, в деталях |
| **Осадки** (вероятность) | Риск для оборудования. В Open-Meteo это вероятность > 0,1 мм за **предыдущий** час. Значение всегда берётся из ансамблей (GFS, ICON, IFS) (FACT) | [Open-Meteo docs](https://open-meteo.com/en/docs) | Да |
| **Ветер и порывы** | Ветер не решает, можно ли наблюдать, но для длиннофокусной съёмки нужен слабый ветер (FACT, CSC). На практике ветер срывает гидирование и раскачивает гид-трубу и кабели (ПО ОПИСАНИЮ: форумы AstroBin, [astropix](https://astropix.com/html/astrophotography/phd2_autoguiding.html)). Порыв в Open-Meteo — максимум за предыдущий час | [CSC key](https://www.cleardarksky.com/c/WAkey.html); [AstroBin](https://app.astrobin.com/forum/topic/84913/phd2-not-giving-sufficient-corrections-causing-severe-star-trails) | Да, в деталях |
| **Влажность и точка росы** | Риск росы на оптике. Роса вероятнее при ясном небе, падающей температуре и слабом ветре, и она не сводится к одной влажности (FACT, CSC). В AstroPlan это эвристика CALC-32: T − Td ≤ запас. Подписана как эвристика | [CSC key](https://www.cleardarksky.com/c/WAkey.html); CALC-32 | Да, в деталях |
| **Температура** | Охлаждение толстых зеркал и токи в трубе; ёмкость батарей на холоде (FACT, CSC). Уход фокуса при изменении температуры: пользователи N.I.N.A. ставят перефокусировку на ΔT ≈ 1 °C, но сами называют порог произвольным (ПО ОПИСАНИЮ, [AstroBin](https://app.astrobin.com/forum/topic/186916/autofocus-questions)) | [CSC key](https://www.cleardarksky.com/c/WAkey.html) | Да |
| **Seeing** (турбулентность, ″) | Ограничивает мелкие детали. Мало связан с водяным паром, поэтому хороший seeing часто совпадает с плохой прозрачностью (FACT, CSC). Шкала CSC откалибрована под инструменты 11–14″. **INFERENCE:** масштаб = 206,265 × пиксель (µм) / фокус (мм). У телефона (≈6,5 мм, 1,2 µм) ≈38″/px, у DSLR с объективом 50 мм и пикселем 4,3 µм ≈18″/px. Оба много больше seeing 1–3″. Seeing существенен только для длинного фокуса: при 500 мм и пикселе 4 µм это ≈1,7″/px | [CSC key](https://www.cleardarksky.com/c/WAkey.html); [meteoblue](https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing) | **Нет:** ни одна переменная Open-Meteo его не даёт (ADR-012 §3) |
| **Transparency** (прозрачность столба) | Глубина и контраст снимка. У CSC прозрачность считается из полного количества водяного пара, без дыма. При облачности > 30 % CSC её не прогнозирует (FACT) | [CSC key](https://www.cleardarksky.com/c/WAkey.html) | **Нет.** Горизонтальная видимость сознательно не выдаётся за прозрачность (ADR-012 §8) |
| **Дым и аэрозоль (AOD)** | Любой дым, кроме «нет дыма», вероятно снижает прозрачность (FACT, CSC: строка Smoke, модель FireWork). В Astrospheric дым входит в Transparency, источник — модель RAP (FACT) | [CSC key](https://www.cleardarksky.com/c/WAkey.html); [Astrospheric](https://www.astrospheric.com/DynamicContent/astrospheric.php) | Нет |
| **Струйное течение** (ветер ≈ 200–250 гПа) | Признак плохого seeing. По meteoblue плохой seeing обычно бывает при скорости > 35 м/с и < 5 м/с. Это эмпирическое правило провайдера, не физический порог | [meteoblue](https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing) | Нет |
| **Lifted index / CAPE** | Неустойчивость атмосферы: конвекция, грозы. Входит в 7Timer ASTRO. Для ночной съёмки вторично (INFERENCE) | [7Timer doc](https://www.7timer.info/doc.php?lang=en) | Нет |
| **Луна** | Освещённость и время над горизонтом в тёмный период. Это факт, а не «влияние» (ADR-010) | CALC-28 и CALC-43 | Да: «Moon up X of Y dark» |

**Вывод (INFERENCE).** У AstroPlan уже есть все «наземные» параметры, которые показывают Clear
Outside и Clear Sky Chart:
- облачность по ярусам;
- осадки;
- ветер и порывы;
- температура, точка росы и влажность;
- видимость.

Clear Outside показывает тот же набор строк (FACT, [clearoutside.com/forecast](https://clearoutside.com/forecast/51.48/0.00)).
Пробел не в данных, а в подаче. Данные запрашиваются только на одну ночь, на Home из них видна
только облачность (RA-E02, E03).

Чего нет совсем: seeing, transparency, дыма и AOD. Seeing важен только для длиннофокусных
установок. Для класса «телефон/DSLR широкоугольно» он вторичен (INFERENCE, масштаб выше).

## 3. Матрица провайдеров

| Провайдер | Данные | Лицензия и условия | Стоимость | Атрибуция | Приватность (что уходит) | Поведение при отказе и надёжность |
| --- | --- | --- | --- | --- | --- | --- |
| **Open-Meteo Forecast** (текущий) | 11 переменных ADR-012, ежечасно, до 16 дней, `best_match`. **Доступны без нового провайдера** (FACT, замер 2026-10-17, 384 ч): `total_column_integrated_water_vapour`, `wind_speed_250hPa` и `wind_speed_200hPa`, `cape`, `boundary_layer_height`. `lifted_index` для `best_match` в точке замера — все 384 значения null. Seeing и transparency нет | Бесплатно для некоммерческого использования. Определение — «без подписок и рекламы». Лимиты: < 10 000 в сутки, 5 000 в час, 600 в минуту, 300 000 в месяц. Запрос с > 10 переменных или > 2 недель считается дробно, например 1,5 вызова (FACT, [terms](https://open-meteo.com/en/terms), [pricing](https://open-meteo.com/en/pricing)) | 0 при текущей модели (free, no ads) | CC BY 4.0, «Weather data by Open-Meteo.com» уже показывается | Координаты сайта и интервал времени. IP-адреса и координаты в логах хранятся 90 дней (FACT, terms) | SLA нет: бесперебойность не гарантируется, злоупотребления блокируются (FACT, terms). Отказы уже обработаны: Unavailable, Malformed, OutOfRange, кэш с возрастом (RA-E05) |
| **Open-Meteo Air Quality** (тот же оператор, другой хост `air-quality-api.open-meteo.com`) | `aerosol_optical_depth` (550 нм) и `dust` из CAMS global: 0,4° (≈45 км), 3-часовой шаг, прогноз 5 дней, обновление каждые 12 ч (FACT, [docs](https://open-meteo.com/en/docs/air-quality-api)). Замер: 168 ч в ответе, последние 35 — null (≈5 дней) | Те же условия Open-Meteo | 0 | Нужна атрибуция **CAMS** и ссылка на Open-Meteo (FACT, docs) | Те же координаты, но **новый хост и новое поле** → обновить privacy и COMPLIANCE (trap 22) | Как у Open-Meteo. Горизонт 5 дней короче 16 → в остальные ночи «нет данных» |
| **7Timer! ASTRO** | Облачность, seeing и transparency (коды 1–8; seeing < 0,5″ … > 2,5″; transparency в mag/airmass), lifted index, RH, ветер 10 м, тип осадок, T. Модель — GFS, обновление 4 раза в сутки (FACT, [doc](https://www.7timer.info/doc.php?lang=en)). **Замер:** шаг 3 ч, 24 точки = 72 ч; поле `init` = время прогона (UTC); ответ 5,3 КБ; HTTPS работает; ключ не нужен | Данные бесплатны, использование и распространение разрешены для **некоммерческих** целей. Разработчиков просят уведомить оператора. Использование — на свой риск (FACT, doc) | 0 | Оператор: Shanghai Astronomical Observatory, CAS. Формальной строки атрибуции нет; разумно указать «7Timer!» (INFERENCE) | **Новый получатель** (Китай): координаты до 0,001° и IP. Политику конфиденциальности оператора найти не удалось (пробел в доказательствах) | SLA нет. Были многодневные «замороженные» данные: сбои дисков и межсетевого экрана (ПО ОПИСАНИЮ: [форум 2014](https://www.iceinspace.com.au/forum/showthread.php?p=1059455), [блог оператора](https://y234.cn/?p=508)). В трекере 2 открытые задачи, последняя от 2020 г. (FACT, [GitHub](https://github.com/Yeqzids/7timer-issues/issues)). Независимой валидации seeing и transparency не найдено. Свежесть нужно считать от `init`, а не от времени загрузки (INFERENCE) |
| **Meteoblue** | Seeing в ″, индексы Seeing 1/2, «bad layers» (градиент > 0,5 K на 100 м), струйное течение, облака по трём ярусам (FACT, [help](https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing)). На сайте бесплатно на 3 дня, с point+ — на 7 дней | В API **пакета seeing не найдено**. Free Weather API: 10 млн кредитов в год, ≈2 500 вызовов, коммерческое использование разрешено; пакеты Basic, Air (CAPE, LI), Clouds/Trend; пакет Sun & Moon недоступен (FACT, [free API](https://business.meteoblue.com/products/weather-apis/free-weather-api)). Платные API — от 2 400 € в год (FACT, [pricing](https://business.meteoblue.com/pricing)). Seeing есть в потребительском point+ и в виджете-iframe | Платно для seeing | Ссылка meteoblue в виджете; условия не прочитаны | Координаты и ключ API. Виджет-iframe потребовал бы WebView и сторонние запросы | Неприменим: seeing через API не подтверждён |
| **Astrospheric** | Облачность, transparency с дымом (RAP), seeing по модели Rahill, точка росы. По описанию — модели CMC/RDPS (Северная Америка) | API только с **Astrospheric Professional**. На странице есть баннер о непроизводственных эндпойнтах; «All rights reserved» (FACT, [api info](https://www.astrospheric.com/dynamiccontent/api_info.php)) | Подписка пользователя | — | Ключ и координаты | Неприменим: ключ платной подписки и неясные условия |
| **ECCC / CMC (RDPS)**: seeing и transparency, источник Clear Sky Chart и Photo Ephemeris | Индексы seeing и sky transparency: GRIB2, 10 км, ежечасно до 84 ч, на повёрнутой сетке RDPS (ПО ОПИСАНИЮ: [рассылка MSC Datamart](https://comm.collab.science.gc.ca/mailman3/hyperkitty/list/dd_info@comm.collab.science.gc.ca/thread/BH3KXVL63I2TJJCQYJUQVRITVGPY7NCO/)). Покрытие: Северная Америка и север Европы (ПО ОПИСАНИЮ, [Photo Ephemeris](https://photoephemeris.com/articles/new-seeing-and-transparency-forecasts)) | ECCC Data Server End-use Licence, коммерческое использование разрешено, атрибуция обязательна (FACT, [licence](https://eccc-msc.github.io/open-data/licence/readme_en/)) | 0 | «Data Source: Environment and Climate Change Canada» | Скачиваются целые GRIB2-файлы: точечного API нет | Неприменим без собственного сервера. Покрытие не глобальное |
| **MET Norway Locationforecast** | Глобальный прогноз на 9 дней (FACT, [docs](https://api.met.no/weatherapi/locationforecast/2.0/documentation)). Seeing нет | CC BY 4.0, обязательный User-Agent, ≤ 20 запросов/с. Браузерам и мобильным приложениям рекомендован **собственный прокси** (FACT, [ToS](https://api.met.no/doc/TermsOfService)) | 0 | CC BY 4.0 | — | Неприменим напрямую: нужен прокси, бэкенда у AstroPlan нет |
| **Clear Outside** (только ссылка) | 7 дней ежечасно: ярусы облаков, видимость, туман, осадки, ветер, точка росы, влажность, Луна. Работает на «Meteosource Weather API» (FACT, [страница прогноза](https://clearoutside.com/forecast/51.48/0.00)). Экспериментальный seeing — из 7Timer (ПО ОПИСАНИЮ, [SGL](https://stargazerslounge.com/topic/340555-clear-outside-update)) | Публичного API нет | — | — | Только при открытии ссылки самим пользователем. Координаты попадают в URL, как у lightpollutionmap.app | Отказ — внешняя страница не открылась; приложение не затронуто |

**Вывод (INFERENCE).**
- **Open-Meteo остаётся единственным реалистичным источником** для многодневного обзора: ничего
  не меняется в лицензии, приватности и стоимости.
- **Единственный бесплатный точечный JSON-источник seeing и transparency** с глобальным покрытием —
  7Timer!. Его ограничения:
  - горизонт 72 ч, шаг 3 ч;
  - грубые коды на основе GFS;
  - условие «некоммерческое использование»;
  - нет SLA и нет найденной политики приватности;
  - нет независимой валидации.
- Meteoblue, Astrospheric, ECCC и MET Norway отпадают по условиям, цене или архитектуре: нет
  бэкенда, ключа, точечного API.

## 4. Многодневный обзор

### 4.1. Один запрос на 16 дней (FACT, замер 2026-10-17)

| Запрос (те же 11 переменных, `best_match`, `timeformat=unixtime`) | Ответ | gzip | Часы | null в хвосте |
| --- | --- | --- | --- | --- |
| Одна ночь (`start_hour..end_hour`, как сейчас) | 1 539 Б | — | ≈16 | — |
| `forecast_days=16` | **21 878 Б** | **6 181 Б** | 384 | 9 ч у большинства переменных; `precipitation_probability` — 21 ч (с часа 363); `visibility` — 11 ч |

- **Учёт вызовов:** по правилу Open-Meteo 11 переменных за 16 дней ≈ 11/10 × 16/14 ≈ **1,26
  вызова** (INFERENCE по [pricing](https://open-meteo.com/en/pricing)). Сейчас ночь стоит 1,1
  вызова, и смена ночи вызывает новый запрос. С обзором смена ночи в пределах горизонта не
  требует запроса, так что общее число вызовов **снижается** (INFERENCE).
- **Сжатие:** `autoUncompress` в `dart:io` по умолчанию `true` (FACT,
  [api.dart.dev](https://api.dart.dev/dart-io/HttpClient/autoUncompress.html)). Что клиент по
  умолчанию отправляет `Accept-Encoding: gzip`, не подтверждено (INFERENCE; проверить при
  реализации).
- **Хвост горизонта:** последние часы приходят как null. Существующий парсер уже превращает их в
  unknown, а не в 0 (SI-008, `open_meteo_forecast_parser.dart`). Подача «no forecast» сохраняется
  (ADR-012 §5).

### 4.2. Карточка ночи: значения без вердикта (совместимо с ADR-012)

Интервал — тот же, что у CALC-32 (закат…восход, h = −0,833°). Новый расчётный интервал не нужен.
Вариант «только тёмный промежуток на пользовательском пределе» означал бы изменение CALC-32,
и это решение владельца.

| Поле | Значение | Подача |
| --- | --- | --- |
| Дата и день недели | «Sat 18 Oct» в зоне сайта | `NightTimeFormatter` (ADR-007) |
| Облачность | **Диапазон** общей облачности min–max, в % | Иконка — только визуальный класс значения, число всегда рядом. Цвет не «хорошо/плохо». Если известна лишь часть часов — «known N of M h» |
| Осадки | Максимум вероятности, % | При отсутствии у модели — «—, unknown», никогда не 0 |
| Ветер | Максимум ветра и порывов, км/ч | Порыв — максимум предыдущего часа (подпись как сейчас) |
| Роса | Часы с риском росы, «N of M h» | Подпись «heuristic» (CALC-32) |
| Температура | min–max, °C | — |
| Луна | Освещённость %, **тёмные часы без Луны** и тип окна (↘ вечер / ↗ утро / • вся ночь / нет) | Считается офлайн. Показывается и вне 16-дневного горизонта |

- **Не показывать:**
  - словесные вердикты («отличная ночь»);
  - сортировку «лучшая ночь первой»;
  - цветовую шкалу пригодности;
  - составной индекс.

  Всё это запрещают ADR-012 §3 и §8 и CLAUDE.md («no black-box Astro Score»).
- **Слово состояния**, как в референсе `com.twtapp` («Clear», «Cloudy»), — это граница по
  облачности, придуманная приложением (INFERENCE: произвольный порог). Альтернатива —
  `weather_code` (WMO) провайдера. Это 12-я переменная и поправка ADR-012 §3, и она описывает
  погоду в целом, а не астрономические условия. Рекомендация: без слова; число и иконка.
- **Упреждение:** CMC сам не знает точности дальше 48 ч ([CSC key](https://www.cleardarksky.com/c/WAkey.html)).
  Поэтому у дальних ночей уместна фактическая подпись «прогноз на N дней вперёд» вместо оценки
  достоверности (INFERENCE). Ансамблевый разброс Open-Meteo — возможное расширение, вне 1.0.

### 4.3. Кэш и свежесть

- **Один снимок на сайт:** ключ из координат, округлённых до 0,01°, модели и **диапазона**
  запроса, а не одной ночи. Это поправка `WeatherSnapshotStore.keyFor` и ADR-012 §4/§6. Ночи —
  срезы этого снимка по `[startUtc, endUtc)`. Правило «данные другого сайта никогда не
  показываются» сохраняется.
- **Свежесть:**
  - у всех ночей одна `fetchedAt`, поэтому одно состояние `WeatherFreshness` на весь обзор:
    current < 3 ч, aging 3–12 ч, stale ≥ 12 ч (`night_weather.dart:18-19`);
  - метка свежести — одна в шапке обзора и повторяется в карточке выбранной ночи;
  - устаревший кэш никогда не выдаётся за текущий; ошибка обновления показывается (ADR-012 §6).
- **Каденция:** обновлять при смене сайта, по явному Refresh и при возврате приложения с aging
  или stale данными, как сейчас. Смена ночи внутри горизонта больше не делает запрос. Ночь за
  горизонтом — «no forecast yet», а Луна для неё считается.
- **Снимок плана (ADR-014):** при сохранении в план, как и сейчас, записывается срез выбранной
  ночи, а не все 16 дней. RA-E06 (показать этот срез в Logbook) не зависит от обзора и передаётся
  в R2e.
- **Объём хранения:** ≈22 КБ JSON на сайт в SharedPreferences (INFERENCE по замеру). Разумно
  хранить снимки для N последних сайтов. Решается при реализации.

## 5. Луна: мобильная подача, календарь, стоимость расчёта

### 5.1. Что показывать (концепт Moonlit, без его кода)

| Элемент | Откуда в AstroPlan | Примечание |
| --- | --- | --- |
| **Название фазы** | `MoonCalculator.phaseLongitudeDeg` уже вычисляет разность долгот: 0 — новолуние, 90 — первая четверть, 180 — полнолуние, 270 — последняя четверть (`moon_calculator.dart:385-390`, Meeus гл. 49) | Границы секторов — **соглашение именования**, не физика. У Moonlit четверти занимают ±5°. Соглашение нужно документировать (SCIENTIFIC_INTEGRITY) и выбрать (RA.D или R2b) |
| **Освещённость** | CALC-28, в средний солнечный полдень + 12 ч, подпись «at midnight» (SCI-09) | Без изменений |
| **Тёмные часы без Луны** (крупно) | dark − moonUp из `MoonDuringDark` (CALC-43) | Определение «Луна над горизонтом» и предел темноты — вопрос R2b §4. Здесь требование одно: **календарь, карточка ночи и полоса используют одно определение и одну сетку 5 мин**. Так делает Moonlit, и иначе числа расходятся |
| **Тип окна и время** (↘ вечер: сумерки→восход Луны; ↗ утро: заход→рассвет; • вся ночь) | Нужен новый вывод: **интервалы** «темно ∧ Луна не над горизонтом» из тех же отсчётов, а не только суммы. Это новый CALC | Символ всегда с текстом («evening», «morning»), а не только стрелка |
| **Восход и заход Луны** | `riseSetForNight` (h₀ по Meeus) | Уже задокументировано: h₀ и «Moon up» (центр > 0°) расходятся на 5–10 мин (SCI-03, S1.13). Если окна показывают время восхода по h₀, а длительность по центру, концы могут не совпасть с длительностью. Это подаётся как в SCI-03 или унифицируется решением R2b |

**Не переносить из Moonlit:** подсветку дня «good» при ≥ 4 ч без Луны (`app.js:147`,
`styles.css:66`). Это фиксированный порог-вердикт, а запрещают его CLAUDE.md («no arbitrary
universal scientific thresholds») и ADR-010 («факт, не влияние»).

### 5.2. Месячный календарь (мобильный)

- **Сетка:** 7 столбцов, ячейка ≥ 48 dp (DESIGN_SYSTEM: field use). В ячейке:
  - число месяца;
  - мини-фаза как изображение без собственной семантики;
  - «3h 20m» и символ окна.

  Пустые дни — «0 h» с причиной в семантике ячейки: «Солнце не опускается ниже предела» или
  «Луна над горизонтом весь тёмный период» (так делает Moonlit). При 200 % текста или на узком
  экране — **неделя вместо месяца**; Moonlit делает то же на коротких экранах.
- **Нажатие:** выбирает ночь. Это та же `SessionNight`, что выбор ночи в планировщике. Вне
  16-дневного горизонта погоды календарь показывает только Луну. Погодные значения для ночей
  1–16 можно наложить строкой ниже. Объединять ли календарь с обзором §4 — вопрос RA.D.
- **Доступность:**
  - у каждой ячейки один семантический ярлык: «18 October: waxing gibbous, 72 % illuminated,
    3 h 20 min moon-free dark, evening window»;
  - цвет не единственный носитель смысла: символ + слово + число;
  - **режим поля (красный):** различия только по яркости и форме, без оттенка, все роли
    красные или чёрные (DESIGN_SYSTEM §Field mode). Сегменты полосы различаются заливкой и
    штриховкой, у легенды есть текст.

### 5.3. Полоса ночи (полдень→полдень)

- **Сегменты:** день, сумерки по порогам −0,833° / −6° / −12° / −18°, «Луна над горизонтом»
  поверх тёмной части, «без Луны». Данные уже есть: `NightTimeline` и отсчёты Луны. Нынешний
  `sky_darkness_widget.dart:340-400` не имеет слоя Луны и легенды (RA-E01).
- **Текстовая альтернатива:** одна строка, например «Noon to noon: 9 h 50 min dark at −18°;
  6 h 30 min moon-free, 23:10–05:40». Так устроен `aria-label` у Moonlit. Видимая легенда
  обязательна.

### 5.4. Стоимость расчёта 30 ночей офлайн

- **На одну ночь сейчас** (FACT, код):
  - Солнце — 289 отсчётов (24 ч / 5 мин + 1), формула низкой точности;
  - Луна — 289 топоцентрических позиций (Meeus гл. 47 с полными таблицами периодических членов,
    плюс нутация и параллакс);
  - `riseSetForNight` — ещё 289 геоцентрических позиций.

  Всё синхронно, в `NightConditionsViewModel.moonConditions`, с кэшем по ключу
  (`night_conditions_viewmodel.dart:180-192`).
- **Косвенный замер** (FACT, `docs/refinement/evidence/STAGE_10_MEASUREMENTS.md:170`): «Planner:
  night change», эмулятор x86_64, profile — худший кадр build **9 и 14 мс**, кадров дольше
  16,7 мс нет. **INFERENCE:** если пересчёт Луны и Солнца для ночи происходит в этом build (геттеры
  ленивые и читаются при построении), полный пересчёт ночи с целью стоит ≤ ≈14 мс на эмуляторе.
  Расчёт без цели дешевле.
- **Оценка 30 ночей (INFERENCE):** ≤ ≈30 × 14 мс ≈ **0,3–0,4 с на эмуляторе** в худшем случае. На
  современном телефоне вероятно меньше, но не измерено. Это больше бюджета кадра (16,7 мс),
  поэтому:
  1. **Вне UI-потока.** `Isolate.run` — тот же образец, что `candidates_viewmodel.dart:40`.
  2. **Кэш.** Ключ: сайт (0,01°), предел темноты, зона, месяц. Результат детерминирован и не
     зависит от сети. Пересчёт только при смене ключа. Соседний месяц можно считать заранее
     после первого кадра.
  3. **Та же сетка 5 мин**, без огрубления. Огрубление до 10–15 мин с уточнением событий
     бисекцией дало бы ускорение в 2–3 раза. Но тогда календарь разойдётся с карточкой ночи на
     минуты, а Moonlit как раз требует единой классификации. Рекомендация — не огрублять,
     пока замер не покажет необходимость.
  4. **Замер на телефоне** — критерий приёмки будущего Task, а не допущение этого отчёта.
- **16 ночей погоды:** свёртка 384 часов по ночам — микросекунды (INFERENCE). Для неё нужно
  Солнце по 16 ночам (интервал CALC-32), и его можно взять из того же кэша календаря.

## 6. Рекомендованная ночная сводка: Home и детали

**Home — одна карточка «Tonight»** (INFERENCE; порядок карточек на Home решает RA.D по K9 и
RA-D03, вместе с R2e):

1. **Темнота:** «Dark 19:42–05:31 (−18°)». Это время на пользовательском пределе (CALC-41).
2. **Луна:** название фазы, освещённость %, «moon-free 3 h 20 min · evening ↘ 19:42–23:02». При
   отсутствии данных: «Moon up all dark» или «no darkness at −18°».
3. **Облачность:** диапазон «Cloud 10–45 %» и свежесть («updated 2 h ago» или «stale»). Без
   данных: «no forecast yet».
4. **Строка значений:** максимум осадков %, порывы (максимум), часы риска росы «2 of 9 h». Минимум
   температуры — опционально. Только при наличии данных; unknown — «—».
5. Ссылка «Night details», атрибуция Open-Meteo (уже есть).

**В деталях** («Night & Moon» и «Weather»):
- **часовая лента** (5 строк сейчас): облачность по ярусам, осадки, ветер и порывы,
  T/Td/RH, видимость, роса. Формат по референсам владельца: 24-часовая полоса с иконками и
  ветром (MIUI, Google);
- **обзор 16 ночей** (§4.2), горизонтальной лентой или списком;
- **месячный календарь Луны** (§5.2) и **полоса ночи** (§5.3);
- **seeing и transparency** — только если RA.D выберет провайдера (§7, W4).

**Что убирается с Home:** ничего из ответа. Облачность внутри окон (аннотации ADR-013, cloud gate)
остаётся частью ответа планировщика, а не дублем (RA-D03). Убрать можно только **строку-дубль**
погоды в планировщике, если Home и детали её покрывают. Это решение R2e и RA.D.

## 7. Варианты для RA.D

| ID | Вопрос | Рекомендация | Альтернатива | Компромиссы | Заменяемое решение | Privacy/COMPLIANCE (trap 22) | Нужно одобрение |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **W1** | Многодневный обзор | Один запрос Open-Meteo `forecast_days=16` на сайт. Ночи — срезы. Один кэш и одна свежесть | Оставить запрос на одну ночь; обзора нет | ≈22 КБ (6 КБ gzip) вместо 1,5 КБ. Меньше запросов при смене ночи. Нужно мигрировать ключ кэша | ADR-012 §4 («запрос покрывает эту ночь»), §6 (ключ кэша по ночи); `WeatherSnapshotStore.keyFor` | Получатель и данные те же (координаты и время). **Нужно обновить формулировки:** privacy `docs/privacy/index.md:50` («the night's hours» → «the next 16 days») и COMPLIANCE `docs/COMPLIANCE.md:42` (каденция «one request per site and night»). Категория Data Safety не меняется | Да (поправка ADR-012) |
| **W2** | Состав карточки ночи | §4.2: облачность (диапазон), осадки (максимум), ветер и порывы (максимум), часы росы, T, Луна (%, без Луны, тип окна). Без вердиктов, цвета пригодности и сортировки | Минимум как у `com.twtapp`: облачность % + Луна % | Больше значений — больше плотность. Минимум проще, но скрывает ветер и росу (RA-E03) | Нет (в рамках ADR-012). Интервал — CALC-32 | Нет | Да (продукт) |
| **W3** | Новые переменные **того же** Open-Meteo | Не добавлять в 1.0. Записать как будущие опции: TCWV (сырой вход прозрачности по образцу CSC), ветер 250 гПа (струйное течение), AOD из Air Quality API | Добавить в детали TCWV и ветер 250 гПа как **сырые значения** с пояснением «proxy, not seeing/transparency». Без порогов: правило meteoblue > 35 / < 5 м/с — эвристика провайдера | Полезно для длинного фокуса, но легко принять за индекс. Нужны тексты и SI-запись. AOD — только 5 дней и отдельная атрибуция CAMS | ADR-012 §3 (таблица переменных; «Deferred: seeing and transparency») | TCWV и 250 гПа: новых данных, уходящих с устройства, нет; только поправка ADR. **AOD:** новый хост `air-quality-api.open-meteo.com` и атрибуция CAMS → privacy, COMPLIANCE и About в том же изменении | Да (ADR) |
| **W4** | Seeing и transparency | **Не вводить провайдера в 1.0.** Указать честно: «seeing/transparency not forecast here». Опционально — ссылка, которую пользователь открывает сам (Clear Outside или страница 7Timer), по образцу lightpollutionmap.app (M2, RG-08/09) | **7Timer! ASTRO** как opt-in, по образцу Nominatim (выключено по умолчанию), только в деталях, с подписью «7Timer! (GFS), 3-hourly, 72 h». Свежесть по `init`. Координаты огрублены до 0,1° (INFERENCE: сетка GFS всё равно грубая). Уведомить оператора | 7Timer: 72 ч, грубые коды, нет SLA и валидации, некоммерческое использование, новый получатель в Китае. Для телефона и DSLR польза мала (§2). Ссылка: ноль кода и рисков, но данные вне приложения | ADR-012 §2 («Open-Meteo stays the only provider for 1.0»), §3 Deferred | **Opt-in 7Timer:** новый получатель (координаты и IP) → privacy, COMPLIANCE (Data Safety: location shared; новый получатель), About, атрибуция, переключатель в Settings. Политику оператора найти не удалось. **Ссылка:** добавить в privacy, раздел «Links you open yourself» | Да (новый провайдер или ссылка) |
| **M1** | Луна на Home и в карточке ночи | Название фазы + освещённость + **крупно «тёмные часы без Луны»** + тип окна со временем | Оставить «Moon up X of Y dark» и добавить фазу | Нужен новый CALC: интервалы без Луны и их классификация. Определение — из R2b §4 | ADR-010 сохраняется (факт). CALC-43 расширяется | Нет (офлайн) | Да (продукт; определение — R2b) |
| **M2** | Месячный календарь | Офлайн, в деталях «Night & Moon». Неделя при крупном тексте. Без подсветки «good». `Isolate.run` + кэш по месяцу. Замер на телефоне — критерий приёмки | Только 7-дневная лента Луны в обзоре W1 | Месяц покрывает планирование за пределами погодного горизонта; цена — новый экран, расчёт ≈0,3–0,4 с (эмулятор, оценка) вне UI-потока | Нет. Вопрос охвата RA-A06 | Нет (офлайн) | Да (охват) |
| **M3** | Полоса ночи полдень→полдень | Слой Луны и легенда в `sky_darkness_widget`, текстовая альтернатива, штриховка для режима поля | Отдельная полоса Луны под полосой сумерек | Одна полоса нагляднее, но плотнее при 200 % текста | Нет | Нет | Да (UI, вместе с R2e) |
| **H1** | Сводка на Home | §6: темнота, Луна, облачность со свежестью, строка значений | Только облачность и Луна | См. K9 и RA-D03: порядок карточек — вопрос R2e | ADR-019 §5/§6, RG-05 T1 (порядок) — только если меняется порядок | Нет | Да (R2e, RA.D) |
| **L1** | Погода в Logbook (RA-E06) | Передать в R2e. Снимок уже хранит часы (`session_snapshot_builder.dart:246-275`) | — | — | ADR-014 (отображение) | Нет | R2e |

**Не подлежит изменению при любом выборе** (RA-E05, ADR-012):
- состояния Idle, Loading, OutOfRange, Unavailable, Available;
- возраст 3 ч / 12 ч;
- «no forecast» вместо 0;
- атрибуция;
- unknown ≠ 0;
- без оценки и без раскраски «хорошо/плохо».

## 8. Источники

Дата обращения ко всем источникам — 2026-10-17.

**Первичные и официальные**
- Open-Meteo Forecast API docs: <https://open-meteo.com/en/docs>
- Open-Meteo Terms: <https://open-meteo.com/en/terms>
- Open-Meteo Pricing (подсчёт вызовов): <https://open-meteo.com/en/pricing>
- Open-Meteo Air Quality API (CAMS, AOD): <https://open-meteo.com/en/docs/air-quality-api>
- Замеры ответов `api.open-meteo.com/v1/forecast` (1 ночь и 16 дней, 11 переменных; переменные
  уровней давления, TCWV, CAPE, LI) и `air-quality-api.open-meteo.com/v1/air-quality` (AOD, dust):
  точка 51.48, 0.0; файлы во временном каталоге сессии, не в репозитории
- 7Timer! documentation: <https://www.7timer.info/doc.php?lang=en>
- Замер `https://www.7timer.info/bin/api.pl?...&product=astro&output=json`
- 7Timer issues: <https://github.com/Yeqzids/7timer-issues/issues>
- Clear Sky Chart, legend (key): <https://www.cleardarksky.com/c/WAkey.html>
- meteoblue, Astronomy Seeing help: <https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing>
- meteoblue Free Weather API: <https://business.meteoblue.com/products/weather-apis/free-weather-api>
- meteoblue Pricing: <https://business.meteoblue.com/pricing>
- meteoblue Astronomy Seeing Widget: <https://business.meteoblue.com/products/plug-and-play-visuals/astronomy-seeing-widget>
- Astrospheric API info: <https://www.astrospheric.com/dynamiccontent/api_info.php>
- Astrospheric, main page: <https://www.astrospheric.com/DynamicContent/astrospheric.php>
- Astrospheric, transparency page: <https://www.astrospheric.com/dynamiccontent/education/ed_transparency_en.html>
- ECCC open data licence: <https://eccc-msc.github.io/open-data/licence/readme_en/>
- MET Norway Terms of Service: <https://api.met.no/doc/TermsOfService>
- MET Norway Locationforecast docs: <https://api.met.no/weatherapi/locationforecast/2.0/documentation>
- Clear Outside, страница прогноза: <https://clearoutside.com/forecast/51.48/0.00>
- Dart `HttpClient.autoUncompress`: <https://api.dart.dev/dart-io/HttpClient/autoUncompress.html>
- Meeus J., *Astronomical Algorithms*, 2nd ed., гл. 47–49 (через код и ADR-010)

**Вторичные, форумы, анекдоты**
- MSC Datamart, рассылка о seeing и transparency RDPS: <https://comm.collab.science.gc.ca/mailman3/hyperkitty/list/dd_info@comm.collab.science.gc.ca/thread/BH3KXVL63I2TJJCQYJUQVRITVGPY7NCO/>
- Photo Ephemeris, seeing и transparency (ECCC): <https://photoephemeris.com/articles/new-seeing-and-transparency-forecasts>
- Stargazers Lounge, обновление Clear Outside: <https://stargazerslounge.com/topic/340555-clear-outside-update>
- IceInSpace, данные 7Timer «замерли»: <https://www.iceinspace.com.au/forum/showthread.php?p=1059455>
- Блог оператора 7Timer о сбоях: <https://y234.cn/?p=508>
- AstroBin: ветер и гидирование: <https://app.astrobin.com/forum/topic/84913/phd2-not-giving-sufficient-corrections-causing-severe-star-trails>
- AstroBin: перефокусировка по температуре: <https://app.astrobin.com/forum/topic/186916/autofocus-questions>
- Astropix, PHD2 и ветер: <https://astropix.com/html/astrophotography/phd2_autoguiding.html>

**Локальные**
- Moonlit (концепт, без лицензии на собственный код): `C:\Users\zalub\OneDrive\Desktop\52\moonlit-main\README.md`,
  `index.html`, `app.js:147`, `astronomy.js:120-129`, `vendor/`
- Код и документы AstroPlan: ссылки `file:line` в §1–§7

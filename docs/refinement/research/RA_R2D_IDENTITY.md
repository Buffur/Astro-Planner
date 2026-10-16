# RA.R2d — Идентичность: имя, app id, знак, splash, иконки и анимации

> Подготовлено 2026-10-17 для RA.R2, задача R2d (`docs/refinement/prompts/RA_R2_RESEARCH_PLAN.md` §3).
> Закрывает находки RA-C01, RA-C02, RA-C03, RA-C04, RA-A09, часть RA-I04 (имя) и K10
> (`research/RA_R1_PHASE_A_ASSESSMENT.md`). Только документация. Ничего не решено: имя, app id и
> направление знака выбирает владелец в RA.D, раунд 1. **Финальный знак выбирает только владелец (P9.4).**
> Метки: **FACT** — проверено по источнику, указанному в §9 (дата доступа 2026-10-17);
> **INFERENCE** — вывод агента; **UNKNOWN** — не удалось установить.

## 1. Метод и ограничения

**Это скрининг, а не юридическое заключение.** Отсутствие находок не означает, что имя свободно для
регистрации или использования. OD-07 уже требует формального поиска товарных знаков (силами
владельца или юриста) до первой загрузки в Google Play. Этот документ его не заменяет.

Что проверено по каждому кандидату (2026-10-17):

| Канал | Как | Ограничение |
| --- | --- | --- |
| Google Play | Страница поиска `play.google.com/store/search?q=<имя>&c=apps&hl=en`, прочитанная через WebFetch | Выдача нечёткая и обрезана примерно на 15 позициях; регион выдачи — США |
| Apple App Store | iTunes Search API, `itunes.apple.com/search?term=<имя>&entity=software&country=us` | Только витрина США; до 6 позиций |
| Общий веб | WebSearch по точному имени, с уточнением «app / software / astronomy» | Поисковик, а не реестр |
| GitHub | REST API `search/repositories?q=<имя>+in:name` и `<имя>+astro` | Совпадение по подстроке даёт шум |
| Домены `.com` / `.app` | RDAP через `rdap.org`: HTTP 200 — запись есть (домен **зарегистрирован**), 404 — записи нет | **Только подсказка**: «нет записи» ≠ «можно купить» (премиум-цены, резервы) |
| Товарные знаки | Попытки открыть WIPO Global Brand Database, EUIPO eSearch, USPTO Trademark Search | **Пробел.** WIPO GBD требует прохождения CAPTCHA (altcha) — агент её не проходит; USPTO tmsearch и EUIPO eSearch отдают только JS-оболочку (WebFetch не видит результатов), а JSON-endpoint USPTO вернул `MethodNotAllowed`. Вместо реестров — поиск по агрегаторам (trademark.justia.com, trademarkia, uspto.report) через WebSearch. Реестр Украины (УКРНОІВІ) не проверялся |

Классы Ниццы, релевантные продукту (INFERENCE): **9** (загружаемое ПО, мобильные приложения) и **42**
(SaaS/разработка ПО). Совпадение в другом классе (например, 33 — вино) — меньший, но не нулевой риск.

Оценка риска (INFERENCE, качественная):
- **low** — нет точных совпадений в сторах, реестрах и нише;
- **medium** — близкое имя в нише или точное в соседнем классе, либо слабая различительность;
- **high** — точное или почти точное имя в астро-нише или сильный бренд в классах 9/42.

Проверка UA/RU — звучание и отсутствие неуместных значений, оценка агента (INFERENCE). Владелец как
носитель языка должен подтвердить её.

## 2. Кандидаты имени и скрининг

Нынешнее имя — ориентир. **Astro Planner**: в App Store США за 2026 год вышли «Astro Planner: Night Sky
Photo» (Daniel Vilela, 2026-03-12), «AstroPlanner» (Hayato Monma, 2026-10-12), «AstroPlan» (Martin
Wilcox, 2026-06-13) и «Free Sky Planner: DarkScout» (FACT, iTunes API). К этому добавляются коллизии
из Phase A: AstroPlanner Пола Родмана (Mac/Windows), веб-инструмент astro-planner.adfr.io, пакет
`astroplan`, а из OD-07 — «Astro Planner» в Google Play (`com.astronomia.astro_planner`). **Риск
high.** Подтверждает RA-C01.

Пятнадцать кандидатов. Все данные — 2026-10-17.

| # | Имя | Смысл; UA/RU | Google Play | App Store (US) | Веб / ТЗ-агрегаторы | GitHub (in:name) | `.com` / `.app` | Риск |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | **AltArc** | altitude arc — ровно то, что рисует знак; «Альтарк», нейтрально | Точных нет; рядом «Altar…» (молитвенные приложения), Arc Search | Точных нет; «Altar», «Altar Live» | Нет упоминаний; ALTARC в агрегаторах не найден | 54 (шум: CentOS/AltArch), с «astro» — 0 | занят / нет записи | **low–medium**: визуально близко к «Altar»; «Alt» читается как клавиша или «alternative» |
| 2 | **Astrarc** | astro + arc; «Астрарк» | Точных нет; выдача — астрологические «Astra…» | Точных нет | Нет упоминаний; в агрегаторах не найден | 0 | занят / нет записи | **low**; позиционный минус — соседство с астрологией «Astra» |
| 3 | **Arcwindow** | дуга + окно съёмки; «Арк-віндоу», длинновато | Точных нет | Точных нет (Arc Search) | В выдаче только браузер Arc | 2 | занят / нет записи | **low**; слабое место — «Arc» как бренд браузера The Browser Company (класс 9), «window» — ассоциация с Windows |
| 4 | **Culmina** | лат. «вершина»; кульминация — звезда на вершине дуги; «Кульміна / Кульмина» понятно | Ничего с «Culmin» | Точных нет; «Culminate Life» (церковное) | **Culmina Family Estate Winery** (Канада, вино, класс 33); CULMINA в агрегаторах не найден (вероятная регистрация винодельни — UNKNOWN) | 1 096 (шум «culminating»), с «astro» — 1 учебный | занят / занят | **low–medium**: класс другой, но оба домена заняты |
| 5 | Lightframe | light frame — термин калибровки | «Light Frame Journal», «Lightframer Pro», «Framelight» | «Lightframer Pro» (кино, солнечный путь) | Mac-приложение LightFrame (Corner-A); USPTO LIGHTFRAME (USG, «dead»); LITEFRAME (освещение) | 80 (EnderMo/LightFrame, 72★) | занят / занят | **high** |
| 6 | Nightframe | ночной кадр | «Night Frames: Photo Effect» | **«Nightframe» (2026-04-03)** — «astrophotography workflow tool»: планирование сессий по сетапам, лог съёмки и калибровок | npm `nightframe` (MIT, веб-фреймворк) | 28 | занят / нет записи | **high**: прямой конкурент в нише |
| 7 | Night Window | ночное окно съёмки; описательное | Точных нет (диммеры экрана) | Точных нет | Рядом в нише: **SkyWindow** (iOS, Dung Le, планировщик астросъёмки), **Nightwatch** (macOS, open source, «clear window») | 7 | занят / занят | **medium**: описательное имя слабо охраняемо, близкие имена в нише |
| 8 | PhotonPlan | план сбора фотонов; «Фотон План» | Точных нет (Photon Camera, Photon file share) | Точных нет (Photon Calc, Photone) | Ниша занята **PhotoPills** — «photo planner» с похожим звучанием; ТЗ **PHOTON** (Exit Games, US serial 86318032, ПО) | 1 | нет записи / нет записи | **medium**. Дополнительно (INFERENCE): имя тянет к «фотонному бюджету», что расходится с правилом CLAUDE.md не подавать √N как абсолютный SNR |
| 9 | Skyhours | часы неба | Точных нет | Точных нет | ТЗ **SKYHOUR** (SKYHOUR, LDA, US serial 79223733, ПО для лётных часов) | 3 | занят / занят | **medium–high**: почти то же слово в классе 9 |
| 10 | Skyslot | слот неба | **Вся выдача — казино и слот-машины** | Точных нет | Веб-выдача «sky slot» — азартные страницы | 3 | занят / занят | **medium** юридически, **high** репутационно: ассоциация с азартными играми, «замусоренный» поиск |
| 11 | StackPlan | план стека | Точных нет | Точных нет | **StackPlanner** (Springbord, SaaS для недвижимости); «stack plan» — термин недвижимости | 7 | занят / занят | **medium**; кроме того, стекинг — обработка, а не ядро продукта |
| 12 | Starwindow | звезда + окно | Точных нет | Точных нет | Рядом в нише — SkyWindow (iOS) | 5 | занят / занят | **medium** |
| 13 | Subframe | субкадр | Точных нет | Точных нет | **Subframe** — визуальный редактор UI (SaaS, класс 9/42); автомобильная деталь | 77 (SubframeApp/subframe, 440★) | занят / занят | **high** |
| 14 | Lightbucket | «light bucket» — сленг для крупного телескопа | Точных нет | Точных нет | **LightBucket** — плагин NINA и сайт app.lightbucket.co; удалённая обсерватория **LightBuckets** | 6, в т.ч. `LightbucketAstro/lightbucket-astro-planner` | занят / нет записи | **high**: имя занято в той же астро-нише |
| 15 | Noctarc | noct(urnal) + arc; «Ноктарк» | Точных нет (Noccarc CRM, Noctra) | Точных нет («Noctar Wallet», крипто) | **Noctar** — по описанию из каталога, приложение планирования астронаблюдений (один источник, serchen.com) | 4 (noctarch…) | нет записи / нет записи | **medium**: одна буква от астро-приложения |

INFERENCE по рынку: в 2026 году ниша «планировщик астросъёмки» быстро заполняется iOS-приложениями
с именами из слов *astro / sky / night / window / frame / plan*. Описательные составные имена из этих
слов почти наверняка столкнутся с чем-то. Различимы придуманные слова с «нашей» семантикой (дуга,
кульминация).

## 3. Шорт-лист

Отобраны кандидаты с риском low или low–medium, связью со знаком «дуга высоты — окно — звезда» и
нормальным звучанием в EN, UA и RU. **Порядок не означает рекомендацию**: выбирает владелец.

| Имя | Почему в списке | Что проверить владельцу до загрузки |
| --- | --- | --- |
| **Culmina** | Имя и знак рассказывают одно: звезда в кульминации на вершине дуги; слово понятно в EN/UA/RU | Регистрации винодельни (класс 33) в WIPO GBD и EUIPO; домены заняты — для политики конфиденциальности остаётся GitHub Pages |
| **AltArc** | Буквально «дуга высоты» — центральная идея знака и планировщика | Визуальное смешение с «Altar» в выдаче; `.app` без записи |
| **Astrarc** | Придуманное слово, совпадений не найдено ни в одном канале | Ассоциация с астрологией («Astra…» в выдаче Play) — вопрос позиционирования, а не права |
| **Arcwindow** | Описывает дугу и окно съёмки, коллизий мало | Близость к бренду браузера Arc в классе 9; длина и звучание в UA/RU |

Резерв (риск medium): **Noctarc** (оба домена без записи, но рядом «Noctar»), **PhotonPlan** (оба
домена без записи, но рядом PHOTON и PhotoPills).

Форма названия в сторе (FACT: лимит названия в Google Play — 30 символов): имя плюс дескриптор,
например «Culmina: Astrophoto Planner» (27 символов) или «AltArc — Astrophoto Planner». Дескриптор
— описательный текст, а не часть бренда (INFERENCE).

Остаётся неизменным при любом имени (trap 20): расширение `.astroplan`, `"app": "AstroPlan"` в
манифесте экспорта и Dart-пакет `astroplan` — это форматы и внутренности. INFERENCE: внутреннее
«AstroPlan» теперь совпадает с iOS-приложением «AstroPlan» (2026). Пользователь видит его только в
расширении файла бэкапа; менять ли формат — отдельный вопрос, не связанный с брендом.

## 4. App id

**Состояние (FACT, код на 2026-10-17):** `io.github.chacha12.astroplanner` используется:
- в `android/app/build.gradle.kts` (`namespace` и `applicationId`);
- в пакете Kotlin `android/app/src/main/kotlin/io/github/chacha12/astroplanner/` (`MainActivity.kt`,
  `MetadataDocumentChannel.kt`, `MetadataSequentialReader.kt`) и в тесте
  `android/app/src/test/kotlin/io/github/chacha12/astroplanner/MetadataSequentialReaderTest.kt`;
- в имени MethodChannel `io.github.chacha12.astroplanner/metadata_document` — на Kotlin-стороне и в
  `lib/data/metadata/android_capture_file_access.dart`;
- в `AppIdentity.packageName` (`lib/core/config/app_identity.dart`);
- в `test/core/config/app_identity_test.dart`.

URL `projectUrl`, `sourceUrl` и `privacyPolicyUrl` (а через них `userAgent`) указывают на `chacha12`
и сейчас возвращают 404 (TD-088, S9.12).

**Правила платформы (FACT, developer.android.com/build/configure-app-module):**
- После публикации application ID менять нельзя: Play примет новый id как другое приложение.
- `namespace` и `applicationId` технически независимы, но рекомендуется держать их одинаковыми.

Google Play ещё ничего не загружено, поэтому сейчас смена id — одна Task, после первой загрузки — новая
карточка в сторе.

**Варианты (связка с RD-01):**

| Вариант | id | RD-01 | Плюсы | Минусы |
| --- | --- | --- | --- | --- |
| **I-1. Оставить id** | `io.github.chacha12.astroplanner` | любой (B′ или C) | Ноль изменений кода | id виден в URL карточки Play (`details?id=…`) и навсегда содержит «astroplanner» и «chacha12» — старое имя и аккаунт, который владелец, по S9.12, публично не использует |
| **I-2. Новый id под Buffur** | `io.github.buffur.<newname>`, например `io.github.buffur.culmina` | B | id отвечает имени и домену, которым владелец реально управляет (`buffur.github.io` при включённых Pages); закрывает TD-088 вместе со ссылками | Одна Task по коду (ниже); данные на телефоне владельца (ниже) |
| **I-3. Новое имя под chacha12** | `io.github.chacha12.<newname>` | C | Имя в id совпадает с брендом | Требует создать и вести `chacha12/…` с GitHub Pages; по S9.12 это не публичный аккаунт владельца |

Объём изменений при смене id (только влияние, без реализации; trap 20):
1. Gradle: `namespace` и `applicationId`.
2. Перенос Kotlin-файлов в новый каталог пакета, строка `package` в каждом (main и test).
3. Имя MethodChannel. Оно внутреннее и может остаться старым, но менять его нужно **одновременно** в
   Kotlin и Dart, иначе сломается импорт метаданных.
4. `AppIdentity.packageName` / `projectUrl` / `sourceUrl` / `privacyPolicyUrl` / `userAgent` и, при
   новом имени, `appName` и `android:label`.
5. `app_identity_test.dart` (он сверяет Dart, Gradle, манифест и `MainActivity`).
6. `docs/COMPLIANCE.md`, `docs/RELEASE.md`, `docs/privacy/index.md`.
7. Настройка отладочного пакета `.s2check` (суффикс к id).

**Важное следствие для данных (INFERENCE по памяти проекта; проверить у владельца):**
- На телефоне владельца установлено `io.github.chacha12.astroplanner` с реальными данными.
- Приложение с новым id установится **рядом**, как отдельное, с пустой базой.
- Перенос — только через бэкап и восстановление приложения (`.astroplan`, TASK 14.4): сделать бэкап в
  старом, восстановить в новом, затем удалить старое вручную.
- Это шаг владельца; агент не удаляет и не заменяет его приложение.

GitHub (FACT, docs.github.com):
- Переименование репозитория перенаправляет всё, **кроме URL сайта GitHub Pages** проекта.
- Если вместе с именем менять имя репозитория `Buffur/Astro-Planner`, URL политики конфиденциальности
  на Pages изменится. Его нужно выбрать до загрузки в Play.
- Нельзя создавать новый репозиторий со старым именем: перестанут работать перенаправления.

## 5. Логотип: направления

### 5.1 Что уже подготовлено (S9.10, 2026-09-29)

Концепт владельца сохраняется во всех вариантах: дуга высоты над горизонтом, отмеченное окно съёмки,
звезда в вершине. S9.10 нашёл пять дефектов исполнения:
1. звезда висит над дугой;
2. три разные толщины штриха;
3. themed-иконка — это цветной рисунок, перекрашенный в один цвет, и окно в ней пропадает;
4. знак смещён вверх;
5. «ошибочный» красный `#FF4D3D`.

Варианты (SVG в S9.10 §3):
- **A** — исправленный оригинал: звезда на вершине, одна система штрихов, знак опущен к центру;
- **B** — окно как площадь под дугой (время), янтарный акцент;
- **C** — минимальный: без горизонта, толстая дуга с янтарным окном и звезда; лучше всего держится на
  24 px и в themed-режиме;
- **D** — сегодняшний знак, исправлены только звезда и monochrome-слой.

### 5.2 Как направления ложатся на шорт-лист (INFERENCE; выбор — владельца)

| Имя | Естественные направления | Почему |
| --- | --- | --- |
| Culmina | **A** или **C** | Имя означает момент кульминации; звезда точно на вершине дуги — буквальная иллюстрация имени |
| AltArc | **C**; возможно новое **E** — монограмма | Дуга — герой знака. E (идея, в S9.10 не прорабатывалась): дуга и горизонт образуют силуэт «A», окно — перекладина |
| Astrarc | **C** с более выраженной звездой | «Astr-» — звезда, «arc» — дуга: оба элемента на равных |
| Arcwindow | **B** | Окно как площадь — центральный смысл имени |

Цвет: S9.10 предлагает уйти от красного ошибок к янтарному акценту (B/C). Красный режим приложения
(field mode) на иконку лаунчера не влияет.

### 5.3 Ограничения платформы (FACT)

- **Адаптивная иконка (developer.android.com, icon_design_adaptive):**
  - все слои 108×108 dp; внешние 18 dp с каждой стороны зарезервированы под маску и эффекты (видимая
    область — 72×72 dp);
  - «safe zone», которую маска OEM никогда не обрезает, — **66×66 dp**; логотип не меньше 48×48 dp и не
    больше 66×66 dp.
  - Уточнение к постановке R2d: «72 dp» — видимое окно, а гарантированная зона — 66 dp. S9.10
    проверял круг радиуса 33 вокруг (54, 54), что согласуется с 66 dp.
- **Themed icon:**
  - с Android 13 (API 33) система тонирует слой `<monochrome>` цветом обоев;
  - с Android 16 QPR 2 система сама тонирует иконки приложений без такого слоя.
  - Сейчас `mipmap-anydpi-v26/ic_launcher.xml` использует цветной foreground как monochrome. Пример в
    документации так делает, но для этого знака нужен отдельный слой (S9.10 §4).
- **Иконка Google Play (developer.android.com, icon-design-specifications):**
  - 512×512 px, 32-bit PNG, sRGB, не больше 1024 KB, полный квадрат;
  - скругление (около 30 %) и тень Play добавляет сам — не закруглять и не добавлять тень;
  - прозрачности лучше избегать;
  - никаких элементов рейтинга или промо.
- **Trap 20:** знак перерисовывается одновременно в `drawable/ic_launcher_foreground.xml` и в
  `tool/make_launcher_icons.py`, который генерирует legacy PNG и `assets/branding/icon_512.png`.

## 6. Splash и анимация загрузки

### 6.1 Факты платформы (developer.android.com, splash-screen и migrate)

- **Android 12+ строит splash сам** — из иконки лаунчера и однотонного `windowBackground`, даже если
  приложение ничего не настроило. Сейчас в `values-v31` и `values-night-v31` задан статичный
  foreground на `#0B1230`.
- **Размеры иконки splash:**
  - с фоном иконки — 240×240 dp, содержимое в круге 160 dp;
  - без фона — 288×288 dp, содержимое в круге 192 dp;
  - треть foreground маскируется, как у адаптивной иконки.
  - Приложение задаёт `windowSplashScreenIconBackgroundColor`, поэтому действует правило с фоном.
- **Анимированная иконка:**
  - формат — AnimatedVectorDrawable (AVD);
  - рекомендуемая длительность — **не больше 1 000 мс на телефонах**; отложенный старт — не больше
    166 мс; если старт приложения дольше 1 000 мс, документация советует зацикленную анимацию;
  - `windowSplashScreenAnimationDuration` нужен только для API 31–32 (на 13+ длительность берётся из
    AVD) и не меняет время показа splash.
- **Splash скрывается, как только приложение нарисовало первый кадр.** Удержать его можно через
  `OnPreDrawListener` — это задерживает первый кадр, и P9.4 такое исключает.
- **Branding image:** 200×80 dp, но гайдлайны рекомендуют её не использовать.
- **До Android 12:** `core-splashscreen` переносит API 12 на API 23+. По справке androidx, поведение
  платформы воспроизводится **без поддержки AVD**, то есть на старых версиях иконка статична. В
  проекте библиотеки нет: до 12 показывается `launch_background.xml` со статичным PNG.
- **Flutter (docs.flutter.dev, splash-screen):** приложение может продолжить последний кадр splash во
  Flutter и отключить exit-анимацию, чтобы не было мерцания. Это опция, а не рекомендация.
- **Reduced motion (api.flutter.dev):** `MediaQueryData.disableAnimations` отражает системную
  настройку Android «Remove animations». В проекте уже есть `AppMotion.duration(context, base)`: при
  reduced motion он возвращает 0.

### 6.2 Предлагаемая форма (INFERENCE; согласуется с P9.4 и S9.10 §5)

1. **Android 12+ — AVD выбранного знака** в `windowSplashScreenAnimatedIcon`:
   - дуга «прорисовывается» от горизонта (trim path, около 400 мс), затем появляется окно (около
     150 мс) и звезда (около 150 мс), всего ≤ 1 000 мс;
   - старт без задержки;
   - зацикливание не нужно, если холодный старт короче секунды. Это **UNKNOWN** — замерить на
     телефоне владельца в Task реализации.
   - Splash исчезает с первым кадром Flutter, поэтому анимация **никогда не задерживает старт**.
   - При «Remove animations» системный аниматор с масштабом 0, ожидаемо, сразу показывает конечный
     кадр (INFERENCE; проверить на устройстве).
2. **До Android 12:** статичная иконка, как сейчас; `core-splashscreen` не добавлять, анимацию он там
   всё равно не даёт.
3. **Продолжение во Flutter (по желанию владельца):**
   - вместо голого `CircularProgressIndicator` на Tonight (`tonight_home_screen.dart`, ветка
     `startupVm.isLoading`) — тот же знак в той же позиции;
   - тихая циклическая «пульсация» окна, которая **длится ровно столько, сколько идёт реальная
     загрузка**;
   - **никакого детерминированного прогресса** (P9.4: не имитировать прогресс);
   - при `disableAnimations` — статичный знак;
   - смена на контент — сразу, как только данные готовы; анимация не удерживает экран.
   - Реализуется встроенными средствами: `AnimationController` и `CustomPainter` или `AnimatedBuilder`
     с токенами `AppMotion`. **Пакет не нужен.**
4. **Бюджет старта:** ни один вариант не добавляет работы до первого кадра. Проверка в Task
   реализации: время до первого кадра на устройстве до и после изменения (метрика «Displayed» в
   logcat) и рендер в reduced motion.

## 7. Иконки и анимационные библиотеки

GPL-3.0-совместимость (FACT, FSF license list, gnu.org/licenses/license-list):
- Apache-2.0 «compatible with version 3 of the GNU GPL» (с GPLv2 — нет);
- Expat (MIT), ISC и Modified BSD (BSD-3-Clause) совместимы с GNU GPL;
- CC BY 4.0 «compatible with all versions of the GNU GPL», но FSF не рекомендует её для ПО;
- SIL OFL 1.1 — «free copyleft license for fonts», в разделе лицензий для прочих работ. Отдельного
  заявления FSF о совместимости OFL с GPL нет.

Шрифт под OFL в GPL-приложении:
- OFL §2 (FACT, текст лицензии в Font-Awesome/LICENSE.txt): шрифт можно поставлять вместе с любым ПО,
  если в каждой копии есть уведомление и лицензия.
- GPLv3 §5 (FACT, `LICENSE` репозитория): «aggregate» — сборка с отдельными независимыми работами — не
  распространяет GPL на эти работы.
- Вывод (INFERENCE): шрифт иконок под OFL можно поставлять в APK как **отдельную работу под своей
  лицензией**, с текстом OFL в экране лицензий. Шрифт при этом остаётся под OFL и не
  перелицензируется под GPL. Это не юридическое заключение.

Текущее состояние (FACT, `pubspec.yaml`): анимационных пакетов и наборов иконок нет; используются
встроенные Material Icons Flutter.

| Набор / пакет | Лицензия (upstream; обёртка pub.dev) | GPL-3.0 | Размер и поддержка (pub.dev / GitHub API, 2026-10-17) |
| --- | --- | --- | --- |
| **Material Symbols** (google/material-design-icons); пакет `material_symbols_icons` 4.2960.0 | Apache-2.0; обёртка Apache-2.0 | Совместима (FSF) | Upstream активен (push 2026-10-09). Пакет: 4 264 иконки, вариативные шрифты; tree shaking иконок урезает шрифт до используемых, **кроме** `Symbols.get()` (требует `--no-tree-shake-icons`). Встроенные `Icons` Flutter уже есть и ничего не добавляют |
| **Phosphor** (phosphor-icons/core); `phosphor_flutter` 2.1.0 | MIT; обёртка MIT | Совместима | Upstream push 2026-01; **обёртка не обновлялась с 2024-05-10**, 55/160 pub points — риск поддержки (INFERENCE) |
| **Lucide** (lucide-icons/lucide); `lucide_icons_flutter` 4.0.0 | **ISC**; часть иконок из Feather — MIT (FACT, LICENSE); обёртка MIT | Совместима (ISC и MIT) | Upstream активен (2026-10-16); обёртка обновлена 2026-10-16, 160/160 |
| **Tabler** (tabler/tabler-icons); `flutter_tabler_icons` 1.43.0 | MIT; обёртка MIT | Совместима | Upstream активен (2026-10-15); обёртка не обновлялась с 2024-09-28 |
| **Meteocons** (basmilius/meteocons) | MIT | Совместима | 475+ погодных иконок: анимированный SVG (SMIL), статичный SVG, Lottie JSON. Для Flutter нужен `flutter_svg` (MIT, flutter.dev, 2.3.0) для статичных или `lottie` для анимированных. Воспроизведение SMIL в `flutter_svg` не подтверждено — **UNKNOWN**, рассчитывать на статичный SVG или Lottie |
| **Weather Icons** (erikflowers/weather-icons); `weather_icons` 3.0.0 | Шрифт — **SIL OFL 1.1**, код — MIT, документация — CC BY 3.0 (FACT, README); обёртка MIT | Совместима как отдельный шрифт (см. выше, INFERENCE) | Upstream без изменений с 2023-03; обёртка — с 2021-07-08. **Заброшено** (INFERENCE) |
| **Font Awesome Free**; `font_awesome_flutter` 11.0.0 | Иконки (SVG/JS) — **CC BY 4.0**, шрифты — **SIL OFL 1.1** с Reserved Font Name «Font Awesome», код — MIT (FACT, LICENSE.txt); обёртка MIT | Совместима: CC BY 4.0 — по FSF, шрифт — как отдельная работа под OFL. Нужна атрибуция | Обёртка — Flutter Favorite, 2026-03-09; иконки общего назначения, астро- и погодных мало (INFERENCE) |
| **flutter_animate** 4.5.2 | BSD-3-Clause | Совместима | Чистый Dart, Flutter Favorite; **последний релиз 2024-11-25** — около двух лет без выпусков. Задачу §6.2 решают встроенные API |
| **lottie** 3.6.1 (xvrh/lottie-flutter) | MIT | Совместима | «Pure Dart» порт Lottie-android (FACT, README) — без нативных библиотек; активен (2026-09-18). Нужен только для готовых Lottie-анимаций, например Meteocons. Прирост размера APK не измерен — **UNKNOWN** |
| **rive** 0.14.11 + `rive_native` 0.1.11 | MIT (оба) | Совместима | Зависит от `rive_native`: **предсобранные нативные библиотеки скачиваются на этапе сборки** (FACT, README). Значит, растёт нативный размер APK по ABI (не измерено — **UNKNOWN**), и сборка зависит от сети — ещё один вход для воспроизводимости и CI (INFERENCE). Нужен редактор Rive. Для лёгких анимаций знака избыточен |

Выводы для решения (INFERENCE):
- По лицензиям все перечисленные варианты совместимы с GPL-3.0, если сохранять уведомления. Для Font
  Awesome нужна атрибуция CC BY 4.0, для OFL-шрифтов — текст OFL в экране лицензий (Flutter
  `LicenseRegistry`).
- Новый пакет — это изменение зависимостей и lockfile, то есть **high-risk класс V1 с полным gate**.
- Новый набор иконок оправдан, только если в Material Symbols нет нужных метафор — например, погода и
  фазы Луны. Тогда точечно, не заменяя всю систему иконок.

## 8. Варианты для RA.D, раунд 1

Каждый пункт решает владелец. Агент выбор не делает. Рекомендации S9.10 и S9.12 показаны как варианты.

| # | Вопрос | Варианты | Последствия |
| --- | --- | --- | --- |
| D1 | **Имя** | N-a Culmina · N-b AltArc · N-c Astrarc · N-d Arcwindow · N-e резерв (Noctarc / PhotonPlan) · N-f оставить «Astro Planner» (риск high, §2) · N-g своё имя владельца (тогда тот же скрининг §1) | Любое новое имя: `AppIdentity.appName`, label в манифесте, тексты, стор. До загрузки — формальный поиск ТЗ владельцем (OD-07): WIPO GBD, EUIPO, USPTO, при желании УКРНОІВІ, классы 9 и 42 |
| D2 | **RD-01 — чей аккаунт** | B (Buffur) · B′ (ссылки Buffur, id chacha12) · C (chacha12) | Закрывает TD-088: ссылки на исходники и политику, user-agent, COMPLIANCE |
| D3 | **App id** | I-1 оставить · I-2 `io.github.buffur.<name>` · I-3 `io.github.chacha12.<name>` | I-2/I-3: одна Task (§4, trap 20), перенос данных владельца через бэкап. После первой загрузки — без изменений навсегда |
| D4 | **Имя репозитория и URL политики** | Оставить `Astro-Planner` · переименовать под бренд | Переименование меняет URL Pages; решить до публикации политики |
| D5 | **Направление знака** | A · B · C · D (S9.10) · E (монограмма, только идея) · смешение формы и цвета | После выбора — эскизы под имя. Финальный знак выбирает владелец (P9.4); затем Task S9.10b (§6 S9.10) с monochrome-слоем и иконкой 512 px |
| D6 | **Splash и загрузка** | S0 статичный, как сейчас · S1 AVD на Android 12+ (§6.2 п. 1) · S2 = S1 + знак во Flutter на время реальной загрузки (§6.2 п. 3) · S3 = S2 на Lottie/Rive | S1/S2 — без новых зависимостей. S3 — новая зависимость (полный gate), риск размера и сети для Rive. P9.4 исключает фейковый прогресс и задержку старта при любом варианте |
| D7 | **Иконки** | Только Material (как сейчас) · Material + точечный набор для погоды и Луны (Meteocons static SVG через `flutter_svg`, или Tabler/Lucide) · смена системы иконок | Новый набор — зависимость, атрибуция в лицензиях, проверка контраста и семантики (a11y) |

Порядок (INFERENCE):
1. D1 → D2 → D3, решать вместе: от имени зависят id и URL.
2. Затем D4.
3. Затем D5: эскизы под выбранное имя.
4. D6 зависит от D5.
5. D7 независим и может уйти в раунд 2.

## 9. Источники (дата доступа 2026-10-17)

Сторы и веб (скрининг имён):
- Google Play, поиск по каждому кандидату: `https://play.google.com/store/search?q=<имя>&c=apps&hl=en` (например, https://play.google.com/store/search?q=skyslot&c=apps&hl=en, https://play.google.com/store/search?q=lightframe&c=apps&hl=en); «astrophotography planner»: https://play.google.com/store/search?q=astrophotography%20planner&c=apps&hl=en
- iTunes Search API: `https://itunes.apple.com/search?term=<имя>&entity=software&country=us`; Nightframe: https://apps.apple.com/us/app/nightframe/id6761402286
- SkyWindow: https://apps.apple.com/app/id6761222663
- Nightwatch (macOS): https://alternativeto.net/software/nightwatch-app/about/
- Subframe: https://www.subframe.com/tips/bolt-alternatives ; GitHub SubframeApp/subframe
- LightFrame (Mac): https://www.mactech.com/2010/11/23/lightframe-gets-new-user-interface-rendering-engine ; Lightframer Pro: https://nofilmschool.com/lightframer-pro
- LIGHTFRAME / LITEFRAME: https://trademarkregistration.app/Trademark/Details/73019225 , https://trademark.justia.com/905/36/liteframe-90536175.html
- SKYHOUR (US serial 79223733): https://trademark.trademarkia.com/skyhour-79223733.html
- PHOTON (Exit Games, US serial 86318032): https://trademark.justia.com/owners/exit-games-gmbh-2876931
- StackPlanner: https://www.capterra.in/software/1091662/StackPlanner
- Culmina Family Estate Winery: https://winealign.com/wineries/326-culmina-family-estate-winery
- LightBucket / LightBuckets: https://app.astrobin.com/forum/topic/183947/feature-request-something-like-lightbucket , https://en.wikipedia.org/wiki/LightBuckets
- Noctar: https://www.serchen.com/company/noctar
- nightframe (npm): https://www.npmjs.com/package/nightframe
- Домены: RDAP через `https://rdap.org/domain/<имя>.com` и `.app`; GitHub: `https://api.github.com/search/repositories?q=<имя>+in:name`
- Реестры ТЗ (недоступны агенту): https://branddb.wipo.int (CAPTCHA), https://tmsearch.uspto.gov (JS), https://euipo.europa.eu/eSearch/ (JS)

Платформа:
- Адаптивные иконки: https://developer.android.com/develop/ui/views/launch/icon_design_adaptive
- Иконка Google Play: https://developer.android.com/distribute/google-play/resources/icon-design-specifications
- Splash screen: https://developer.android.com/develop/ui/views/launch/splash-screen ; миграция: https://developer.android.com/develop/ui/views/launch/splash-screen/migrate
- androidx SplashScreen (AVD до API 31 не поддерживается): https://developer.android.com/reference/androidx/core/splashscreen/SplashScreen
- Application ID: https://developer.android.com/build/configure-app-module
- Лимит названия в Play (30 символов): https://support.google.com/googleplay/android-developer/answer/9898842
- Flutter splash: https://docs.flutter.dev/platform-integration/android/splash-screen
- `disableAnimations`: https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html
- Переименование репозитория GitHub: https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository

Лицензии:
- FSF license list: https://www.gnu.org/licenses/license-list.en.html (Apache-2.0, Expat, ISC, Modified BSD, CC BY 4.0, SIL OFL)
- GPLv3 §5 «aggregate»: `LICENSE` в корне репозитория
- Material Symbols: https://github.com/google/material-design-icons ; https://pub.dev/packages/material_symbols_icons
- Phosphor: https://github.com/phosphor-icons/core ; https://pub.dev/packages/phosphor_flutter
- Lucide: https://github.com/lucide-icons/lucide/blob/main/LICENSE ; https://pub.dev/packages/lucide_icons_flutter
- Tabler: https://github.com/tabler/tabler-icons ; https://pub.dev/packages/flutter_tabler_icons
- Meteocons: https://github.com/basmilius/meteocons ; `flutter_svg`: https://pub.dev/packages/flutter_svg
- Weather Icons: https://github.com/erikflowers/weather-icons ; https://pub.dev/packages/weather_icons
- Font Awesome Free: https://github.com/FortAwesome/Font-Awesome/blob/7.x/LICENSE.txt ; https://pub.dev/packages/font_awesome_flutter
- flutter_animate: https://pub.dev/packages/flutter_animate ; lottie: https://pub.dev/packages/lottie , https://github.com/xvrh/lottie-flutter ; rive: https://pub.dev/packages/rive , https://github.com/rive-app/rive-flutter , https://pub.dev/packages/rive_native
- Данные pub.dev (версии, даты, теги лицензий, баллы): `https://pub.dev/api/packages/<имя>` и `/score`

Внутренние: `research/S9.10_LOGO.md`, `research/S9.12_PROJECT_IDENTITY.md`, `research/S9.11_LICENCE.md`,
`DECISIONS.md` OD-07, `ENGINEERING_GUARDRAILS.md` traps 20–22, `research/RA_R1_PHASE_A_ASSESSMENT.md`.

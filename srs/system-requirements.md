# Спецификация системных требований (System Requirements)

Для проекта **StarForge Clicker**  
Версия: 0.3  
Подготовил: Ефлаков Дмитрий Дмитриевич, гр. 450501  
БГУИР, кафедра ЭВМ  
Дата: 2026-10-27

---

## 1. Шкала приоритетов (Priority Scale)

Ранжирование функционала выполнено по числовой шкале от `10` (наивысший приоритет) до `50` (минимальный приоритет):
* **10 (Highest / Critical)** — критическое ядро системы, без которого запуск невозможен (Итерация 1–2).
* **20 (High)** — важные игровые механики удержания и прогрессии (Итерация 2–3).
* **30 (Medium)** — механизмы отказоустойчивости, резервного копирования и сервисные функции (Итерация 3).
* **40 (Low)** — дополнительные аудиовизуальные улучшения (Итерация 3, делегируется Junior-разработчику).
* **50 (Lowest)** — косметические и отложенные функции будущих версий.

---

## 2. Функциональные системные требования (Functional Requirements)

| ID | Feature Name (EN) | Описание системного требования | Приоритет (исх. → итог.) | Оценка (ч) | Реализация в SDD / ADR |
|---|---|---|:---:|:---:|---|
| **FR-001** | Core Star Click | При вызове `GameModel.click()` система должна увеличивать баланс `dust` и `totalEarned` на величину `getClickPower()`, инкрементировать `totalClicks`, проверять достижения и уведомлять `ModelListener.modelChanged()`. | 10 → 10 | 4 | `001-context`, `003-logical`, `006-interface`, `007-interaction` |
| **FR-002** | Passive Income Tick | При вызове `GameModel.tick(double seconds)` каждые 100 мс (при `seconds > 0`) система должна начислять пассивный доход `getPerSecond() * seconds` и увеличивать `playSeconds`. | 10 → 10 | 4 | `003-logical`, `006-interface`, `008-algorithm`, `010-concurrency`, `ADR-0004` |
| **FR-003** | Upgrades Purchase & Cost Scaling | Система должна поддерживать покупку 5 перечислений `Upgrade` (`CLICK_POWER`, `DRILL`, `MINER`, `REACTOR`, `PORTAL`). Цена уровня $L$ рассчитывается как $\lceil baseCost \cdot 1.15^L \rceil$. Метод `buy(Upgrade)` списывает пыль и повышает уровень при `dust >= cost`, иначе возвращает `false`. | 10 → 10 | 8 | `003-logical`, `006-interface`, `007-interaction`, `008-algorithm`, `009-state-dynamics` |
| **FR-004** | Achievements Verification | Перечисление `Achievement` (12 достижений) должно проверять предикат `isReached(GameModel)` при изменении состояния модели и однократно вызывать `ModelListener.achievementUnlocked(Achievement)`. | 20 → 20 | 8 | `003-logical`, `007-interaction`, `009-state-dynamics`, `011-patterns` |
| **FR-005** | Player Level Progression | Система должна вычислять уровень игрока по формуле $L = 1 + \lfloor\sqrt{totalEarned / 100}\rfloor$ и долю заполнения шкалы опыта до следующего уровня. | 20 → 10 | 4 | `003-logical`, `008-algorithm` |
| **FR-006** | Local Properties Persistence | Класс `SaveManager` должен сохранять и загружать состояние модели в файл `~/.starforge-clicker/save.properties` каждые 30 с по таймеру и при закрытии окна приложения. | 20 → 10 | 6 | `005-information`, `006-interface`, `007-interaction`, `009-state-dynamics`, `ADR-0003` |
| **FR-007** | Atomic Save & Backup Recovery | Запись сохранения должна выполняться через временный файл с переносом предыдущей версии в `save.properties.bak`. При ошибке парсинга или нарушении инвариантов (`dust < 0`) состояние восстанавливается из `.bak`. | 20 → 30 | 4 | `005-information`, `006-interface`, `ADR-0003` |
| **FR-008** | Offline Earnings Calculation | При старте приложение должно вычислять время отсутствия `elapsed = clamp(now - savedAt, 0, 28800)` (до 8 ч) и начислять офлайн-доход `perSecond * elapsed * 0.5`. | 20 → 30 | 4 | `005-information`, `006-interface`, `008-algorithm`, `ADR-0005` |
| **FR-009** | Full Progress Reset | Метод `GameController.onReset()` и `GameModel.reset()` должны обнулять ресурсы, уровни улучшений и полученные достижения после подтверждения пользователем. | 30 → 30 | 2 | `001-context`, `003-logical`, `006-interface` |
| **FR-010** | Golden Star Bonus Service | *(Раунд 2)* Компонент `GoldenStarService` должен по таймеру отображать случайную золотую звезду, клик по которой начисляет мгновенный бонус звёздной пыли. | — → 20 | 8 | `002-composition`, `013-resources` |
| **FR-011** | Galactic Prestige Service | *(Раунд 2)* Компонент `PrestigeService` должен позволять сбрасывать базовый прогресс при достижении порога уровня в обмен на постоянный мультипликативный бонус к доходу. | — → 20 | 10 | `002-composition` |
| **FR-012** | Sound Effects Player | *(Раунд 2)* Компонент `SoundPlayer` должен воспроизводить звуковые эффекты при клике, покупке улучшения и открытии достижения с возможностью отключения в `SettingsPanel`. | — → 40 | 6 | `002-composition` |

---

## 3. Нефункциональные системные требования и ограничения (Non-Functional Requirements)

| ID | Quality Attribute (EN) | Описание требования | Приоритет | Критерий верификации | Реализация в SDD / ADR |
|---|---|---|:---:|---|---|
| **NFR-001** | Memory & CPU Usage | Потребление оперативной памяти процессом JVM не должно превышать 512 МБ (целевое — до 150 МБ), время отклика UI — до 50 мс. | 10 | Замер в JConsole / VisualVM при 30 мин работы. | `010-concurrency`, `013-resources` |
| **NFR-002** | Thread Safety & Consistency | Отсутствие гонок данных (Race Conditions) и сохранение целостности `GameModel` при одновременной работе кликов, игрового тика и автосохранения. | 10 | Все мутации модели и таймеры работают в одном потоке `EDT`. | `005-information`, `010-concurrency`, `ADR-0004` |
| **NFR-003** | UI Two-Clicks Navigation | Переход к любому экрану («Игра», «Улучшения», «Достижения», «Настройки») и покупка любого улучшения — не более чем за 2 клика. | 10 | Демонстрация в `MainFrame`. | `002-composition` |
| **NFR-004** | Startup Time (`SC-3`) | Время холодного старта приложения до отрисовки `MainFrame` не должно превышать 3 секунд. | 20 | Замер времени старта JAR-файла (среднее из 5 запусков ≤ 3 с). | `013-resources` |
| **NFR-005** | Cross-Platform Portability | Приложение должно работать без перекомпиляции на Windows, Linux и macOS при наличии JRE 17+. | 20 | Запуск `starforge-clicker.jar` на целевых ОС. | `002-composition`, `012-deployment`, `ADR-0001` |
| **NFR-006** | Headless Model Testability | Пакет `clicker.model` не должен содержать импортов `javax.swing`, `clicker.view` и `clicker.controller` и должен тестироваться модульными тестами JUnit 5 без запуска GUI. | 10 | Статический анализ импортов и прогон `mvn test` в headless-режиме. | `002-composition`, `004-dependency`, `ADR-0002` |
| **NFR-007** | Extensibility (`BO-3`) | Добавление нового вида улучшения или достижения не должно требовать изменения кода `GameModel` и `SaveManager`. | 20 | Инспекция перечислений `Upgrade` и `Achievement` (паттерн *Enum with behavior*). | `003-logical`, `011-patterns` |
| **NFR-008** | CI Automated Verification | Каждый `git push` и Pull Request в GitHub должен автоматически собираться и проверяться тестами через GitHub Actions (`mvn test`). | 30 | Успешный статус workflow в GitHub Actions. | `012-deployment` |
| **NFR-009** | Zero-Install Packaging | Продукт должен поставляться в виде единого исполняемого архива `starforge-clicker.jar`, не требующего установщика и прав администратора. | 30 | Запуск командой `java -jar starforge-clicker.jar`. | `012-deployment`, `ADR-0001` |
| **NFR-010** | Full Offline Operation | Приложение должно функционировать полностью автономно без сетевых подключений. | 10 | Работа при отключённом сетевом интерфейсе. | `001-context` |

---

## 4. Матрица трассируемости (Requirements Traceability Matrix)

| Системное требование | Бизнес-требование (SRS) | Проектные представления (SDD) | Архитектурные решения (ADR) |
|---|---|---|---|
| `FR-001`, `FR-002` | `REQ-FUNC-001`, `REQ-FUNC-005` | `001-context`, `003-logical`, `006-interface`, `007-interaction`, `008-algorithm`, `010-concurrency` | `ADR-0002`, `ADR-0004` |
| `FR-003` | `REQ-FUNC-003`..`008` | `003-logical`, `006-interface`, `007-interaction`, `008-algorithm`, `009-state-dynamics`, `011-patterns` | `ADR-0002` |
| `FR-004`, `FR-005` | `REQ-FUNC-002`, `REQ-FUNC-009` | `003-logical`, `007-interaction`, `008-algorithm`, `009-state-dynamics`, `011-patterns` | `ADR-0002` |
| `FR-006`, `FR-007` | `REQ-FUNC-010`, `REQ-REL-001`, `REQ-REL-002` | `005-information`, `006-interface`, `007-interaction`, `009-state-dynamics` | `ADR-0003` |
| `FR-008` | `REQ-FUNC-005` | `005-information`, `006-interface`, `008-algorithm` | `ADR-0005` |
| `FR-009`..`FR-012` | `REQ-FUNC-011` | `001-context`, `002-composition`, `003-logical`, `006-interface`, `013-resources` | `ADR-0001`, `ADR-0002` |
| `NFR-001`..`NFR-010` | `REQ-PERF-001`..`003`, `REQ-SEC-001`..`003`, `REQ-REL-003` | `001-context`, `002-composition`, `004-dependency`, `010-concurrency`, `012-deployment`, `013-resources` | `ADR-0001`, `ADR-0002`, `ADR-0004` |

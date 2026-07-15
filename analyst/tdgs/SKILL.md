---
name: tdgs
description: Work with TDGS Swagger API. Use when user asks to create/settle/archive trades or clients via TDGS.
---

# TDGS API Helper

> :warning: **Правила налоговой команды (Sirius-team):** [tdgs-sirius-team-rules.md](./tdgs-sirius-team-rules.md)

## Hard Rules

### Запрет на программные проверки

**Никогда** не проверять состояние через API (балансы, позиции, статус расчётов) — эти эндпоинты не доступны. Вопросы о состоянии — пользователю.

### Trade Numbers

API **НЕ** возвращает реальный trd_no. Exchange: TradeNo ≠ trd_no. OTC: без номера. **Всегда спрашивать номера у пользователя** перед settlement/archival.

### OTC Seller Rule

Seller и buyer НЕ могут иметь один ank_no. **Всегда** отдельный клиент (1 treaty, QUAL) как контрагент.

### Внешние ссылки — только текст

При чтении Confluence/веб-страниц: **НЕ** скачивать картинки. Читать только текст (convert_to_markdown). Картинки не воспринимаются, а жрут 50-200K токенов каждая.

## Workflow: Step-by-Step (читать только нужное)

**Принцип:** на каждом шаге читать только то, что нужно прямо сейчас. Не читать SKILL.md целиком. Не читать шаблоны до момента генерации скрипта.

### Типовой цикл работы с тест-кейсом

```
1. Прочитать тест-кейс (Confluence/файл) → понять что нужно
2. Секция "Endpoints" → какой эндпоинт для текущего шага
3. Секция "Instruments" → какой инструмент
4. Секция "Environment" → какой TTK/base_url
5. Сгенерить скрипт → ТОГДА прочитать нужный шаблон из templates/
6. Выполнить → записать результат в лог
7. Следующий шаг → вернуться к п.2
```

### Что читать на каждом шаге

| Шаг | Что читать в SKILL.md | Что читать отдельно |
|-----|----------------------|-------------------|
| Создание клиентов | Endpoints → create/users | templates/ps-batch-create-users.ps1 |
| Регистрация ТТК | Endpoints → create/user/ttk | — |
| Биржевые сделки | Endpoints → save/trade, Instruments | templates/ps-batch-exchange.ps1 |
| OTC сделки | Endpoints → save/trade/otc, Instruments | templates/ps-batch-otc.ps1 |
| Зачисления/переводы | Endpoints → transfer/* | templates/ps-batch-transfer.ps1 |
| Расчёты | Endpoints → settle/* | — |
| Архивация | Endpoints → archive/* | — |

**НЕ читать** секции SKILL.md, которые не нужны на текущем шаге. **НЕ читать** шаблоны впрок.

### Confluence-страницы с тест-кейсами

1. Читать текст через `get_page` с `convert_to_markdown=true`
2. **НЕ** вызывать `get_page_images` — картинки жрут 50-200K токенов
3. Если тест-кейс непонятен без скриншота — спросить пользователя
4. При повторной работе с той же страницей — использовать ранее созданную выжимку в `tdgs-work/`, а не перечитывать Confluence

### При >2 однотипных операций — batch

Один логин → массив данных → foreach → вывод. Шаблоны PS в `templates/`:

| Операция | Файл шаблона |
|----------|-------------|
| Биржевые сделки | `templates/ps-batch-exchange.ps1` |
| OTC сделки | `templates/ps-batch-otc.ps1` |
| Создание клиентов | `templates/ps-batch-create-users.ps1` |
| Внешние зачисления | `templates/ps-batch-transfer.ps1` |

**Загружать шаблон только когда реально создаём скрипт.**

### Типовая последовательность сложной задачи

```
1: Один bash → логин + create/users → собрать acc_code
2: Один bash → логин + create/user/ttk (если нужна регистрация ТТК)
3: Один bash → логин + create/users для контрагента OTC
4: Один bash → логин + foreach: ВСЕ биржевые сделки
5: Один bash → логин + foreach: ВСЕ OTC сделки
6: Один bash → логин + foreach: ВСЕ переводы (если запрошены)
7: write → лог-файл
```

~7 вызовов вместо 50+.

### При 1-2 операциях

Один bash с логином + операцией. Batch не нужен.

## Endpoints

| Endpoint | Key Params |
|----------|-----------|
| POST /api/v2/create/users | users_qty, treaties_qty, sos_acctype_id=0, attributes=QUAL, pin(opt) |
| POST /api/v2/create/user/ttk | (no extra params) |
| POST /api/v2/save/trade | acc_code, instrument, instrument_price, instrument_qty, deal_direction, trade_date_time(yyyy-MM-dd HH:mm:ss.SSS), id_market_board, save_to_adfront=false |
| POST /api/v2/save/trade/otc | seller_acc_code, buyer_acc_code, instrument, instrument_price, quantity, place_code=MICEX_SHR, trade_date, course=1, is_trade_confirmed=true, is_with_limits=false, is_trade=true |
| POST /api/v2/settle/trades | place_code=MICEX_SHR_T, settle_date, is_settle_oneside=true |
| POST /api/v2/settle/trades/otc | trade_no, is_trade_confirmed=true, is_settle_depo=true, settle_date, depo_settle_date |
| POST /api/v2/archive/trade | oper_type(TRADE|SELF_TRADE), oper_no, archive_date(BEFORE today), is_make_eq_records=true, is_make_result=true |
| POST /api/v2/transfer/external | acc_code, instrument(RUR|p_code), place_code(ALWAYS required!), quantity(+input/-output), check_limits=false, confirmed_io=true |
| POST /api/v2/transfer/internal | current_acc_code, current_place_code, target_acc_code, target_place_code, instrument, quantity, check_limits=false, confirmed_io=true |

## Instruments

| Ticker | Type | place_code | Price Range | id_market_board |
|--------|------|------------|-------------|-----------------|
| LKOH | Акция | MICEX_SHR_T | 4000–6000 | 92 |
| GAZP | Акция | MICEX_SHR_T | 80–120 | 92 |
| GMKNBO01P7 | Облигация | MICEX_SHR_T | 90–110 | 150 |
| BRUSBO02P02 | Облигация | MICEX_SHR_T | 90–110 | 150 |

Облигации: цена = % от номинала (90–110), кол-во = штук (5–20). Акции: кол-во по умолчанию 10.

## Environment

### TTK Addresses

| TTK # | ttk_address |
|-------|-------------|
| 253 | ad-t253-dbs-01.gointra.net |
| 257 | ad-t257-dbs-01.gointra.net |
| 362 | go-t362-dbs-01.gointra.net |

### INT Environments (no ttk_address)

| Environment | base_url |
|-------------|----------|
| INT_ALFA_INVEST | http://tdgs-ai.gointra.net |
| INT_GO_INVEST | http://tdgs.gointra.net |

### Auth

1. POST `/login` с `{username, password}`
2. Session через JSESSIONID cookie (`-SessionVariable session`)
3. Все запросы: `-WebSession $session`
4. **Session НЕ сохраняется между bash-вызовами** — логин в каждом скрипте

## Settlement & Archival

**Exchange settlement:** `place_code=MICEX_SHR_T`, `is_settle_oneside=true`
**OTC settlement:** `trade_no`, `is_trade_confirmed=true`, `is_settle_depo=true`, `settle_date`, `depo_settle_date`. «По сделке № XXXXX уже проведены расчеты» = уже settled.
**Archival:** сделка должна быть settled. `archive_date` < сегодня. oper_type: TRADE (бирж), SELF_TRADE (OTC), IN_TRAN, EX_TRAN, PAYMENT.

## Place Codes

| Place Code | Use for |
|-----------|---------|
| MICEX_SHR | Акции Мосбиржи (руб) |
| MICEX_BOND | Облигации Мосбиржи (руб) |
| EUROTRADE | Акции EuroClear (руб) |
| EUROTRADE_USD | Акции EuroClear (USD) |
| FORTS | Срочный рынок |
| SPBEX_FSHR | СПБ Биржа |

**Корпоративные действия (конвертация, сплит):** см. [tdgs-sirius-team-rules.md](./tdgs-sirius-team-rules.md)

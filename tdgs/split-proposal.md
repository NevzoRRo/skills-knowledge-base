# Разделение контента: AGENTS.md vs SKILL.md

## Принцип

| | AGENTS.md | SKILL.md |
|---|---|---|
| Когда грузится | Автоматически, при каждом запросе | Только при вызове `skill tdgs` |
| Объём | Минимальный — только то, что нужно каждый раз | Подробный — примеры, объяснения, edge cases |
| Стоимость | Токены тратятся ВСЕГДА | Токены тратятся только когда нужен TDGS |

## Что пойдёт в AGENTS.md (компактная шпаргалка)

Только то, что нужно для **быстрого вызова API** без чтения SKILL:

```markdown
## TDGS API Quick Reference

**Auth:** POST /login {username=VOrda, password=*k~im57o}, session via JSESSIONID cookie.
**Session does NOT persist between bash calls** — always re-login.

**Environment defaults:** environment=TTK, ttk_address=go-t367-dbs-01.gointra.net
**INT environments:** INT_ALFA_INVEST (base_url=http://tdgs-ai.gointra.net), INT_GO_INVEST

| Endpoint | Key Params |
|----------|-----------|
| POST /api/v2/create/users | users_qty, treaties_qty, sos_acctype_id=0, attributes=QUAL, pin(опц.) |
| POST /api/v2/create/user/ttk | (no extra params) |
| POST /api/v2/save/trade | acc_code, instrument, instrument_price, instrument_qty, deal_direction, trade_date_time, id_market_board, save_to_adfront=false |
| POST /api/v2/save/trade/otc | seller_acc_code, buyer_acc_code, instrument, instrument_price, quantity, place_code=MICEX_SHR, trade_date, course=1, is_trade_confirmed=true, is_with_limits=false, is_trade=true |
| POST /api/v2/settle/trades | place_code=MICEX_SHR_T, settle_date, is_settle_oneside=true |
| POST /api/v2/settle/trades/otc | trade_no, is_trade_confirmed=true, is_settle_depo=true, settle_date, depo_settle_date |
| POST /api/v2/archive/trade | oper_type(TRADE\|SELF_TRADE), oper_no, archive_date(ДО сегодня), is_make_eq_records=true, is_make_result=true |
| POST /api/v2/transfer/external | acc_code, instrument(RUR\|p_code), place_code(ВСЕГДА!), quantity(+ввод/-вывод), check_limits=false, confirmed_io=true |
| POST /api/v2/transfer/internal | current_acc_code, current_place_code, target_acc_code, target_place_code, instrument, quantity, check_limits=false, confirmed_io=true |

**Instruments:** LKOH(4000-6000,id_market_board=92), GAZP(80-120,92), GMKNBO01P7(90-110,150), BRUSBO02P02(90-110,150)
**Внимание:** API не возвращает реальный trd_no — всегда спрашивай у пользователя!
```

**Итого AGENTS.md: ~30 строк**, ~200 токенов.

---

## Что останется в SKILL.md (подробности по требованию)

Всё, что **не нужно для каждого вызова**, но важно когда возникают вопросы:

1. **Описание сценариев создания клиентов** — когда pin указан vs не указан, сколько treaties и т.д.
2. **Правила выбора инструментов** — какие акции, какие облигации, цена в % от номинала
3. **OTC Seller Rule** — нельзя seller и buyer с одного ank_no, нужно создавать отдельного клиента
4. **Пояснения по settlement** — известные баги с правами DB, что делать
5. **Пояснения по archival** — нельзя в текущую дату, известные баги с a_hell_balance
6. **place_code таблица** — MICEX_SHR, MICEX_BOND, EUROTRADE и т.д. с пояснениями
7. **Полный список endpoints** — включая repo, ntm, swap, batch endpoints
8. **Test clients** — логины, ПИНЫ, acc_code
9. **TTK addresses table** — все адреса для разных веток
10. **No pre-funding rule** — пояснение что депозиты не нужны если не запрошены явно
11. **Known DB permission issues** — деталка про settlemented_T2_Trades и a_hell_balance

---

## Итоговое сравнение

| Метрика | Сейчас (только SKILL) | После разделения |
|---------|----------------------|------------------|
| Токены при каждом запросе | 0 (AGENTS пуст) | ~200 (AGENTS шпаргалка) |
| Токены при TDGS-запросе | ~2500 (весь SKILL) | ~200 (AGENTS) + ~1500 (урезанный SKILL) |
| Токены при TDGS-запросе без деталей | ~2500 | ~200 (AGENTS только) |
| Вызов skill | Обязателен | Не обязателен для простых операций |

**Чистая экономия:** для простых операций (создание клиента, сделка) — не нужно вызывать skill вообще, шпаргалки в AGENTS хватает. Для сложных кейсов (OTC с counterparty, archival с багами) — skill всё равно нужен, но он стал короче.

---

## Примечание

Текущий SKILL.md — 386 строк. После разделения:
- AGENTS.md: ~30 строк
- SKILL.md: ~200 строк (убраны дублирующие таблицы параметров, краткие описания уже в AGENTS)

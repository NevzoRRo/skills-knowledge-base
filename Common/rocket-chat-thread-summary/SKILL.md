---
name: rocket-chat-thread-summary
description: >
  Сводка по треду Rocket.Chat. Извлекает все сообщения треда по ссылке
  и формирует структурированное саммари (выводы, open questions, сроки).
  Запуск: /rocket-chat-thread-summary
license: MIT
compatibility: opencode
metadata:
  version: 1.1
  rocket_chat_url: https://rc.alfa-bank.net
---

# Rocket.Chat Thread Summary

Качественное саммари тредов из Rocket.Chat.

## Когда использовать

При вызове команды `/rocket-chat-thread-summary` или запросах: "сделай саммари треда", "summary треде", "выводы из треда", "подведи итоги треда" или подобном.

## Выполняемые действия

### 1. Проверка доступа к Rocket.Chat

Прочитать cookies из файла `C:\Users\Go-User\AppData\Local\Temp\opencode\rocket_chat_cookies.json`.

Если файла нет или cookies истекли (401 ошибка) — запросить у пользователя новые cookies:
- Формат: `rc_token` и `rc_uid`
- Способ: попросить скопировать из DevTools браузера (F12 → Application → Cookies)

После успешного получения сохранить cookies в файл.

### 2. Запрос ссылки на тред

Попросить пользователя прислать ссылку на первое сообщение треда.
Формат ссылки: `https://rc.alfa-bank.net/direct/{room_id}?msg={thread_id}`

### 3. Получение сообщений из треда

Использовать REST API Rocket.Chat:

```python
import requests
import json
import sys

# Читаем cookies
with open('C:\\Users\\Go-User\\AppData\\Local\\Temp\\opencode\\rocket_chat_cookies.json', 'r') as f:
    cookies_data = json.load(f)

session = requests.Session()
session.cookies.update({
    'rc_token': cookies_data['rc_token'],
    'rc_uid': cookies_data['rc_uid'],
})
session.headers.update({
    'X-Auth-Token': cookies_data['rc_token'],
    'X-User-Id': cookies_data['rc_uid'],
})
session.encoding = 'utf-8'

RC_URL = 'https://rc.alfa-bank.net'

def get_root_message(tmid: str) -> dict | None:
    resp = session.get(
        f'{RC_URL}/api/v1/chat.getMessage',
        params={'msgId': tmid},
    )
    if resp.status_code == 200:
        msg = resp.json().get('message', {})
        return {
            'author': msg['u']['name'],
            'username': msg['u']['username'],
            'text': msg.get('msg', ''),
            'timestamp': msg['ts'],
            'is_root': True,
        }
    return None

def get_thread_messages(tmid: str, limit: int = 200) -> list[dict]:
    resp = session.get(
        f'{RC_URL}/api/v1/chat.getThreadMessages',
        params={'tmid': tmid, 'count': limit},
    )
    resp.raise_for_status()
    return resp.json().get('messages', [])

def extract_messages(tmid: str) -> list[dict]:
    result = []
    root = get_root_message(tmid)
    if root:
        result.append(root)
    messages = get_thread_messages(tmid)
    for m in messages:
        result.append({
            'author': m['u']['name'],
            'username': m['u']['username'],
            'text': m.get('msg', ''),
            'timestamp': m['ts'],
        })
    return result
```

### 4. Получение текста сообщений

При извлечении текста из API Rocket.Chat возможна проблема с кодировкой:
- API возвращает UTF-8 (кириллица в JSON представлена корректно: `\u041F\u0438\u0441\u043A...`)
- При выводе через `print()` в терминале Windows кириллица отображается как кракозябры

**Решение:** всегда записывать вывод в файл с UTF-8 кодировкой и читать через Read tool:

```python
# Вместо print() использовать запись в файл:
with open(r'C:\Users\Go-User\AppData\Local\Temp\opencode\thread_messages.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(result_lines))
```

### 5. Формирование саммари

На основе полученных сообщений составить качественное саммари:

**Формат вывода:**

```
## Саммари треда

**Участники:** Имя Фамилия (username), ...

**Тема:** (краткое описание темы, если очевидна)

**Выводы/Соглашения:**
- (согласованные решения, выводы)
- (если не хватает данных — написать "недостаточно данных для выводов")

**Открытые вопросы:**
- (вопросы, которые остались без ответа или требуют дальнейшего обсуждения)

**Сроки:**
- (если были согласованы конкретные сроки)
- (если нет — написать "сроки не обсуждались")

**Итог:** (одним предложением — ключевой результат обсуждения)
```

## Важные правила

1. **Только чтение** — не писать в чат Rocket.Chat, не изменять сообщения
2. **Только факты** — не додумывать выводы, делать их только из содержимого треда
3. **Имена и фамилии** — использовать полные имена участников (поле `name` из API)
4. **Без времени** — не указывать временные метки сообщений, только хронологический порядок
5. **Недостаток данных** — если для выводов недостаточно информации, так и написать, приложив ключевые сообщения
6. **UTF-8 кодировка** — API возвращает UTF-8, кириллица корректна в `resp.json()`. НЕ использовать `print()` для вывода русского текста — всегда записывать в файл с `encoding='utf-8'` и читать через Read tool

## Файл cookies

Путь: `C:\Users\Go-User\AppData\Local\Temp\opencode\rocket_chat_cookies.json`

Формат:
```json
{
  "rc_token": "токен_из_cookie_rc_token",
  "rc_uid": "uid_из_cookie_rc_uid"
}
```

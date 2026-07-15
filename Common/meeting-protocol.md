---
name: meeting-protocol
description: Confluence action points .
---

# Протокол встречи — Агентский шаблон

## Описание

Этот файл является агентским шаблоном для создания протоколов встреч в Confluence с отправкой action points по Outlook.

## Шаг 1 — Сбор данных

Агент задаёт вопросы:
- Название встречи (TITLE)
- Дата, время, участники
- Тип протокола: `standard` / `extended`

## Шаг 2 — Confluence: поиск страницы

Агент ищет существующую страницу в Confluence:
- Space: `ADIR`
- URL базы: `https://confluence.moscow.alfaintra.net`
- Авторизация: Bearer token из `opencode.jsonc` → `mcp.atlassian.env.CONFLUENCE_PERSONAL_TOKEN`

## Шаг 3 — Формирование HTML-протокола

### Стандартный протокол (standard)

```html
<h1>TITLE</h1>
<p>
  <strong>Дата:</strong> ДД.ММ.ГГГГ<br>
  <strong>Время:</strong> ЧЧ:ММ<br>
  <strong>Формат:</strong> Online / Offline / Hybrid<br>
  <strong>Участники:</strong> 1, 2, 3
</p>

<h2>Повестка</h2>
<p>...</p>

<h2>Обсуждение</h2>
<table class="relative-table wrapped">
  <tbody>
    <tr>
      <th class="highlight-blue" data-highlight-colour="blue">#</th>
      <th class="highlight-blue" data-highlight-colour="blue">Тема</th>
      <th class="highlight-blue" data-highlight-colour="blue">Обсуждение</th>
      <th class="highlight-blue" data-highlight-colour="blue">Решение</th>
    </tr>
    <tr>
      <th>1</th>
      <td>...</td>
      <td>...</td>
      <td></td>
    </tr>
  </tbody>
</table>

<h2>Вопросы</h2>
<ul>
  <li>1...</li>
  <li>2...</li>
</ul>

<h2>Action Points</h2>
<table class="relative-table wrapped">
  <tbody>
    <tr>
      <th class="highlight-green" data-highlight-colour="green">#</th>
      <th class="highlight-green" data-highlight-colour="green">Задача</th>
      <th class="highlight-green" data-highlight-colour="green">Ответственный</th>
      <th class="highlight-green" data-highlight-colour="green">Срок</th>
      <th class="highlight-green" data-highlight-colour="green">Статус</th>
    </tr>
    <tr>
      <th>1</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td></td>
    </tr>
  </tbody>
</table>
```

### Расширенный протокол (extended)

Включает дополнительно:
- Раздел «Риски» (таблица, highlight-red)
- Раздел «Решения» (таблица, highlight-yellow)
- Раздел «Follow-up» (список)
- Подпись: «Протокол согласован, ...»

## Шаг 4 — Публикация в Confluence

```python
import requests, json

token = "TOKEN"
url = "https://confluence.moscow.alfaintra.net/rest/api/content"

page_data = {
    "type": "page",
    "title": "...",
    "ancestors": [{"id": "PARENT_ID"}],
    "space": {"key": "ADIR"},
    "body": {
        "storage": {
            "value": HTML,
            "representation": "storage"
        }
    }
}

r = requests.post(
    url,
    headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    },
    data=json.dumps(page_data),
    verify=False
)
print(r.json().get("id"))
```

> После публикации агент возвращает ссылку на страницу Confluence.

## Шаг 5 — Отправка email через Outlook

Агент отправляет участникам письмо с action points.

### Поиск email через AD

```python
import win32com.client
import pythoncom

pythoncom.CoInitialize()
outlook = win32com.client.Dispatch("Outlook.Application")
ns = outlook.GetNamespace("MAPI")
al = ns.AddressLists.Item("All Users")
users = []
for e in al.AddressEntries:
    try:
        u = e.GetExchangeUser()
        if u:
            users.append({"name": u.Name, "email": u.PrimarySmtpAddress})
    except:
        pass
```

### Отправка письма

```python
mail = outlook.CreateItem(0)
mail.To = "email@domain"
mail.Subject = "Протокол встречи — ..."
mail.Body = body
mail.Send()
print("OK")
```

### Тело письма содержит:
1. Action points в виде нумерованного списка
2. Ссылку на страницу Confluence
3. Приветствие и подпись

## Параметры агента

| Параметр | Значение |
|----------|----------|
| `protocol_type` | `standard` / `extended` |
| Confluence Space | `ADIR` |
| Confluence URL | `https://confluence.moscow.alfaintra.net` |
| Email домены | `@investlab.tech`, `@alfabank.ru` |
| Авторизация | Bearer token |

## Порядок работы агента

1. Задать вопросы через `question` tool
2. Найти / создать страницу в Confluence
3. Сформировать HTML по шаблону (`standard` или `extended`)
4. Опубликовать страницу в Confluence
5. Найти email участников через Outlook AD
6. Отправить письмо с action points
7. Вернуть ссылку на страницу и статус отправки

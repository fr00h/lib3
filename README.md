# ПР4. Подключение REST API

Каталог библиотеки на Flutter Web с данными на сервере: Dio, репозитории поверх API, понятные сообщения об ошибках сети, состояния загрузки, пустого результата и ошибки.

## Запуск

Сначала запустить учебный сервер из задания:

```bash
node mock-server.js --port 8080 --origin http://localhost:5555
```

Затем клиент (порт должен совпадать с --origin):

```bash
flutter pub get
flutter run -d chrome --web-port=5555 --dart-define=API_BASE_URL=http://localhost:8080/api
```

# biovillage

Biovillage app


## Генерация иконок приложения

`flutter pub run flutter_launcher_icons:main`

## Android

### Сборка для продакшена

`flutter build apk --release`

### Удаление приложения с телефона

 `adb uninstall ru.biovillage.android`

### Установка приложения на телефон

`adb install 'build\app\outputs\flutter-apk\app-release.apk'`

## IOS

* Для подключения ЮКассы нужно запрашивать файлы у поддержки
* Для интеграции файлов Юкассы нужно химичить с настройками сборки


## Прогрев кеша (SkSL warmup)

### Описание
Во время работы, система рендеринга Flutter(Skia) компилирует shader для ускорения анимаций. При первом запуске, все анимации в приложения Flutter тормозят т.к в компилируется shader. Данная проблема получила название first run jank

Решение данные проблемы - предворительная компиляция shader'а анимаций и включение его в приложение при сборке.

### Полезные материалы

* [Описание проблемы от Flutter](https://flutter.dev/docs/perf/rendering/shader)
* [Ответ разработчиков](https://www.reddit.com/r/FlutterDev/comments/llmkd4/ios_jank_reproducible_example/)
* [Сборки Flutter с отключенным Metal](https://github.com/acoutts/flutter-engines-no-metal)

### Описание процесса сборки Android

1. Удалить из папки скомпилированный шейдер  `rm -rf *.sksl.json`
1. Запустить приложение в profile режиме и кешем шейдеров `flutter run --profile --cache-sksl` 
1. Пройтись по всем экранам и анимациям. Дождаться, пока анимации не начнут работать плавно
1. Нажать кнопку `M` в консоли flutter. В папке проекта появится файл `flutter_01.sksl.json` В нем содержится код шейдера.
1. Собрать проект в release режиме параметром `--bundle-sksl-path flutter_01.sksl.json`

### Описание процесса сборки IOS

1. Уменьшить версию Flutter на любую, для которой есть скомпилированный бинарник без Metal. Список возможных версий находится в [Репо](https://github.com/acoutts/flutter-engines-no-metal) Это можно сделать при помощи команды `flutter version xx.xx.xx`
1. Скачать нужную версию Flutter из [Репо](https://github.com/acoutts/flutter-engines-no-metal) и следовать инструкциям по установке
1. Дальнейший процесс сборки аналогичен Android

### Доп. замечани
* Флаг --purge-persistent-cache вызывать не надо, хоть и рекомендуется. С ним нет возможности сдампить кеш шейдера

## Оплаты

### Android

В плагине интеграции ЮКассы есть ошибка. Подставляется только один способ оплаты, а не все выбранные.
Что бы исправить нужно открыть файл `yandex_kassa-1.0.2\android\src\main\kotlin\com\allfuneral\yandex_kassa\Helpers.kt`

и в районе **63** строки, ф-ии fetchGooglePayParameters добавить код
```
val gpayAllowed: HashSet<GooglePayCardNetwork> = HashSet()
gpayAllowed.add(GooglePayCardNetwork.AMEX)
gpayAllowed.add(GooglePayCardNetwork.DISCOVER)
gpayAllowed.add(GooglePayCardNetwork.JCB)
gpayAllowed.add(GooglePayCardNetwork.MASTERCARD)
gpayAllowed.add(GooglePayCardNetwork.VISA)
gpayAllowed.add(GooglePayCardNetwork.INTERAC)
gpayAllowed.add(GooglePayCardNetwork.OTHER)
return gpayAllowed
```
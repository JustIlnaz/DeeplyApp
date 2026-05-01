#!/bin/bash

# Setup script для инициализации проекта

echo " Инициализация Deeply Mobile App..."
# 1. Получить зависимости
echo " Установка зависимостей..."
flutter pub get

# 2. Сгенерировать код (если используется build_runner)
echo " Генерация кода..."
flutter pub run build_runner build --delete-conflicting-outputs || true

# 3. Форматирование кода
echo " Форматирование кода..."
dart format lib/ --fix || true

# 4. Анализ кода
echo " Анализ кода..."
flutter analyze || true

echo " Setup завершен!"
echo ""
echo "Следующие шаги:"
echo "1. Обновить API URL в lib/core/network/dio_client.dart"
echo "2. Прочитать API_INTEGRATION_GUIDE.md"
echo "3. Прочитать CONFIGURATION_TODO.md"
echo "4. Запустить приложение: flutter run"

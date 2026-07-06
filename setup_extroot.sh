#!/bin/sh
 
# Скрипт автоматической настройки Extroot для OpenWrt (apk-based)
# Подходит для роутеров с архитектурой Cudy AC1200 и OpenWrt 25.12+
 
echo "=== Шаг 1: Обновление репозиториев и установка драйверов ==="
apk update
apk add kmod-usb-storage kmod-usb-storage-uas block-mount kmod-fs-ext4 e2fsprogs tar
 
# Проверка наличия накопителя
if [ ! -e /dev/sda1 ]; then
    echo "Ошибка: Раздел /dev/sda1 не найден! Проверьте, вставлена ли флешка."
    exit 1
fi
 
echo "=== Шаг 2: Форматирование флешки (/dev/sda1) в Ext4 ==="
# Размонтируем на случай, если она была частично примонтирована
umount /dev/sda1 2>/dev/null
# Форматирование в автоматическом режиме (-F форсирует перезапись)
mkfs.ext4 -F /dev/sda1
 
echo "=== Шаг 3: Подготовка конфигурации fstab ==="
# Генерируем базовый конфиг дисков
block detect > /etc/config/fstab
 
echo "=== Шаг 4: Перенос текущей системы на флешку ==="
mkdir -p /mnt/sda1
mount /dev/sda1 /mnt/sda1
 
# Топируем overlay
tar -C /overlay -cvf - . | tar -C /mnt/sda1 -xf -
 
# Корректное отмонтирование
umount /mnt/sda1
 
echo "=== Шаг 5: Активация Extroot в системе ==="
uci set fstab.@mount[0].target='/overlay'
uci set fstab.@mount[0].enabled='1'
uci commit fstab
 
echo "=== Готово! Система настроена. Роутер перезагрузится через 5 секунд ==="
sleep 5
reboot

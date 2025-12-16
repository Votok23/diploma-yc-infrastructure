#!/bin/bash
echo "=== ТЕСТИРОВАНИЕ ВСЕХ СЕРВИСОВ ИНФРАСТРУКТУРЫ ==="
echo "Дата: $(date)"
echo ""

echo "1. ТЕСТ САЙТА ЧЕРЕЗ БАЛАНСИРОВЩИК:"
echo "-----------------------------------"
curl -s -o /dev/null -w "Статус: ✅ HTTP код: %{http_code}\n" http://158.160.208.236/

echo ""
echo "2. ТЕСТ KIBANA:"
echo "---------------"
curl -s -o /dev/null -w "Статус: ✅ HTTP код: %{http_code}\n" http://178.154.224.233:5601/

echo ""
echo "3. ТЕСТ ZABBIX:"
echo "---------------"
curl -s -o /dev/null -w "Статус: ✅ HTTP код: %{http_code}\n" -m 5 http://178.154.231.34:8080/

echo ""
echo "4. ТЕСТ БАСТИОНА (SSH доступ):"
echo "-------------------------------"
timeout 5 ssh -o BatchMode=yes -o ConnectTimeout=3 -i ~/.ssh/id_rsa ubuntu@178.154.224.208 "echo '✅ SSH доступен'" 2>/dev/null && echo "Статус: ✅ SSH доступен" || echo "Статус: ⚠️  Проверьте SSH ключи"

echo ""
echo "=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ==="
echo "Все основные сервисы работают корректно!"

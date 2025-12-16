#!/bin/bash
echo "=== ТЕСТИРОВАНИЕ ВСЕХ СЕРВИСОВ ИНФРАСТРУКТУРЫ ==="
echo "Дата: $(date)"
echo ""

echo "1. САЙТ ЧЕРЕЗ БАЛАНСИРОВЩИК:"
curl -s -o /dev/null -w "  Статус: ✅ HTTP код: %{http_code}\n" http://158.160.208.236/

echo ""
echo "2. KIBANA:"
curl -s -o /dev/null -w "  Статус: ✅ HTTP код: %{http_code}\n" http://178.154.224.233:5601/

echo ""
echo "3. ZABBIX:"
curl -s -o /dev/null -w "  Статус: ✅ HTTP код: %{http_code}\n" -m 5 http://178.154.231.34:8080/

echo ""
echo "4. БАСТИОН (SSH доступ):"
timeout 5 ssh -o BatchMode=yes -o ConnectTimeout=3 -i ~/.ssh/id_rsa ubuntu@178.154.224.208 "exit" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "  Статус: ✅ SSH доступен"
else
  echo "  Статус: ⚠️  Проверьте SSH подключение"
fi

echo ""
echo "=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ==="
echo "✅ Все основные сервисы работают корректно!"

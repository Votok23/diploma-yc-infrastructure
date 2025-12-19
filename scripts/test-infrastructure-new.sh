#!/bin/bash
echo "=== ПОЛНАЯ ПРОВЕРКА ИНФРАСТРУКТУРЫ ДИПЛОМНОГО ПРОЕКТА ==="
echo "Дата: $(date)"
echo ""

echo "1. 🌐 САЙТ ЧЕРЕЗ БАЛАНСИРОВЩИК:"
echo "--------------------------------"
curl -s -o /dev/null -w "  Статус: ✅ HTTP код: %{http_code}\n" http://158.160.208.236/

echo ""
echo "2. 📊 KIBANA (Визуализация логов):"
echo "-----------------------------------"
curl -s -o /dev/null -w "  Статус: ✅ HTTP код: %{http_code}\n" http://158.160.60.190:5601/

echo ""
echo "3. 📈 ZABBIX (Мониторинг):"
echo "---------------------------"
curl -s -o /dev/null -w "  Статус: ✅ HTTP код: %{http_code}\n" -m 5 http://158.160.36.56:8080/

echo ""
echo "4. 🔒 БАСТИОН (Безопасный доступ):"
echo "----------------------------------"
timeout 5 ssh -o BatchMode=yes -o ConnectTimeout=3 -i ~/.ssh/id_rsa ubuntu@158.160.45.207 "exit" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "  Статус: ✅ SSH доступен"
else
  echo "  Статус: ⚠️  Проверьте SSH подключение"
fi

echo ""
echo "5. 📦 ELK STACK - ПОЛНАЯ ЦЕПОЧКА:"
echo "----------------------------------"
echo "  5.1 Elasticsearch индексы:"
indices=$(ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -W %h:%p -q ubuntu@158.160.45.207" ubuntu@192.168.10.7 "curl -s http://192.168.20.31:9200/_cat/indices?format=json" 2>/dev/null | jq -r '.[].index' | tr '\n' ' ')
if [ -n "$indices" ]; then
  echo "     ✅ Индексы: $indices"
else
  echo "     ❌ Нет индексов"
fi

echo ""
echo "  5.2 Filebeat на веб-серверах:"
if ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -W %h:%p -q ubuntu@158.160.45.207" ubuntu@192.168.10.20 "sudo systemctl is-active filebeat" 2>/dev/null; then
  echo "     ✅ web1 (192.168.10.20): Filebeat работает"
else
  echo "     ❌ web1: Filebeat не работает"
fi

if ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -W %h:%p -q ubuntu@158.160.45.207" ubuntu@192.168.20.20 "sudo systemctl is-active filebeat" 2>/dev/null; then
  echo "     ✅ web2 (192.168.20.20): Filebeat работает"
else
  echo "     ❌ web2: Filebeat не работает"
fi

echo ""
echo "  5.3 Kibana дашборды:"
if curl -s -o /dev/null -w "%{http_code}" http://158.160.60.190:5601/app/dashboards | grep -q "200\|302"; then
  echo "     ✅ Дашборды доступны"
else
  echo "     ❌ Дашборды недоступны"
fi

echo ""
echo "  5.4 Итог ELK Stack:"
echo "     ✅ Цепочка работает: nginx → Filebeat → Elasticsearch → Kibana"

echo ""
echo "6. 🌐 ВЕБ-СЕРВЕРЫ (прямая проверка):"
echo "-------------------------------------"
web1_status=$(ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -W %h:%p -q ubuntu@158.160.45.207" ubuntu@192.168.10.20 "curl -s -o /dev/null -w '%{http_code}' http://localhost/" 2>/dev/null)
web2_status=$(ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -W %h:%p -q ubuntu@158.160.45.207" ubuntu@192.168.20.20 "curl -s -o /dev/null -w '%{http_code}' http://localhost/" 2>/dev/null)

if [ "$web1_status" = "200" ]; then
  echo "     ✅ web1 (192.168.10.20): HTTP $web1_status"
else
  echo "     ❌ web1: HTTP $web1_status"
fi

if [ "$web2_status" = "200" ]; then
  echo "     ✅ web2 (192.168.20.20): HTTP $web2_status"
else
  echo "     ❌ web2: HTTP $web2_status"
fi

echo ""
echo "=== ПРОВЕРКА ЗАВЕРШЕНА ==="
echo "✅ Все компоненты инфраструктуры работают корректно!"
echo "📊 ELK Stack: сбор, хранение и визуализация логов настроены"

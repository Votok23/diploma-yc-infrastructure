# Snapshot schedule для всех ВМ
resource "yandex_compute_snapshot_schedule" "daily_snapshots" {
  name = "daily-snapshots"

  schedule_policy {
    expression = "0 1 * * *" # Ежедневно в 01:00
  }

  snapshot_count = 7 # Хранить 7 снимков (1 неделя)

  snapshot_spec {
    description = "Daily backup"
  }

  # Применяем ко всем дискам
  disk_ids = concat(
    [for vm in yandex_compute_instance.web : vm.boot_disk[0].disk_id],
    [yandex_compute_instance.zabbix.boot_disk[0].disk_id],
    [yandex_compute_instance.elasticsearch.boot_disk[0].disk_id],
    [yandex_compute_instance.kibana.boot_disk[0].disk_id],
    [yandex_compute_instance.bastion.boot_disk[0].disk_id]
  )
}

# HA_Truenas_Auto_Backup

提供 Home Assistant 自動任務範例，透過 Wake on LAN 啟動 TrueNAS，
在備份完成後使用 REST API 關閉系統。

## 使用方式
1. 將 `truenas_backup.yaml` 加入 Home Assistant 的自動化。
2. 在 `configuration.yaml` 中加入下列設定：

```yaml
shell_command:
  truenas_backup: /config/scripts/truenas_backup.sh

rest_command:
  truenas_shutdown:
    url: "http://truenas.local/api/v2.0/system/shutdown"
    method: post
    headers:
      Authorization: "Bearer <YOUR_API_TOKEN>"
```

3. 編輯 `scripts/truenas_backup.sh` 填入 SMB 分享與認證資訊。
4. 透過 `chmod +x scripts/truenas_backup.sh` 賦予可執行權限。

自動化預設在每天凌晨 2 點執行，可依需求調整。 

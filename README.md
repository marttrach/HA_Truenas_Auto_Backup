# HA_Truenas_Auto_Backup

[![GitHub release](https://img.shields.io/github/v/release/marttrach/HA_Truenas_Auto_Backup)](https://github.com/marttrach/HA_Truenas_Auto_Backup/releases/latest)

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

3. 編輯 `scripts/truenas_backup.sh` 或透過新增的 Home Assistant Add-on 在 Web UI 中輸入設定值。
4. 透過 `chmod +x scripts/truenas_backup.sh` 賦予可執行權限（若未使用 add-on）。
5. 若 TrueNAS 開機時間較長，可透過 `STARTUP_DELAY` 環境變數（秒）調整在 Wake on LAN 後等待多久才開始備份，或於自動化中修改 `delay` 步驟。

自動化預設在每天凌晨 2 點執行，可依需求調整。

## Add-on 安裝

若希望在 Home Assistant 的網頁介面中設定參數，可使用 `addon` 資料夾中的範例 add-on。
將整個資料夾放入 `/addons` 路徑後，在 Supervisor – Add-on Store 中就能看到此套件。
安裝後即可在設定頁面填入 SMB 分享路徑、帳號密碼與備份目標位置等資訊。

點擊下方按鈕即可將此 GitHub 儲存庫加入 Home Assistant 的 Add-on Store，並在有新版本發佈時收到更新通知。

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmarttrach%2FHA_Truenas_Auto_Backup)

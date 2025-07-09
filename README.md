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
  shutdown_truenas:
    url: https://YOUR_TRUENAS_HOST/api/v2.0/system/shutdown
    method: POST
    headers:
      # secrets.yaml 內請存放完整字串：  truenas_api: "Bearer XXXXXXXXXXX"
      Authorization: !secret truenas_api
      Content-Type: "application/json"
    payload: >
      {"reason":"HA automation shutdown","options":{"delay":10}}
    verify_ssl: true
```

將上述 `YOUR_TRUENAS_HOST` 替換為 TrueNAS 主機位址，或透過 `TRUENAS_HOST` 環境變數設定。

3. 編輯 `scripts/truenas_backup.sh` 或透過新增的 Home Assistant Add-on 在 Web UI 中輸入設定值。
4. 透過 `chmod +x scripts/truenas_backup.sh` 賦予可執行權限（若未使用 add-on）。
5. 若 TrueNAS 開機時間較長，可透過 `STARTUP_DELAY` 環境變數（秒）調整在 Wake on LAN 後等待多久才開始備份。
6. 若執行環境無法掛載 SMB 分享，腳本將改用 `smbget` 直接下載，請先安裝 `smbclient` 套件。
7. 使用 `TRUENAS_HOST` 環境變數指定 TrueNAS 主機位址，預設為 `truenas.local`。
8. 使用 `LOG_LEVEL` 環境變數調整日誌輸出等級，可選 `debug`、`info`、`warn`、`error` 或 `none`。
9. 使用 `WATCHDOG` 環境變數（`true` 或 `false`）控制是否啟用容器 Watchdog 功能。
10. 透過 add-on 設定頁面可調整 `wol_mac`、`wol_broadcast`、`wol_port` 及 `trigger_time` 等參數。
11. 若需立即測試備份流程，可匯入 `truenas_backup_test.yaml` 並在 UI 中按下按鈕觸發。

範例自動化會在每天凌晨 2 點啟動 add-on，實際執行時間可在設定頁面透過 `trigger_time` 調整。
手動測試可呼叫 `hassio.addon_stdin` 服務並傳送 `run`，或使用 `truenas_backup_test.yaml` 範例。

## Add-on 安裝

若希望在 Home Assistant 的網頁介面中設定參數，可使用 `truenas_backup` 資料夾中的範例 add-on。
您可以直接將本 GitHub 儲存庫加入 Home Assistant 的 Add-on Store，或是將整個資料夾手動放入 `/addons` 目錄後重新啟動 Supervisor，即可在 Add-on Store 中看到此套件。
安裝後即可在設定頁面填入 SMB 分享路徑、帳號密碼與備份目標位置等資訊。

點擊下方按鈕即可將此 GitHub 儲存庫加入 Home Assistant 的 Add-on Store，並在有新版本發佈時收到更新通知。

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmarttrach%2FHA_Truenas_Auto_Backup)

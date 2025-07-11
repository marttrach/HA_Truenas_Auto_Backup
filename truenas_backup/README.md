# TrueNAS Backup Add-on

此資料夾提供將備份腳本包裝成 Home Assistant Add-on 的範例，
方便在 Web 介面中填入相關設定值後執行。

將 `truenas_backup` 整個目錄放入 `/addons` 後重啟 Supervisor，
即可於 Add-on Store 看到 `TrueNAS Backup`。

啟動時會依 `TZ` 環境變數設定時區，通常會與 Home Assistant 主機相同。

`startup_delay` 參數可以指定在發送 Wake on LAN 後等待多少秒才開始備份，以符合 TrueNAS 開機所需時間。
`wol_mac`、`wol_broadcast` 與 `wol_port` 分別對應 Wake on LAN 的目標 MAC 位址、廣播位置以及連接埠，
`trigger_time` 則用來指定每天何時執行備份，add-on 啟動後會依此時間自動執行。
自 1.2.0 起，`log_level` 於設定頁面提供下拉選單，`trigger_time` 以 `HH:MM:SS` 文字形式輸入，設定更加直覺。

## Ingress 與文件
本 add-on 不包含額外的 Web 介面，但可以透過 Ingress 檢視此說明文件。進入 Add-on 詳細畫面後，點選上方的 `Documentation` 按鈕即可開啟。

### 日誌
備份腳本執行時的輸出會顯示在 Add-on 的 **Logs** 頁面，可於此檢視備份過程。

### 更新日誌
完整更新內容請參考 [CHANGELOG](./CHANGELOG.md) 或 GitHub 的 [Releases](https://github.com/marttrach/HA_Truenas_Auto_Backup/releases)。

### Watchdog
在設定頁面可切換 `watchdog` 選項，啟用後 Home Assistant 將監控容器狀態並在需要時重新啟動。

### 手動測試
若想立即驗證備份流程，可透過 `hassio.addon_stdin` 服務傳送 `run` 指令。
本儲存庫提供 `truenas_backup_test.yaml`，加入後即可在介面按下按鈕觸發一次備份。

## 設定參數範例
以下為各設定欄位範例輸入，可依實際環境調整：

| 參數 | 範例值 | 說明 |
| --- | --- | --- |
| `truenas_host` | `truenas.local` | TrueNAS 主機位址 |
| `smb_share` | `//truenas/backup` | SMB 分享路徑 |
| `mount_point` | `/tmp/truenas_backup_mount` | 臨時掛載點 |
| `username` | `backupuser` | SMB 使用者名稱 |
| `password` | `yourpassword` | SMB 密碼 |
| `local_path` | `/backup/truenas` | 儲存備份的路徑 |
| `startup_delay` | `120` | WOL 後等待開機秒數 |
| `log_level` | `info` | 日誌等級 |
| `verify_shutdown` | `false` | 備份後是否呼叫關機 |
| `watchdog` | `false` | 啟用容器監控 |
| `wol_mac` | `00:11:22:33:44:55` | TrueNAS 網卡 MAC |
| `wol_broadcast` | `255.255.255.255` | 廣播地址 |
| `wol_port` | `9` | WOL 連接埠 |
| `trigger_time` | `02:00:00` | 每日觸發時間 |
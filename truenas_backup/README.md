# TrueNAS Backup Add-on

此資料夾提供將備份腳本包裝成 Home Assistant Add-on 的範例，
方便在 Web 介面中填入相關設定值後執行。

將 `truenas_backup` 整個目錄放入 `/addons` 後重啟 Supervisor，
即可於 Add-on Store 看到 `TrueNAS Backup`。

`startup_delay` 參數可以指定在發送 Wake on LAN 後等待多少秒才開始備份，以符合 TrueNAS 開機所需時間。

## Ingress 與文件
本 add-on 不包含額外的 Web 介面，但可以透過 Ingress 檢視此說明文件。進入 Add-on 詳細畫面後，點選上方的 `Documentation` 按鈕即可開啟。

### 日誌
備份腳本執行時的輸出會顯示在 Add-on 的 **Logs** 頁面，可於此檢視備份過程。

### 更新日誌
完整更新內容請參考 [CHANGELOG](./CHANGELOG.md) 或 GitHub 的 [Releases](https://github.com/marttrach/HA_Truenas_Auto_Backup/releases)。

### Watchdog
在設定頁面可切換 `watchdog` 選項，啟用後 Home Assistant 將監控容器狀態並在需要時重新啟動。

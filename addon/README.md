# TrueNAS Backup Add-on

此資料夾提供將備份腳本包裝成 Home Assistant Add-on 的範例，
方便在 Web 介面中填入相關設定值後執行。

將 `addon` 整個目錄放入 `/addons` 後重啟 Supervisor，
即可於 Add-on Store 看到 `TrueNAS Backup`。

`startup_delay` 參數可以指定在發送 Wake on LAN 後等待多少秒才開始備份，以符合 TrueNAS 開機所需時間。

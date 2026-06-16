# hermes-sandbox

用 Apple 原生的 [`container`](https://github.com/apple/container)（**不是 Docker**）把
[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) 跑在一個隔離的
Linux micro-VM 裡。

---

## 需求（前置，每台機器都要先做）

> ⚠️ 這部分**不在這個資料夾裡**，每個要用的人都得自己先弄好。

- Apple Silicon 的 Mac
- macOS 26 以上
- 安裝 Apple `container` CLI，並啟動服務：
  ```bash
  # 從 https://github.com/apple/container/releases 下載簽章好的 .pkg 安裝
  container system start
  ```

---

## 檔案結構

| 檔案                   | 作用                                                                    |
| ---------------------- | ----------------------------------------------------------------------- |
| `Containerfile`        | Ubuntu 24.04 base + 用官方 `install.sh` 裝 hermes                       |
| `docker-entrypoint.sh` | 首次啟動時把預設 config/skills seed 進 `/root/.hermes`                  |
| `build.sh`             | 建 image（`hermes:dev`）                                                |
| `start.sh`             | 啟動常駐容器 `hermes-box`（idempotent）                                 |
| `shell.sh`             | `exec` 進 ubuntu shell，自己下指令                                      |
| `chat.sh`              | `exec` 開 hermes（也可帶子指令，如 `./chat.sh setup`）                  |
| `stop.sh`              | 停止容器（`--rm` 連容器一起刪）                                         |
| `install-service.sh`   | 裝 LaunchAgent：開機自動啟動 + 防睡眠（真常駐）                         |
| `uninstall-service.sh` | 移除常駐、恢復正常睡眠                                                  |
| `keepalive.sh`         | 常駐用的背景 supervisor（由 launchd 呼叫，別手動跑）                    |
| `hermes-data/`         | hermes 的狀態（config / memory / skills / sessions）— **已被 git 忽略** |

---

## 快速開始

```bash
./build.sh         # 建 image（第一次，或改了 Containerfile 後）
./start.sh         # 啟動常駐容器 hermes-box
./shell.sh         # 進 ubuntu，自己裝東西 / 下指令
./chat.sh          # 開 hermes 聊天
./stop.sh          # 停（./stop.sh --rm 連容器刪掉）
```

`shell.sh` / `chat.sh` 會自動確保容器有起來，不用先手動 `start`。

---

## Model / 登入（Codex）

hermes 內建 `openai-codex` provider，用 **OAuth device flow** 登入——對無瀏覽器的容器很友善，
不需要 localhost 回呼：

```bash
./chat.sh login --provider openai-codex --no-browser   # 會印出 網址 + 代碼
#   在你 Mac 的瀏覽器打開那網址、登入 ChatGPT/OpenAI、輸入代碼、核准
./chat.sh model                                        # 選 openai-codex + gpt-5.5
./chat.sh                                              # 開聊
```

`--no-browser` 很重要：容器裡沒有瀏覽器可以自動開，加了它 hermes 就只印出網址/代碼讓你到別處核准。
`gpt-5.5` 會不會出現在清單，取決於你的 Codex/ChatGPT 帳號有沒有開放該 model。

---

## 常駐（開機自動啟動 + 防睡眠）

```bash
./install-service.sh     # 裝 LaunchAgent（com.hermes-sandbox.keepalive）
./uninstall-service.sh   # 移除，恢復正常睡眠（不會動到 hermes-box）
```

裝了之後：登入自動拉起 `hermes-box`、它掛了會自動重啟、**重開機也會自己回來**。

> ⚠️ 物理限制（caffeinate 擋不住）：
>
> 1. **要插著電**——防系統睡眠只在接電源時有效，靠電池 macOS 還是會睡。
> 2. **別闔蓋**——闔上筆電蓋仍會睡（除非外接螢幕+電源的 clamshell）。
> 3. 服務裝著時 **Mac 基本不會睡**，這是 24/7 的代價；不要時 `./uninstall-service.sh` 關掉。

---

## 東西存在哪 / 會不會留著

| 你做的事                                                   | 留存狀況                                                          |
| ---------------------------------------------------------- | ----------------------------------------------------------------- |
| hermes 的 config / memory / skills / sessions / 登入 token | 存 `./hermes-data/`，**永遠在**（連 `--rm` 都留）                 |
| 你在 ubuntu 裡 `apt install` 等                            | 存在 `hermes-box` 容器內，**容器活著就在**；`./stop.sh --rm` 會沒 |
| 想永久且可重現                                             | 寫進 `Containerfile` → 重新 `./build.sh`                          |

---

## 分享給別人

**可以照跑**，但有 4 件事不會、也不該自動跟著走：

1. **前置要自己裝**：對方得先有 Apple Silicon + macOS 26+、裝好 `container` CLI 並 `container system start`（見上方〈需求〉）。
2. **自己 build**：image 只在你本機。對方 clone 後自己跑 `./build.sh`（會下載 ~800MB、幾分鐘）。或你 `container image push` 到 registry 讓他 pull。
3. **自己登入**：`./hermes-data/` 被 git 忽略，裡面有**你的 Codex token**——分享時不會帶走（**這是對的，那等於你的帳號憑證**）。對方要用自己帳號 `./chat.sh login`。
4. **版本**：`Containerfile` 抓的是**當下最新版** hermes（沒鎖版本），對方 build 出來可能比你新。要完全一致就在 `install.sh` 加 `--commit <SHA>` 鎖版本。

**分享方式**：請用 **git**（會保留腳本執行權限、也尊重 `.gitignore`）。
若用 zip 之類複製，記得：(a) **排除 `hermes-data/`**（否則你的 token 外洩），(b) 對方解開後跑 `chmod +x *.sh`。

對方完整流程：

```bash
# 0) 先裝好 container CLI 並 container system start
git clone <你的 repo>
cd hermes-sandbox
./build.sh
./start.sh
./chat.sh login --provider openai-codex --no-browser   # 用他自己的帳號
./chat.sh model        # 選 gpt-5.5
./chat.sh
# 想常駐再 ./install-service.sh
```

---

## 設計筆記

- **root 安裝 → FHS 佈局**：code 在 `/usr/local/lib/hermes-agent`、指令 `/usr/local/bin/hermes`、
  資料在 `/root/.hermes`（bind-mount 到 `./hermes-data`），讓掛載的 volume 保持精簡。
- **build 時跳過**互動式 setup（`--skip-setup`）跟笨重的 Playwright/Chromium（`--skip-browser`）；
  之後要瀏覽器工具再補。
- **常駐**用 macOS LaunchAgent + `caffeinate`，綁定 `hermes-box` 生命週期。

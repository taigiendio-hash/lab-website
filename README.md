# 研究室網站上傳說明

這個資料夾包含你的研究室網站檔案：
- `index.html`：前台首頁
- `admin.html`：後台管理頁面
- `data.json`：網站內容資料
- `supabase_setup.sql`：Supabase 資料表與安全規則定義

## 上傳到 GitHub 的建議方式

### 1. 先建立 GitHub 倉庫
1. 到 `https://github.com` 登入或註冊帳號。
2. 點右上角 `+` → `New repository`。
3. Repository name 建議填 `lab-website`。
4. 選 `Public`。
5. 可以不勾選 `Add a README`，因為這個資料夾已經有 `README.md`。
6. 建立後你會得到遠端倉庫網址，例如：
   `https://github.com/你的帳號/lab-website.git`

### 2. 安裝 Git（如果還沒安裝）
- Windows：請到 https://git-scm.com/download/win 下載並安裝。
- 安裝完成後，請重新開啟 PowerShell 或終端機。

### 3. 從 `老師作業` 目錄初始化 Git
1. 開啟 PowerShell
2. 進到這個資料夾：
   ```powershell
   cd "c:\Users\pc\OneDrive\桌面\AI 作業-王婉霽 lab-website\老師作業"
   ```
3. 執行以下命令：
   ```powershell
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/你的帳號/lab-website.git
   git push -u origin main
   ```

### 4. 啟用 GitHub Pages
1. 到你的 GitHub 倉庫頁面。
2. 點 `Settings`。
3. 右側或下方找到 `Pages`。
4. `Source` 選擇 `main` branch，Folder 選 `/(root)`。
5. 按 `Save`。
6. 幾分鐘後，GitHub 會顯示你的網站網址，通常是：
   `https://你的帳號.github.io/lab-website`

## 注意事項
- 你網站中使用的 Supabase 後端仍然在 Supabase 雲端，GitHub Pages 只負責前端靜態網站。
- `admin.html` 也可以放上去，但必須靠 Supabase login 確認管理者身份。
- 如果你的網站需要改成中文路徑或特殊檔名，請先確認瀏覽器能正確讀取。

## 如果你想直接從 GitHub Desktop 上傳
1. 安裝 GitHub Desktop： https://desktop.github.com/
2. 選 `File` → `Add local repository`，選擇 `老師作業` 資料夾。
3. 進行 commit，然後 `Publish repository`。
4. 再去 GitHub Pages 啟用對應分支。

---

## 其他檔案
- `.gitignore`：建議忽略系統暫存檔和開發工具檔案。
- `UPLOAD_TO_GITHUB.ps1`：如果你安裝 Git 之後，可以直接執行來上傳。
# הוראות העלאה ל-GitHub 📤

## שלב 1: התקנת Git

1. הורד Git מ: https://git-scm.com/download/win
2. התקן את Git עם ההגדרות המומלצות
3. הפעל מחדש את PowerShell/Terminal

## שלב 2: העלאה ל-GitHub

לאחר התקנת Git, הרץ את הפקודות הבאות ב-PowerShell:

```powershell
# מעבר לתיקיית הפרויקט (אם לא כבר שם)
cd "C:\Users\omrib\OneDrive\מסמכים\my-awesome-project"

# אתחול מאגר Git
git init

# הוספת כל הקבצים
git add .

# יצירת commit ראשוני
git commit -m "Initial commit: Add interactive web projects"

# הוספת ה-remote של GitHub
git remote add origin https://github.com/omribuchman/my-awesome-project.git

# שינוי שם הסניף ל-main (אם צריך)
git branch -M main

# העלאה ל-GitHub
git push -u origin main
```

## שלב 3: אימות

אם GitHub דורש אימות, תצטרך:

1. **אם יש לך Personal Access Token:**
   - השתמש בו במקום סיסמה כשמבקשים credentials

2. **אם אין לך Token:**
   - לך ל: https://github.com/settings/tokens
   - לחץ על "Generate new token (classic)"
   - בחר הרשאות: `repo`
   - העתק את ה-Token והשתמש בו כסיסמה

## העלאה ידנית (אם Git לא עובד)

אם אתה מעדיף להעלות ידנית:

1. פתח: https://github.com/omribuchman/my-awesome-project
2. לחץ על "uploading an existing file"
3. גרור את כל הקבצים:
   - `index.html`
   - `israeli_stocks.html`
   - `protein_folding.html`
   - `README.md`
   - `.gitignore`
4. לחץ על "Commit changes"

## עזרה

אם נתקלת בבעיות, בדוק:
- ש-Git מותקן: `git --version`
- שהתיקייה נקייה: `git status`
- שה-remote נכון: `git remote -v`


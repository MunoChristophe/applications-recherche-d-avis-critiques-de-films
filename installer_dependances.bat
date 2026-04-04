@echo off
REM ============================================================
REM  CineAvis — Installation des dependances Python
REM  A executer UNE SEULE FOIS avant le premier lancement.
REM ============================================================
title CineAvis - Installation

echo ============================================================
echo   CineAvis - Installation des dependances
echo ============================================================
echo.

python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo  ERREUR : Python n'est pas installe.
    echo  Telechargez-le sur : https://www.python.org/downloads/
    echo  (Cochez "Add Python to PATH" lors de l'installation)
    echo.
    pause
    exit /b 1
)

echo  Python detecte. Installation des bibliotheques...
echo.
python -m pip install --upgrade pip
python -m pip install requests Pillow

echo.
echo ============================================================
echo   Installation terminee avec succes !
echo   Vous pouvez maintenant double-cliquer sur lancer.bat
echo ============================================================
echo.
pause

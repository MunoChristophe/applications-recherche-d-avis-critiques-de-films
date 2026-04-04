@echo off
REM ============================================================
REM  CineAvis — Lanceur Windows
REM  Double-cliquez sur ce fichier pour demarrer l'application.
REM ============================================================
title CineAvis - Recherche de Films

REM Verifier que Python est installe
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERREUR : Python n'est pas installe ou pas dans le PATH.
    echo  Telechargez Python sur : https://www.python.org/downloads/
    echo  (Cochez bien "Add Python to PATH" lors de l'installation)
    echo.
    pause
    exit /b 1
)

REM Verifier / installer les dependances
echo Verification des dependances...
python -m pip install --quiet --upgrade requests Pillow

REM Lancer l'application
echo Demarrage de CineAvis...
python "%~dp0cineavis.py"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo  Une erreur s'est produite. Consultez le message ci-dessus.
    pause
)

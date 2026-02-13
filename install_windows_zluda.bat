@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ==========================================
echo noScribe Installation Script for Windows
echo With ZLUDA support (AMD GPU RX 6800)
echo ==========================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Warning: Not running as administrator. Some features may not work.
    echo.
)

:: Check Python version
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Error: Python is not installed or not in PATH
    echo Please install Python 3.12 from https://www.python.org
    pause
    exit /b 1
)

for /f "tokens=2" %%a in ('python --version') do set PYTHON_VERSION=%%a
echo [✓] Found Python %PYTHON_VERSION%

:: Check Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Error: Git is not installed or not in PATH
    echo Please install Git from https://git-scm.com
    pause
    exit /b 1
)
echo [✓] Found Git

:: Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: Check if we're in the noScribe directory
if not exist "noScribe.py" (
    echo [X] Error: noScribe.py not found in current directory
    echo Please run this script from the noScribe folder
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Step 1: Creating virtual environment
echo ==========================================
echo.

if exist "venv_zluda" (
    echo [i] Virtual environment already exists
    choice /C YN /M "Do you want to recreate it"
    if %errorlevel% equ 1 (
        rmdir /s /q venv_zluda
        python -m venv venv_zluda
        echo [✓] Virtual environment recreated
    ) else (
        echo [i] Keeping existing environment
    )
) else (
    python -m venv venv_zluda
    echo [✓] Virtual environment created
)

echo.
echo ==========================================
echo Step 2: Activating virtual environment
echo ==========================================
echo.

call venv_zluda\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo [X] Error: Failed to activate virtual environment
    pause
    exit /b 1
)
echo [✓] Virtual environment activated

echo.
echo ==========================================
echo Step 3: Upgrading pip
echo ==========================================
echo.

python -m pip install --upgrade pip
if %errorlevel% neq 0 (
    echo [X] Error: Failed to upgrade pip
    pause
    exit /b 1
)
echo [✓] Pip upgraded

echo.
echo ==========================================
echo Step 4: Installing ZLUDA dependencies
echo ==========================================
echo.
echo This will install PyTorch with CUDA support
echo ZLUDA will translate CUDA calls to ROCm at runtime
echo.

pip install -r environments\requirements_win_zluda.txt
if %errorlevel% neq 0 (
    echo [X] Error: Failed to install dependencies
    echo.
    echo Troubleshooting:
    echo 1. Check your internet connection
    echo 2. Try running: pip install --upgrade pip setuptools wheel
    echo 3. Make sure you have enough disk space (3GB+)
    pause
    exit /b 1
)
echo [✓] Dependencies installed

echo.
echo ==========================================
echo Step 5: Downloading AI Models
echo ==========================================
echo.

if not exist "models" mkdir models

echo [i] Downloading fast model (int8)...
if not exist "models\fast" (
    git clone https://huggingface.co/mukowaty/faster-whisper-int8 models\fast
    if %errorlevel% neq 0 (
        echo [!] Warning: Failed to download fast model
        echo You can manually download it later from:
        echo https://huggingface.co/mukowaty/faster-whisper-int8
    ) else (
        echo [✓] Fast model downloaded
    )
) else (
    echo [i] Fast model already exists
)

echo.
echo [i] Downloading precise model (large-v3-turbo)...
if not exist "models\precise" (
    git clone https://huggingface.co/mobiuslabsgmbh/faster-whisper-large-v3-turbo models\precise
    if %errorlevel% neq 0 (
        echo [!] Warning: Failed to download precise model
        echo You can manually download it later from:
        echo https://huggingface.co/mobiuslabsgmbh/faster-whisper-large-v3-turbo
    ) else (
        echo [✓] Precise model downloaded
    )
) else (
    echo [i] Precise model already exists
)

echo.
echo ==========================================
echo Step 6: Checking ZLUDA
echo ==========================================
echo.

if "%ZLUDA_PATH%"=="" (
    echo [!] Warning: ZLUDA_PATH environment variable not set
    echo.
    echo To use your AMD GPU (RX 6800), you need ZLUDA:
    echo 1. Download ZLUDA from: https://github.com/vosen/ZLUDA/releases
    echo 2. Extract it to a folder (e.g., C:\ZLUDA)
    echo 3. Set ZLUDA_PATH environment variable to that folder
    echo 4. Add %%ZLUDA_PATH%% to your PATH
    echo.
    echo For now, noScribe will run on CPU mode.
    echo.
) else (
    echo [✓] ZLUDA_PATH is set to: %ZLUDA_PATH%
    if exist "%ZLUDA_PATH%\nvcuda.dll" (
        echo [✓] ZLUDA files found
    ) else (
        echo [!] Warning: ZLUDA files not found in %ZLUDA_PATH%
        echo Make sure ZLUDA is properly extracted
    )
)

echo.
echo ==========================================
echo Step 7: Testing Installation
echo ==========================================
echo.

python -c "import torch; print(f'PyTorch version: {torch.__version__}')"
if %errorlevel% equ 0 (
    echo [✓] PyTorch is working
) else (
    echo [X] Error: PyTorch test failed
)

python -c "import faster_whisper" >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Faster-Whisper is working
) else (
    echo [X] Error: Faster-Whisper test failed
)

echo.
echo ==========================================
echo Installation Complete!
echo ==========================================
echo.
echo To use noScribe with ZLUDA:
echo.
echo 1. Make sure ZLUDA is installed and ZLUDA_PATH is set
echo 2. Activate the environment: venv_zluda\Scripts\activate
echo 3. Run noScribe: python noScribe.py
echo.
echo GPU Support:
echo - Whisper: GPU via ZLUDA (if ZLUDA is configured)
echo - PyAnnote: GPU via ZLUDA (if ZLUDA is configured)
echo - Fallback: Automatic CPU if GPU fails
echo.
echo For issues, check:
echo - GitHub: https://github.com/skyline624/noScribe
echo - ZLUDA: https://github.com/vosen/ZLUDA
echo.
pause

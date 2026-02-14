@echo off
chcp 65001 >nul
echo ==========================================
echo Starting noScribe with ZLUDA
echo ==========================================
echo.

:: Check if ZLUDA is configured
if "%ZLUDA_PATH%"=="" (
    echo [!] Warning: ZLUDA_PATH not set
    echo Please set ZLUDA_PATH to your ZLUDA installation directory
    echo Example: set ZLUDA_PATH=C:\ZLUDA
    echo.
    echo Continuing without GPU acceleration...
    echo.
    pause
) else (
    echo [OK] ZLUDA_PATH: %ZLUDA_PATH%
    set PATH=%ZLUDA_PATH%;%PATH%
    echo [OK] ZLUDA added to PATH
)

:: Activate virtual environment
echo [INFO] Activating virtual environment...
call venv_zluda\Scripts\activate.bat

:: Check PyTorch
echo [INFO] Checking PyTorch installation...
python -c "import torch; print('PyTorch:', torch.__version__); print('CUDA available:', torch.cuda.is_available())"

:: Launch noScribe
echo.
echo [OK] Starting noScribe...
echo ==========================================
python noScribe.py

:: Deactivate on exit
call deactivate

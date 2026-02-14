@echo off
setlocal EnableDelayedExpansion

echo ==========================================
echo Starting noScribe with ZLUDA
echo ==========================================
echo.

REM Check if ZLUDA is configured
if not defined ZLUDA_PATH (
    echo WARNING: ZLUDA_PATH not set
    echo Please set ZLUDA_PATH to your ZLUDA installation directory
    echo Example: set ZLUDA_PATH=C:\ZLUDA
    echo.
    echo Continuing without GPU acceleration...
    echo.
    pause
) else (
    echo OK: ZLUDA_PATH: %ZLUDA_PATH%
    set "PATH=%ZLUDA_PATH%;%PATH%"
    echo OK: ZLUDA added to PATH
)

REM Activate virtual environment
echo INFO: Activating virtual environment...
call "%~dp0venv_zluda\Scripts\activate.bat"

REM Check PyTorch
echo INFO: Checking PyTorch installation...
python -c "import torch; print('PyTorch:', torch.__version__); print('CUDA available:', torch.cuda.is_available())"

REM Launch noScribe
echo.
echo OK: Starting noScribe...
echo ==========================================
python "%~dp0noScribe.py"

REM Deactivate on exit
call deactivate

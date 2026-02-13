# AGENTS.md - Guidelines for noScribe Development

## Project Overview

**noScribe** is an AI-powered audio transcription application (Version 0.7) written in Python 3.12. It's built with tkinter/customtkinter for the GUI and uses Whisper (via faster-whisper) for transcription and Pyannote for speaker diarization.

**Main entry point**: `noScribe.py`

## Build/Test/Lint Commands

### Testing
```bash
# Install pytest (if not already installed)
pip install pytest pytest-cov

# Run all tests
python -m pytest

# Run a single test file
python -m pytest tests/test_utils.py

# Run a specific test function
python -m pytest tests/test_utils.py::test_str_to_ms

# Run with coverage
python -m pytest --junitxml=junit/test-results.xml --cov=com --cov-report=xml --cov-report=html
```

### Dependencies
```bash
# Install dependencies (Linux)
pip install -r environments/requirements_linux.txt

# Windows - CPU version
pip install -r environments/requirements_win_cpu.txt

# Windows - NVIDIA CUDA version
pip install -r environments/requirements_win_cuda.txt

# Windows - AMD ROCm version (RX 6800 series) - ROCm 6.2 + PyTorch 2.5.1
pip install -r environments/requirements_win_rocm.txt

# Other platforms: see environments/requirements_*.txt
```

### ROCm Support (AMD GPU on Windows)
```bash
# Install ROCm dependencies (requires ROCm 7.0 SDK and AMD GPU drivers)
pip install -r environments/requirements_win_rocm.txt

# Verify ROCm is available
python -c "import torch; print('ROCm:', torch.version.hip)"

# Run with ROCm (Whisper uses GPU, PyAnnote uses CPU for stability)
python noScribe.py
```

### Running the Application
```bash
# Run from source
python noScribe.py

# CLI mode (no GUI)
python noScribe.py --no-gui [options]
```

## Code Style Guidelines

### Imports
- **Order**: Standard library → Third-party → Local modules
- Group imports by category with blank lines between groups
- Use explicit imports (avoid `from module import *`)
- Example from noScribe.py:
```python
import sys
import argparse
import os

import tkinter as tk
import customtkinter as ctk
from PIL import Image

import utils
```

### Naming Conventions
- **Classes**: PascalCase (e.g., `TranscriptionJob`, `JobEntryFrame`)
- **Functions/Variables**: snake_case (e.g., `get_config`, `html_node_to_text`)
- **Constants**: UPPERCASE_WITH_UNDERSCORES for true constants (e.g., `_CUDA_ERROR_KEYWORDS`)
- **Private methods**: Prefix with underscore (e.g., `_is_cuda_error_message`)
- **Type hints**: Use where appropriate (especially in `utils.py`)

### Error Handling
- Use try/except blocks with specific exceptions
- Always chain exceptions properly using `from e` when re-raising
- Example from `utils.py`:
```python
try:
    h, m, s = time_str.split(":")
    ret = (int(h) * 3600 + int(m) * 60 + int(s)) * 1000
except ValueError as e:
    raise ValueError("time string is invalid", i18n.t("err_invalid_time_string"), time_str) from e
```

### Platform-Specific Code
The codebase heavily uses platform detection. Follow the existing pattern:
```python
if platform.system() == 'Windows':
    # Windows-specific code
elif platform.system() == 'Darwin':  # macOS
    # macOS-specific code
elif platform.system() == 'Linux':
    # Linux-specific code
```

### Documentation
- Use docstrings for all public functions (follow Google style in `utils.py`)
- Include Args, Returns, and Raises sections where applicable
- Add inline comments for complex logic

### GUI Development (CustomTkinter)
- Use `ctk` prefix for customtkinter widgets
- Follow the existing UI patterns in `noScribe.py`
- Tooltips: Use `CTkToolTip` from the included `CTkToolTips.py`

### Internationalization (i18n)
- Use the `i18n` library for all user-facing strings
- Translation files are in `trans/` directory (YAML format)
- Access translations via: `i18n.t("translation_key")`

### Type Hints
Use type hints consistently, especially in utility modules:
```python
def str_to_ms(time_str: str) -> int:
def get_config(key: str, default) -> str:
```

### Testing Standards
- Write pytest-style tests (see `tests/test_utils.py`)
- Use descriptive test function names
- Use `pytest.raises()` for exception testing
- Use `tmp_path` fixture for filesystem operations

## Project Structure

```
noScribe/
├── noScribe.py           # Main application (~3000+ lines)
├── utils.py              # Helper functions with type hints
├── CTkToolTips.py        # Custom tooltip widget
├── tkHyperlinkManager.py # Hyperlink handler for tkinter
├── pyannote_mp_worker.py # Multiprocessing worker for speaker diarization
├── whisper_mp_worker.py  # Multiprocessing worker for transcription
├── tests/                # Test directory
│   └── test_utils.py     # Unit tests for utils.py
├── environments/         # Requirements files per platform
├── trans/                # Translation files (YAML)
├── models/               # AI model storage (see README)
└── noScribeEdit/         # Embedded editor (separate repository)
```

## Important Notes

- **No formal linting/formatting tools** are currently configured (no Black, flake8, etc.)
- **Python 3.12** is the target version
- **GPU/CUDA/ROCm handling**: The code has extensive error handling for CUDA (NVIDIA) and ROCm (AMD GPU) related failures. ROCm mode uses GPU for Whisper and CPU for PyAnnote.
- **Multiprocessing**: Uses `mp.freeze_support()` for PyInstaller compatibility
- **Config files**: Stored in user config directory via `appdirs`

## Adding New Features

1. Follow existing code patterns in `noScribe.py`
2. Extract reusable logic to `utils.py` with proper type hints and tests
3. Update translations in `trans/` if adding new UI strings
4. Test on all three platforms (Windows, macOS, Linux) if platform-specific
5. Run `python -m pytest` to ensure tests pass

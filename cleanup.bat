@echo off
setlocal enabledelayedexpansion

echo ================================================
echo  불필요한 파일 및 폴더 제거
echo ================================================
echo.

set "deleted=0"
set "failed=0"

REM Backend 폴더
if exist "backend\build" (
    echo [1/9] Removing backend\build...
    rmdir /s /q "backend\build" 2>nul
    if not exist "backend\build" (
        echo     ✓ 제거 완료
        set /a deleted+=1
    ) else (
        echo     ✗ 제거 실패 ^(사용 중^)
        set /a failed+=1
    )
) else (
    echo [1/9] backend\build - 이미 없음
)

if exist "backend\.gradle" (
    echo [2/9] Removing backend\.gradle...
    rmdir /s /q "backend\.gradle" 2>nul
    if not exist "backend\.gradle" (
        echo     ✓ 제거 완료
        set /a deleted+=1
    ) else (
        echo     ✗ 제거 실패
        set /a failed+=1
    )
) else (
    echo [2/9] backend\.gradle - 이미 없음
)

if exist "backend\data" (
    echo [3/9] Removing backend\data...
    rmdir /s /q "backend\data" 2>nul
    if not exist "backend\data" (
        echo     ✓ 제거 완료
        set /a deleted+=1
    ) else (
        echo     ✗ 제거 실패
        set /a failed+=1
    )
) else (
    echo [3/9] backend\data - 이미 없음
)

if exist "backend\logs" (
    echo [4/9] Removing backend\logs...
    rmdir /s /q "backend\logs" 2>nul
    if not exist "backend\logs" (
        echo     ✓ 제거 완료
        set /a deleted+=1
    ) else (
        echo     ✗ 제거 실패
        set /a failed+=1
    )
) else (
    echo [4/9] backend\logs - 이미 없음
)

REM Root 폴더
if exist ".idea" (
    echo [5/9] Removing .idea...
    rmdir /s /q ".idea" 2>nul
    if not exist ".idea" (
        echo     ✓ 제거 완료
        set /a deleted+=1
    ) else (
        echo     ✗ 제거 실패
        set /a failed+=1
    )
) else (
    echo [5/9] .idea - 이미 없음
)

if exist "logs" (
    echo [6/9] Removing logs...
    rmdir /s /q "logs" 2>nul
    if not exist "logs" (
        echo     ✓ 제거 완료
        set /a deleted+=1
    ) else (
        echo     ✗ 제거 실패
        set /a failed+=1
    )
) else (
    echo [6/9] logs - 이미 없음
)

REM Frontend 폴더
if exist "frontend\build" (
    echo [7/9] Removing frontend\build...
    rmdir /s /q "frontend\build" 2>nul
    if not exist "frontend\build" (
        echo     ✓ 제거 완료
        set /a deleted+=1
    ) else (
        echo     ✗ 제거 실패
        set /a failed+=1
    )
) else (
    echo [7/9] frontend\build - 이미 없음
)

if exist "frontend\.dart_tool" (
    echo [8/9] Removing frontend\.dart_tool...
    rmdir /s /q "frontend\.dart_tool" 2>nul
    if not exist "frontend\.dart_tool" (
        echo     ✓ 제거 완료
        set /a deleted+=1
    ) else (
        echo     ✗ 제거 실패
        set /a failed+=1
    )
) else (
    echo [8/9] frontend\.dart_tool - 이미 없음
)

if exist "frontend\.idea" (
    echo [9/9] Removing frontend\.idea...
    rmdir /s /q "frontend\.idea" 2>nul
    if not exist "frontend\.idea" (
        echo     ✓ 제거 완료
        set /a deleted+=1
    ) else (
        echo     ✗ 제거 실패
        set /a failed+=1
    )
) else (
    echo [9/9] frontend\.idea - 이미 없음
)

echo.
echo ================================================
echo  제거 완료: !deleted!개
if !failed! gtr 0 (
    echo  제거 실패: !failed!개 ^(파일 사용 중^)
    echo.
    echo  참고: 실패한 파일은 프로그램을 종료 후 다시 시도하세요
)
echo ================================================
echo.
pause

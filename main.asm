.386
.model		flat, stdcall
option		casemap:none

include		windows.inc
include		gdi32.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
includelib	gdi32.lib
include		Comctl32.inc
includelib	Comctl32.lib
include		Comdlg32.inc
includelib	Comdlg32.lib

ICO_MINE_COMMON			equ		101
ICO_MINE_RED			equ		102
ICO_MINE_BROKEN			equ		103
ICO_SMILEY_WIN			equ		104
ICO_SMILEY				equ		105
ICO_SMILEY_OH			equ		106
ICO_SMILEY_SAD			equ		107
ICO_TILE_COMMON			equ		108
IDI_ICON9				equ		109
ICO_TILE_UNKNOWN		equ		109
ICO_TILE_FLAG			equ		110


.data?
hInstance		dd				?
hWinMain		dd				?
hIcoMain		dd				?

.const
szClassName		db		"MinesweeperClass", 0
szCaptionMain	db		"É¨À×", 0
szButtonClass	db		"button",0


.code
_ProcWinMain	proc	uses ebx edi esi, hWnd, uMsg, wParam, lParam
				local	@stPs:PAINTSTRUCT
				local	@stRect:RECT
				local	@hDc
				local	@hFont
				local	@hOldFont

				mov		eax, uMsg
				.if		eax == WM_CREATE

				.elseif	eax == WM_PAINT
				
				.elseif	eax == WM_COMMAND
				
				.elseif eax == WM_CLOSE
						invoke	DestroyWindow, hWinMain
						invoke	PostQuitMessage, NULL
				.else
						invoke	DefWindowProc, hWnd, uMsg, wParam, lParam
						ret
				.endif
				xor		eax, eax
				ret
_ProcWinMain	endp

_WinMain		proc
				local	@stWndClass:WNDCLASSEX
				local	@stMsg:MSG

				invoke	GetModuleHandle, NULL
				mov		hInstance, eax
				invoke	RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
				invoke	LoadIcon, hInstance, ICO_MINE_COMMON
				mov		@stWndClass.hIcon, eax
				mov		@stWndClass.hIconSm, eax
				mov		hIcoMain, eax
				invoke	LoadCursor, 0, IDC_ARROW
				mov		@stWndClass.hCursor, eax
				push	hInstance
				pop		@stWndClass.hInstance
				mov		@stWndClass.cbSize, sizeof WNDCLASSEX
				mov		@stWndClass.style, CS_HREDRAW or CS_VREDRAW
				mov		@stWndClass.lpfnWndProc, offset _ProcWinMain
				mov		@stWndClass.hbrBackground, COLOR_WINDOW + 1
				mov		@stWndClass.lpszClassName, offset szClassName
				invoke	RegisterClassEx, addr @stWndClass
				invoke	CreateWindowEx, WS_EX_CLIENTEDGE,						;dwExStyle
										offset szClassName,						;lpClassName
										offset szCaptionMain,					;lpWindowName
										WS_OVERLAPPEDWINDOW xor WS_THICKFRAME,	;dwStyle
										CW_USEDEFAULT,							;x
										CW_USEDEFAULT,							;y
										600,									;nWidth
										600,									;nHeight
										NULL,									;hWndParent
										NULL,									;hMenu
										hInstance,								;hInstance
										NULL									;lpParam
				mov		hWinMain, eax
				invoke	ShowWindow,		hWinMain,
										SW_SHOWNORMAL
				invoke	UpdateWindow, hWinMain
				.while	TRUE
						invoke	GetMessage, addr @stMsg, NULL, 0, 0
						.break	.if eax == 0
						invoke	TranslateMessage, addr @stMsg
						invoke	DispatchMessage, addr @stMsg
				.endw
				ret
_WinMain		endp

start:
		call	_WinMain
		invoke	ExitProcess, NULL
		xor		eax, eax
		ret
end		start
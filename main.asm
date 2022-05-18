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
include		msvcrt.inc
includelib	msvcrt.lib
include		masm32.inc
includelib	masm32.lib
include		Shlwapi.inc
includelib	Shlwapi.lib

;图标定义
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

;菜单定义
IDR_MENU				equ		111
IDR_BEGINNER			equ		40007
IDR_INTERMEDIATE		equ		40008
IDR_ADVANCED			equ		40009
IDR_MASTER				equ		40010
IDR_CUSTOM				equ		40011
IDR_ABOUT				equ		40012

;加速键定义
IDR_ACCELERATOR			equ		112
IDA_ESC					equ		40015

;按钮ID
IDB_START				equ		50001

;对话框
IDD_CUSTOM				equ		115
IDC_EDIT_ROW			equ		1013
IDC_EDIT_COL			equ		1014
IDC_EDIT_MINE			equ		1015

;自定义按钮右键单击通知
BN_RCLICKED				equ		0AAH
;自定义按钮中键单击通知
BN_MCLICKED				equ		0BBH
;格子大小
TILE_SIZE				equ		25
;开始按钮大小
START_SIZE				equ		60
;开始按钮里的图标大小
START_ICON_SIZE			equ		32
;边框大小
BORDER_SIZE				equ		20
;初始格子ID
TILE_START				equ		60000

;最大行列限制
MAX_ROW					equ		30
MAX_COL					equ		30

.data?
hInstance		dd				?
hWinMain		dd				?
hIcoMain		dd				?
hStartButton	dd				?
hMenu			dd				?
lpDefProcTile	dd				?

.data
ddMineSweepedCount		dd		0
ddMineTotalCount		dd		10
dwRow					dw		10
dwColumn				dw		10
dwTileID				dd		TILE_START

.const
szClassName				db		"MinesweeperClass", 0
szCaptionMain			db		"扫雷", 0
szButtonClass			db		"button",0
szTextAboutCaption		db		"关于扫雷",0
szTextAbout				db		"这是一个经典Windows扫雷游戏的汇编版本复刻。",0
szDigitFmt				db		"%d",0
szError					db		"错误",0
szRowExceedFmt			db		"最大行数不能超过%d",0
szColExceedFmt			db		"最大列数不能超过%d",0
szMineExceedFmt			db		"雷数不能大于%d",0
dwRowBeginner			dw		10
dwColBeginner			dw		10
ddMinesBeginner			dd		10
dwRowIntermediate		dw		16
dwColIntermediate		dw		16
ddMinesIntermediate		dd		40
dwRowAdvanced			dw		16
dwColAdvanced			dw		30
ddMinesAdvanced			dd		99
dwRowMaster				dw		30
dwColMaster				dw		30
ddMinesMaster			dd		500

.code
;响应Tile的点击事件
_ClickTile		proc	hWnd, stPoint:POINT, typeID, tileID
				local	@szTemp[128]:byte
				local	@hIcon
				local	@hTile
				invoke	GetDlgItem, hWnd, tileID
				mov		@hTile, eax
				;右键单击
				.if		typeID == BN_RCLICKED
						invoke	LoadIcon, hInstance, ICO_TILE_FLAG
						mov		@hIcon, eax
						invoke	SendMessage, @hTile, BM_SETIMAGE, IMAGE_ICON, @hIcon
				;中键单击
				.elseif	typeID == BN_MCLICKED
						invoke	LoadIcon, hInstance, ICO_TILE_UNKNOWN
						mov		@hIcon, eax
						invoke	SendMessage, @hTile, BM_SETIMAGE, IMAGE_ICON, @hIcon
				;左键单击，清空标记
				.else
						invoke	SendMessage, @hTile, BM_SETIMAGE, IMAGE_ICON, NULL
				.endif
				ret
_ClickTile		endp

_ProcTile		proc	uses ebx edi esi, hWnd, uMsg, wParam, lParam
				local	@hParent
				local	@hIcon
				invoke	GetParent, hWnd
				mov		@hParent, eax
				mov		eax, uMsg
				.if		eax == WM_RBUTTONDOWN
						invoke	GetDlgCtrlID, hWnd
						mov		ebx, eax
						mov		ax, BN_RCLICKED
						shl		eax, 16
						mov		ax, bx
						invoke	SendMessage, @hParent, WM_COMMAND, eax, lParam
				.elseif	eax == WM_LBUTTONDOWN
						invoke	LoadIcon, hInstance, ICO_SMILEY_OH
						mov		@hIcon, eax
						invoke	SendMessage, hStartButton, BM_SETIMAGE, IMAGE_ICON, eax
						invoke	CallWindowProc, lpDefProcTile, hWnd, uMsg, wParam, lParam
						ret
				.elseif	eax == WM_LBUTTONUP
						invoke	LoadIcon, hInstance, ICO_SMILEY
						mov		@hIcon, eax
						invoke	SendMessage, hStartButton, BM_SETIMAGE, IMAGE_ICON, eax
						invoke	CallWindowProc, lpDefProcTile, hWnd, uMsg, wParam, lParam
						ret
				.elseif	eax == WM_MBUTTONDOWN
						invoke	GetDlgCtrlID, hWnd
						mov		ebx, eax
						mov		ax, BN_MCLICKED
						shl		eax, 16
						mov		ax, bx
						invoke	SendMessage, @hParent, WM_COMMAND, eax, lParam
				.else
						invoke	CallWindowProc, lpDefProcTile, hWnd, uMsg, wParam, lParam
						ret
				.endif
				xor		eax, eax
				ret
_ProcTile		endp

_CreateGame		proc	uses eax ebx ecx edx esi edi, hWnd, level
				local	@stRect:RECT
				local	@dwCx:WORD, @dwCy:WORD
				local	@dwX:WORD, @dwY:WORD
				.if		level == IDR_BEGINNER
						push	dwRowBeginner
						pop		dwRow
						push	dwColBeginner
						pop		dwColumn
						push	ddMinesBeginner
						pop		ddMineTotalCount
				.elseif	level == IDR_INTERMEDIATE
						push	dwRowIntermediate
						pop		dwRow
						push	dwColIntermediate
						pop		dwColumn
						push	ddMinesIntermediate
						pop		ddMineTotalCount
				.elseif	level == IDR_ADVANCED
						push	dwRowAdvanced
						pop		dwRow
						push	dwColAdvanced
						pop		dwColumn
						push	ddMinesAdvanced
						pop		ddMineTotalCount
				.elseif	level == IDR_MASTER
						push	dwRowMaster
						pop		dwRow
						push	dwColMaster
						pop		dwColumn
						push	ddMinesMaster
						pop		ddMineTotalCount
				.endif
				mov		ddMineSweepedCount, 0
				mov		ax, dwColumn
				mov		bx, TILE_SIZE
				mul		bx
				add		ax, BORDER_SIZE*3
				mov		@dwCx, ax
				mov		ax, dwRow
				mov		bx, TILE_SIZE
				mul		bx
				add		ax, START_SIZE
				add		ax, BORDER_SIZE*6
				mov		@dwCy, ax
				invoke	GetDlgItem, hWnd, IDB_START
				invoke	DestroyWindow, eax
				.while	dwTileID > TILE_START
						invoke	GetDlgItem, hWnd, dwTileID
						invoke	DestroyWindow, eax
						dec		dwTileID
				.endw
				invoke	SetWindowPos, hWnd, NULL, 0, 0, @dwCx, @dwCy, SWP_NOMOVE
				invoke	GetClientRect, hWnd, addr @stRect
				mov		eax, @stRect.right
				sub		eax, @stRect.left
				shr		eax, 1
				sub		eax, START_SIZE/2
				;绘制开始按钮
				invoke	CreateWindowEx, NULL,
										offset szButtonClass,
										NULL,
										WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or BS_ICON or BS_NOTIFY,
										eax, BORDER_SIZE, START_SIZE, START_SIZE,
										hWnd, IDB_START, hInstance, NULL
				mov		hStartButton, eax
				invoke	LoadIcon, hInstance, ICO_SMILEY
				invoke	SendMessage, hStartButton, BM_SETIMAGE, IMAGE_ICON, eax
				xor		bx, bx
				;创建格子
				.while	bx < dwRow
						xor		cx, cx
						.while	cx < dwColumn
								inc		dwTileID
								mov		ax, cx
								mov		dx, TILE_SIZE
								mul		dx
								add		ax, BORDER_SIZE
								mov		@dwX, ax
								mov		ax, bx
								mov		dx, TILE_SIZE
								mul		dx
								add		ax, START_SIZE+BORDER_SIZE*2
								mov		@dwY, ax
								push	ecx
								invoke	CreateWindowEx, NULL,
													offset szButtonClass,
													NULL,
													WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or BS_ICON or BS_NOTIFY,
													@dwX, @dwY, TILE_SIZE, TILE_SIZE,
													hWnd, dwTileID, hInstance, NULL
								invoke	SetWindowLong, eax, GWL_WNDPROC, addr _ProcTile
								mov		lpDefProcTile, eax
								pop		ecx
								inc		cx
						.endw
						inc		bx
				.endw
				ret
_CreateGame		endp

;自定义对话框过程
_CustomDlgProc	proc	uses ebx ecx edx esi edi, hWnd, wMsg, wParam, lParam
				local	@buf[100]:byte
				local	@hEdit
				mov		eax, wMsg
				.if		eax == WM_CLOSE
						invoke	EndDialog, hWnd, NULL
				.elseif		eax == WM_INITDIALOG
						invoke	wsprintf, addr @buf, offset szDigitFmt, dwRow
						invoke	GetDlgItem, hWnd, IDC_EDIT_ROW
						mov		@hEdit, eax
						invoke	SetWindowText, @hEdit, addr @buf
						invoke	wsprintf, addr @buf, offset szDigitFmt, dwColumn
						invoke	GetDlgItem, hWnd, IDC_EDIT_COL
						mov		@hEdit, eax
						invoke	SetWindowText, @hEdit, addr @buf
						invoke	wsprintf, addr @buf, offset szDigitFmt, ddMineTotalCount
						invoke	GetDlgItem, hWnd, IDC_EDIT_MINE
						mov		@hEdit, eax
						invoke	SetWindowText, @hEdit, addr @buf
				.elseif	eax == WM_COMMAND
						mov		eax, wParam
						movzx	eax, ax
						.if		eax == IDOK
								invoke	GetDlgItem, hWnd, IDC_EDIT_ROW
								mov		@hEdit, eax
								invoke	GetWindowText, @hEdit, addr @buf, sizeof @buf
								invoke	StrToInt, addr @buf
								;行数限制
								.if		ax > MAX_ROW
										invoke	wsprintf, addr @buf, offset szRowExceedFmt, MAX_ROW
										invoke	MessageBox, hWnd, addr @buf, offset szError, MB_ICONERROR
										ret
								.endif
								mov		dwRow, ax
								;列数限制
								invoke	GetDlgItem, hWnd, IDC_EDIT_COL
								mov		@hEdit, eax
								invoke	GetWindowText, @hEdit, addr @buf, sizeof @buf
								invoke	StrToInt, addr @buf
								.if		ax > MAX_COL
										invoke	wsprintf, addr @buf, offset szColExceedFmt, MAX_COL
										invoke	MessageBox, hWnd, addr @buf, offset szError, MB_ICONERROR
										ret
								.endif
								mov		dwColumn, ax
								;雷数限制
								invoke	GetDlgItem, hWnd, IDC_EDIT_MINE
								mov		@hEdit, eax
								invoke	GetWindowText, @hEdit, addr @buf, sizeof @buf
								invoke	StrToInt, addr @buf
								mov		edi, eax
								mov		ax, dwColumn
								mul		dwRow
								movzx	eax, ax
								.if		edi > eax
										invoke	wsprintf, addr @buf, offset szMineExceedFmt, eax
										invoke	MessageBox, hWnd, addr @buf, offset szError, MB_ICONERROR
										ret
								.endif
								mov		ddMineTotalCount, eax

								invoke	EndDialog, hWnd, TRUE
						.elseif	eax == IDCANCEL
								invoke	EndDialog, hWnd, FALSE
						.endif
				.else
						mov		eax, FALSE
						ret
				.endif
				mov		eax, TRUE
				ret
_CustomDlgProc	endp

_Quit			proc
						invoke	DestroyWindow, hWinMain
						invoke	PostQuitMessage, NULL
						ret
_Quit			endp

_ProcWinMain	proc	uses ebx edi esi, hWnd, uMsg, wParam, lParam
				local	@stPs:PAINTSTRUCT
				local	@stRect:RECT
				local	@stPoint:POINT
				local	@hDc
				local	@hSysMenu
				local	@hStartButton
				local	@hFont
				local	@hOldFont
				local	@level

				mov		eax, uMsg
				.if		eax == WM_CREATE
						invoke	CheckMenuRadioItem, hMenu, IDR_BEGINNER, IDR_CUSTOM, IDR_BEGINNER, MF_BYCOMMAND
						invoke	_CreateGame, hWnd, IDR_BEGINNER
				.elseif	eax == WM_COMMAND
						mov		eax, wParam
						movzx	eax, ax
						.if		eax == IDR_ABOUT
								;invoke	_DisplayMenuItem, wParam
								invoke	MessageBox, hWnd, offset szTextAbout, offset szTextAboutCaption, MB_OK
						.elseif	eax >= IDR_BEGINNER && eax <= IDR_CUSTOM
								mov		@level, eax
								invoke	CheckMenuRadioItem, hMenu, IDR_BEGINNER, IDR_CUSTOM, @level, MF_BYCOMMAND
								.if		@level == IDR_CUSTOM
										invoke	DialogBoxParam, hInstance, IDD_CUSTOM, hWnd, _CustomDlgProc, NULL
										.if		eax == TRUE
												invoke	_CreateGame, hWnd, IDR_CUSTOM
										.endif
								.else
										invoke	_CreateGame, hWnd, @level
								.endif
						.elseif	eax > TILE_START && eax <= dwTileID
								sub		eax, 60001
								xor		edx, edx
								div		dwColumn
								mov		@stPoint.x, edx
								mov		@stPoint.y, eax
								mov		eax, wParam
								shr		eax, 16
								mov		ebx, wParam
								movzx	ebx, bx
								.if		ax == BN_RCLICKED
										invoke	_ClickTile, hWnd, @stPoint, BN_RCLICKED, ebx
								.elseif	ax == BN_MCLICKED
										invoke	_ClickTile, hWnd, @stPoint, BN_MCLICKED, ebx
								.elseif	ax == BN_CLICKED
										invoke	_ClickTile, hWnd, @stPoint, BN_CLICKED, ebx
								.endif
								
						.elseif	eax == IDB_START
								mov		eax, wParam
								shr		eax, 16
								.if		ax == BN_CLICKED
										invoke	_CreateGame, hWnd, IDR_CUSTOM
								.elseif	ax == BN_PUSHED
										invoke	GetDlgItem, hWnd, IDB_START
										invoke	LoadIcon, hInstance, ICO_SMILEY_SAD
										invoke	SendMessage, @hStartButton, BM_SETIMAGE, IMAGE_ICON, eax
								.elseif	ax == BN_UNPUSHED
										invoke	GetDlgItem, hWnd, IDB_START
										invoke	LoadIcon, hInstance, ICO_SMILEY
										invoke	SendMessage, @hStartButton, BM_SETIMAGE, IMAGE_ICON, eax
								.endif
						.elseif	eax == IDA_ESC 
								invoke	_Quit
						.endif
				.elseif	eax == WM_SYSCOMMAND
						mov		eax, wParam
						movzx	eax, ax
						;禁止最大化
						.if		eax == SC_MAXIMIZE
								ret
						.else
								invoke	DefWindowProc, hWnd, uMsg, wParam, lParam
								ret
						.endif
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
				local	@hAccelerator

				invoke	GetModuleHandle, NULL
				mov		hInstance, eax
				invoke	RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
				invoke	LoadIcon, hInstance, ICO_MINE_COMMON
				mov		@stWndClass.hIcon, eax
				mov		@stWndClass.hIconSm, eax
				mov		hIcoMain, eax
				invoke	LoadAccelerators, hInstance, IDR_ACCELERATOR
				mov		@hAccelerator, eax
				invoke	LoadMenu, hInstance, IDR_MENU
				mov		hMenu, eax
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
										hMenu,									;hMenu
										hInstance,								;hInstance
										NULL									;lpParam
				mov		hWinMain, eax
				invoke	ShowWindow, hWinMain, SW_SHOWNORMAL
				invoke	UpdateWindow, hWinMain
				.while	TRUE
						invoke	GetMessage, addr @stMsg, NULL, 0, 0
						.break	.if eax == 0
						invoke	TranslateAccelerator, hWinMain, @hAccelerator, addr @stMsg
						.if		eax == 0
								invoke	TranslateMessage, addr @stMsg
								invoke	DispatchMessage, addr @stMsg
						.endif
				.endw
				ret
_WinMain		endp

start:
		call	_WinMain
		invoke	ExitProcess, NULL
		xor		eax, eax
		ret
end		start
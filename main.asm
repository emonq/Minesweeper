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

rand	PROTO C

;图标定义
ICO_MINE_COMMON			equ		101
ICO_MINE_RED			equ		102
ICO_MINE_BROKEN			equ		103
ICO_SMILEY_WIN			equ		104
ICO_SMILEY				equ		105
ICO_SMILEY_OH			equ		106
ICO_SMILEY_SAD			equ		107
ICO_TILE_COMMON			equ		108
ICO_TILE_UNKNOWN		equ		109
ICO_TILE_FLAG			equ		110
IDI_ICON1				equ		117
IDI_ICON2				equ		118
IDI_ICON3				equ		119
IDI_ICON4				equ		120
IDI_ICON5				equ		121
IDI_ICON6				equ		122
IDI_ICON7				equ		123
IDI_ICON8				equ		124
IDI_NUMBER0             equ     140
IDI_NUMBER1             equ     141
IDI_NUMBER2             equ     142
IDI_NUMBER3             equ     143
IDI_NUMBER4             equ     144
IDI_NUMBER5             equ     145
IDI_NUMBER6             equ     146
IDI_NUMBER7             equ     147
IDI_NUMBER8             equ     148
IDI_NUMBER9             equ     149

;菜单定义
IDR_MENU				equ		111
IDR_BEGINNER			equ		40007
IDR_INTERMEDIATE		equ		40008
IDR_ADVANCED			equ		40009
IDR_MASTER				equ		40010
IDR_CUSTOM				equ		40011
IDR_ABOUT				equ		40012
IDR_CHEAT				equ		40019

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
;自定义双击通知
BN_DBCLICK				equ		0CCH
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

;剩余雷数显示框
ID_MINE_SHOW1				equ		70001
ID_MINE_SHOW2				equ		70002
ID_MINE_SHOW3				equ		70003
;时间显示框
ID_TIMER_SHOW1				equ		70004
ID_TIMER_SHOW2				equ		70005
ID_TIMER_SHOW3				equ		70006

ID_TIMER				equ		70010

.data?
hInstance		dd				?
hWinMain		dd				?
hIcoMain		dd				?
hIconFlag		dd				?
hIconUnknown	dd				?
hIconTileCommon	dd				?
hIconMineCommon	dd				?
hIconMineBroken	dd				?
hIconMineRed	dd				?
hIcon1			dd				?
hIcon2			dd				?
hIcon3			dd				?
hIcon4			dd				?
hIcon5			dd				?
hIcon6			dd				?
hIcon7			dd				?
hIcon8			dd				?
hIconSad		dd				?
hIconSmile		dd				?
hIconOh			dd				?
hNumber0		dd				?
hNumber1		dd				?
hNumber2		dd				?
hNumber3		dd				?
hNumber4		dd				?
hNumber5		dd				?
hNumber6		dd				?
hNumber7		dd				?
hNumber8		dd				?
hNumber9		dd				?
hStartButton	dd				?
hMenu			dd				?
lpDefProcTile	dd				?

.data
ddFlagCount				dd		0
ddMineSweepedCount		dd		0
ddMineTotalCount		dd		10
ddNoneMineCount			dd		90
dwRow					dw		10
dwColumn				dw		10
dwTileID				dd		TILE_START
bStarted				db		0
ddPointer				dd		0	
hMineShow				dd		0, 0, 0
hTimerShow				dd		0, 0, 0
ddTimer					dd		0
ddFlagCheat				dd		0

.const
szClassName				db		"MinesweeperClass", 0
szCaptionMain			db		"扫雷", 0
szButtonClass			db		"button", 0
szStaticClass			db		"static", 0
szTextAboutCaption		db		"关于扫雷",0
szTextFailCaption		db		"失败",0
szTextSucessCaption		db		"胜利",0
szTextFail				db		"您触雷了，游戏失败",0ah,"要开始新游戏吗？",0
szTextSucess			db		"真厉害，您胜利了！",0ah,"要开始新游戏吗？",0
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

_CreateGame	proto stdcall hWnd:dword, level:dword

_ShowNumber proc uses ecx ebx edx,handle:dword, number:dword
	xor eax, eax
	mov	eax, number
	mov edx, 4
	mul edx 
	mov	ecx, offset hNumber0
	add ecx, eax
	invoke SendMessage, handle, BM_SETIMAGE, IMAGE_ICON, [ecx]
	xor eax, eax
	ret
_ShowNumber endp

_ShowTime	proc uses edx eax ebx ecx
	local @: dword
	xor edx, edx
	mov	eax, ddTimer
	mov	ebx, 10
	div	ebx
	mov @, edx
	push	eax
	invoke _ShowNumber, hTimerShow[8], @
	xor	edx, edx
	pop eax
	mov	ebx, 10
	div ebx
	mov @, eax
	invoke _ShowNumber, hTimerShow[0], @
	mov	@, edx
	invoke _ShowNumber, hTimerShow[4], @
	xor eax, eax
	ret
_ShowTime	endp

_ShowMineCount	proc uses edx eax ebx ecx
	local @ : dword
	xor edx, edx
	mov	eax, ddMineTotalCount
	sub eax, ddFlagCount
	mov	ebx, 10
	div ebx
	push eax 
	mov	@, edx
	invoke _ShowNumber, hMineShow[8], @
	xor edx, edx
	pop eax
	mov	ebx, 10
	div	ebx
	mov	@, eax
	mov	ecx, hMineShow[0]
	invoke _ShowNumber,ecx , @
	mov @, edx
	invoke _ShowNumber, hMineShow[4], @

	xor	eax, eax
	ret
_ShowMineCount	endp	

_DisableTiles	proc uses eax esi
				mov		esi, dwTileID
				.while	esi > TILE_START
						invoke	GetDlgItem, hWinMain, esi
						invoke	EnableWindow, eax, FALSE
						dec		esi
				.endw
				ret
_DisableTiles	endp

;按下后数字显示
_Show	proc	uses eax ebx ecx edi esi, hWnd,stPoint:POINT,tileID
	local	@myOffset	;当前点击坐标的偏移量
	local	@newOffset	;要拓展的坐标的偏移量
	local	@newtileID
	local	@hTile
	local	i
	local	j
	local	@stPoint:POINT
	invoke	GetDlgItem, hWnd, tileID
	mov		@hTile, eax
	invoke	SendMessage, @hTile, BM_GETIMAGE, IMAGE_ICON, 0
	.if eax == hIconFlag
		ret
	.endif
	mov	ebx,tileID
	sub	ebx,TILE_START
	dec ebx
	add	ebx,ddPointer
	mov @myOffset,ebx
	;产生爆炸
	.if byte ptr [ebx] == 0ffh
		invoke SendMessage,@hTile,BM_SETIMAGE,IMAGE_ICON, hIconMineBroken
		.if		ddFlagCheat
				ret
		.endif
		invoke	KillTimer, hWinMain, ID_TIMER
		invoke	SendMessage, hStartButton, BM_SETIMAGE, IMAGE_ICON, hIconSad
		invoke	MessageBox, hWnd, offset szTextFail, offset szTextFailCaption, MB_OKCANCEL
		.if		eax == IDOK
				invoke	_CreateGame, hWinMain, IDR_CUSTOM
		.else
				invoke	_DisableTiles
		.endif
	.elseif byte ptr [ebx] < 9
		.if byte ptr [ebx] == 0	
			invoke SendMessage,@hTile,BM_SETIMAGE,IMAGE_ICON, hIconTileCommon
			mov	al,9
			mov byte ptr [ebx],al
			inc	ddMineSweepedCount 
			mov	eax,ddNoneMineCount
			.if ddMineSweepedCount == eax
				invoke	KillTimer, hWinMain ,ID_TIMER
				invoke	MessageBox, hWnd, offset szTextSucess, offset szTextSucessCaption, MB_OKCANCEL
				.if		eax == IDOK
						invoke	_CreateGame, hWinMain, IDR_CUSTOM
				.else
						invoke	_DisableTiles
				.endif
				
			.endif
			mov	i,0
			.while i < 3
				mov j,0
				.while j < 3
					xor ecx,ecx
					xor	edx,edx
					mov cx,dwRow
					mov	dx,dwColumn
					dec	ecx
					dec	edx
					.if (stPoint.y == 0 && i == 0) || (stPoint.x == 0 && j == 0)
						inc	j
						.continue
					.elseif	(ecx == stPoint.y && i == 2) || (edx == stPoint.x && j == 2)
						inc j
						.continue
					.else
						mov	eax,i
						mul dwColumn
						add	eax,tileID
						sub	ax,dwColumn
						add	eax,j
						dec	eax
						mov	@newtileID,eax
						add	eax,@myOffset
						sub	eax,tileID
						mov	@newOffset,eax
						mov	eax,j
						add	eax,stPoint.x
						dec	eax
						mov	@stPoint.x,eax
						mov	eax,i
						add	eax,stPoint.y
						dec	eax
						mov @stPoint.y,eax
						mov	eax,@newtileID
						sub	eax,TILE_START
						add	eax,ddPointer
						dec	eax
						mov	edi,eax		
						.if	ddPointer == 0
							ret
						.endif
						.if	byte ptr [edi] != 9 
							invoke _Show,hWnd,@stPoint,@newtileID
						.endif
					.endif
					inc j
				.endw
				inc	i
			.endw
		.else
			mov al,byte ptr [ebx]
			movzx eax,al
			mov	cl,4
			mul cl
			add eax,offset hIcon1
			sub eax,4
			invoke SendMessage,@hTile,BM_SETIMAGE,IMAGE_ICON, [eax]
			mov al,9
			mov byte ptr [ebx],al
			inc	ddMineSweepedCount
			mov	eax,ddNoneMineCount
			.if ddMineSweepedCount == eax
				invoke	KillTimer, hWinMain ,ID_TIMER
				invoke	MessageBox, hWnd, offset szTextSucess, offset szTextSucessCaption, MB_OKCANCEL
				.if		eax == IDOK
						invoke	_CreateGame, hWinMain, IDR_CUSTOM
				.else
						invoke	_DisableTiles
				.endif
			.endif
		.endif
	.endif
	ret
_Show	endp

_DoubleClick proc uses edi ebx eax esi edi edx ecx,hWnd,stPoint:POINT,tileID,Number
	local @newtileID
	local @newstPoint:POINT
	local	num
	local	i
	local	j
	mov		i,0
	mov		num,0
	.while	i < 3
		mov	j,0
		.while j < 3
		xor	edx,edx
		mov	dx,dwColumn
		dec	dx
		.if	(stPoint.x == 0 && i == 0) || (stPoint.x == edx && i == 2)
			inc	j
			.continue
		.endif
		xor	edx,edx
		mov	dx,dwRow
		dec	dx
		.if (stPoint.y == 0 && j == 0) || (stPoint.y == edx && j == 2)
			inc	j
			.continue
		.endif
		mov	eax,j
		mul	dwColumn
		add	eax,tileID
		sub	ax,dwColumn
		add	eax,i
		dec	eax
		mov	@newtileID,eax
		invoke	GetDlgItem, hWnd, @newtileID
		invoke	SendMessage, eax, BM_GETIMAGE, IMAGE_ICON, 0
		.if	eax == hIconFlag
			inc	num
		.endif
		inc	j
		.endw
		inc	i
	.endw
	mov	eax,num
	.if	eax == 	Number
		mov		i,0
		.while	i < 3
		mov	j,0
		.while j < 3
		xor edx,edx
		mov	dx,dwColumn
		dec	dx
		.if	(stPoint.x == 0 && i == 0) || (stPoint.x == edx && i == 2)
			inc	j
			.continue
		.endif
		xor	edx,edx
		mov	dx,dwRow
		dec	dx
		.if (stPoint.y == 0 && j == 0) || (stPoint.y == edx && j == 2)
			inc	j
			.continue
		.endif
		mov	eax,j
		mul	dwColumn
		add	eax,tileID
		sub	ax,dwColumn
		add	eax,i
		dec	eax
		mov	@newtileID,eax
		invoke	GetDlgItem, hWnd, @newtileID
		invoke	SendMessage, @newtileID, BM_GETIMAGE, IMAGE_ICON, 0
		.if	eax == 0
			mov	eax,stPoint.x
			add	eax,i
			dec	eax
			mov	@newstPoint.x,eax
			mov	eax,stPoint.y
			add	eax,j
			dec	eax
			mov	@newstPoint.y,eax
			invoke	_Show,hWnd,@newstPoint,@newtileID
			.if	ddPointer == 0
				ret
			.endif
		.endif
		inc	j
		.endw
		inc	i
	.endw
	.endif
	ret
_DoubleClick	endp

;初始化雷
_Init	proc	uses edi ebx eax esi edi edx ecx,stPoint:POINT
		local	@size:word
		local	@pAddr
		local	@num
		local	@myOffset
		local	i
		local	j
		xor		eax,eax
		mov		ax,dwRow
		mov		bx,dwColumn
		mul		bx
		mov		@size,ax
		sub		eax,ddMineTotalCount
		mov		ddNoneMineCount,eax
		invoke	GlobalAlloc,GPTR,@size
		mov		ddPointer,eax
		mov		eax,stPoint.y
		mul		dwColumn
		add		eax,stPoint.x
		add		eax,ddPointer
		mov		@pAddr,eax
		mov		byte ptr [eax],0ffh
		mov		i,0
		xor		ebx,ebx
		mov		ebx,i
		.while	ebx < ddMineTotalCount
				invoke rand
				mov	edx,eax
				shr	edx,16
				div	@size
				mov	bx,dx
				movzx	ebx, bx
				mov	edi, ddPointer
				add	edi, ebx
				.if	byte ptr [edi] == 0ffh
					mov	ebx,i
					.continue
				.else	
					mov byte ptr [edi],0ffh 
				.endif
				inc	i
				mov	ebx,i
		.endw
		mov		eax,@pAddr
		mov		byte ptr [eax],0
		xor		eax,eax
		xor		ebx,ebx
		mov		i,0
		mov		j,0
		mov		ebx,0
		;ddPointer+ebx+(i-1)*column+j-1
		.while	bx < @size
			movzx	ecx,bx
			add		ecx,ddPointer
			.if	byte ptr [ecx] == 0ffh
				inc	bx
				.continue
			.endif
			mov	i,0
			mov	@num,0
			.while	i < 3
				mov	j,0
				.while	j < 3
					mov	eax,ddPointer
					add	eax,ebx
					add	eax,j
					dec	eax
					sub	ax,dwColumn
					mov	@myOffset,eax
					mov	eax,i
					mul dwColumn
					add	@myOffset,eax
					push	eax
					push	edx
					xor		dx,dx
					mov		ax,bx
					div		dwColumn
					.if (ax == 0 && i == 0) ||(dx==0 && j==0)
						pop	edx
						pop eax
						inc j
						.continue
					.else
						inc	ax
						inc	dx
						.if (ax == dwRow && i == 2) || (dx == dwColumn && j == 2)
							pop	edx
							pop	eax
							inc j
							.continue
						.endif
					.endif

					mov	ecx,@myOffset
					.if byte ptr [ecx] == 0ffh
						inc	@num
					.endif
				inc	j
				.endw
				inc	i
			.endw
			mov	eax,@num
			mov	ecx,ddPointer
			add	ecx,ebx
			mov	byte ptr [ecx],al
			inc	bx
		.endw
		ret
_Init	endp

;响应Tile的点击事件
_ClickTile		proc	hWnd, stPoint:POINT, typeID, tileID
				local	@szTemp[128]:byte
				local	@hTile
				invoke	GetDlgItem, hWnd, tileID
				mov		@hTile, eax
				;右键单击
				.if		typeID == BN_RCLICKED
						invoke	SendMessage, @hTile, BM_GETIMAGE, IMAGE_ICON, 0
						.if eax == hIconFlag
							ret
						.endif
						.if	bStarted == 1
							mov	eax,stPoint.y
							mul	dwColumn
							add	eax,ddPointer
							add	eax,stPoint.x
							.if	byte ptr [eax] != 9
								push edx
								mov	edx, ddMineTotalCount
								.if ddFlagCount < edx
									inc	ddFlagCount
									invoke _ShowMineCount
									invoke	SendMessage, @hTile, BM_SETIMAGE, IMAGE_ICON, hIconFlag
								.endif
								pop edx
							.endif
						.else
							push edx
							mov	edx, ddMineTotalCount
							.if ddFlagCount < edx
								inc	ddFlagCount
								invoke _ShowMineCount
								invoke	SendMessage, @hTile, BM_SETIMAGE, IMAGE_ICON, hIconFlag
							.endif
						.endif
				;中键单击
				.elseif	typeID == BN_MCLICKED
						.if	bStarted == 1
							mov	eax,stPoint.y
							mul	dwColumn
							add	eax,ddPointer
							add	eax,stPoint.x
							.if	byte ptr [eax] != 9
								invoke	SendMessage, @hTile, BM_SETIMAGE, IMAGE_ICON, hIconFlag
							.endif
						.elseif
							invoke	SendMessage, @hTile, BM_SETIMAGE, IMAGE_ICON, hIconUnknown
						.endif
				;双击事件
				.elseif	typeID == BN_DBCLICK
						.if	bStarted == 1
							mov	ebx,tileID
							sub	ebx,TILE_START
							dec	ebx
							add	ebx,ddPointer
							.if	byte ptr [ebx] == 9
								invoke	SendMessage, @hTile, BM_GETIMAGE, IMAGE_ICON, 0
								.if	eax == hIconTileCommon
									invoke _DoubleClick,hWnd,stPoint,tileID,0
								.elseif eax == hIcon1
									invoke _DoubleClick,hWnd,stPoint,tileID,1
								.elseif eax == hIcon2
									invoke _DoubleClick,hWnd,stPoint,tileID,2
								.elseif eax == hIcon3
									invoke _DoubleClick,hWnd,stPoint,tileID,3
								.elseif eax == hIcon4
									invoke _DoubleClick,hWnd,stPoint,tileID,4
								.elseif eax == hIcon5
									invoke _DoubleClick,hWnd,stPoint,tileID,5
								.elseif eax == hIcon6
									invoke _DoubleClick,hWnd,stPoint,tileID,6
								.elseif eax == hIcon7
									invoke _DoubleClick,hWnd,stPoint,tileID,7
								.elseif eax == hIcon8
									invoke _DoubleClick,hWnd,stPoint,tileID,8
								.endif
							.endif
						.endif
				;左键单击，清空标记
				.else
						invoke	SendMessage, @hTile, BM_GETIMAGE, IMAGE_ICON, 0
						.if		eax == hIconFlag
								invoke	SendMessage, @hTile, BM_SETIMAGE, IMAGE_ICON, hIconUnknown
								dec	ddFlagCount
								invoke _ShowMineCount
						.elseif	eax == hIconUnknown
								invoke	SendMessage, @hTile, BM_SETIMAGE, IMAGE_ICON, 0
						.else	
							.if	bStarted == 0
								invoke _Init, stPoint
								mov		byte ptr bStarted,1
								invoke	SetTimer, hWinMain, ID_TIMER, 1000, NULL
							.endif
							invoke _Show, hWnd,stPoint,tileID
						.endif
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
						invoke	SendMessage, hStartButton, BM_SETIMAGE, IMAGE_ICON, hIconOh
						invoke	CallWindowProc, lpDefProcTile, hWnd, uMsg, wParam, lParam
						ret
				.elseif	eax == WM_LBUTTONUP
						invoke	SendMessage, hStartButton, BM_SETIMAGE, IMAGE_ICON, hIconSmile
						invoke	CallWindowProc, lpDefProcTile, hWnd, uMsg, wParam, lParam
						ret
				.elseif	eax == WM_MBUTTONDOWN
						invoke	GetDlgCtrlID, hWnd
						mov		ebx, eax
						mov		ax, BN_MCLICKED
						shl		eax, 16
						mov		ax, bx
						invoke	SendMessage, @hParent, WM_COMMAND, eax, lParam
				.elseif	eax == WM_LBUTTONDBLCLK
						invoke	GetDlgCtrlID, hWnd
						mov		ebx, eax
						mov		ax, BN_DBCLICK
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
				mov		byte ptr bStarted,0
				mov		ddPointer,0
				mov		ddMineSweepedCount,0
				mov		ddFlagCount,0
				mov		ddTimer, 0
				invoke	KillTimer, hWinMain ,ID_TIMER
				invoke	GlobalFree,ddPointer
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
				invoke	GetDlgItem, hWnd, ID_TIMER_SHOW1
				invoke	DestroyWindow, eax
				invoke	GetDlgItem, hWnd, ID_TIMER_SHOW2
				invoke	DestroyWindow, eax
				invoke	GetDlgItem, hWnd, ID_TIMER_SHOW3
				invoke	DestroyWindow, eax
				invoke	GetDlgItem, hWnd, ID_MINE_SHOW1
				invoke	DestroyWindow, eax
				invoke	GetDlgItem, hWnd, ID_MINE_SHOW2
				invoke	DestroyWindow, eax
				invoke	GetDlgItem, hWnd, ID_MINE_SHOW3
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
				invoke	SendMessage, hStartButton, BM_SETIMAGE, IMAGE_ICON, hIconSmile

				; 创建剩余雷数窗口
				xor	ecx,	ecx
				.while	ecx < 3
					mov		ebx, BORDER_SIZE
					xor		eax, eax
					mov		eax, START_SIZE/2
					mul		ecx
					add		ebx, eax
					mov		eax, ID_MINE_SHOW1
					add		eax, ecx
					push	ecx
					invoke	CreateWindowEx, NULL,
											offset szButtonClass,
											NULL,
											WS_CHILD or WS_VISIBLE  or BS_ICON or BS_NOTIFY,
											ebx , BORDER_SIZE + START_SIZE/4, START_SIZE/2-4, START_SIZE/2,
											hWnd, eax, hInstance, NULL
					pop		ecx
					mov		hMineShow[ecx*4],	eax
					mov		ebx,	eax
					;push	ecx
					;invoke	SendMessage, ebx, BM_SETIMAGE, IMAGE_ICON, hNumber0 
					;pop     ecx
					;invoke _ShowNumber, ebx, 5
					inc	ecx
				.endw
				invoke	_ShowMineCount

				; 创建计时器窗口
				mov		ebx, @stRect.right
				sub		ebx, @stRect.left
				sub		ebx, BORDER_SIZE
				xor     eax, eax
				mov		eax, START_SIZE/2
				mov		ecx, 3
				mul     ecx
				sub		ebx, eax
				xor		ecx, ecx
				.while ecx < 3
						push    ebx
						xor		eax, eax
						mov		eax, START_SIZE/2
						mul		ecx
						add		ebx, eax
						mov		eax, ID_TIMER_SHOW1
						add		eax, ecx
						push	ecx
						invoke	CreateWindowEx, NULL,
												offset szButtonClass,
												NULL,
												WS_CHILD or WS_VISIBLE  or BS_ICON or BS_NOTIFY,
												ebx , BORDER_SIZE + START_SIZE/4, START_SIZE/2-4, START_SIZE/2,
												hWnd, eax, hInstance, NULL
						pop		ecx
						mov		hTimerShow[ecx*4],	eax
						inc		ecx
						pop		ebx
				.endw
				invoke _ShowTime

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
								dec		eax
								.if		edi > eax
										invoke	wsprintf, addr @buf, offset szMineExceedFmt, eax
										invoke	MessageBox, hWnd, addr @buf, offset szError, MB_ICONERROR
										ret
								.endif
								mov		ddMineTotalCount, edi

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
						;加载图标
						invoke	LoadIcon, hInstance, ICO_SMILEY
						mov		hIconSmile, eax
						invoke	LoadIcon, hInstance, ICO_SMILEY_SAD
						mov		hIconSad, eax
						invoke	LoadIcon, hInstance, ICO_SMILEY_OH
						mov		hIconOh, eax
						invoke	LoadIcon, hInstance, ICO_TILE_FLAG
						mov		hIconFlag, eax
						invoke	LoadIcon, hInstance, ICO_TILE_UNKNOWN
						mov		hIconUnknown, eax
						invoke	LoadIcon, hInstance, IDI_ICON1
						mov		hIcon1, eax
						invoke	LoadIcon, hInstance, IDI_ICON2
						mov		hIcon2, eax
						invoke	LoadIcon, hInstance, IDI_ICON3
						mov		hIcon3, eax
						invoke	LoadIcon, hInstance, IDI_ICON4
						mov		hIcon4, eax
						invoke	LoadIcon, hInstance, IDI_ICON5
						mov		hIcon5, eax
						invoke	LoadIcon, hInstance, IDI_ICON6
						mov		hIcon6, eax
						invoke	LoadIcon, hInstance, IDI_ICON7
						mov		hIcon7, eax
						invoke	LoadIcon, hInstance, IDI_ICON8
						mov		hIcon8, eax

						invoke	LoadIcon, hInstance, ICO_TILE_COMMON
						mov		hIconTileCommon, eax
						invoke	LoadIcon, hInstance, ICO_MINE_COMMON
						mov		hIconMineCommon, eax
						invoke	LoadIcon, hInstance, ICO_MINE_BROKEN
						mov		hIconMineBroken, eax
						invoke	LoadIcon, hInstance, ICO_MINE_RED
						mov		hIconMineRed, eax

						invoke	LoadIcon, hInstance, IDI_NUMBER0
						mov		hNumber0,	eax
						invoke	LoadIcon, hInstance, IDI_NUMBER1
						mov		hNumber1,	eax
						invoke	LoadIcon, hInstance, IDI_NUMBER2
						mov		hNumber2,	eax
						invoke	LoadIcon, hInstance, IDI_NUMBER3
						mov		hNumber3,	eax
						invoke	LoadIcon, hInstance, IDI_NUMBER4
						mov		hNumber4,	eax
						invoke	LoadIcon, hInstance, IDI_NUMBER5
						mov		hNumber5,	eax
						invoke	LoadIcon, hInstance, IDI_NUMBER6
						mov		hNumber6,	eax
						invoke	LoadIcon, hInstance, IDI_NUMBER7
						mov		hNumber7,	eax
						invoke	LoadIcon, hInstance, IDI_NUMBER8
						mov		hNumber8,	eax
						invoke	LoadIcon, hInstance, IDI_NUMBER9
						mov		hNumber9,	eax

						invoke	CheckMenuRadioItem, hMenu, IDR_BEGINNER, IDR_CUSTOM, IDR_BEGINNER, MF_BYCOMMAND
						invoke	_CreateGame, hWnd, IDR_BEGINNER

				.elseif	eax == WM_COMMAND
						mov		eax, wParam
						movzx	eax, ax
						.if		eax == IDR_ABOUT
								invoke	MessageBox, hWnd, offset szTextAbout, offset szTextAboutCaption, MB_OK
						.elseif	eax == IDR_CHEAT
								mov		ebx, eax
								invoke	GetMenuState, hMenu, ebx, MF_BYCOMMAND
								.if		eax == MF_CHECKED
										mov		eax, MF_UNCHECKED
										mov		ddFlagCheat, 0
								.else
										mov		eax, MF_CHECKED
										mov		ddFlagCheat, 1
								.endif
								invoke	CheckMenuItem, hMenu, ebx, eax
						.elseif	eax >= IDR_BEGINNER && eax <= IDR_CUSTOM
								mov		@level, eax
								.if		@level == IDR_CUSTOM
										invoke	DialogBoxParam, hInstance, IDD_CUSTOM, hWnd, _CustomDlgProc, NULL
										.if		eax == TRUE
												invoke	_CreateGame, hWnd, IDR_CUSTOM
												invoke	CheckMenuRadioItem, hMenu, IDR_BEGINNER, IDR_CUSTOM, @level, MF_BYCOMMAND
										.endif
								.else
										invoke	CheckMenuRadioItem, hMenu, IDR_BEGINNER, IDR_CUSTOM, @level, MF_BYCOMMAND
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
								.elseif	ax == BN_DBCLICK
										invoke	_ClickTile, hWnd, @stPoint, BN_DBCLICK, ebx
								.endif
						.elseif	eax == IDB_START
								mov		eax, wParam
								shr		eax, 16
								.if		ax == BN_CLICKED
										invoke	_CreateGame, hWnd, IDR_CUSTOM
								.endif
						.elseif	eax == IDA_ESC 
								invoke	_Quit
						.endif
				.elseif eax == WM_CLOSE
						invoke	DestroyWindow, hWinMain
						invoke	PostQuitMessage, NULL
				.elseif eax == WM_TIMER
						inc	ddTimer
						.if ddTimer < 1000
							invoke _ShowTime	
						.endif
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
				mov		eax, WS_OVERLAPPEDWINDOW
				xor		eax, WS_THICKFRAME
				xor		eax, WS_MAXIMIZEBOX
				invoke	CreateWindowEx, WS_EX_CLIENTEDGE,						;dwExStyle
										offset szClassName,						;lpClassName
										offset szCaptionMain,					;lpWindowName
										eax,	;dwStyle
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
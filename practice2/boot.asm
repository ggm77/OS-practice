;2025.11.25 - https://itguava.tistory.com/15

%include "init.inc"
[org 0]

jmp 07c0h:start

start:
    mov ax, cs
    mov ds, ax

    mov ax, 0xB800
    mov es, ax
    mov di, 0
    mov ax, word [msgBack]
    mov cx, 0x7FF

    mov [BootDrive], dl ;부팅한 드라이브 번호 저장

paint:
    mov word [es:di], ax
    add di, 2
    dec cx

    jnz paint

    mov edi, 0
    mov byte [es:edi], 'R'
    inc edi
    mov byte [es:edi], 0x20
    inc edi
    mov byte [es:edi], 'e'
    inc edi
    mov byte [es:edi], 0x20
    inc edi
    mov byte [es:edi], 'a'
    inc edi
    mov byte [es:edi], 0x20
    inc edi
    mov byte [es:edi], 'l'
    inc edi
    mov byte [es:edi], 0x20
    inc edi
    mov byte [es:edi], ' '
    inc edi
    mov byte [es:edi], 0x20
    inc edi
    mov byte [es:edi], 'M'
    inc edi
    mov byte [es:edi], 0x20
    inc edi
    mov byte [es:edi], 'o'
    inc edi
    mov byte [es:edi], 0x20
    inc edi
    mov byte [es:edi], 'd'
    inc edi
    mov byte [es:edi], 0x20
    inc edi
    mov byte [es:edi], 'e'
    inc edi
    mov byte [es:edi], 0x20
    inc edi

;커널 읽어오는 부분
disk_read:
    ; int 13h는 읽어온걸 항상 es:bx에 넣는다.
    mov ax, 0x1000          ;복사 목적지 주소 값 지정 ES:BX = 0x1000:0000 (물리 주소 = 0x10000)
    mov es, ax
    mov bx, 0

    mov ah, 2               ;디스크에서 읽어오는 기능 사용하기 (디스크에 있는 데이터를 es:bx의 주소로)
    ; mov dl, 0               ;0번 드라이브
    mov dl, [BootDrive]     ;처음에 저장한 부팅한 드라이브 번호 저장
    mov ch, 0               ;0번째 실린더
    mov dh, 0               ;0번 헤드
    mov cl, 2               ;(몇번째 섹터부터 읽을 것인가?) 2번째 섹터부터 읽을 것이다. [섹터는 1번부터 시작 (1번에는 부트로더 있음)]
    mov al, 1               ;(처리할 연속적 섹터 번호: 몇개의 섹터를 읽을 것인가?) 1개의 섹터를 읽을 것이다.


    int 13h                 ;읽기

    jc disk_read            ;에러나면 다시 함.

    cli

    lgdt[gdtr]              ;GDT 가져오기

    mov eax, cr0            ;CR0의 값을 eax에 넣어준다.
    or eax, 0x00000001      ;eax의 값을 0x00000001과 or 연산하고
    mov cr0, eax            ;다시 CR0에 or연산된 값을 넣어준다. ; 이때 보호모드 시작

    jmp $+2                 ;2개의 명령을 점프한다.
    nop
    nop

    ;플랫 메모리 모델을 위해서 모두 같은 값으로 설정
    mov bx, SysDataSelector
    mov ds, bx
    mov es, bx
    mov ss, bx

    jmp dword SysCodeSelector:0x10000 ;커널로 점프 ;아래는 전부 데이터

    msgBack db '.', 0x17

;GDT
gdtr:
    dw gdt_end - gdt - 1    ;GDT의 limit
    dd gdt+0x7C00           ;GDT의 베이스 어드레스

gdt:
    dd 0x00000000, 0x00000000 ;NULL 세그먼트 디스크립터
    dd 0x0000FFFF, 0x00CF9A00 ;코드 세그먼트 디스크립터
    dd 0x0000FFFF, 0x00CF9200 ;데이터 세그먼트 디스크립터
    dd 0x8000FFFF, 0x0040920B ;비디오 세그먼트 디스크립터

gdt_end:
    times 510-($-$$) db 0
    dw 0xAA55

BootDrive db 0

;아래 코드는 위의 gdt코드와 의미가 같다.
; gdt:                        ;NULL 세그먼트 디스크립터
;     dw 0                    ;모든 비트가 0
;     dw 0
;     db 0
;     db 0
;     db 0
;     db 0

; SysCodeSelector equ 0x08    ;코드 세그먼트 디스크립터
;     dw 0xFFFF               ;세그먼트 리미트 0~15비트:                    (2진수: 1111 1111 1111 1111)
;     dw 0x0000               ;베이스 어드레스 하위 0~15비트:                (2진수: 0000 0000 0000 0000)
;     db 0x01                 ;베이스 어드레스 상위 16~23비트:                         (2진수: 0000 0001)
;     db 0x9A                 ;속성 비트(P, DPL, S, TYPE):                         (2진수: 1001 1010)
;     db 0xCF                 ;속성 비트(G, D, 예약비트, AVL, 세그먼트 리미트 16~19비트): (2진수: 1100 1111)
;     db 0x00                 ;베이스 어드레스 상위 24~31비트:                         (2진수: 0000 0000)

; SysDataSelector equ 0x10    ;데이터 세그먼트 디스크립터
;     dw 0xFFFF
;     dw 0x0000
;     db 0x01
;     db 0x92
;     db 0xCF
;     db 0x00

; VideoSelector equ 0x18      ;비디오 세그먼트 디스크립터
;     dw 0xFFFF
;     dw 0x8000
;     db 0x0B
;     db 0x92
;     db 0xCF
;     db 0x00
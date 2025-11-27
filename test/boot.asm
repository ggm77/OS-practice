; ============================
; boot.asm (512 byte boot sector)
; - Real Mode: 화면에 "HELLO"
; - Protected Mode: 다른 줄에 "PM"
; ============================

[org 0x7C00]        ; 이 바이너리가 물리 주소 0x7C00에 올라온다고 가정
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00        ; 간단한 스택

    ; -------- Real Mode: 화면에 HELLO 찍기 --------
    mov ax, 0xB800
    mov es, ax
    xor di, di

    mov byte [es:di], 'H'
    mov byte [es:di+1], 0x07
    mov byte [es:di+2], 'E'
    mov byte [es:di+3], 0x07
    mov byte [es:di+4], 'L'
    mov byte [es:di+5], 0x07
    mov byte [es:di+6], 'L'
    mov byte [es:di+7], 0x07
    mov byte [es:di+8], 'O'
    mov byte [es:di+9], 0x07

    ; -------- GDT 로드 + 보호 모드 진입 --------
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1             ; PE bit = 1
    mov cr0, eax

    ; 보호 모드 진입 직후: 코드 세그먼트(0x08)로 far jump 해서 파이프라인 플러시
    jmp CODE_SEG:pm_start


; -------- 여기부터 32비트 보호 모드 코드 --------
[bits 32]
pm_start:
    ; 세그먼트 초기화
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x9FC00      ; 적당한 스택

    ; 비디오 메모리(0xB8000)에 바로 접근 (플랫 모델, base=0)
    mov edi, 80*2*2       ; 3번째 줄(row=2) 맨 앞
    mov eax, 0x07200750   ; 'P'(0x50), attr=0x07, ' ' 등 한꺼번에 써도 되지만
    ; 여기서는 그냥 한 글자씩 가자

    mov edi, 80*2*2       ; row 2, col 0
    mov byte [0xB8000 + edi], 'P'
    mov byte [0xB8000 + edi + 1], 0x07
    add edi, 2
    mov byte [0xB8000 + edi], 'M'
    mov byte [0xB8000 + edi + 1], 0x07

.hang:
    jmp .hang


; -------- 다시 16비트로 내려와서 GDT 데이터 정의 --------
[bits 16]

CODE_SEG equ 0x08
DATA_SEG equ 0x10

gdt_start:
    ; NULL descriptor
    dd 0x00000000
    dd 0x00000000

    ; Code segment: base=0, limit=4GB, 32-bit
    dd 0x0000FFFF          ; limit low, base low
    dd 0x00CF9A00          ; base mid/high, access, flags

    ; Data segment: base=0, limit=4GB
    dd 0x0000FFFF
    dd 0x00CF9200
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; limit
    dd gdt_start                  ; base (org 0x7C00이라 실제 물리주소도 이 값 그대로)


; -------- Boot Signature --------
times 510-($-$$) db 0
dw 0xAA55

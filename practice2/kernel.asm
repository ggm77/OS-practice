;2025.11.27 - https://itguava.tistory.com/15

%include "init.inc"

[org 0x10000]
[bits 32]

PM_Start:
    mov bx, SysDataSelector             ;SysDataSelector 초기화
    mov ds, bx                          ;SysDataSelector는 부트로더에서 이미 초기화 했지만
    mov es, bx                          ;커널 입장에서는 했는지 안했는지 확실히 하기 위해서 다시 초기화 함

    mov ax, VideoSelector               ;VideoSelector 초기화
    mov es, ax

    ;출력 시 한 줄에 들어갈 글자의 수 * 2(컬러 텍스트라 글자+색상 2바이트가 필요함) * 출력할 줄의 수 + 문자열 출력하기 전에 더 추가 될 문자의 수 
    mov edi, 80*2*10+2*10               ;printf:의 문자를 출력할 부분 선택 ;row 10, col 10를 뜻하는 코드
    call printf                         ;printf:부분 출력

    jmp $

printf:

    mov byte [es:edi], 'P'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'r'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'o'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 't'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'e'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'c'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 't'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'e'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'd'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], ' '
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'M'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'o'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'd'
    inc edi
    mov byte [es:edi], 0x47
    inc edi
    mov byte [es:edi], 'e'
    inc edi
    mov byte [es:edi], 0x47
    inc edi


    ret                                 ;32비트 커널 영역 종료
;2025.11.22 - https://itguava.tistory.com/9#google_vignette

[org 0]                     ;메모리의 몇 번지에서 실행해야 하는지 알려주는 선언문
[bits 16]                   ;이 프로그램이 16비트 단위로 데이터를 처리하는 프로그램이라고 알린다.
    jmp 0x07C0:start        ;세그먼트:오프셋 논리주소 형식으로, 0x07C0:0x5 주소로 이동한다.
                            ;이 때 동시에 CS레지스터에는 0x0000이, IP에는 0x7C00이 삽입된다.
                        
start:                      ;위에서 점프하면 이곳에서 명령을 수행한다.
    mov ax, cs
    mov ds, ax              ;AX를 통해 DS를 CS에 저장된 값으로 초기화 한다.
                            ;즉 DS는 0x0000으로 초기화된다.
    mov ax, 0xB800
    mov es, ax              ;AX를 통해 ES를 0xB800으로 초기화한다.
    mov di, 0               ;DI를 0으로 초기화 한다.
    mov ax, word [msgBack]  ;하단부에 정의된 문자를 워드 단위로 읽어들이고 임시로 AX에 저장한다.
    mov cx, 0x7FF           ;CX를 0x7FF로 초기화한다.

    ;********************************
    ;****아래에서 부터 반복문이 실행된다.****
    ;********************************

paint:
    mov word [es:di], ax    ;AX 값 [msgBack]을 워드 단위로 논리 주소인 [es:di]에 저장한다.
    add di, 2               ;0으로 초기화 되었던 DI레지스터의 주소 값을 2바이트씩 더한다.
    dec cx                  ;0x7FF로 초기화 되었던 CX값을 1씩 줄인다.
                            ;CX값이 0이 되면 ZF가 자동으로 0이 된다.
    jnz paint               ;ZF가 0이면 다음으로 넘어가고 1이면 Paint:의 처음으로 돌아가서 반복 실행한다.

    mov edi, 0              ;EDI를 0으로 초기화 한다.
    mov byte [es:edi], 'H'  ;문자 H를 바이트 단위로 0xB800:0000 주소에 넣는다.
    inc edi                 ;EDI의 값에 1을 더한다. 즉, 주소를 한 칸 뒤로 옮긴다.
    mov byte [es:edi], 0x05 ;옮겨진 주소 0xB800:0001에 0x05을 바이트 단위로 넣는다.
    inc edi                 ;또 다시 EDI 값에 1을 더한다. 이후에도 이를 반복한다.
    mov byte [es:edi], 'E'
    inc edi
    mov byte [es:edi], 0x16
    inc edi
    mov byte [es:edi], 'L'
    inc edi
    mov byte [es:edi], 0x27
    inc edi
    mov byte [es:edi], 'L'
    inc edi
    mov byte [es:edi], 0x30
    inc edi
    mov byte [es:edi], 'O'
    inc edi
    mov byte [es:edi], 0x41
    inc edi

    jmp $                   ;$는 현재 지정되어 있는 주소 값을 의미한다. 즉 이 곳으로 계속 점프한다.
                            ;while(1)과 같은 의미이다.

msgBack db '.', 0x17        ;문자 '.'이 저장되어 있으며, 이는 위에서 이미 활용된 바 있다.

times 510-($-$$) db 0       ;$(현재 주소)에서 $$(처음 시작주소)를 뺀 주소를 510으로 뺀 곳까지 0으로 채운다.

dw 0xAA55                   ;나머지 511번지에는 0x55, 512번지에는 0xAA로 채운다.

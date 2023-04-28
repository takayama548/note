;
; dump Z80 registers (z88bk)
;
;   by takayama
;
SECTION code_user
PUBLIC _main

; BIOS call
CHPUT:      EQU 0x00A2          ; BIOS: CHPUT
CHGET:      EQU 0x009F
;
CHGMOD:     EQU $005F           ; BIOS: change screen mode
WRTVRM:     EQU $004D           ; BIOS: WRTVRM
LINL32:     EQU $F3AF           ; WIDTH

_main:      LD A,1              ; 
            CALL CHGMOD         ; SCREEN 1
            LD A,32             ; 
            LD (LINL32),A       ; WIDTH 32
            ;
            CALL FOOBAR
PRTSTR_END:
    JR PRTSTR_END               ; infinite loop

FOOBAR:     LD A, 0xFF
            ADD A, 1
            LD BC, 0x2233
            LD DE, 0x4455
            LD HL, 0x6677
            LD IX, 0x8899
            LD IY, 0xAABB
            CALL DUMP_REGS
            LD B, 0
            RET

; dump Z80 registers
DUMP_REGS:  LD (REG_BC), BC
            LD (REG_DE), DE
            LD (REG_HL), HL
            LD (REG_IX), IX
            LD (REG_IY), IY
            LD (PTR), SP
            LD HL, (PTR)
            INC HL
            INC HL
            LD (REG_SP), HL
            PUSH AF
            LD (PTR), SP
            LD IX, (PTR)
            LD A, (IX)
            LD (REG_F), A
            LD A, (IX+1)
            LD (REG_A), A
            POP AF
            ;
            LD HL, S_HEAD1
            CALL PRN_STR
            LD HL, S_HEAD2
            CALL PRN_STR
            ;
            LD HL, S_AEQ
            CALL PRN_STR
            LD A, (REG_A)
            CALL DUMP_REG
            LD HL, S_CMA
            CALL PRN_STR
            LD A, (REG_F)
            CALL DUMP_REG
            LD HL, S_SPC3
            CALL PRN_STR
            CALL DUMP_FLAGS
            LD HL, S_CRLF
            CALL PRN_STR
            ;
            LD HL, S_BCEQ
            CALL PRN_STR
            LD BC, (REG_BC)
            CALL DUMP_REGP
            LD HL, S_SPC
            CALL PRN_STR
            ;
            LD HL, S_DEEQ
            CALL PRN_STR
            LD BC, (REG_DE)
            CALL DUMP_REGP
            LD HL, S_CRLF
            CALL PRN_STR
            ;
            LD HL, S_HLEQ
            CALL PRN_STR
            LD BC, (REG_HL)
            CALL DUMP_REGP
            LD HL, S_SPC
            CALL PRN_STR
            ;
            LD HL, S_SPEQ
            CALL PRN_STR
            LD BC, (REG_SP)
            CALL DUMP_REGP
            LD HL, S_CRLF
            CALL PRN_STR
            ;
            LD HL, S_IXEQ
            CALL PRN_STR
            LD BC, (REG_IX)
            CALL DUMP_REGP
            LD HL, S_SPC
            CALL PRN_STR
            ;
            LD HL, S_IYEQ
            CALL PRN_STR
            LD BC, (REG_IY)
            CALL DUMP_REGP
            LD HL, S_CRLF
            CALL PRN_STR
            ; CALL CHGET
            LD SP, (REG_SP0)
            RET

DUMP_FLAGS: LD B, 8
            LD HL, REG_F
            LD C, (HL)
LOOP_FLAGS: RLC C
            LD A, '1'
            JR C, PRN_FLAG
            LD A, '0'
PRN_FLAG:   CALL CHPUT
            LD A, B
            CP 5
            JR NZ, NEXT_FLAG
            LD A, ' '
            CALL CHPUT
NEXT_FLAG:  DJNZ LOOP_FLAGS
            RET

DUMP_REG:   PUSH AF
            LD H, 0
            LD L, A
            CALL CPY_HEX
            LD HL, BUFFER
            CALL PRN_STR
            POP AF
            RET

DUMP_REGP:  PUSH BC
            LD H, 0
            LD L, B
            CALL CPY_HEX
            LD HL, BUFFER
            CALL PRN_STR
            LD HL, S_CMA
            CALL PRN_STR
            POP BC
            LD H, 0
            LD L, C
            CALL CPY_HEX
            LD HL, BUFFER
            CALL PRN_STR
            RET
            
PRN_STR:    ld a, (hl)
            cp 0
            ret z
            call CHPUT
            inc hl
            jr PRN_STR

CPY_HEX:    LD DE, BUFFER
            LD BC, 0x10
            CALL DIVS
            LD A, L
            CALL HEX2ASC
            LD (DE), A
            RET

DIVS:       XOR A
DIV1:       SBC HL, BC
            JR C, DIV2
            INC A
            JR DIV1
DIV2:       ADD HL, BC
            CALL HEX2ASC
            LD (DE), A
            INC DE
            RET

HEX2ASC:    SUB 0x0A
            JR NC, ASC2
            ADD A, 0x3A
            RET
ASC2:       ADD A, 0x41
            RET

; constant data
SECTION rodata_user
S_HEAD1:    DB "                  P", 0x0D,0x0A,0
S_HEAD2:    DB "            SZ/H /VNC", 0x0D,0x0A,0
S_AEQ:      DB "A,F:", 0
S_BCEQ:     DB "B,C:", 0
S_DEEQ:     DB "D,E:", 0
S_HLEQ:     DB "H,L:", 0
S_IXEQ:     DB " IX:", 0
S_IYEQ:     DB " IY:", 0
S_SPEQ:     DB " SP:", 0
S_SPC:      DB " ", 0
S_SPC3:     DB "   ", 0
S_CMA:      DB ",", 0
S_CRLF:     DB 0x0D,0x0A,0

; user data (RAM)
SECTION data_user
BUFFER:     DB 0,0,0,0
BUFSIZ:     EQU 4
PTR:        DB 0,0
REG_A:      DB 0
REG_F:      DB 0
REG_BC:     DB 0,0
REG_DE:     DB 0,0
REG_HL:     DB 0,0
REG_SP:     DB 0,0
REG_IX:     DB 0,0
REG_IY:     DB 0,0
REG_SP0:    DB 0,0

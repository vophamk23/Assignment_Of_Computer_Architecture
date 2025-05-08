# Chuong trinh: Doc 2 so float32 tu file FLOAT2_3.BIN, in ra man hinh va cong thu cong khong dung lenh float
# Tac gia: Pham Cong Vo - 2313946
# MIPS Assembly (chay trong MARS/SPIM)

.data
# Phan khai bao du lieu
float1:       .space 4       # Danh ra 4 byte cho so thuc thu nhat
float2:       .space 4       # Danh ra 4 byte cho so thuc thu hai
float_sum:    .word 0        # Bien luu ket qua cong (dang bit pattern)

# Khai bao ten file du lieu
tenfile:      .asciiz "FLOAT25.BIN"  # Ten file chua 2 so float

# Khai bao cac chuoi thong bao
msg_f1:       .asciiz "FLOAT 1 = "         # Thong bao so float thu nhat
msg_f2:       .asciiz "FLOAT 2 = "         # Thong bao so float thu hai
msg_result:   .asciiz "TONG 2 SO: "        # Thong bao ket qua
msg_plus:     .asciiz " + "                # Dau cong
msg_equal:    .asciiz " = "                # Dau bang
newline:      .asciiz "\n"                 # Xuong dong
err_msg:      .asciiz "Loi: Khong the mo file \n"  # Thong bao loi

.text
.globl main

main:
    ############### Mo FILE ################
    li   $v0, 13          # Syscall 13: Mo file
    la   $a0, tenfile     # Tham so 1: Dia chi chuoi ten file
    li   $a1, 0           # Tham so 2: Che do = doc (0)
    li   $a2, 0           # Tham so 3: Khong can che do bo sung
    syscall               # Thuc hien syscall

    bltz $v0, file_fail   # Neu tra ve < 0 thi co loi, nhay toi file_fail
    move $s0, $v0         # Luu file descriptor vao $s0 de su dung sau

    ############### DOC FLOAT 1 ################
    move $a0, $s0         # Tham so 1: File descriptor
    la   $a1, float1      # Tham so 2: Dia chi bien luu data
    li   $a2, 4           # Tham so 3: Doc 4 byte (kich thuoc float32)
    li   $v0, 14          # Syscall 14: Doc file
    syscall               # Thuc hien syscall

    ############### DOC FLOAT 2 ################
    move $a0, $s0         # Tham so 1: File descriptor
    la   $a1, float2      # Tham so 2: Dia chi bien luu data
    li   $a2, 4           # Tham so 3: Doc 4 byte (kich thuoc float32)
    li   $v0, 14          # Syscall 14: Doc file
    syscall               # Thuc hien syscall

    ############### DONG FILE ################
    move $a0, $s0         # Tham so 1: File descriptor
    li   $v0, 16          # Syscall 16: Dong file
    syscall               # Thuc hien syscall

    ############### IN FLOAT 1 ################
    li   $v0, 4           # Syscall 4: In chuoi
    la   $a0, msg_f1      # Tham so: Dia chi chuoi thong bao
    syscall               # Thuc hien syscall

    lw   $t1, float1      # Lay bit pattern cua float1 vao $t1
    mtc1 $t1, $f12        # Chuyen gia tri trong $t1 vao $f12 (thanh ghi float)
    li   $v0, 2           # Syscall 2: In so thuc
    syscall               # Thuc hien syscall

    li   $v0, 4           # Syscall 4: In chuoi
    la   $a0, newline     # Tham so: Dia chi chuoi xuong dong
    syscall               # Thuc hien syscall

    ############### IN FLOAT 2 ################
    li   $v0, 4           # Syscall 4: In chuoi
    la   $a0, msg_f2      # Tham so: Dia chi chuoi thong bao
    syscall               # Thuc hien syscall

    lw   $t2, float2      # Lay bit pattern cua float2 vao $t2
    mtc1 $t2, $f12        # Chuyen gia tri trong $t2 vao $f12 (thanh ghi float)
    li   $v0, 2           # Syscall 2: In so thuc
    syscall               # Thuc hien syscall

    li   $v0, 4           # Syscall 4: In chuoi
    la   $a0, newline     # Tham so: Dia chi chuoi xuong dong
    syscall               # Thuc hien syscall

    ############### CONG FLOAT BANG BIT ################
    lw   $a0, float1      # Tham so 1: Bit pattern float1
    lw   $a1, float2      # Tham so 2: Bit pattern float2
    jal  add_ieee754      # Goi ham cong so thuc
    sw   $v0, float_sum   # Luu ket qua vao bien float_sum

    ############### IN KET QUA: TONG ################
    li   $v0, 4           # Syscall 4: In chuoi
    la   $a0, msg_result  # Tham so: Dia chi chuoi thong bao
    syscall               # Thuc hien syscall

    lw   $t1, float1      # Lay bit pattern cua float1
    mtc1 $t1, $f12        # Chuyen vao thanh ghi float de in
    li   $v0, 2           # Syscall 2: In so thuc
    syscall               # Thuc hien syscall

    li   $v0, 4           # Syscall 4: In chuoi
    la   $a0, msg_plus    # Tham so: Dia chi chuoi dau cong
    syscall               # Thuc hien syscall

    lw   $t2, float2      # Lay bit pattern cua float2
    mtc1 $t2, $f12        # Chuyen vao thanh ghi float de in
    li   $v0, 2           # Syscall 2: In so thuc
    syscall               # Thuc hien syscall

    li   $v0, 4           # Syscall 4: In chuoi
    la   $a0, msg_equal   # Tham so: Dia chi chuoi dau bang
    syscall               # Thuc hien syscall

    lw   $t3, float_sum   # Lay bit pattern cua ket qua
    mtc1 $t3, $f12        # Chuyen vao thanh ghi float de in
    li   $v0, 2           # Syscall 2: In so thuc
    syscall               # Thuc hien syscall

    li   $v0, 4           # Syscall 4: In chuoi
    la   $a0, newline     # Tham so: Dia chi chuoi xuong dong
    syscall               # Thuc hien syscall

    ############### THOAT ################
    li   $v0, 10          # Syscall 10: Thoat chuong trinh
    syscall               # Thuc hien syscall

############### Xu LY LOI KHONG MO FILE ################
file_fail:
    li   $v0, 4           # Syscall 4: In chuoi
    la   $a0, err_msg     # Tham so: Dia chi chuoi thong bao loi
    syscall               # Thuc hien syscall
    li   $v0, 10          # Syscall 10: Thoat chuong trinh
    syscall               # Thuc hien syscall
    
###############################
# Ham: add_ieee754
# Mo ta: Cong 2 so float theo chuan IEEE-754 bang thao tac bit
# Dau vao: $a0, $a1 chua bit pattern cua 2 so float
# Ket qua: $v0 la bit pattern float cua tong
# Khong su dung lenh float
###############################
add_ieee754:
    # Lay cac thanh phan cua so float thu nhat
    andi $t0, $a0, 0x80000000     # Lay bit dau (sign1)
    srl  $t1, $a0, 23             # Dich phai 23 bit
    andi $t1, $t1, 0xFF           # Lay 8 bit so mu (exp1)
    andi $t2, $a0, 0x7FFFFF       # Lay 23 bit phan dinh (frac1)
    beq  $t1, $zero, skip_imp1    # Neu exp=0 (denormalized) thi bo qua
    ori  $t2, $t2, 0x800000       # Them bit ngam 1 neu la so binh thuong
skip_imp1:

    # Lay cac thanh phan cua so float thu hai
    andi $t3, $a1, 0x80000000     # Lay bit dau (sign2)
    srl  $t4, $a1, 23             # Dich phai 23 bit
    andi $t4, $t4, 0xFF           # Lay 8 bit so mu (exp2)
    andi $t5, $a1, 0x7FFFFF       # Lay 23 bit phan dinh (frac2)
    beq  $t4, $zero, skip_imp2    # Neu exp=0 (denormalized) thi bo qua
    ori  $t5, $t5, 0x800000       # Them bit ngam 1 neu la so binh thuong
skip_imp2:

    # Can chinh hai so co cung so mu
    sub  $t6, $t1, $t4            # Tinh chenh lech so mu
    bgez $t6, align1              # Neu exp1 >= exp2 thi khong can doi
    # Hoan doi neu exp2 > exp1 de dam bao exp1 >= exp2
    negu $t6, $t6                 # Lay gia tri tuyet doi chenh lech
    move $t7, $t1                 # Hoan doi exp1 va exp2
    move $t1, $t4
    move $t4, $t7
    move $t7, $t2                 # Hoan doi frac1 va frac2
    move $t2, $t5
    move $t5, $t7
    move $t7, $t0                 # Hoan doi sign1 va sign2
    move $t0, $t3
    move $t3, $t7
align1:
    srlv $t5, $t5, $t6            # Dich phai mantissa cua so co so mu nho hon

    # Kiem tra cong hay tru theo dau
    xor  $t7, $t0, $t3            # XOR hai bit dau: khac=1, giong=0
    beqz $t7, do_add              # Neu cung dau thi cong

    # Tru mantissa neu khac dau
    sub  $t8, $t2, $t5            # frac1 - frac2
    bltz $t8, rev_sign            # Neu ket qua am thi doi dau
    move $t2, $t8                 # Gan mantissa = ket qua phep tru
    j normalize                   # Nhay toi buoc chuan hoa
rev_sign:
    negu $t2, $t8                 # Lay gia tri tuyet doi
    move $t0, $t3                 # Doi dau ket qua
    j normalize                   # Nhay toi buoc chuan hoa

do_add:
    add  $t2, $t2, $t5            # Cong hai mantissa
    li   $t8, 0x1000000           # 2^24
    blt  $t2, $t8, normalize      # Neu chua tran thi chuan hoa
    srl  $t2, $t2, 1              # Dich phai 1 bit neu tran
    addi $t1, $t1, 1              # Tang so mu len 1

normalize:
    beqz $t2, result_zero         # Neu mantissa = 0 thi ket qua = 0
norm_loop:
    li   $t9, 0x800000            # Bit ngam 1 (bit thu 24)
    and  $t8, $t2, $t9            # Kiem tra bit ngam
    bnez $t8, assemble            # Neu bit ngam = 1 thi da chuan hoa xong
    sll  $t2, $t2, 1              # Dich trai mantissa
    addi $t1, $t1, -1             # Giam so mu
    j norm_loop                   # Lap lai qua trinh

result_zero:
    li $v0, 0                     # Ket qua = 0
    jr $ra                        # Tro ve

assemble:
    andi $t2, $t2, 0x7FFFFF       # Loai bo bit ngam
    sll  $t1, $t1, 23             # Dich so mu vao vi tri
    or   $v0, $t0, $t1            # Ghep dau va so mu
    or   $v0, $v0, $t2            # Ghep them phan dinh
    jr $ra                        # Tro ve voi ket qua trong $v0

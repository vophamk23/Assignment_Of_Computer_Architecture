# Chuong trinh: Tao file FLOAT2_3.BIN chua 2 so thuc
#----------------------------------- 


# Data segment 
.data 
# Cac so float can ghi (IEEE 754 float32)
f1: .float -123.337433
f2: .float 783,7340

filename: .asciiz "FLOAT2_TEST2.BIN"
fdescr:  .word 0  

# Thong bao
msg_ok:   .asciiz "Da tao file Fthanh cong.\n"
msg_err:  .asciiz "Loi: Khong mo duoc file.\n"

#----------------------------------- 
.text
#----------------------------------- 
main: 
    # Mo file de ghi (write-only)
    la   $a0, filename
    li   $a1, 1         # 1 = write only
    li   $v0, 13        # syscall: open
    syscall

    bltz $v0, file_fail # neu loi mo file
    sw   $v0, fdescr    # luu file descriptor

    # Ghi so float1 -> file
    lw   $a0, fdescr
    la   $a1, f1
    li   $a2, 4         # 4 byte
    li   $v0, 15        # syscall: write
    syscall

    # Ghi so float2 -> file
    lw   $a0, fdescr
    la   $a1, f2
    li   $a2, 4
    li   $v0, 15
    syscall

    # Dong file
    lw   $a0, fdescr
    li   $v0, 16        # syscall: close
    syscall

    # In thong bao thanh cong
    li   $v0, 4
    la   $a0, msg_ok
    syscall

    # Ket thuc
    li $v0, 10
    syscall

file_fail:
    li $v0, 4
    la $a0, msg_err
    syscall
    li $v0, 10
    syscall

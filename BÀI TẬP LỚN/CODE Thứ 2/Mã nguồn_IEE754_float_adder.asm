# Chuong trinh: Doc 2 so float32 tu file FLOAT2_3.BIN, in ra man hinh va cong thu cong khong dung lenh float
# Tac gia: Pham Cong Vo - 2313946
# MIPS Assembly (chay trong MARS/SPIM)


.data
	# Khai bao cac bien trong phan data
	filename: .asciiz "FLOAT2.BIN"  		# Duong dan ngan gon - dat file trong cung thu muc chuong trinh
	buffer:   .space 8                		# Bo nho dem de luu 2 so float (2 x 4 byte)
	newline:  .asciiz "\n"            		# Ky tu xuong dong
	result_str: .asciiz "Ket qua phep Cong hai so thuc la: "   	# Chuoi hien thi ket qua
	error_file: .asciiz "Loi mo file!\n"     			# Thong bao loi mo file
	error_read: .asciiz "Loi doc file!\n"    			# Thong bao loi doc file
	debug_msg1: .asciiz "Doc file thanh cong.\n"
	debug_msg2: .asciiz "Gia tri so thuc thu nhat : "
	debug_msg3: .asciiz "Gia tri so thuc thu hai: "

.text
.globl main

	# Ham chinh cua chuong trinh
  main:
    	# Mo file
    	li 	$v0, 13                    	# syscall: open file
    	la 	$a0, filename              	# Ten file
    	li 	$a1, 0                     	# Che do doc (Read-only mode)
    	li 	$a2, 0                     	# Khong can permission
    	syscall                       		# Goi ham he thong
    	move 	$s0, $v0                 	# Luu file descriptor vao $s0
    
    	# Kiem tra loi mo file
    	bltz 	$s0, file_error          	# Neu $v0 < 0, nhay den file_error
    
    	# Doc du lieu tu file
    	li 	$v0, 14                    	# syscall: doc file
    	move 	$a0, $s0                 	# File descriptor
    	la 	$a1, buffer                	# Dia chi cua buffer
    	li 	$a2, 8                     	# Doc 8 byte (2 so float x 4 byte)
    	syscall                       		# Goi ham he thong
    
    	# Kiem tra doc file thanh cong
    	bne 	$v0, 8, read_error        	# Neu khong doc duoc 8 byte, nhay den read_error
    
    	# Dong file (da doc xong)
    	li 	$v0, 16                    	# syscall: dong file
    	move 	$a0, $s0                 	# File descriptor
    	syscall                       		# Goi ham he thong
    
    	# Debug: In thong bao da doc file thanh cong
    	li 	$v0, 4                     	# syscall: in chuoi
    	la 	$a0, debug_msg1            # Dia chi chuoi debug
   	syscall                       		# Goi ham he thong

    	# In so float thu nhat
    	li 	$v0, 4                     	# syscall: in chuoi
    	la 	$a0, debug_msg2            # Dia chi chuoi debug
    	syscall                       		# Goi ham he thong
    
    	la 	$t0, buffer                	# Dia chi so thuc dau tien
    	lwc1 	$f12, 0($t0)             	# Load so thuc vao thanh ghi $f12 (dung de in)
    	li 	$v0, 2                     	# syscall: in so float
    	syscall                       		# Goi ham he thong

    	# In xuong dong
    	li 	$v0, 4                     	# syscall: in chuoi
    	la 	$a0, newline               	# Dia chi chuoi xuong dong
    	syscall                       		# Goi ham he thong
    
    	# In so float thu hai
    	li 	$v0, 4                     	# syscall: in chuoi
    	la 	$a0, debug_msg3            # Dia chi chuoi debug
    	syscall                       		# Goi ham he thong
    
    	la 	$t0, buffer                	# Dia chi so thuc dau tien
    	lwc1 	$f12, 4($t0)             	# Load so thuc thu hai vao thanh ghi $f12
    	li 	$v0, 2                     	# syscall: in so float
    	syscall                       		# Goi ham he thong

    	# In xuong dong
    	li 	$v0, 4                     	# syscall: in chuoi
    	la 	$a0, newline               	# Dia chi chuoi xuong dong
    	syscall                       		# Goi ham he thong
    
    	# In chuoi ket qua
    	li 	$v0, 4                     	# syscall: in chuoi
    	la 	$a0, result_str            	# Dia chi chuoi ket qua
    	syscall                       		# Goi ham he thong

    	# Chuan bi tham so cho ham cong
    	la 	$a0, buffer                	# Dia chi so thuc dau tien
    	la 	$a1, buffer+4              	# Dia chi so thuc thu hai
 
    	# Goi ham cong
    	jal 	add_float                 	# Nhay den ham add_float
    
    	# Ket thuc chuong trinh
    	j 	exit_program                	# Nhay den exit_program
	
# Ham phan tach so thuc IEEE 754 thanh cac thanh phan
# Dau vao: $a0 - dia chi cua so thuc
# Dau ra: 
#   $t0 - bit dau (sign bit)
#   $t1 - phan mu (exponent)
#   $t2 - phan dinh tri (mantissa)
extract_float_components:
    	lw 	$t3, 0($a0)        		# Nap gia tri 32-bit cua so thuc tu dia chi $a0
    
    	# Tach bit dau (bit 31)
    	srl 	$t0, $t3, 31      		# Dich phai 31 bit de lay bit dau
    
    	# Tach phan mu (bit 23-30)
    	srl 	$t1, $t3, 23      		# Dich phai 23 bit
    	andi 	$t1, $t1, 0xFF   		# Giu lai 8 bit mu (AND voi 0xFF = 0b11111111)
    
    	# Tach phan dinh tri (bit 0-22)
    	andi 	$t2, $t3, 0x7FFFFF  	# Giu lai 23 bit dinh tri (AND voi 0x7FFFFF)
    
    	jr 	$ra                		# Tra ve dia chi goi ham

# Ham cong 2 so thuc IEEE 754 
# Dau vao: 
#   $a0 - dia chi cua so thuc thu nhat
#   $a1 - dia chi cua so thuc thu hai
# Dau ra: so thuc ket qua duoc in ra
add_float:
    	# Luu cac thanh ghi tren stack de bao toan gia tri
    	addi 	$sp, $sp, -20    		# Giam con tro stack 20 byte (5 thanh ghi x 4 byte)
    	sw 	$ra, 0($sp)        		# Luu dia chi tra ve
    	sw 	$a0, 4($sp)        		# Luu dia chi so thu nhat
    	sw 	$a1, 8($sp)        		# Luu dia chi so thu hai
    	sw 	$s0, 12($sp)       		# Luu thanh ghi $s0
    	sw 	$s1, 16($sp)       		# Luu thanh ghi $s1
    
    	# Kiem tra xem $a0 va $a1 co hop le khong
    	beqz 	$a0, restore_and_return
    	beqz 	$a1, restore_and_return
    
    	# Kiem tra truong hop dac biet: so 0
    	lw 	$t8, 0($a0)
    	andi 	$t8, $t8, 0x7FFFFFFF  	# Bo qua bit dau
    	beqz 	$t8, second_operand   	# Neu so 1 = 0, ket qua la so 2
    
    	lw 	$t8, 0($a1)
    	andi 	$t8, $t8, 0x7FFFFFFF  	# Bo qua bit dau
    	beqz 	$t8, first_operand    	# Neu so 2 = 0, ket qua la so 1
    
    	# Trich xuat cac thanh phan so thuc thu nhat
    	move 	$t9, $a0            		# Luu tam dia chi $a0
    	jal 	extract_float_components
    	move 	$s0, $t0     		# Luu bit dau so 1
    	move 	$s1, $t1     		# Luu mu so 1
    	move 	$a3, $t1     		# Luu mu so 1 de so sanh ve sau
    	move 	$a2, $t2     		# Luu dinh tri so 1
    
    	# Kiem tra xem so thu nhat co phai denormalized (mu = 0)
   	bnez 	$s1, normal_first
    	# So thu nhat la denormalized, KHONG them bit an 1
    	j 	check_second
    
normal_first:
    	# So binh thuong, them bit an 1
    	ori 	$a2, $a2, 0x800000  	# Them bit an 1 vao dinh tri so 1
    
check_second:
    	# Khoi phuc dia chi so thuc thu hai
    	lw 	$a0, 8($sp)
    
    	# Trich xuat cac thanh phan so thuc thu hai
    	jal 	extract_float_components
    	move 	$t3, $t0     		# Bit dau so 2
    	move 	$t4, $t1     		# Mu so 2
    	move 	$t5, $t2     		# Dinh tri so 2
    
    	# Kiem tra xem so thu hai co phai denormalized (mu = 0)
    	bnez 	$t4, normal_second
    	# So thu hai la denormalized, KHONG them bit an 1
    	j 	continue_add
    
normal_second:
    	# So binh thuong, them bit an 1
    	ori 	$t5, $t5, 0x800000  	# Them bit an 1 vao dinh tri so 2
    
continue_add:
    	# Dieu chinh mu va dinh tri de cong
    	beq 	$a3, $t4, same_exponent
    
    	# Neu mu khac nhau, dich dinh tri cua so co mu nho hon
    	bgt 	$a3, $t4, adjust_second
    
    	# Dieu chinh so thu nhat
    	sub 	$t6, $t4, $a3   		 # So bit dich
    	beq 	$t6, $zero, same_exponent # Tranh dich 0 bit
    	li 	$t7, 24
    	bge 	$t6, $t7, zero_first  	# Neu dich qua 24 bit, dinh tri = 0
    	srlv 	$a2, $a2, $t6  		# Dich dinh tri so 1
    	move 	$a3, $t4       		# Mu moi = mu lon hon (mu 2)
    	j 	same_exponent
    
zero_first:
    	li $a2, 0           			# Dinh tri so 1 = 0
    	j same_exponent
    
adjust_second:
    	sub 	$t6, $a3, $t4   		 # So bit dich
    	beq 	$t6, $zero, same_exponent # Tranh dich 0 bit
    	li 	$t7, 24
    	bge 	$t6, $t7, zero_second  	 # Neu dich qua 24 bit, dinh tri = 0
    	srlv 	$t5, $t5, $t6  		 # Dich dinh tri so 2
    	j 	same_exponent
    
zero_second:
    	li 	$t5, 0           		# Dinh tri so 2 = 0
    
same_exponent:
    	# Xac dinh dau va thuc hien cong/tru dinh tri
    	beq 	$s0, $t3, same_sign
    
    	# Khac dau: thuc hien tru
    	bgt 	$a2, $t5, first_larger
    	beq 	$a2, $t5, zero_result  	# Neu bang nhau, ket qua = 0
    	sub 	$t5, $t5, $a2
    	move 	$t0, $t3       		# Lay dau cua so lon hon
    	j 	normalize
    
zero_result:
    	li 	$t0, 0           		# Bit dau = 0
    	li 	$a3, 0           		# Mu = 0
    	li 	$t5, 0           		# Dinh tri = 0
    	j 	build_float
    
first_larger:
    	sub 	$a2, $a2, $t5
    	move 	$t0, $s0       		# Lay dau cua so lon hon
    	move 	$t5, $a2
    	j 	normalize
    
same_sign:
    	# Cung dau: thuc hien cong
    	add $t5, $a2, $t5
    	move $t0, $s0       		# Giu nguyen bit dau
    
normalize:
    	# Neu ket qua dinh tri la 0, thi tra ve 0
    	bnez 	$t5, not_zero
    	li 	$t0, 0       		# Bit dau = 0
    	li 	$a3, 0       		# Mu = 0
    	j 	build_float

not_zero:
    	# Kiem tra va xu ly overflow
    	li 	$t6, 0x1000000   	# Kiem tra bit vuot qua 24 bit
    	and 	$t7, $t5, $t6
    	bnez 	$t7, handle_overflow

    	# Chuan hoa dinh tri (shift trai neu can)
    	li 	$t6, 0x800000   		# Kiem tra bit an (leading 1)
   	li 	$t9, 0          		# Dem so bit dich
    	li 	$t8, -126       		# Mu nho nhat chuan hoa
normalize_loop:
   	and 	$t7, $t5, $t6  		# Lay bit an
    	bnez	$t7, no_shift 		# Neu da co bit an, thoat vong lap
    	addi 	$t9, $t9, 1   		# Tang dem
    	sll 	$t5, $t5, 1    		# Dich trai dinh tri
    	sub 	$a3, $a3, 1    		# Giam mu di 1
    
    	# Kiem tra neu mu qua nho, chuyen sang denormalized
    	ble 	$a3, $t8, denormalize
    
    	# Gioi han so lan lap de tranh lap vo han
    	li 	$t7, 24
    	bge 	$t9, $t7, denormalize
    
    	j 	normalize_loop

denormalize:
    	# Chuyen sang so denormalized
    	li 	$a3, 0          	# Mu = 0
    	j 	no_shift

handle_overflow:
    	# Neu overflow, dich phai va tang mu
    	srl 	$t5, $t5, 1
    	addi 	$a3, $a3, 1
    
    	# Kiem tra neu mu qua lon (>= 255) -> tra ve so lon nhat
    	li 	$t7, 255
    	blt 	$a3, $t7, no_shift
    
    	# Tra ve so lon nhat
    	li 	$a3, 254        	# Mu gan max
    	li 	$t5, 0x7FFFFF   	# Dinh tri max
	j 	build_float

no_shift:
    	# Loai bo bit an (chi giu 23 bit dinh tri)
    	li 	$t6, 0x7FFFFF   	# Mau bit = 0x7FFFFF
    	and 	$t5, $t5, $t6  	# Chi giu lai 23 bit thap

build_float:
    	# Xay dung lai so thuc IEEE 754
    	sll 	$t0, $t0, 31    		# Dich bit dau len vi tri 31
    	sll 	$a3, $a3, 23    	# Dich phan mu len vi tri 23-30
    	or 	$t5, $t5, $t0    	# Them bit dau vao ket qua
    	or 	$t5, $t5, $a3    	# Them phan mu vao ket qua

    	# In ket qua
    	mtc1 	$t5, $f12      	# Chuyen gia tri tu thanh ghi nguyen sang thanh ghi float
    	li 	$v0, 2           	# Syscall in float
    	syscall             		# Goi ham he thong

    	# In xuong dong
    	li 	$v0, 4           	# Syscall in chuoi
    	la 	$a0, newline     	# Dia chi chuoi xuong dong
    	syscall             		# Goi ham he thong

    	# Khoi phuc cac thanh ghi tu stack
    	lw 	$ra, 0($sp)      	# Lay lai dia chi tra ve
    	lw 	$a0, 4($sp)      	# Lay lai dia chi so thu nhat
    	lw 	$a1, 8($sp)      	# Lay lai dia chi so thu hai
    	lw 	$s0, 12($sp)     	# Lay lai thanh ghi $s0
    	lw 	$s1, 16($sp)     	# Lay lai thanh ghi $s1
    	addi 	$sp, $sp, 20   	# Tang con tro stack 20 byte
    	jr 	$ra              	# Tra ve dia chi goi ham

	# Truong hop so 1 la 0, tra ve so 2
first_operand:
    	lw 	$t0, 0($a0)       	# Lay gia tri so 1
    	mtc1 	$t0, $f12       	# Chuyen sang thanh ghi float
    	li 	$v0, 2            	# Syscall in float
    	syscall
    	j 	restore_and_return

	# Truong hop so 2 la 0, tra ve so 1
second_operand:
    	lw 	$t0, 0($a1)       	# Lay gia tri so 2
    	mtc1 	$t0, $f12       	# Chuyen sang thanh ghi float
    	li 	$v0, 2            	# Syscall in float
    	syscall
    	j 	restore_and_return

# Khoi phuc thanh ghi va tra ve
restore_and_return:
    	# Khoi phuc cac thanh ghi tu stack
    	lw 	$ra, 0($sp)
    	lw 	$a0, 4($sp)
    	lw 	$a1, 8($sp)
    	lw 	$s0, 12($sp)
   	lw 	$s1, 16($sp)
    	addi 	$sp, $sp, 20
    	jr 	$ra

# Xu ly loi mo file
file_error:
    	li 	$v0, 4                   	# syscall: in chuoi
    	la 	$a0, error_file          	# Dia chi chuoi thong bao loi
    	syscall                     		# Goi ham he thong
    	j 	exit_program              	# Ket thuc chuong trinh

# Xu ly loi doc file
read_error:
    	li 	$v0, 4                   	# syscall: in chuoi
    	la 	$a0, error_read          	# Dia chi chuoi thong bao loi
    	syscall                     		# Goi ham he thong
    	j 	exit_program              	# Ket thuc chuong trinh

# Ket thuc chuong trinh
exit_program:
    	li 	$v0, 10                  	# syscall: exit
    	syscall                     		# Goi ham he thong

.data
    	filename: .asciiz "PI.txt"      	# Ten file output
    	msg1: .asciiz "So diem nam trong hinh tron: "
    	msg2: .asciiz "/50000\nSo PI tinh duoc: "
    	newline: .asciiz "\n"
    	success_msg: .asciiz "Tao file Pi.txt thanh cong\n"   # Thêm thông báo thành công
    	pi: .float 0.0                  	# Bien luu gia tri PI tinh duoc
    	zero: .float 0.0                	# So 0 dang float
    	ten: .float 10.0                	# So 10 dang float
    	one: .float 1.0                 	# So 1 dang float
    	four: .float 4.0                		# So 4 dang float
    	total: .word 50000             	# Tong so diem can tao
    	buffer1: .space 200             	# Bo nho dem cho chuoi so 1
    	buffer2: .space 200             	# Bo nho dem cho chuoi so 2
    	onehundred: .float 100.0        	# So 100 dang float
    	space: .asciiz" "               	# Khoang trang
    	buffer: .space 200              	# Bo nho dem cho chuoi so
    
.text
main:
    	# Dat seed cho random number generator dua tren time
    	li 	$v0, 30                      	# syscall 30: lay thoi gian hien tai theo milliseconds
    	syscall
    
    	move 	$a0, $v0                   	# Chuyen thoi gian lam hat giong (seed)
    	li 	$v0, 40                      	# syscall 40: dat hat giong cho bo sinh so ngau nhien
    	syscall
    
    	li 	$t0, 0                       	# Khoi tao bien dem cho so diem nam trong hinh tron
    	li 	$t1, 0                       	# Bien dem cho tong so diem da tao
    	lw 	$t2, total                   	# Lay tong so diem can tao (50000)
    
    loop:
     	# Tao toa do x ngau nhien trong khoang [0,1]
    	li 	$v0, 41                      	# syscall 41: tao so nguyen ngau nhien
    	syscall
    	abs 	$a0, $a0                    	# Lay gia tri tuyet doi de dam bao duong
    	mtc1 	$a0, $f1                   	# Chuyen sang dang so thuc
   	cvt.s.w 	$f1, $f1                	# Chuyen tu nguyen sang float
    	li 	$s5, 0x4f000000              	# Gia tri de chia de co so trong khoang [0,1]
    	mtc1 	$s5, $f2
    	div.s 	$f1, $f1, $f2             	# Chia de co gia tri x trong khoang [0,1]
    
 	# Tao toa do y ngau nhien trong khoang [0,1]
    	li 	$v0, 41                      	# syscall 41: tao so nguyen ngau nhien
    	syscall
    	abs 	$a0, $a0                    	# Lay gia tri tuyet doi de dam bao duong
    	mtc1 	$a0, $f2                   	# Chuyen sang dang so thuc
    	cvt.s.w 	$f2, $f2                	# Chuyen tu nguyen sang float
    	li 	$s5, 0x4f000000              # Gia tri de chia de co so trong khoang [0,1]
    	mtc1 	$s5, $f3
    	div.s 	$f2, $f2, $f3             	# Chia de co gia tri y trong khoang [0,1]
    
    	# Tinh x^2
    	mul.s $f3, $f1, $f1             	# $f3 = x^2
    	# Tinh y^2
    	mul.s $f4, $f2, $f2             	# $f4 = y^2
    	# Tinh x^2 + y^2
    	add.s $f5, $f3, $f4             	# $f5 = x^2 + y^2
    
    	# So sanh voi 1 (ban kinh hinh tron don vi)
    	l.s 	$f6, one                    	# $f6 = 1.0
    	c.lt.s 	$f5, $f6                 	# So sanh: neu x^2 + y^2 < 1 thi flag = true
    	bc1f skip_increment             	# Neu flag = false (x^2 + y^2 >= 1), bo qua tang bien dem
    
    	addi 	$t0, $t0, 1               	# Tang so diem nam trong hinh tron
    
skip_increment:
    	addi 	$t1, $t1, 1               	# Tang tong so diem da tao
    	bne 	$t1, $t2, loop             	# Lap lai neu chua du so diem can tao
    
    	# Tinh PI = 4 * (so diem trong hinh tron / tong so diem)
    	mtc1 	$t0, $f7                  	# Chuyen so diem trong hinh tron sang float
    	cvt.s.w 	$f7, $f7
    	mtc1 	$t2, $f8                  	# Chuyen tong so diem sang float
    	cvt.s.w 	$f8, $f8
    	div.s 	$f9, $f7, $f8            	# Chia de tinh ti le diem trong hinh tron/tong so diem
   	 l.s 	$f10, four			# $f10 = 4.0
     	mul.s 	$f12, $f9, $f10 		# $f12 = 4 * ti le = PI
    	
    	# Mo file de ghi
    	li 	$v0, 13                     	# syscall 13: mo file
    	la 	$a0, filename               	# Ten file
    	li 	$a1, 1                      	# Flags: 1 de ghi
    	li 	$a2, 0                      	# Mode: bo qua
    	syscall
    	move 	$s0, $v0                  	# Luu file descriptor vao $s0
    	
    	# Ghi thong bao msg1 vao file
    	li 	$v0, 15                     	# syscall 15: ghi vao file
    	move 	$a0, $s0                  	# File descriptor
    	la 	$a1, msg1                   	# "So diem nam trong hinh tron: "
   	 li 	$a2, 29                     	# Do dai chuoi
    	syscall

    	# Chuyen so diem trong hinh tron thanh chuoi
   	la 	$a0, buffer1                	# Dia chi cua buffer de luu chuoi so
    	jal 	int_to_string              		# Goi ham chuyen so nguyen thanh chuoi
    
    	# Ghi chuoi so nguyen vao file
    	li 	$v0, 15                     	# syscall 15: ghi vao file
    	move 	$a0, $s0                  	# File descriptor
    	la 	$a1, buffer1                	# Buffer chua chuoi so nguyen
    	li 	$a2, 5                      	# Do dai cua chuoi
    	syscall

    	# Ghi thong bao tiep theo vao file
    	li 	$v0, 15                     	# syscall 15: ghi vao file
   	move 	$a0, $s0                 	# File descriptor
    	la 	$a1, msg2                   	# "/50000 So PI tinh duoc: "
    	li 	$a2, 24                     	# Do dai chuoi
    	syscall

   	# Chuyen so PI thanh chuoi va ghi vao file
    	jal 	float_to_string            	# Goi ham chuyen so thuc sang chuoi
  
    	# Ghi ghi chuoi so nguyen vao file
    	li 	$v0, 15                     	# syscall 15: ghi vao file
    	move 	$a0, $s0                  	# File descriptor
    	la 	$a1, buffer                 	# Buffer chua chuoi so thuc
    	li 	$a2, 8                      	# Do dai cua chuoi
    	syscall
    
    	# Dong file
    	li $v0, 16                     		# syscall 16: close file
    	move $a0, $s0                  	# File descriptor
    	syscall
    	
	# In thong bao thanh cong ra man hinh
	li $v0, 4                      	# syscall 4: in chuoi
	la $a0, success_msg           	# Dia chi chuoi thong bao thanh cong
	syscall
	
    	# Ket thuc chuong trinh
    	li $v0, 10                     		# syscall 10: thoat chuong trinh
    	syscall

# Ham int_to_string
# Input: $t0 chua so nguyen can chuyen doi, $a0 chua dia chi cua buffer
# Output: Chuoi so nguyen duoc luu vao buffer (dinh dang tu trai qua phai)
int_to_string:
    	li 	$t1, 0              		# Dem so chu so (tam thoi)
    	li 	$t2, 10             		# De chia lay so du
    	li 	$t3, 0              		# Dat co cho so am (chua xu ly)
    
    	# Neu so la 0, ghi '0' vao buffer va tra ve
    	beq 	$t0, $zero, int_is_zero
    
    	# Tim vi tri cuoi cua buffer de bat dau luu tu cuoi den dau
    	add 	$a1, $a0, $zero    		# Luu dia chi bat dau cua buffer vao $a1
    	addi 	$a1, $a1, 31      		# Gia su buffer co kich thuoc 32 bytes
    	li 	$t6, 0              		# Bien dem so luong chu so

     	# Chuyen doi tung chu so (tu cuoi den dau)
int_to_string_loop:
    	div 	$t4, $t0, $t2      		# Chia so cho 10
    	mfhi 	$t5               		# Lay so du (chu so cuoi cung)
    	addi 	$t5, $t5, 48      		# Chuyen so sang ma ASCII (48 la '0')
    	sb 	$t5, 0($a1)         		# Luu chu so vao buffer
	addi 	$a1, $a1, -1      		# Dich vi tri luu buffer nguoc ve sau
    	addi 	$t6, $t6, 1       		# Tang dem so chu so
    	mflo 	$t0               		# Lay phan nguyen cua phep chia
    	bnez 	$t0, int_to_string_loop  	# Neu so chua bang 0, lap lai
    
    	# Di chuyen chuoi sang ben trai de loai bo khoang trong du thua
    	add 	$a0, $a0, $zero    		# Dat lai chi so $a0
    	addi 	$a1, $a1, 1       		# Dich den chu so dau tien
    	li 	$t7, 0              		# Bien dem vi tri buffer
    
copy_loop:
    	lb 	$t8, 0($a1)         		# Lay tung ky tu tu buffer
    	sb 	$t8, 0($a0)         		# Luu vao vi tri dau cua buffer
    	addi 	$a0, $a0, 1       		# Tang chi so luu buffer
    	addi 	$a1, $a1, 1 		#Tang vi tri doc
    	addi 	$t7, $t7, 1
    	blt 	$t7, $t6, copy_loop  	# Lap lai cho den khi het cac chu so
    
    	# Them ky tu ket thuc chuoi '\0'
    	li 	$t9, 0              		# Ky tu '\0'
	sb 	$t9, 0($a0)         		# Luu '\0' vao buffer
    
    	jr 	$ra                 		# Tro ve sau khi hoan thanh

int_is_zero:
    	li 	$t5, 48             		# '0'
    	sb 	$t5, 0($a0)         		# Luu '0' vao buffer
    	addi 	$a0, $a0, 1       		# Tang chi so luu buffer
    	li 	$t9, 0              		# Ky tu '\0'
    	sb 	$t9, 0($a0)         		# Luu '\0' vao buffer
    	jr 	$ra                 		# Tro ve



	# Ham chuyen doi so thuc sang chuoi
float_to_string:
    	# Luu $ra
    	move 	$t9, $ra          		# Luu dia chi tro ve
    
    	# Lay phan nguyen
    	cvt.w.s 	$f14, $f12     		# Chuyen so thuc sang so nguyen
    	mfc1 	$t1, $f14         		# Chuyen sang thanh ghi nguyen
    	mtc1 	$t1, $f14         		# Chuyen lai vao thanh ghi thuc
    	cvt.s.w 	$f14, $f14     		# Chuyen sang dang float

    	# Chuyen phan nguyen sang chuoi
    	la 	$t3, buffer         		# Con tro buffer
    
   	# Chuyen so nguyen thanh ky tu
    	addi 	$t1, $t1, 48      		# Chuyen sang ma ASCII
    	sb 	$t1, ($t3)          		# Luu vao buffer
    	addi 	$t3, $t3, 1       		# Tang con tro buffer
    
    	# Them dau cham
    	li 	$t4, 46             		# Ma ASCII cua '.'
    	sb 	$t4, ($t3)          		# Luu vao buffer
    	addi 	$t3, $t3, 1       		# Tang con tro buffer
    
    	# Khoi tao cac thanh ghi so thuc
    	l.s 	$f30, ten          		# Nap gia tri 10.0
    	sub.s 	$f15, $f12, $f14 		# Lay phan thap phan
    
    	# Phan thap phan
    	li 	$t2, 0              		# Bien dem so chu so thap phan
    
decimal_loop:
    	beq 	$t2, 6, end_decimal 	# 6 chu so thap phan
    
    	# Nhan 10 va lay chu so
    	mul.s 	$f15, $f15, $f30  		# Nhan voi 10
    	cvt.w.s 	$f16, $f15      		# Chuyen sang so nguyen
    	mfc1 	$t1, $f16          		# Chuyen sang thanh ghi nguyen
    
    	move 	$t4, $t1
    	addi 	$t4, $t4, 48       		# Chuyen sang ky tu
    	sb 	$t4, ($t3)           		# Luu vao buffer
    	addi 	$t3, $t3, 1        		# Tang con tro buffer
    
    	mtc1 	$t1, $f14
    	cvt.s.w 	$f14, $f14
    	sub.s 	$f15, $f15, $f14  		# Lay phan thap phan moi
    
    	addi 	$t2, $t2, 1        		# Tang bien dem
   	j 	decimal_loop

end_decimal:
    	# Them ky tu null ket thuc chuoi
    	li $t4, 0
    	sb $t4, ($t3)
    
    	# Quay lai
    	jr $t9                  		# Tro ve dia chi goc


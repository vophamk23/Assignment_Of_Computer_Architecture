# 📘 BÀI TẬP LỚN MIPS ASSEMBLY
**Học phần: Kiến trúc Máy tính**
**Ngôn ngữ: MIPS Assembly – MARS Simulator**
---

## 🧠 Giới thiệu chung
Dự án này gồm **1 bài tập lớn + 1 bài tập cá nhân**, được thực hiện bằng ngôn ngữ hợp ngữ **MIPS Assembly**, nhằm giúp sinh viên:
* Hiểu sâu hơn về cơ chế xử lý số thực và biểu diễn IEEE 754 trong vi xử lý.
* Vận dụng phương pháp thống kê Monte Carlo để ước lượng giá trị số Pi.
* Phân tích hoạt động bộ nhớ cache Direct-mapped và tính toán tài nguyên phần cứng cần thiết.

---

## 📌 **Đề 1 – Ước lượng số Pi bằng phương pháp Monte Carlo**

### 🎯 **Mục tiêu**

Viết chương trình sinh ngẫu nhiên 50.000 điểm trong hệ tọa độ Đề Cát (Descarte), với $0 < x < 1$ và $0 < y < 1$. Từ đó xác định số lượng điểm rơi vào hình tròn nội tiếp hình vuông đơn vị, để **ước lượng giá trị số Pi** theo công thức:

$$
\pi \approx 4 \times \frac{\text{Số điểm trong hình tròn}}{\text{Tổng số điểm}}
$$

### ⚙️ **Cách thực hiện**

* Sử dụng syscall `30` để lấy thời gian thực tại làm seed và syscall `40` để khởi tạo bộ phát số ngẫu nhiên.
* Sinh ra 50.000 cặp số thực (x, y) với giá trị ngẫu nhiên trong đoạn (0, 1).
* Kiểm tra mỗi điểm có nằm trong hình tròn nội tiếp bán kính 0.5 (tâm tại (0.5, 0.5)) không.
* Đếm tổng số điểm nằm trong hình tròn.
* Tính gần đúng số Pi và ghi kết quả vào file `PI.TXT` dưới định dạng:

```
So diem nam trong hinh tron: ddddd/50000
So PI tinh duoc: f.ffffff
```

### 🧪 **Kết quả mong đợi**

Giá trị Pi gần đúng xấp xỉ \~3.141592 với sai số nhỏ, thể hiện độ chính xác tăng theo số lượng điểm sinh ra.

---

# 🔧 Bài Tập Lớn: Cộng 2 Số Thực Chuẩn IEEE 754 (MIPS Assembly)

## 📘 Mô tả

Chương trình thực hiện phép cộng 2 số thực định dạng IEEE 754 độ chính xác đơn (single precision, 32-bit) **không sử dụng lệnh số thực của MIPS** (như `add.s`, `mul.s`, `cvt.s.w`,...). Toàn bộ tính toán thực hiện bằng thao tác bit với thanh ghi nguyên.
## 🛠 Công cụ sử dụng

* Trình biên dịch: **MARS 4.5**
* Ngôn ngữ: MIPS Assembly
* File nhị: `FLOAT2.BIN` chứa 2 số thực 32-bit (8 byte)

## 📁 Cấu trúc thư mục

```
BTL_FloatAdder/
├── main.asm                 # Chương trình MIPS
├── FLOAT2.BIN              # File nhị đầu vào (2 float)
├── create_input.py         # Script Python tạo file FLOAT2.BIN
├── tao_file.asm            # Code ASM tạo file FLOAT2.BIN (tuùy chọn)
├── README.md               # Tài liệu hướng dẫn
```

### 🧠 **Kiến thức liên quan**

Số thực IEEE 754 single precision (32 bit) gồm 3 phần:

* **1 bit dấu (sign)**: 0 hoặc 1
* **8 bit số mũ (exponent)**: có bias 127
* **23 bit trị tuyệt đối (mantissa)**: có thêm bit ẩn 1

$$
\text{Giá trị} = (-1)^s \times 1.M \times 2^{(E - 127)}
$$

### ⚙️ **Cách thực hiện**

* **Đọc file nhị phân** bằng syscall 13 (open), 14 (read), 16 (close).
* **Tách thành phần S, E, M** từ mỗi số bằng phép dịch bit.
* **Căn chỉnh số mũ** để đưa về cùng bậc.
* **Thực hiện phép cộng/trừ mantissa** tùy theo dấu của từng số.
* **Chuẩn hóa kết quả**, điều chỉnh lại số mũ nếu cần.
* **Ghép lại thành một số IEEE 754** và lưu vào thanh ghi để xuất kết quả.
---

## 📥 Tạo file FLOAT2.BIN (2 số thực)

### Cách 1: Dùng Python

```python
import struct

# Nhập 2 số thực
a = float(input("Nhap so thuc thu 1: "))
b = float(input("Nhap so thuc thu 2: "))

# Tạo file FLOAT2.BIN
with open("FLOAT2.BIN", "wb") as f:
    f.write(struct.pack('ff', a, b))

print("Da tao xong file FLOAT2.BIN")
```

### Cách 2: Dùng Assembly (trong MARS)

```assembly
.data
f1: .float 3.14
f2: .float 2.71
filename: .asciiz "FLOAT2.BIN"
msg: .asciiz "Da tao file thanh cong.\n"

.text
main:
    la   $a0, filename
    li   $a1, 1
    li   $v0, 13
    syscall
    sw   $v0, $s0

    # float 1
    move $a0, $s0
    la   $a1, f1
    li   $a2, 4
    li   $v0, 15
    syscall

    # float 2
    move $a0, $s0
    la   $a1, f2
    li   $a2, 4
    li   $v0, 15
    syscall

    # dong file
    move $a0, $s0
    li   $v0, 16
    syscall

    # thong bao
    li $v0, 4
    la $a0, msg
    syscall

    li $v0, 10
    syscall
```

### ⚠️ Lưu ý quan trọng:

* **Phải đặt đúng tên filename trong code .asm đúng với tên file Input đã tạo. Vd: `FLOAT2.BIN`** (không được sai chữ, số hay đuôi)
* Nếu tên file sai, chương trình MIPS không đọc được file, gây lỗi hoặc sai kết quả

---

## 🧠 Nguyên lý tính toán float trong ASM

1. Tách 2 số float ra:

   * Bit dấu: bit 31
   * Số mũ: bits 30–23
   * Phần trị (mantissa): bits 22–0 (cộng bit 1 ẩn)
2. So sánh và đồng bộ số mũ
3. Cộng/trừ hai mantissa theo dấu
4. Chuẩn hóa kết quả
5. Ghép lại thành float IEEE 754 và xuất ra

---

## 🔍 Kiểm tra kết quả (Python):

```python
import struct

with open("FLOAT2.BIN", "rb") as f:
    a = struct.unpack("f", f.read(4))[0]
    b = struct.unpack("f", f.read(4))[0]

print("A =", a, "B =", b)
print("Tổng =", a + b)
```


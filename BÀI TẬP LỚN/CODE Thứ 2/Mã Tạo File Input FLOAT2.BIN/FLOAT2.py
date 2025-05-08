# Floatbin.py
# Chuong trinh ghi 2 so thuc 32-bit vao file nhi phan
# Chuong trinh nay su dung module struct de chuyen doi so thuc thanh dang nhi phan
import struct

# Ghi file voi 2 so thuc 32-bit
floats = [3.14, 4.13]
with open("FLOAT2.B", "wb") as f:
    f.write(struct.pack('ff', *floats))

print("Đã ghi thành công 2 số thực vào file data123.bin")
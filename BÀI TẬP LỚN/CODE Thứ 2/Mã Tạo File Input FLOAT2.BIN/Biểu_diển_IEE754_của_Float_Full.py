#Floatbin.py
#Chương trình ghi 2 số thực 32 - bit vào file nhị phân và kiểm tra kết quả
#Chương trình này sử dụng module struct để chuyển đổi số thực thành dạng nhị phân

import struct  # Thư viện xử lý dữ liệu nhị phân
import os      # Thư viện tương tác với hệ điều hành
import binascii  # Thư viện chuyển đổi nhị phân sang hex để hiển thị

def main():
#Thông số đầu vào
    so_thu_nhat = 3.14
    so_thu_hai = 4.13
    ten_file = "FLOAT2.BIN"  # Tên file đầu ra
#Kiểm tra xem file đã tồn tại chưa
    if os.path.exists(ten_file):
        print(f"[WARNING] File '{ten_file}' đã tồn tại và sẽ bị ghi đè!")
        print("[INFO] Nếu bạn không muốn ghi đè, hãy thay đổi tên file hoặc xóa file cũ.")
            

#Hiển thị thông tin về các số thực sẽ ghi
    print(f"[INFO] Chuẩn bị ghi các số thực sau vào file '{ten_file}':")
    print(f"       - Số thứ nhất: {so_thu_nhat}")
    print(f"       - Số thứ hai: {so_thu_hai}")

#Tạo mảng các số thực
    floats = [so_thu_nhat, so_thu_hai]
    
    try:
#Mở file ở chế độ ghi nhị phân(wb = write binary)
        with open(ten_file, "wb") as f:
#Sử dụng struct.pack để chuyển đổi các số thực thành dạng nhị phân
#'ff' chỉ ra rằng chúng ta đang đóng gói hai số thực 32 - bit
#* floats giải nén mảng thành các tham số riêng biệt
            binary_data = struct.pack('ff', *floats)

#Hiển thị thông tin chi tiết về dữ liệu nhị phân
            print(f"[INFO] Dữ liệu nhị phân đã được tạo thành công")
            print(f"       - Kích thước: {len(binary_data)} bytes")
            print(f"       - Giá trị Hex: {binascii.hexlify(binary_data).decode('utf-8')}")

#Ghi dữ liệu nhị phân vào file
            f.write(binary_data)
            
        print(f"[SUCCESS] Đã ghi thành công 2 số thực vào file '{ten_file}'")

#Kiểm tra file đã ghi
        kiem_tra_file(ten_file)
        
    except Exception as e:
        print(f"[ERROR] Đã xảy ra lỗi: {e}")

def kiem_tra_file(ten_file):
    """Hàm kiểm tra nội dung của file đã ghi"""
    
    print("\n[INFO] Kiểm tra file đã ghi:")

#Kiểm tra xem file có tồn tại không
    if not os.path.exists(ten_file):
        print(f"[ERROR] File '{ten_file}' không tồn tại!")
        return

#Lấy kích thước file
    file_size = os.path.getsize(ten_file)
    print(f"[INFO] Kích thước file: {file_size} bytes")
    
    try:
#Đọc file nhị phân
        with open(ten_file, "rb") as f:
#Đọc toàn bộ nội dung file
            binary_content = f.read()

#Hiển thị nội dung dưới dạng hex
            hex_content = binascii.hexlify(binary_content).decode('utf-8')
            print(f"[INFO] Nội dung file (hex): {hex_content}")

#Giải mã các số thực từ dữ liệu nhị phân
#'ff' chỉ ra rằng chúng ta đang giải mã hai số thực 32 - bit
            unpacked_floats = struct.unpack('ff', binary_content)

#Hiển thị các số thực đã đọc được
            print(f"[INFO] Số thực đọc từ file:")
            print(f"       - Số thứ nhất: {unpacked_floats[0]}")
            print(f"       - Số thứ hai: {unpacked_floats[1]}")

#Hiển thị biểu diễn nhị phân của từng số(IEEE 754)
            print("\n[INFO] Biểu diễn IEEE 754 của các số thực:")
            for i, float_val in enumerate(unpacked_floats):
                show_ieee754_representation(float_val, i+1)
                
    except Exception as e:
        print(f"[ERROR] Đã xảy ra lỗi khi đọc file: {e}")

def show_ieee754_representation(float_val, index):
    """Hiển thị biểu diễn IEEE 754 của một số thực"""

#Đóng gói số thực thành dạng nhị phân
    binary = struct.pack('f', float_val)

#Chuyển đổi thành số nguyên 32 - bit
    integer_representation = struct.unpack('I', binary)[0]

#Chuyển đổi thành biểu diễn nhị phân
    binary_representation = bin(integer_representation)[2:].zfill(32)

#Tách thành các phần của IEEE 754
    sign_bit = binary_representation[0]
    exponent_bits = binary_representation[1:9]
    mantissa_bits = binary_representation[9:]

#Tính giá trị số mũ thực tế(trừ đi bias 127)
    exponent_value = int(exponent_bits, 2) - 127
    
    print(f"       Số thứ {index} ({float_val}):")
    print(f"         - Dấu: {sign_bit} ({'Âm' if sign_bit == '1' else 'Dương'})")
    print(f"         - Số mũ (biased): {exponent_bits} (giá trị: {int(exponent_bits, 2)})")
    print(f"         - Số mũ (unbiased): {exponent_value}")
    print(f"         - Phần định trị: {mantissa_bits}")
    print(f"         - Biểu diễn đầy đủ: {sign_bit} | {exponent_bits} | {mantissa_bits}")

#Gọi hàm main khi chạy trực tiếp script này
if __name__ == "__main__":
    main()
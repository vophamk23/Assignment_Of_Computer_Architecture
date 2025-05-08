#include <iostream>  // Thu vien nhap/xuat co ban
#include <fstream>   // Thu vien lam viec voi tep
#include <random>    // Thu vien ho tro sinh so ngau nhien
#include <ctime>     // Thu vien lam viec voi thoi gian
#include <iomanip>   // Thu vien dinh dang dau ra
using namespace std; // Su dung namespace std de don gian hoa cu phap
// ==================== CHUONG TRINH TINH XAP XI GIA TRI PI ====================
/**
 * Chuong trinh tinh xap xi gia tri PI bang phuong phap Monte Carlo
 *
 * Nguyen ly:
 * 1. Hinh tron don vi duoc dat trong hinh vuong 2x2 (tu -1 den 1 tren moi truc)
 * 2. Ti le giua dien tich hinh tron va hinh vuong la: (pi*r^2)/(2*r)^2 = pi/4
 * 3. Vi vay: pi = 4 * (so diem trong hinh tron / tong so diem)
 *
 * Trong bai nay, chung ta su dung toa do [0,1] x [0,1] va hinh tron co tam (0,0) ban kinh 1
 */
// Chuong trinh su dung phuong phap sinh so ngau nhien de tao ra cac diem trong hinh vuong
int main()
{
    // ==================== KHAI BAO BIEN ====================
    const int TOTAL_POINTS = 50000; // Tong so diem can tao
    int pointsInCircle = 0;         // So diem nam trong hinh tron
    double pi;                      // Bien luu gia tri PI tinh duoc

    // ==================== KHOI TAO BO SINH SO NGAU NHIEN ====================
    // Khoi tao bo sinh so ngau nhien - tuong tu viec dat seed trong MIPS
    random_device rd;                                // Lay entropy tu thiet bi
    mt19937 gen(static_cast<unsigned int>(time(0))); // Khoi tao bo sinh so voi hat giong la thoi gian hien tai
    uniform_real_distribution<double> dis(0.0, 1.0); // Phan phoi deu trong khoang [0, 1]

    // ==================== TAO VA KIEM TRA CAC DIEM NGAU NHIEN ====================
    // Tuong duong voi vong lap 'loop' trong MIPS
    for (int i = 0; i < TOTAL_POINTS; i++)
    {
        // Sinh ngau nhien toa do x trong khoang [0, 1]
        // Tuong duong voi viec sinh so ngau nhien cho x trong MIPS
        double x = dis(gen);

        // Sinh ngau nhien toa do y trong khoang [0, 1]
        // Tuong duong voi viec sinh so ngau nhien cho y trong MIPS
        double y = dis(gen);

        // Tinh x^2 + y^2
        // Tuong duong voi cac lenh mul.s va add.s trong MIPS
        double distanceSquared = x * x + y * y;

        // Kiem tra xem diem co nam trong hinh tron don vi khong (x^2 + y^2 < 1)
        // Tuong duong voi lenh c.lt.s va bc1f trong MIPS
        if (distanceSquared < 1.0)
        {
            pointsInCircle++; // Tang so diem nam trong hinh tron
        }
    }

    // ==================== TINH GIA TRI PI ====================
    // Tinh xap xi gia tri PI = 4 * (so diem trong hinh tron / tong so diem)
    // Tuong duong voi cac phep tinh div.s va mul.s trong MIPS
    pi = 4.0 * static_cast<double>(pointsInCircle) / TOTAL_POINTS;

    // ==================== HIEN THI KET QUA ====================
    // Hien thi ket qua ra man hinh
    cout << "So diem nam trong hinh tron: " << pointsInCircle << "/" << TOTAL_POINTS << std::endl;
    cout << "So PI tinh duoc: " << std::fixed << std::setprecision(6) << pi << std::endl;

    // ==================== GHI KET QUA RA TEP ====================
    // Mo tep de ghi - tuong duong voi syscall 13 trong MIPS
    ofstream outFile("PI.txt");

    // Kiem tra xem tep co mo thanh cong hay khong
    if (outFile.is_open())
    {
        // Ghi thong tin ve so diem - tuong duong voi syscall 15 dau tien trong MIPS
        outFile << "So diem nam trong hinh tron: " << pointsInCircle << "/" << TOTAL_POINTS << std::endl;

        // Ghi thong tin ve PI - tuong duong voi syscall 15 thu hai trong MIPS
        outFile << "So PI tinh duoc: " << std::fixed << std::setprecision(6) << pi << std::endl;

        // Dong tep - tuong duong voi syscall 16 trong MIPS
        outFile.close();

        cout << "Da ghi ket qua vao tep PI.txt" << std::endl;
    }
    else
    {
        // Thong bao loi neu khong the mo tep
        cerr << "Khong the mo tep de ghi!" << std::endl;
        return 1;
    }

    // Ket thuc chuong trinh - tuong duong voi syscall 10 trong MIPS
    return 0;
}

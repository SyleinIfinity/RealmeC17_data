package LOPLYTHUYET.WEEK9.BAITAP;

import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

public class Liststaff {
    private Map<String, staff> staffMap;
    static Scanner sc;

    public Liststaff() {
        staffMap = new HashMap<>();
    }

    public Liststaff(Map<String, staff> staffMap) {
        this.staffMap = staffMap;
    }

    public void addStaff(staff A) {
        staffMap.put(A.getStaffCode(), A);
    }

    public void displayStaff() {
        for (String key : staffMap.keySet()) {
            staff s = staffMap.get(key);
            s.XUAT();
        }
    }

    public void NHAP() {
        Liststaff Ls = new Liststaff();
        sc = new Scanner(System.in);
        // // Tạo một số đối tượng staff"
        // staff st = new staff();
        // st.NHAP();

        // // Thêm các đối tượng staff vào HashMap
        // Ls.addStaff(st);

        // // Hiển thị thông tin các staff
        // Ls.displayStaff();
        System.out.printf("Lua chon la F, I, E: ");
        String loaiNV = sc.nextLine();
        if (loaiNV.equalsIgnoreCase("F")) {
            fresher fr = new fresher();
            fr.NHAP();
            Ls.addStaff(fr);
            Ls.displayStaff();
        } else if (loaiNV.equalsIgnoreCase("I")) {
            intern it = new intern();
            it.NHAP();
            Ls.addStaff(it);
            Ls.displayStaff();
        } else if (loaiNV.equalsIgnoreCase("E")) {
            experience ex = new experience();
            ex.NHAP();
            Ls.addStaff(ex);
            Ls.displayStaff();
        } else {
            System.out.println("Loai nhan vien khong hop le!");
        }
    }
}

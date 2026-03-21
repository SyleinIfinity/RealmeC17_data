import java.util.*;
public class lopchinh {
    static double soTienGui;
    static double soTienRut;
    static Scanner sc;
    static String mk_moi;
    public static void main(String[] args) {
        sc= new Scanner(System.in);
        TaiKhoan tk = new TaiKhoan();
        tk.NHAP();
        tk.XUAT();
        tk.kiemtraSoDu();
        /////////////
        System.out.printf("\nNhap vao so tien gui:");
        soTienGui= sc.nextDouble();
        tk.guiTien(soTienGui);
        tk.kiemtraSoDu();
        //////////
        System.out.printf("\nNhap vao so tien rut: ");
        soTienRut= sc.nextDouble();
        do {
            if(soTienRut >tk.getsoDuTK()){
            System.out.println("So du khong du de rut tien, moi ban nhap lai. \n");
            System.out.printf("Nhap vao so tien rut: ");
            soTienRut= sc.nextDouble();
            }
        } while (soTienRut >tk.getsoDuTK());
        tk.rutTien(soTienRut);
        tk.kiemtraSoDu();
        //////
        System.out.printf("\nHay nhap mat khau hien tai: ");
        String OLD_mk = sc.nextLine();
        sc.nextLine();
        do {
            if(!OLD_mk.equals(tk.getmatKhauTK()))
                System.out.printf("\nMat khau cu nhap sai. Moi nhap lai: ");
                OLD_mk = sc.nextLine();
        } while (!OLD_mk.equals(tk.getmatKhauTK()));
        System.out.printf("\nMoi nhap mat khau moi: ");
        mk_moi = sc.nextLine();
        tk.doiMK(mk_moi);
        tk.XUAT();
    }
}
// scanf("%f",&sotiengui);
// soTienRut= sc.nextDouble();
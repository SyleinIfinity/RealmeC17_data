import java.util.*;
public class TaiKhoan{
    private String soTaiKhoan;
    private String chuTaiKhoan;
    private double soDu;
    private String matKhau;
    Scanner sc;

    public String getSOTK(){
        return this.soTaiKhoan;
    }

    public String getCHUTK(){
        return this.chuTaiKhoan;
    }

    public double getsoDuTK(){
        return this.soDu;
    }

    public String getmatKhauTK(){
            return this.matKhau;
    }

    public void NHAP(){
        sc = new Scanner(System.in);//sc la kieu nhap voi cach thuc nhap vao la : system.in - nhap vao tu ban phim)
        System.out.printf("Moi ban nhap thong tin STK  :");
        this.soTaiKhoan=sc.nextLine();
        System.out.printf("Moi ban nhap thong tin CHUTK:");
        this.chuTaiKhoan=sc.nextLine();
        System.out.printf("Moi ban nhap So DU TK       :");
        this.soDu= sc.nextDouble();
        sc.nextLine();
        System.out.printf("Moi ban nhap mat khau       :");
        this.matKhau= sc.nextLine();

    }

    public void XUAT(){
        System.out.printf("\nSTK              : %s  ", getSOTK());
        System.out.printf("\nChu TK           : %s  ", getCHUTK());
        System.out.printf("\nSo Du TK         : %.3f", getsoDuTK());
        System.out.printf("\nMat Khau hien tai: %s \n ", getmatKhauTK());

    }
    public void kiemtraSoDu(){
            System.out.printf("So du hien tai: %.3f", this.soDu);
    }

    public void guiTien(double soTien){//guitien vao tai khoan
        this.soDu= this.soDu + soTien;
    }//Phuong thuc nay se cap nhat so du = so du + sotien nhap vao

    public void rutTien(double soTien){
        this.soDu= this.soDu - soTien;
    }

    public void doiMK(String mk_moi){
        this.matKhau = mk_moi;
    }

}


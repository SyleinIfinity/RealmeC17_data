package BAITHUCHANH.TUAN8;

import java.security.SecureRandom;
import java.util.Scanner;

public class taikhoanBank {
protected String sotaikhoan;
    protected String chutaikhoan;
    protected double sodutaikhoan;
    protected String sodienthoai;
    protected String matkhau;
    private String maOTP;
    private static final String kitusotaikhoan = "0123456789";
    private static final SecureRandom chuoingaunhien = new SecureRandom();
    static Scanner sc;

    public taikhoanBank(){
        sc = new Scanner(System.in);
    }

    public taikhoanBank(String sotaikhoan, String chutaikhoan, double sodutaikhoan, String matkhau) {
        this.sotaikhoan = sotaikhoan;
        this.chutaikhoan = chutaikhoan;
        this.sodutaikhoan = sodutaikhoan;
        this.matkhau = matkhau;
    }

    public String getsotaikhoan() {
        return sotaikhoan;
    }
    public void setsotaikhoan(String sotaikhoan) {
        this.sotaikhoan = sotaikhoan;
    }

    public String getChutaikhoan() {
        return chutaikhoan;
    }
    public void setChutaikhoan(String chutaikhoan) {
        this.chutaikhoan = chutaikhoan;
    }

    public double getSodutaikhoan() {
        return sodutaikhoan;
    }
    public void setSodutaikhoan(double sodutaikhoan) {
        this.sodutaikhoan = sodutaikhoan;
    }

    public String getSodienthoai() {
        return sodienthoai;
    }
    public void setSodienthoai(String sodienthoai) {
        this.sodienthoai = sodienthoai;
    }
    
    public String getMatkhau() {
        return matkhau;
    }
    public void setMatkhauMoi(String matkhaumoi) {
        this.matkhau = matkhaumoi;
    }

    public String getMaOTP() {
        return maOTP;
    }
    public void setMaOTP(String maOTP) {
        this.maOTP = maOTP;
    }

    @Override
    public String toString() {
        return getsotaikhoan() + "," + getChutaikhoan() + ","
        + getSodutaikhoan() + "," + getMatkhau();
    }


}

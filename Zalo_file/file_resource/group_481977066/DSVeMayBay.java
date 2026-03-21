import java.util.ArrayList;
import java.util.Scanner;

public class DSVeMayBay {
    private ArrayList<VeMayBay> danhSachVe;

    public DSVeMayBay() {
        danhSachVe = new ArrayList<>();
    }

    // Phuong thuc them ve
    public void addTicket(VeMayBay ve) {
        danhSachVe.add(ve);
        System.out.println("Ve da duoc them: " + ve);
    }

    // Phuong thuc tim ve
    public void searchTicket() {
        Scanner scanner = new Scanner(System.in);
        System.out.println("Nhap ID ve muon tim:");
        String idToSearch = scanner.nextLine();

        for (VeMayBay ve : danhSachVe) {
            if (ve.getIdTicket().equals(idToSearch)) {
                System.out.println("Ve tim thay: " + ve);
                return;
            }
        }
        System.out.println("Khong tim thay ve voi ID: " + idToSearch);
    }

    // Phuong thuc xoa ve
    public boolean deleteTicket(String idTicket) {
        for (VeMayBay ve : danhSachVe) {
            if (ve.getIdTicket().equals(idTicket)) {
                danhSachVe.remove(ve);
                System.out.println("Ve da duoc xoa: " + ve);
                return true;
            }
        }
        System.out.println("Khong tim thay ve voi ID: " + idTicket);
        return false;
    }

    // Phuong thuc thay doi thong tin ve
    public void updateTicket() {
        Scanner scanner = new Scanner(System.in);
        System.out.println("Nhap ID ve muon cap nhat:");
        String idToUpdate = scanner.nextLine();

        for (VeMayBay ve : danhSachVe) {
            if (ve.getIdTicket().equals(idToUpdate)) {
                System.out.println("Chon thong tin muon thay doi:");
                System.out.println("1. ID Chuyen Bay (hien tai: " + ve.getIdFlight() + ")");
                System.out.println("2. ID Khach Hang (hien tai: " + ve.getIdCustomer() + ")");
                System.out.println("3. Ngay Dat Ve (hien tai: " + ve.getBookingDate() + ")");
                System.out.println("4. So Ghe (hien tai: " + ve.getSeatNumber() + ")");
                System.out.println("5. Trang Thai Ve (hien tai: " + ve.getStatusTicket() + ")");
                int choice = scanner.nextInt();
                scanner.nextLine();

                switch (choice) {
                    case 1:
                        System.out.println("Nhap ID Chuyen Bay moi:");
                        String newFlight = scanner.nextLine();
                        ve.setIdFlight(newFlight);
                        break;
                    case 2:
                        System.out.println("Nhap ID Khach Hang moi:");
                        String newCustomer = scanner.nextLine();
                        ve.setIdCustomer(newCustomer);
                        break;
                    case 3:
                        System.out.println("Nhap Ngay Dat Ve moi:");
                        String newDate = scanner.nextLine();
                        ve.setBookingDate(newDate);
                        break;
                    case 4:
                        System.out.println("Nhap So Ghe moi:");
                        String newSeat = scanner.nextLine();
                        ve.setSeatNumber(newSeat);
                        break;
                    case 5:
                        System.out.println("Nhap Trang Thai Ve moi:");
                        String newStatus = scanner.nextLine();
                        ve.setStatusTicket(newStatus);
                        break;
                    default:
                        System.out.println("Lua chon khong hop le.");
                        break;
                }
                System.out.println("Thong tin ve da duoc cap nhat: " + ve);
                return;
            }
        }
        System.out.println("Khong tim thay ve voi ID: " + idToUpdate);
    }

}
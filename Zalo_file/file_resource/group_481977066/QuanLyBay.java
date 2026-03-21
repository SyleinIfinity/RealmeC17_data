package com.example;

// import java.sql.Connection;
// import java.sql.ResultSet;
// import java.sql.Statement;
import java.util.Scanner;

import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;

public class QuanLyBay {
    // Mã màu chữ ANSI
    public static final String RESET = "\u001B[0m";
    public static final String RED = "\u001B[31m";
    public static final String GREEN = "\u001B[32m";
    public static final String YELLOW = "\u001B[33m";
    public static final String BLUE = "\u001B[34m";
    public static final String MAGENTA = "\u001B[35m";
    public static final String CYAN = "\u001B[36m";
    public static final String WHITE = "\u001B[37m";
    public static final String GRAY = "\u001B[90m";

    // Mã màu nền ANSI
    public static final String BLACK_BG = "\u001B[40m";
    public static final String RED_BG = "\u001B[41m";
    public static final String GREEN_BG = "\u001B[42m";
    public static final String YELLOW_BG = "\u001B[43m";
    public static final String BLUE_BG = "\u001B[44m";
    public static final String MAGENTA_BG = "\u001B[45m";
    public static final String CYAN_BG = "\u001B[46m";
    public static final String WHITE_BG = "\u001B[47m";
    static Scanner sc = new Scanner(System.in);

    private static boolean statuLogin = false;
    private static String idUser;
    private static String role;

    public static void main(String[] args) {
        SetUp loginFrame = new SetUp(new LoginCallback() {
            @Override
            public void onLoginSuccess(String r, String stk, boolean stt) {
                statuLogin = stt;
                idUser = stk;
                role = r;
            }

            @Override
            public void onLoginFailure(String message) {
                System.out.println("Dang nhap that bai: " + message);
            }
        });
        SwingUtilities.invokeLater(() -> {
            loginFrame.setVisible(true);
        });

        while (!statuLogin) {
            try {
                Thread.sleep(100);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        JOptionPane.showMessageDialog(new JOptionPane(), "Dang nhap thanh cong id" + role + ": " + idUser);
        // try {

        // String select = "SELECT * FROM TICKET WHERE CustomerID = 'C001' ";
        // Connection connection = SQLServerHandle.getConnection();
        // Statement statement = connection.createStatement();
        // ResultSet resultSet = statement.executeQuery(select);
        // int i = 0;
        // while (resultSet.next()) {
        // String ticketID = resultSet.getString("TicketID");
        // String flightID = resultSet.getString("FlightID");
        // String customerID = resultSet.getString("CustomerID");
        // String seatNumber = resultSet.getString("SeatNumber");
        // String bookingDate = resultSet.getString("BookingDate");
        // String statusTicket = resultSet.getString("StatusTicket");
        // switch (statusTicket) {
        // case "Confirmed":
        // statusTicket = GREEN_BG + statusTicket + RESET;
        // break;
        // case "Pending":
        // statusTicket = YELLOW_BG + statusTicket + RESET;
        // break;
        // case "Cancelled":
        // statusTicket = RED_BG + statusTicket + RESET;
        // break;
        // case "Checked In":
        // statusTicket = BLUE_BG + statusTicket + RESET;
        // break;
        // case "Refunded":
        // statusTicket = MAGENTA_BG + statusTicket + RESET;
        // break;
        // case "No Show":
        // statusTicket = CYAN_BG + statusTicket + RESET;
        // break;
        // default:
        // break;
        // }
        // i++;
        // VeMayBay vmb = new VeMayBay(ticketID, flightID, customerID, bookingDate,
        // seatNumber, statusTicket);
        // vmb.display(i);
        // }
        // statement.close();
        // connection.close();
        // } catch (Exception e) {
        // System.out.println("Error connection!!!");
        // }

    }

    public void showMenu() {
        System.out.print(
                "1. Nhap thong tin chuyen bay\n2. Luu thong tin chuyen bay\n3. Doc thong tin chuyen bay\n4. Sap xep theo gia\n5. In thong tin theo tung hang ra 1 file\nChoose: ");
    }
}

package com.example;


public class VeMayBay {
    String idTicket;
    String idFlight;
    String idCustomer;
    String bookingDate;
    String seatNumber;
    String statusTicket;

    // Constructors
    public VeMayBay() {
    }

    public VeMayBay(String idT, String idF, String idC, String date, String seat, String stt) {
        this.idTicket = idT;
        this.idFlight = idF;
        this.idCustomer = idC;
        this.bookingDate = date;
        this.seatNumber = seat;
        this.statusTicket = stt;
    }
    public String getIdTicket() {
        return idTicket;
    }
    public void setIdTicket(String idTicket) {
        this.idTicket = idTicket;
    }
    public String getIdFlight() {
        return idFlight;
    }
    public void setIdFlight(String idFlight) {
        this.idFlight = idFlight;
    }
    public String getIdCustomer() {
        return idCustomer;
    }
    public void setIdCustomer(String idCustomer) {
        this.idCustomer = idCustomer;
    }
    public String getBookingDate() {
        return bookingDate;
    }
    public void setBookingDate(String bookingDate) {
        this.bookingDate = bookingDate;
    }
    public String getSeatNumber() {
        return seatNumber;
    }
    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }
    public String getStatusTicket() {
        return statusTicket;
    }
    public void setStatusTicket(String statusTicket) {
        this.statusTicket = statusTicket;
    }
    public String toString(int i) {
        return "VeMayBay " + i +" [idTicket=" + idTicket + ", idFlight=" + idFlight + ", idCustomer=" + idCustomer
                + ", bookingDate=" + bookingDate + ", seatNumber=" + seatNumber + ", statusTicket=" + statusTicket
                + "]";
    }

    public void display(int i) {
        System.out.println(i + ". " +toString(i));
    }
}

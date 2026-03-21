package code.MODEL;

public class INVOICE {
    private String invoice_id;
    private String booking_id;
    private String wallet_id;
    private Double total_amount;
    private String payment_method;
    private String payment_date;
    
    public INVOICE(String invoice_id, String booking_id, String wallet_id, Double total_amount, String payment_method,
            String payment_date) {
        this.invoice_id = invoice_id;
        this.booking_id = booking_id;
        this.wallet_id = wallet_id;
        this.total_amount = total_amount;
        this.payment_method = payment_method;
        this.payment_date = payment_date;
    }

    public INVOICE() {
    }

    public String getInvoice_id() {
        return invoice_id;
    }

    public String getBooking_id() {
        return booking_id;
    }

    public String getWallet_id() {
        return wallet_id;
    }

    public Double getTotal_amount() {
        return total_amount;
    }

    public String getPayment_method() {
        return payment_method;
    }

    public String getPayment_date() {
        return payment_date;
    }

    public void setInvoice_id(String invoice_id) {
        this.invoice_id = invoice_id;
    }

    public void setBooking_id(String booking_id) {
        this.booking_id = booking_id;
    }

    public void setWallet_id(String wallet_id) {
        this.wallet_id = wallet_id;
    }

    public void setTotal_amount(Double total_amount) {
        this.total_amount = total_amount;
    }

    public void setPayment_method(String payment_method) {
        this.payment_method = payment_method;
    }

    public void setPayment_date(String payment_date) {
        this.payment_date = payment_date;
    }

    @Override
    public String toString() {
        return "INVOICE [invoice_id=" + invoice_id + ", booking_id=" + booking_id + ", wallet_id=" + wallet_id
                + ", total_amount=" + total_amount + ", payment_method=" + payment_method + ", payment_date="
                + payment_date + "]";
    }
}

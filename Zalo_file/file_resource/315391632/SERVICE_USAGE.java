package code.MODEL;

public class SERVICE_USAGE {
    private String usage_id;
    private String booking_id;
    private String service_id;
    private String quantity;
    private Double total_price;
    
    public SERVICE_USAGE(String usage_id, String booking_id, String service_id, String quantity, Double total_price) {
        this.usage_id = usage_id;
        this.booking_id = booking_id;
        this.service_id = service_id;
        this.quantity = quantity;
        this.total_price = total_price;
    }

    public SERVICE_USAGE() {
    }

    public String getUsage_id() {
        return usage_id;
    }

    public String getBooking_id() {
        return booking_id;
    }

    public String getService_id() {
        return service_id;
    }

    public String getQuantity() {
        return quantity;
    }

    public Double getTotal_price() {
        return total_price;
    }

    public void setUsage_id(String usage_id) {
        this.usage_id = usage_id;
    }

    public void setBooking_id(String booking_id) {
        this.booking_id = booking_id;
    }

    public void setService_id(String service_id) {
        this.service_id = service_id;
    }

    public void setQuantity(String quantity) {
        this.quantity = quantity;
    }

    public void setTotal_price(Double total_price) {
        this.total_price = total_price;
    }

    public String toString() {
        return "SERVICE_USAGE{" +
                "usage_id='" + usage_id + '\'' +
                ", booking_id='" + booking_id + '\'' +
                ", service_id='" + service_id + '\'' +
                ", quantity='" + quantity + '\'' +
                ", total_price=" + total_price +
                '}';
    }
}

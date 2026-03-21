package code.MODEL;

public class ROOM {
    private String roomId;          
    private String roomNumber;      
    private ROOM_TYPE roomTypeId;     
    private int floor;              
    private HOTELBRANCH branchId;     
    private double price;           
    private String status;          

    public ROOM(String roomId, String roomNumber, ROOM_TYPE roomTypeId, 
               int floor, HOTELBRANCH branchId, double price, String status) {
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.roomTypeId = roomTypeId;
        this.floor = floor;
        this.branchId = branchId;
        this.price = price;
        this.status = status;
    }

    // Getter và Setter methods
    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public ROOM_TYPE getRoomTypeId() {
        return roomTypeId;
    }

    public void setRoomTypeId(ROOM_TYPE roomTypeId) {
        this.roomTypeId = roomTypeId;
    }

    public int getFloor() {
        return floor;
    }

    public void setFloor(int floor) {
        this.floor = floor;
    }

    public HOTELBRANCH getBranchId() {
        return branch;
    }

    public void setBranch(HOTELBRANCH branchId) {
        this.branch = branchId;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "ROOM{" + "roomId='" + roomId + '\'' + ", roomNumber='" + roomNumber + '\'' + ", roomType=" + roomTypeId + ", floor=" + floor + ", branch=" + branchId + ", price=" + price + ", status='" + status + '\'' + '}';
    }
}
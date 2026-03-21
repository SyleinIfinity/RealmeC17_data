package code.MODEL;

public class ROOM_TYPE {
    private String roomTypeId;   
    private String typeName;     
    private String descript;      
    private double basePrice;     

    public ROOM_TYPE(String roomTypeId, String typeName, String descript, double basePrice) {
        this.roomTypeId = roomTypeId;
        this.typeName = typeName;
        this.descript = descript;
        this.basePrice = basePrice;
    }

    public String getRoomTypeId() {
        return roomTypeId;
    }

    public void setRoomTypeId(String roomTypeId) {
        this.roomTypeId = roomTypeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getDescript() {
        return descript;
    }

    public void setDescript(String descript) {
        this.descript = descript;
    }

    public double getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    @Override
    public String toString() {
        return "ROOM_TYPE{" + "roomTypeId='" + roomTypeId + '\'' + ", typeName='" + typeName + '\'' + ", descript='" + descript + '\'' + ", basePrice=" + basePrice + '}';
    }
}
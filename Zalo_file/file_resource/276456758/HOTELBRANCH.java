package code.MODEL;

public class HOTELBRANCH {
    private String branchId;
    private String branchName;
    private String address;
    private String phone;
    
    public HOTELBRANCH(String branchId, String branchName, String address, String phone) {
        this.branchId = branchId;
        this.branchName = branchName;
        this.address = address;
        this.phone = phone;
    }
    
    public String getBranchId() {
        return branchId;
    }
    public void setBranchId(String branchId) {
        this.branchId = branchId;
    }
    public String getBranchName() {
        return branchName;
    }
    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }
    public String getAddress() {
        return address;
    }
    public void setAddress(String address) {
        this.address = address;
    }
    public String getPhone() {
        return phone;
    }
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    @Override
    public String toString() {
        return "HotelBranch{" + "branchId='" + branchId + '\'' + ", branchName='" + branchName + '\'' + ", address='" + address + '\'' + ", phone='" + phone + '\'' + '}';
    }
}

public class QuanTriVien extends TaiKhoan {
    String IDAdmin;
    String nameAdmin;
    String address;
    String phoneNumber;
    String position; // chức vụ

    public QuanTriVien(String IDAdmin, String nameAdmin, String address, String phoneNumber, String position,String loginName, String password) {
        super(loginName, password);
        this.IDAdmin = IDAdmin;
        this.nameAdmin = nameAdmin;
        this.address = address;
        this.phoneNumber = phoneNumber;
        this.position = position;
    }

    public String getIDAdmin() {
        return IDAdmin;
    }

    public void setIDAdmin(String IDAdmin) {
        this.IDAdmin = IDAdmin;
    }

    public String getNameAdmin() {
        return nameAdmin;
    }

    public void setNameAdmin(String nameAdmin) {
        this.nameAdmin = nameAdmin;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public void displayInfo() {
        System.out.println("ID Admin: " + IDAdmin);
        System.out.println("Name Admin: " + nameAdmin);
        System.out.println("Address: " + address);
        System.out.println("Phone Number: " + phoneNumber);
        System.out.println("Position: " + position);
    }
}

import java.util.Date;

public class NguoiDung extends TaiKhoan{
    String IDUserName;
    String userName;
    Date dateOfBirth;
    String address;
    String cic; // citizen identification card -- căn cước công dân
    String email;
    String phoneNumber;

    public NguoiDung(String IDUserName, String userName, Date dateOfBirth, String address, String cic, String email, String phoneNumber, String loginName, String password) {
        super(loginName, password);
        this.IDUserName = IDUserName;
        this.userName = userName;
        this.dateOfBirth = dateOfBirth;
        this.address = address;
        this.cic = cic;
        this.email = email;
        this.phoneNumber = phoneNumber;
    }

    public String getIDUserName() {
        return IDUserName;
    }

    public void setIDUserName(String IDUserName) {
        this.IDUserName = IDUserName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCIC() {
        return cic;
    }

    public void setCIC(String cic) {
        this.cic = cic;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public void displayInfo() {
        System.out.println("ID Username: " + IDUserName);
        System.out.println("Username: " + userName);
        System.out.println("Date of Birth: " + dateOfBirth);
        System.out.println("Address: " + address);
        System.out.println("CIC: " + cic);
        System.out.println("Email: " + email);
        System.out.println("Phone Number: " + phoneNumber);
    }
}
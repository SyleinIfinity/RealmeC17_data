package code.MODEL;

public class USER {
    private String userId;
    private String name;
    private String phone;
    private String email;
    private String password;
    private String roleId;
    

    public USER() {
    }

    public USER(String userId, String name, String phone, String email, String password, String roleId) {
        this.userId = userId;
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.password = password;
        this.roleId = roleId;
    }
    
    public String getUserId() {
        return userId;
    }
    public void setUserId(String userId) {
        this.userId = userId;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getPhone() {
        return phone;
    }
    public void setPhone(String phone) {
        this.phone = phone;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public String getroleId() {
        return roleId;
    }
    public void setroleId(String roleId) {
        this.roleId = roleId;
    }
    
    @Override
    public String toString() {
        return "User{" + "userId='" + userId + '\'' + ", name='" + name + '\'' + ", phone='" + phone + '\'' + ", email='" + email + '}';
    }
}

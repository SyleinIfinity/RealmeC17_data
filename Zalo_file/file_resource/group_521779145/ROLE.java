package code.MODEL;

public class ROLE {
    private String roleId;
    private String roleName;
    private String description;
    
    public ROLE(String roleId, String roleName, String description){
        this.roleId = roleId;
        this.roleName = roleName;
        this.description = description;
    }
    
    public String getRoleId(){
        return roleId;
    }
    public void setRoleId(String roleId){
        this.roleId = roleId;
    }
    public String getRoleName(){
        return roleName;
    }
    public void setRoleName(String roleName){
        this.roleName = roleName;
    }
    public String getDescription(){
        return description;
    }
    public void setDescription(String description){
        this.description = description;
    }
    
    @Override
    public String toString() {
        return "Role{" + "roleId='" + roleId + '\'' + ", roleName='" + roleName + '\'' + ", description='" + description + '\'' + '}';
    }
}

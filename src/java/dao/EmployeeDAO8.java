package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Employee8;
import model.Role8;
import model.RoleAssignment8;

// Lớp hỗ trợ đăng nhập để chạy thử, nằm ngoài hai module của đề
public class EmployeeDAO8 extends DAO8 {

    public EmployeeDAO8() {
        super();
    }

    // Kiểm tra tài khoản, đúng thì trả về nhân viên kèm danh sách phân công vai trò
    public Employee8 checkLogin(String username, String password) {
        String sql = "SELECT * FROM tblEmployee8 WHERE username = ? AND password = ? "
                + "AND employmentStatus = 'Đang làm việc'";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Employee8 e = new Employee8();
                e.setId(rs.getInt("id"));
                e.setName(rs.getString("name"));
                e.setDateOfBirth(rs.getDate("dateOfBirth"));
                e.setGender(rs.getString("gender"));
                e.setPhoneNumber(rs.getString("phoneNumber"));
                e.setAddress(rs.getString("address"));
                e.setEmail(rs.getString("email"));
                e.setUsername(rs.getString("username"));
                e.setHireDate(rs.getDate("hireDate"));
                e.setTerminationDate(rs.getDate("terminationDate"));
                e.setEmploymentStatus(rs.getString("employmentStatus"));
                e.setRoleAssignmentList(getRoleAssignmentList(e.getId()));
                return e;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    // Lấy các phân công vai trò của một nhân viên, mỗi phân công kèm vai trò
    private RoleAssignment8[] getRoleAssignmentList(int employeeId) throws Exception {
        String sql = "SELECT ra.*, r.roleName, r.description FROM tblRoleAssignment8 ra "
                + "JOIN tblRole8 r ON ra.tblRole8id = r.id WHERE ra.tblEmployee8id = ?";
        List<RoleAssignment8> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Role8 role = new Role8();
                role.setId(rs.getInt("tblRole8id"));
                role.setRoleName(rs.getString("roleName"));
                role.setDescription(rs.getString("description"));

                RoleAssignment8 ra = new RoleAssignment8();
                ra.setId(rs.getInt("id"));
                ra.setRole(role);
                ra.setStartDate(rs.getDate("startDate"));
                ra.setEndDate(rs.getDate("endDate"));
                ra.setAssignmentStatus(rs.getString("assignmentStatus"));
                list.add(ra);
            }
        }
        return list.toArray(new RoleAssignment8[0]);
    }
}
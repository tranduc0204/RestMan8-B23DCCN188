package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import model.Customer8;

public class CustomerDAO8 extends DAO8 {

    public CustomerDAO8() {
        super();
    }

    public Customer8 getCustomerByPhone(String phoneNumber) {
        String sql = "SELECT * FROM tblCustomer8 WHERE phoneNumber = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, phoneNumber);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Customer8 c = new Customer8();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setPhoneNumber(rs.getString("phoneNumber"));
                c.setEmail(rs.getString("email"));
                c.setDateOfBirth(rs.getDate("dateOfBirth"));
                c.setAddress(rs.getString("address"));
                return c;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Customer8 addCustomer(Customer8 customer) {
        String sql = "INSERT INTO tblCustomer8 (name, phoneNumber, email, dateOfBirth, address) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, customer.getName());
            ps.setString(2, customer.getPhoneNumber());
            ps.setString(3, customer.getEmail());
            if (customer.getDateOfBirth() != null) {
                ps.setDate(4, new java.sql.Date(customer.getDateOfBirth().getTime()));
            } else {
                ps.setNull(4, java.sql.Types.DATE);
            }
            ps.setString(5, customer.getAddress());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                customer.setId(keys.getInt(1));
                return customer;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
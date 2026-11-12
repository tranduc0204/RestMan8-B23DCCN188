package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Size8;

public class SizeDAO8 extends DAO8 {

    public SizeDAO8() {
        super();
    }

    public Size8[] getSizeList() {
        String sql = "SELECT * FROM tblSize8 WHERE status = 'Đang sử dụng' ORDER BY id";
        List<Size8> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Size8 s = new Size8();
                s.setId(rs.getInt("id"));
                s.setSizeName(rs.getString("sizeName"));
                s.setDescription(rs.getString("description"));
                s.setStatus(rs.getString("status"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list.toArray(new Size8[0]);
    }
}
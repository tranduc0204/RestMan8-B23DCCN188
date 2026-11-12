package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.DishCategory8;

public class DishCategoryDAO8 extends DAO8 {

    public DishCategoryDAO8() {
        super();
    }

    // Lấy các loại món ăn đang ở trạng thái sử dụng
    public DishCategory8[] getCategoryList() {
        String sql = "SELECT * FROM tblDishCategory8 WHERE status = 'Đang sử dụng' ORDER BY id";
        List<DishCategory8> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                DishCategory8 c = new DishCategory8();
                c.setId(rs.getInt("id"));
                c.setCategoryName(rs.getString("categoryName"));
                c.setDescription(rs.getString("description"));
                c.setStatus(rs.getString("status"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list.toArray(new DishCategory8[0]);
    }
}
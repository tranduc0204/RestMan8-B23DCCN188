package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import model.Dish8;

public class DishDAO8 extends DAO8 {

    public DishDAO8() {
        super();
    }

    // Kiểm tra tên món ăn đã tồn tại trong các món đang phục vụ hay chưa
    public boolean checkDishExists(String dishName) {
        String sql = "SELECT COUNT(*) FROM tblDish8 "
                + "WHERE LOWER(TRIM(dishName)) = LOWER(TRIM(?)) AND servingStatus = 'Đang phục vụ'";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, dishName);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lưu món ăn mới, trả về món ăn đã có id.
    // Mở transaction và CHƯA commit: saveDishSizeList() của DishSizeDAO8 sẽ commit hoặc rollback
    // để món ăn và các kích cỡ được lưu cùng nhau.
    public Dish8 addDish(Dish8 dish) {
        String sql = "INSERT INTO tblDish8 (dishName, description, image, servingStatus, tblDishCategory8id) "
                + "VALUES (?, ?, ?, ?, ?)";
        try {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, dish.getDishName());
                ps.setString(2, dish.getDescription());
                ps.setString(3, dish.getImage());
                ps.setString(4, dish.getServingStatus());
                ps.setInt(5, dish.getCategory().getId());
                ps.executeUpdate();
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    dish.setId(keys.getInt(1));
                    return dish;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        // Lỗi: hủy transaction và trả kết nối về chế độ tự commit
        try {
            con.rollback();
            con.setAutoCommit(true);
        } catch (Exception ignored) {
        }
        return null;
    }
}
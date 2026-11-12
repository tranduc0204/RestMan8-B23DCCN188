package dao;

import java.sql.PreparedStatement;
import model.DishSize8;

public class DishSizeDAO8 extends DAO8 {

    public DishSizeDAO8() {
        super();
    }

    // Lưu danh sách kích cỡ kèm đơn giá của một món ăn, lưu một lượt.
    // Chạy tiếp transaction do DishDAO8.addDish() mở: thành công thì commit cả món ăn lẫn kích cỡ,
    // lỗi thì rollback cả hai.
    public boolean saveDishSizeList(DishSize8[] dishSizeList) {
        String sql = "INSERT INTO tblDishSize8 (unitPrice, servingStatus, tblDish8id, tblSize8id) "
                + "VALUES (?, ?, ?, ?)";
        try {
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                for (DishSize8 ds : dishSizeList) {
                    ps.setFloat(1, ds.getUnitPrice());
                    ps.setString(2, ds.getServingStatus());
                    ps.setInt(3, ds.getDish().getId());
                    ps.setInt(4, ds.getSize().getId());
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try {
                con.rollback();
            } catch (Exception ignored) {
            }
            return false;
        } finally {
            try {
                con.setAutoCommit(true);
            } catch (Exception ignored) {
            }
        }
    }
}
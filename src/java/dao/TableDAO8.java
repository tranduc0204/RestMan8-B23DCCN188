package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import model.Table8;

public class TableDAO8 extends DAO8 {

    public TableDAO8() {
        super();
    }

    // Lấy các bàn đang sử dụng và chưa có phiếu đặt bàn đang hiệu lực trong ngày và khung giờ đã chọn
    public Table8[] getAvailableTableList(Date reservationDate, int timeSlotId) {
        String sql = "SELECT * FROM tblTable8 t WHERE t.tableStatus = 'Đang sử dụng' "
                + "AND t.id NOT IN (SELECT r.tblTable8id FROM tblReservation8 r "
                + "WHERE r.reservationDate = ? AND r.tblTimeSlot8id = ? "
                + "AND r.status IN ('Chờ xác nhận', 'Đã xác nhận')) "
                + "ORDER BY t.tableNumber";
        List<Table8> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, new java.sql.Date(reservationDate.getTime()));
            ps.setInt(2, timeSlotId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Table8 t = new Table8();
                t.setId(rs.getInt("id"));
                t.setTableNumber(rs.getString("tableNumber"));
                t.setCapacity(rs.getInt("capacity"));
                t.setLocation(rs.getString("location"));
                t.setTableStatus(rs.getString("tableStatus"));
                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list.toArray(new Table8[0]);
    }
}
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Date;
import model.Reservation8;

public class ReservationDAO8 extends DAO8 {

    public ReservationDAO8() {
        super();
    }

    // Bàn còn trống khi chưa có phiếu đặt bàn đang hiệu lực trong ngày và khung giờ đó
    public boolean checkTableAvailable(int tableId, Date reservationDate, int timeSlotId) {
        String sql = "SELECT COUNT(*) FROM tblReservation8 WHERE tblTable8id = ? "
                + "AND reservationDate = ? AND tblTimeSlot8id = ? "
                + "AND status IN ('Chờ xác nhận', 'Đã xác nhận')";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tableId);
            ps.setDate(2, new java.sql.Date(reservationDate.getTime()));
            ps.setInt(3, timeSlotId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) == 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lưu phiếu đặt bàn ở trạng thái chờ xác nhận, trả về phiếu đã có id
    public Reservation8 saveReservation(Reservation8 reservation) {
        String sql = "INSERT INTO tblReservation8 (reservationDate, note, status, "
                + "tblTable8id, tblTimeSlot8id, tblCustomer8id, tblEmployee8id) "
                + "VALUES (?, ?, ?, ?, ?, ?, NULL)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setDate(1, new java.sql.Date(reservation.getReservationDate().getTime()));
            ps.setString(2, reservation.getNote());
            ps.setString(3, "Chờ xác nhận");
            ps.setInt(4, reservation.getTable().getId());
            ps.setInt(5, reservation.getTimeSlot().getId());
            ps.setInt(6, reservation.getCustomer().getId());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                reservation.setId(keys.getInt(1));
                reservation.setStatus("Chờ xác nhận");
                reservation.setCreatedAt(new Date());
                return reservation;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
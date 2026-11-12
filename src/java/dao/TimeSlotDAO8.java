package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.TimeSlot8;

public class TimeSlotDAO8 extends DAO8 {

    public TimeSlotDAO8() {
        super();
    }

    // Lấy các khung giờ đang ở trạng thái áp dụng
    public TimeSlot8[] getTimeSlotList() {
        String sql = "SELECT * FROM tblTimeSlot8 WHERE slotStatus = 'Đang áp dụng' ORDER BY startTime";
        List<TimeSlot8> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TimeSlot8 t = new TimeSlot8();
                t.setId(rs.getInt("id"));
                t.setStartTime(rs.getTime("startTime"));
                t.setEndTime(rs.getTime("endTime"));
                t.setSlotStatus(rs.getString("slotStatus"));
                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list.toArray(new TimeSlot8[0]);
    }
}
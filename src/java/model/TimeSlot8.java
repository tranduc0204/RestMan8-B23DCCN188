package model;

import java.util.Date;

public class TimeSlot8 {
    private int id;
    private Date startTime;
    private Date endTime;
    private String slotStatus;

    public TimeSlot8() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Date getStartTime() { return startTime; }
    public void setStartTime(Date startTime) { this.startTime = startTime; }
    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }
    public String getSlotStatus() { return slotStatus; }
    public void setSlotStatus(String slotStatus) { this.slotStatus = slotStatus; }
}
package model;

import java.util.Date;

public class Reservation8 {
    private int id;
    private Table8 table;
    private TimeSlot8 timeSlot;
    private Customer8 customer;
    private Employee8 employee;
    private Date reservationDate;
    private String note;
    private Date createdAt;
    private String status;

    public Reservation8() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Table8 getTable() { return table; }
    public void setTable(Table8 table) { this.table = table; }
    public TimeSlot8 getTimeSlot() { return timeSlot; }
    public void setTimeSlot(TimeSlot8 timeSlot) { this.timeSlot = timeSlot; }
    public Customer8 getCustomer() { return customer; }
    public void setCustomer(Customer8 customer) { this.customer = customer; }
    public Employee8 getEmployee() { return employee; }
    public void setEmployee(Employee8 employee) { this.employee = employee; }
    public Date getReservationDate() { return reservationDate; }
    public void setReservationDate(Date reservationDate) { this.reservationDate = reservationDate; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
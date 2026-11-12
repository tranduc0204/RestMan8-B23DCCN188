package model;

import java.util.Date;

public class RoleAssignment8 {
    private int id;
    private Role8 role;
    private Date startDate;
    private Date endDate;
    private String assignmentStatus;

    public RoleAssignment8() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Role8 getRole() { return role; }
    public void setRole(Role8 role) { this.role = role; }
    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }
    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }
    public String getAssignmentStatus() { return assignmentStatus; }
    public void setAssignmentStatus(String assignmentStatus) { this.assignmentStatus = assignmentStatus; }
}
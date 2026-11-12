package model;

import java.util.Date;

public class MembershipCard8 {
    private int id;
    private Employee8 employee;
    private String cardTier;
    private int loyaltyPoint;
    private float totalSpending;
    private Date issueDate;
    private String cardStatus;

    public MembershipCard8() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Employee8 getEmployee() { return employee; }
    public void setEmployee(Employee8 employee) { this.employee = employee; }
    public String getCardTier() { return cardTier; }
    public void setCardTier(String cardTier) { this.cardTier = cardTier; }
    public int getLoyaltyPoint() { return loyaltyPoint; }
    public void setLoyaltyPoint(int loyaltyPoint) { this.loyaltyPoint = loyaltyPoint; }
    public float getTotalSpending() { return totalSpending; }
    public void setTotalSpending(float totalSpending) { this.totalSpending = totalSpending; }
    public Date getIssueDate() { return issueDate; }
    public void setIssueDate(Date issueDate) { this.issueDate = issueDate; }
    public String getCardStatus() { return cardStatus; }
    public void setCardStatus(String cardStatus) { this.cardStatus = cardStatus; }
}
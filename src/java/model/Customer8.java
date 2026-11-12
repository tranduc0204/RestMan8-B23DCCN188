package model;

import java.util.Date;

public class Customer8 {
    private int id;
    private String name;
    private String phoneNumber;
    private String email;
    private Date dateOfBirth;
    private String address;
    private MembershipCard8 membershipCard;

    public Customer8() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public Date getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public MembershipCard8 getMembershipCard() { return membershipCard; }
    public void setMembershipCard(MembershipCard8 membershipCard) { this.membershipCard = membershipCard; }
}
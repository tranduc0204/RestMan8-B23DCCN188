package model;

public class DishSize8 {
    private int id;
    private Dish8 dish;
    private Size8 size;
    private float unitPrice;
    private String servingStatus;

    public DishSize8() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Dish8 getDish() { return dish; }
    public void setDish(Dish8 dish) { this.dish = dish; }
    public Size8 getSize() { return size; }
    public void setSize(Size8 size) { this.size = size; }
    public float getUnitPrice() { return unitPrice; }
    public void setUnitPrice(float unitPrice) { this.unitPrice = unitPrice; }
    public String getServingStatus() { return servingStatus; }
    public void setServingStatus(String servingStatus) { this.servingStatus = servingStatus; }
}
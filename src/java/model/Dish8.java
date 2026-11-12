package model;

public class Dish8 {
    private int id;
    private DishCategory8 category;
    private String dishName;
    private String description;
    private String image;
    private String servingStatus;

    public Dish8() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public DishCategory8 getCategory() { return category; }
    public void setCategory(DishCategory8 category) { this.category = category; }
    public String getDishName() { return dishName; }
    public void setDishName(String dishName) { this.dishName = dishName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public String getServingStatus() { return servingStatus; }
    public void setServingStatus(String servingStatus) { this.servingStatus = servingStatus; }
}
package controller;

import dao.DishCategoryDAO8;
import dao.DishDAO8;
import dao.DishSizeDAO8;
import dao.SizeDAO8;
import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import model.Dish8;
import model.DishCategory8;
import model.DishSize8;
import model.Size8;

@WebServlet("/AddDishServlet8")
@MultipartConfig
public class AddDishServlet8 extends HttpServlet {

    private DishCategoryDAO8 categoryDAO = new DishCategoryDAO8();
    private SizeDAO8 sizeDAO = new SizeDAO8();
    private DishDAO8 dishDAO = new DishDAO8();
    private DishSizeDAO8 dishSizeDAO = new DishSizeDAO8();

    // GET: bấm link "Thêm món ăn" ở ManageDishView8.jsp
    // Lấy danh sách loại món ăn và kích cỡ rồi mở trang thêm món ăn
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect("LoginServlet8");
            return;
        }
        request.setAttribute("categoryList", categoryDAO.getCategoryList());
        request.setAttribute("sizeList", sizeDAO.getSizeList());
        request.getRequestDispatcher("/view/manager/AddDishView8.jsp").forward(request, response);
    }

    // POST: bấm nút "Thêm món ăn" ở AddDishView8.jsp
    // Kiểm tra thông tin -> lưu ảnh -> lưu món ăn -> lưu danh sách kích cỡ
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect("LoginServlet8");
            return;
        }

        String dishName = request.getParameter("dishName");
        String categoryId = request.getParameter("categoryId");
        String description = request.getParameter("description");
        String servingStatus = request.getParameter("servingStatus");
        String[] sizeIds = request.getParameterValues("sizeId");
        String[] unitPrices = request.getParameterValues("unitPrice");
        Part imagePart = request.getPart("image");

        boolean hasImage = imagePart != null && imagePart.getSize() > 0;

        // Kiểm tra thông tin: lỗi đầu tiên gặp phải được giữ lại trong error
        String error = null;
        if (dishName == null || dishName.trim().isEmpty() || !isPositiveInt(categoryId)) {
            // Ngoại lệ 8.1
            error = "Vui lòng nhập tên món ăn và chọn loại món ăn.";
        } else if (hasImage && !isValidImage(imagePart)) {
            // Ngoại lệ 5.1: chỉ kiểm tra khi có chọn ảnh
            error = "Hình ảnh không hợp lệ. Chỉ nhận file JPG hoặc PNG, tối đa 5 MB.";
        } else if (sizeIds == null || sizeIds.length == 0 || unitPrices == null || unitPrices.length != sizeIds.length) {
            // Ngoại lệ 8.3
            error = "Món ăn phải có ít nhất một kích cỡ kèm đơn giá.";
        }
        if (error == null) {
            Set<String> seen = new HashSet<>();
            for (int i = 0; i < sizeIds.length; i++) {
                if (!isPositiveInt(sizeIds[i]) || !seen.add(sizeIds[i])) {
                    error = "Mỗi kích cỡ chỉ được khai báo một lần.";
                    break;
                }
                if (!isPositiveInt(unitPrices[i])) {
                    error = "Đơn giá phải là số nguyên lớn hơn 0.";
                    break;
                }
            }
        }
        if (error == null && dishDAO.checkDishExists(dishName.trim())) {
            // Ngoại lệ 8.2
            error = "Tên món ăn đã tồn tại trong các món đang phục vụ.";
        }
        if (error != null) {
            request.setAttribute("errorMessage", error);
            doGet(request, response);
            return;
        }

        // Ghi file ảnh (nếu có). Nếu lưu CSDL thất bại thì xóa file này đi.
        File imageFile = null;
        if (hasImage) {
            String original = new File(imagePart.getSubmittedFileName()).getName();
            String fileName = System.currentTimeMillis() + "_" + original.replaceAll("[^a-zA-Z0-9._-]", "");
            String folder = getServletContext().getRealPath("/view/manager/images");
            new File(folder).mkdirs();
            imageFile = new File(folder, fileName);
            imagePart.write(imageFile.getAbsolutePath());
        }

        // Đóng gói thông tin món ăn mới
        DishCategory8 category = new DishCategory8();
        category.setId(Integer.parseInt(categoryId));

        Dish8 dish = new Dish8();
        dish.setDishName(dishName.trim());
        dish.setDescription(description == null || description.trim().isEmpty() ? null : description.trim());
        // Lưu đường dẫn tính từ gốc web, ví dụ "view/manager/images/1731400000000_garan.jpg"
        dish.setImage(imageFile == null ? null : "view/manager/images/" + imageFile.getName());
        dish.setServingStatus(servingStatus);
        dish.setCategory(category);

        // addDish() mở transaction, saveDishSizeList() commit hoặc rollback cả món ăn lẫn kích cỡ
        Dish8 savedDish = dishDAO.addDish(dish);
        if (savedDish == null) {
            deleteFile(imageFile);
            request.setAttribute("errorMessage", "Thêm món ăn không thành công.");
            doGet(request, response);
            return;
        }

        // Đóng gói danh sách kích cỡ trỏ về món vừa lưu
        DishSize8[] dishSizeList = new DishSize8[sizeIds.length];
        for (int i = 0; i < sizeIds.length; i++) {
            Size8 size = new Size8();
            size.setId(Integer.parseInt(sizeIds[i]));

            DishSize8 ds = new DishSize8();
            ds.setDish(savedDish);
            ds.setSize(size);
            ds.setUnitPrice(Float.parseFloat(unitPrices[i]));
            ds.setServingStatus(servingStatus);
            dishSizeList[i] = ds;
        }

        if (!dishSizeDAO.saveDishSizeList(dishSizeList)) {
            deleteFile(imageFile);
            request.setAttribute("errorMessage", "Thêm món ăn không thành công, chưa có dữ liệu nào được lưu.");
            doGet(request, response);
            return;
        }

        request.setAttribute("successMessage", "Thêm món ăn thành công");
        doGet(request, response);
    }

    private boolean isPositiveInt(String s) {
        return s != null && s.matches("\\d{1,9}") && Integer.parseInt(s) > 0;
    }

    // Chỉ nhận JPG/PNG, tối đa 5 MB
    private boolean isValidImage(Part part) {
        String type = part.getContentType();
        String name = part.getSubmittedFileName() == null ? "" : part.getSubmittedFileName().toLowerCase();
        boolean okType = "image/jpeg".equals(type) || "image/png".equals(type);
        boolean okName = name.endsWith(".jpg") || name.endsWith(".jpeg") || name.endsWith(".png");
        return okType && okName && part.getSize() <= 5L * 1024 * 1024;
    }

    private void deleteFile(File file) {
        if (file != null && file.exists()) {
            file.delete();
        }
    }
}
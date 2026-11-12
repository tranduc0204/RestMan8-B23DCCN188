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
        // Lưu vào session để doPost quay lại trang (khi lỗi hoặc thành công) không phải lấy lại danh sách
        session.setAttribute("categoryList", categoryDAO.getCategoryList());
        session.setAttribute("sizeList", sizeDAO.getSizeList());
        request.getRequestDispatcher("/view/manager/AddDishView8.jsp").forward(request, response);
    }

    // POST: bấm nút "Thêm món ăn" ở AddDishView8.jsp
    // Kiểm tra thông tin -> lưu món ăn -> lưu danh sách kích cỡ -> báo kết quả
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect("LoginServlet8");
            return;
        }
        String view = "/view/manager/AddDishView8.jsp";

        String dishName = request.getParameter("dishName");
        String categoryId = request.getParameter("categoryId");
        String description = request.getParameter("description");
        String servingStatus = request.getParameter("servingStatus");
        String[] sizeIds = request.getParameterValues("sizeId");
        String[] unitPrices = request.getParameterValues("unitPrice");
        Part imagePart = request.getPart("image");
        boolean hasImage = imagePart != null && imagePart.getSize() > 0;

        // ===== Kiểm tra thông tin (số nguyên dương: chữ số 1-9 đứng đầu, tối đa 9 chữ số) =====
        String error = null;
        if (dishName == null || dishName.trim().isEmpty()
                || categoryId == null || !categoryId.matches("[1-9]\\d{0,8}")) {
            // Ngoại lệ 8.1: trống tên món hoặc chưa chọn loại
            error = "Vui lòng nhập tên món ăn và chọn loại món ăn.";
        } else if (hasImage) {
            // Ngoại lệ 5.1: chỉ kiểm tra khi có chọn ảnh — chỉ nhận JPG/PNG, tối đa 5 MB
            String type = imagePart.getContentType();
            String fileName = imagePart.getSubmittedFileName() == null ? "" : imagePart.getSubmittedFileName().toLowerCase();
            boolean dungKieu = "image/jpeg".equals(type) || "image/png".equals(type);
            boolean dungDuoi = fileName.endsWith(".jpg") || fileName.endsWith(".jpeg") || fileName.endsWith(".png");
            if (!dungKieu || !dungDuoi || imagePart.getSize() > 5L * 1024 * 1024) {
                error = "Hình ảnh không hợp lệ. Chỉ nhận file JPG hoặc PNG, tối đa 5 MB.";
            }
        }
        if (error == null && (sizeIds == null || sizeIds.length == 0
                || unitPrices == null || unitPrices.length != sizeIds.length)) {
            // Ngoại lệ 8.3: chưa có kích cỡ nào
            error = "Món ăn phải có ít nhất một kích cỡ kèm đơn giá.";
        }
        if (error == null) {
            Set<String> daCo = new HashSet<>();
            for (int i = 0; i < sizeIds.length; i++) {
                if (sizeIds[i] == null || !sizeIds[i].matches("[1-9]\\d{0,8}") || !daCo.add(sizeIds[i])) {
                    error = "Mỗi kích cỡ chỉ được khai báo một lần.";
                    break;
                }
                if (unitPrices[i] == null || !unitPrices[i].matches("[1-9]\\d{0,8}")) {
                    error = "Đơn giá phải là số nguyên lớn hơn 0.";
                    break;
                }
            }
        }
        if (error == null && dishDAO.checkDishExists(dishName.trim())) {
            // Ngoại lệ 8.2: trùng tên món đang phục vụ
            error = "Tên món ăn đã tồn tại trong các món đang phục vụ.";
        }
        if (error != null) {
            request.setAttribute("errorMessage", error);
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===== Ghi file ảnh (nếu có). Lưu CSDL thất bại thì xóa file này đi =====
        File imageFile = null;
        if (hasImage) {
            String original = new File(imagePart.getSubmittedFileName()).getName();
            String fileName = System.currentTimeMillis() + "_" + original.replaceAll("[^a-zA-Z0-9._-]", "");
            String folder = getServletContext().getRealPath("/view/manager/images");
            new File(folder).mkdirs();
            imageFile = new File(folder, fileName);
            imagePart.write(imageFile.getAbsolutePath());
        }

        // ===== Đóng gói thông tin món ăn mới =====
        DishCategory8 category = new DishCategory8();
        category.setId(Integer.parseInt(categoryId));

        Dish8 dish = new Dish8();
        dish.setDishName(dishName.trim());
        dish.setDescription(description == null || description.trim().isEmpty() ? null : description.trim());
        // Lưu đường dẫn tính từ gốc web, ví dụ "view/manager/images/1731400000000_garan.jpg"
        dish.setImage(imageFile == null ? null : "view/manager/images/" + imageFile.getName());
        dish.setServingStatus(servingStatus);
        dish.setCategory(category);

        // ===== Lưu món ăn: addDish() mở transaction, saveDishSizeList() commit hoặc rollback =====
        Dish8 savedDish = dishDAO.addDish(dish);
        if (savedDish == null) {
            if (imageFile != null) {
                imageFile.delete();
            }
            request.setAttribute("errorMessage", "Thêm món ăn không thành công.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===== Đóng gói danh sách kích cỡ trỏ về món vừa lưu =====
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

        // ===== Lưu kích cỡ của món =====
        if (!dishSizeDAO.saveDishSizeList(dishSizeList)) {
            if (imageFile != null) {
                imageFile.delete();
            }
            request.setAttribute("errorMessage", "Thêm món ăn không thành công, chưa có dữ liệu nào được lưu.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===== Thành công: quay về trang kèm thông báo =====
        request.setAttribute("successMessage", "Thêm món ăn thành công");
        request.getRequestDispatcher(view).forward(request, response);
    }
}

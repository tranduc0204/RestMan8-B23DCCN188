package controller;

import dao.CustomerDAO8;
import java.io.IOException;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Customer8;

@WebServlet("/AddCustomerServlet8")
public class AddCustomerServlet8 extends HttpServlet {

    private CustomerDAO8 customerDAO = new CustomerDAO8();

    // GET: bấm "Thêm khách hàng mới" cạnh nút tìm khách hàng (ngoại lệ 7.3) -> mở form thêm khách
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getSession().getAttribute("table") == null) {
            response.sendRedirect("SearchTableServlet8");
            return;
        }
        request.getRequestDispatcher("/view/customer/AddCustomerView8.jsp").forward(request, response);
    }

    // POST: bấm nút "Thêm khách hàng" -> kiểm tra -> lưu khách hàng -> quay lại trang đặt bàn
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        if (session.getAttribute("table") == null) {
            response.sendRedirect("SearchTableServlet8");
            return;
        }
        String view = "/view/customer/AddCustomerView8.jsp";

        String name = request.getParameter("name");
        String phoneNumber = request.getParameter("phoneNumber");
        String email = request.getParameter("email");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String address = request.getParameter("address");

        // ===== Kiểm tra thông tin =====
        if (name == null || name.trim().isEmpty() || phoneNumber == null || phoneNumber.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập họ tên và số điện thoại.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }
        if (!phoneNumber.trim().matches("0\\d{9}")) {
            request.setAttribute("errorMessage", "Số điện thoại không đúng định dạng (10 chữ số, bắt đầu bằng 0).");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===== Đóng gói thông tin khách hàng mới (ô bỏ trống thì lưu NULL) =====
        Customer8 customer = new Customer8();
        customer.setName(name.trim());
        customer.setPhoneNumber(phoneNumber.trim());
        customer.setEmail(email == null || email.trim().isEmpty() ? null : email.trim());
        customer.setAddress(address == null || address.trim().isEmpty() ? null : address.trim());
        if (dateOfBirth != null && !dateOfBirth.trim().isEmpty()) {
            try {
                customer.setDateOfBirth(new SimpleDateFormat("yyyy-MM-dd").parse(dateOfBirth));
            } catch (Exception e) {
                request.setAttribute("errorMessage", "Ngày sinh không hợp lệ.");
                request.getRequestDispatcher(view).forward(request, response);
                return;
            }
        }

        // ===== Lưu khách hàng =====
        // Cột phoneNumber trong CSDL là UNIQUE nên số điện thoại đã có người dùng
        // thì addCustomer() trả về null -> nhánh [lưu lỗi] (ngoại lệ 7.3.1)
        Customer8 saved = customerDAO.addCustomer(customer);
        if (saved == null) {
            request.setAttribute("errorMessage", "Thêm khách hàng không thành công: số điện thoại này đã được đăng kí cho một khách hàng khác.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===== Lưu xong: quay lại trang đặt bàn với khách hàng vừa thêm =====
        session.setAttribute("customer", saved);
        response.sendRedirect("BookTableServlet8");
    }
}

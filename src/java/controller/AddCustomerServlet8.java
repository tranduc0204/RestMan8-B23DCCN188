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

    // GET: bấm nút "Thêm khách hàng mới" cạnh nút tìm khách hàng (ngoại lệ 7.3)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getSession().getAttribute("table") == null) {
            response.sendRedirect("SearchTableServlet8");
            return;
        }
        request.getRequestDispatcher("/view/customer/AddCustomerView8.jsp").forward(request, response);
    }

    // POST: bấm nút "Thêm khách hàng"
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        if (session.getAttribute("table") == null) {
            response.sendRedirect("SearchTableServlet8");
            return;
        }

        String name = request.getParameter("name");
        String phoneNumber = request.getParameter("phoneNumber");
        String email = request.getParameter("email");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String address = request.getParameter("address");

        if (name == null || name.trim().isEmpty() || phoneNumber == null || phoneNumber.trim().isEmpty()) {
            backWithError(request, response, "Vui lòng nhập họ tên và số điện thoại.");
            return;
        }
        if (!phoneNumber.trim().matches("0\\d{9}")) {
            backWithError(request, response, "Số điện thoại không đúng định dạng (10 chữ số, bắt đầu bằng 0).");
            return;
        }
        // Ngoại lệ 7.3.1: số điện thoại đã có khách hàng dùng
        if (customerDAO.getCustomerByPhone(phoneNumber.trim()) != null) {
            backWithError(request, response, "Số điện thoại này đã được đăng kí cho một khách hàng khác.");
            return;
        }

        // Đóng gói thông tin khách hàng mới
        Customer8 customer = new Customer8();
        customer.setName(name.trim());
        customer.setPhoneNumber(phoneNumber.trim());
        customer.setEmail(isBlank(email) ? null : email.trim());
        customer.setAddress(isBlank(address) ? null : address.trim());
        if (!isBlank(dateOfBirth)) {
            try {
                customer.setDateOfBirth(new SimpleDateFormat("yyyy-MM-dd").parse(dateOfBirth));
            } catch (Exception e) {
                backWithError(request, response, "Ngày sinh không hợp lệ.");
                return;
            }
        }

        Customer8 saved = customerDAO.addCustomer(customer);
        if (saved == null) {
            backWithError(request, response, "Thêm khách hàng không thành công, vui lòng thử lại.");
            return;
        }

        // Quay lại trang đặt bàn với khách hàng vừa thêm
        session.setAttribute("customer", saved);
        response.sendRedirect("BookTableServlet8");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private void backWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/view/customer/AddCustomerView8.jsp").forward(request, response);
    }
}
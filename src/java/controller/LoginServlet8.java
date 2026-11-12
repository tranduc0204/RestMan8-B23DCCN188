package controller;

import dao.EmployeeDAO8;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Employee8;

// Servlet hỗ trợ đăng nhập để chạy thử, nằm ngoài hai module của đề
@WebServlet("/LoginServlet8")
public class LoginServlet8 extends HttpServlet {

    private EmployeeDAO8 employeeDAO = new EmployeeDAO8();

    // GET: mở trang đăng nhập, bỏ phiên cũ để mỗi lần vào là bắt đầu sạch
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();   // vào trang đăng nhập là bỏ phiên cũ
        }
        request.getRequestDispatcher("/view/employee/login.jsp").forward(request, response);
    }

    // POST: bấm nút Đăng nhập
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Employee8 employee = employeeDAO.checkLogin(username, password);
        if (employee == null) {
            request.setAttribute("errorMessage", "Sai tên đăng nhập hoặc mật khẩu.");
            request.getRequestDispatcher("/view/employee/login.jsp").forward(request, response);
            return;
        }
        if (!"Quản lí nhà hàng".equals(employee.getCurrentRoleName())) {
            request.setAttribute("errorMessage", "Tài khoản này không có quyền quản lí món ăn.");
            request.getRequestDispatcher("/view/employee/login.jsp").forward(request, response);
            return;
        }
        request.getSession().setAttribute("employee", employee);
        response.sendRedirect(request.getContextPath() + "/view/manager/ManagerHomeView8.jsp");
    }
}
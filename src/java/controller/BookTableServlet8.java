package controller;

import dao.CustomerDAO8;
import dao.ReservationDAO8;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Customer8;
import model.Reservation8;
import model.Table8;
import model.TimeSlot8;

@WebServlet("/BookTableServlet8")
public class BookTableServlet8 extends HttpServlet {

    private CustomerDAO8 customerDAO = new CustomerDAO8();
    private ReservationDAO8 reservationDAO = new ReservationDAO8();

    // GET: bấm "Chọn" một bàn ở SearchTableView8.jsp, hoặc quay về sau khi thêm khách hàng
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String tableId = request.getParameter("tableId");

        if (tableId != null) {
            Table8 table = findTable((Table8[]) session.getAttribute("tableList"), Integer.parseInt(tableId));
            if (table == null) {
                response.sendRedirect("SearchTableServlet8");
                return;
            }
            session.setAttribute("table", table);
            session.setAttribute("reservationDate", session.getAttribute("searchDate"));
            session.setAttribute("timeSlot", session.getAttribute("searchTimeSlot"));
            session.removeAttribute("customer");
        }

        if (session.getAttribute("table") == null) {
            response.sendRedirect("SearchTableServlet8");
            return;
        }
        request.getRequestDispatcher("/view/customer/BookTableView8.jsp").forward(request, response);
    }

    // POST: hai nút submit, phân biệt bằng tham số action
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        if (session.getAttribute("table") == null) {
            response.sendRedirect("SearchTableServlet8");
            return;
        }

        if ("searchCustomer".equals(request.getParameter("action"))) {
            searchCustomer(request, response);
        } else {
            confirmReservation(request, response);
        }
    }

    // Nút "Tìm khách hàng"
    private void searchCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String phoneNumber = request.getParameter("phoneNumber");

        // Ngoại lệ 7.1: để trống số điện thoại
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            backWithError(request, response, "Vui lòng nhập số điện thoại.");
            return;
        }
        phoneNumber = phoneNumber.trim();
        // Ngoại lệ 7.2: sai định dạng
        if (!phoneNumber.matches("0\\d{9}")) {
            request.setAttribute("clearPhone", true);
            backWithError(request, response, "Số điện thoại không đúng định dạng (10 chữ số, bắt đầu bằng 0).");
            return;
        }

        Customer8 customer = customerDAO.getCustomerByPhone(phoneNumber);
        if (customer == null) {
            // Ngoại lệ 8.1: hiện thông báo không tìm thấy khách hàng, chỉ có nút OK
            request.getSession().removeAttribute("customer");
            request.setAttribute("notFoundPhone", phoneNumber);
        } else {
            request.getSession().setAttribute("customer", customer);
        }
        request.getRequestDispatcher("/view/customer/BookTableView8.jsp").forward(request, response);
    }

    // Nút "Xác nhận đặt bàn"
    private void confirmReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Table8 table = (Table8) session.getAttribute("table");
        TimeSlot8 timeSlot = (TimeSlot8) session.getAttribute("timeSlot");
        Date reservationDate = (Date) session.getAttribute("reservationDate");
        Customer8 customer = (Customer8) session.getAttribute("customer");

        if (customer == null) {
            backWithError(request, response, "Vui lòng tìm khách hàng theo số điện thoại trước khi xác nhận.");
            return;
        }

        // Ngoại lệ 9.1: bàn vừa bị khách khác đặt
        if (!reservationDAO.checkTableAvailable(table.getId(), reservationDate, timeSlot.getId())) {
            session.setAttribute("flashMessage", "Bàn " + table.getTableNumber()
                    + " vừa được khách hàng khác đặt. Vui lòng chọn bàn khác.");
            String date = new SimpleDateFormat("yyyy-MM-dd").format(reservationDate);
            response.sendRedirect("SearchTableServlet8?reservationDate=" + date + "&timeSlotId=" + timeSlot.getId());
            return;
        }

        // Đóng gói phiếu đặt bàn rồi lưu
        Reservation8 reservation = new Reservation8();
        reservation.setTable(table);
        reservation.setTimeSlot(timeSlot);
        reservation.setCustomer(customer);
        reservation.setReservationDate(reservationDate);
        reservation.setNote(request.getParameter("note"));

        Reservation8 saved = reservationDAO.saveReservation(reservation);
        if (saved == null) {
            backWithError(request, response, "Đặt bàn không thành công, vui lòng thử lại.");
            return;
        }

        request.setAttribute("savedReservation", saved);
        session.removeAttribute("table");
        session.removeAttribute("customer");
        session.removeAttribute("tableList");
        request.getRequestDispatcher("/view/customer/BookTableView8.jsp").forward(request, response);
    }

    private Table8 findTable(Table8[] list, int id) {
        if (list == null) {
            return null;
        }
        for (Table8 t : list) {
            if (t.getId() == id) {
                return t;
            }
        }
        return null;
    }

    private void backWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/view/customer/BookTableView8.jsp").forward(request, response);
    }
}
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

    // GET: bấm "Chọn" một bàn ở SearchTableView8.jsp, hoặc quay về sau khi thêm khách hàng mới
    // Ghi nhớ bàn, ngày, khung giờ đã chọn rồi mở trang đặt bàn
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String tableId = request.getParameter("tableId");

        if (tableId != null) {
            // Tìm bàn đã chọn trong danh sách bàn trống vừa tìm được
            Table8[] tableList = (Table8[]) session.getAttribute("tableList");
            Table8 table = null;
            if (tableList != null) {
                for (Table8 t : tableList) {
                    if (String.valueOf(t.getId()).equals(tableId)) {
                        table = t;
                    }
                }
            }
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

    // POST: trang có 2 nút gửi form, phân biệt bằng tham số action
    //   action=searchCustomer : nút "Tìm khách hàng"
    //   action=confirm        : nút "Xác nhận đặt bàn"
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        if (session.getAttribute("table") == null) {
            response.sendRedirect("SearchTableServlet8");
            return;
        }
        String view = "/view/customer/BookTableView8.jsp";

        // ===================== Nút "Tìm khách hàng" =====================
        if ("searchCustomer".equals(request.getParameter("action"))) {
            String phoneNumber = request.getParameter("phoneNumber");

            // Ngoại lệ 7.1: để trống số điện thoại
            if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập số điện thoại.");
                request.getRequestDispatcher(view).forward(request, response);
                return;
            }
            phoneNumber = phoneNumber.trim();
            // Ngoại lệ 7.2: sai định dạng (10 chữ số, bắt đầu bằng 0) -> xóa trống ô số điện thoại
            if (!phoneNumber.matches("0\\d{9}")) {
                request.setAttribute("clearPhone", true);
                request.setAttribute("errorMessage", "Số điện thoại không đúng định dạng (10 chữ số, bắt đầu bằng 0).");
                request.getRequestDispatcher(view).forward(request, response);
                return;
            }

            Customer8 customer = customerDAO.getCustomerByPhone(phoneNumber);
            if (customer == null) {
                // Ngoại lệ 8.1: không tìm thấy khách hàng, hiện thông báo chỉ có nút OK
                session.removeAttribute("customer");
                request.setAttribute("notFoundPhone", phoneNumber);
            } else {
                session.setAttribute("customer", customer);
            }
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===================== Nút "Xác nhận đặt bàn" =====================
        Table8 table = (Table8) session.getAttribute("table");
        TimeSlot8 timeSlot = (TimeSlot8) session.getAttribute("timeSlot");
        Date reservationDate = (Date) session.getAttribute("reservationDate");
        Customer8 customer = (Customer8) session.getAttribute("customer");

        // Ngoại lệ 9.3: chưa xác định khách hàng
        if (customer == null) {
            request.setAttribute("errorMessage", "Vui lòng tìm khách hàng theo số điện thoại trước khi xác nhận.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // Ngoại lệ 9.1: bàn vừa bị khách khác đặt -> quay về trang tìm bàn với danh sách cập nhật
        if (!reservationDAO.checkTableAvailable(table.getId(), reservationDate, timeSlot.getId())) {
            session.setAttribute("flashMessage", "Bàn " + table.getTableNumber()
                    + " vừa được khách hàng khác đặt. Vui lòng chọn bàn khác.");
            String date = new SimpleDateFormat("yyyy-MM-dd").format(reservationDate);
            response.sendRedirect("SearchTableServlet8?reservationDate=" + date + "&timeSlotId=" + timeSlot.getId());
            return;
        }

        // Đóng gói phiếu đặt bàn mới
        Reservation8 reservation = new Reservation8();
        reservation.setTable(table);
        reservation.setTimeSlot(timeSlot);
        reservation.setCustomer(customer);
        reservation.setReservationDate(reservationDate);
        reservation.setNote(request.getParameter("note"));

        // Lưu phiếu đặt bàn
        Reservation8 saved = reservationDAO.saveReservation(reservation);
        if (saved == null) {
            request.setAttribute("errorMessage", "Đặt bàn không thành công, vui lòng thử lại.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // Thành công: báo kèm mã phiếu, xóa thông tin đặt bàn trong phiên
        request.setAttribute("savedReservation", saved);
        session.removeAttribute("table");
        session.removeAttribute("customer");
        session.removeAttribute("tableList");
        request.getRequestDispatcher(view).forward(request, response);
    }
}

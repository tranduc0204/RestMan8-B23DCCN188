package controller;

import dao.TableDAO8;
import dao.TimeSlotDAO8;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Table8;
import model.TimeSlot8;

@WebServlet("/SearchTableServlet8")
public class SearchTableServlet8 extends HttpServlet {

    private TimeSlotDAO8 timeSlotDAO = new TimeSlotDAO8();
    private TableDAO8 tableDAO = new TableDAO8();


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        session.setAttribute("timeSlotList", timeSlotDAO.getTimeSlotList());

        // Ngoại lệ 9.1: BookTableServlet8 chuyển về kèm ngày và khung giờ (bàn vừa bị người khác đặt)
        // -> lấy lại danh sách bàn trống bằng doPost
        if (request.getParameter("reservationDate") != null && request.getParameter("timeSlotId") != null) {
            doPost(request, response);
            return;
        }
        session.removeAttribute("tableList");
        request.getRequestDispatcher("/view/customer/SearchTableView8.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        TimeSlot8[] timeSlotList = (TimeSlot8[]) session.getAttribute("timeSlotList");
        if (timeSlotList == null) {
            // Phiên làm việc đã hết hạn: mở lại trang tìm bàn từ đầu
            response.sendRedirect("SearchTableServlet8");
            return;
        }
        String view = "/view/customer/SearchTableView8.jsp";
        String dateText = request.getParameter("reservationDate");
        String timeSlotId = request.getParameter("timeSlotId");

        // ===== Ngoại lệ 3.1: chưa chọn đủ ngày và khung giờ =====
        if (dateText == null || dateText.isEmpty() || timeSlotId == null || timeSlotId.isEmpty()) {
            session.removeAttribute("tableList");
            request.setAttribute("errorMessage", "Vui lòng chọn đầy đủ ngày sử dụng và khung giờ.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===== Đọc ngày dạng yyyy-MM-dd =====
        Date reservationDate;
        try {
            SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd");
            f.setLenient(false);
            reservationDate = f.parse(dateText);
        } catch (Exception e) {
            session.removeAttribute("tableList");
            request.setAttribute("errorMessage", "Ngày sử dụng không hợp lệ.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===== Tìm khung giờ đã chọn trong danh sách khung giờ =====
        TimeSlot8 timeSlot = null;
        for (TimeSlot8 t : timeSlotList) {
            if (String.valueOf(t.getId()).equals(timeSlotId)) {
                timeSlot = t;
            }
        }
        if (timeSlot == null) {
            session.removeAttribute("tableList");
            request.setAttribute("errorMessage", "Khung giờ không hợp lệ.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===== Ngoại lệ 3.2: ghép ngày đã chọn với giờ bắt đầu của khung giờ, so với hiện tại =====
        Calendar batDau = Calendar.getInstance();
        batDau.setTime(reservationDate);
        Calendar gio = Calendar.getInstance();
        gio.setTime(timeSlot.getStartTime());
        batDau.set(Calendar.HOUR_OF_DAY, gio.get(Calendar.HOUR_OF_DAY));
        batDau.set(Calendar.MINUTE, gio.get(Calendar.MINUTE));
        batDau.set(Calendar.SECOND, 0);
        if (!batDau.getTime().after(new Date())) {
            session.removeAttribute("tableList");
            request.setAttribute("errorMessage", "Chỉ được đặt bàn cho các khung giờ chưa bắt đầu.");
            request.getRequestDispatcher(view).forward(request, response);
            return;
        }

        // ===== Lấy danh sách bàn còn trống =====
        Table8[] tableList = tableDAO.getAvailableTableList(reservationDate, timeSlot.getId());
        session.setAttribute("searchDate", reservationDate);
        session.setAttribute("searchTimeSlot", timeSlot);
        session.setAttribute("tableList", tableList);

        // Ngoại lệ 4.1: không còn bàn trống
        if (tableList.length == 0) {
            request.setAttribute("errorMessage", "Không còn bàn trống trong khung giờ đã chọn. "
                    + "Vui lòng chọn ngày hoặc khung giờ khác.");
        }
        request.getRequestDispatcher(view).forward(request, response);
    }
}

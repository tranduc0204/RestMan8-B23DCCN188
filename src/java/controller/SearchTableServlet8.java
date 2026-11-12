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

    // GET: bấm "Đặt bàn trực tuyến" ở trang chủ, hoặc được chuyển về sau khi bàn bị người khác đặt
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        session.setAttribute("timeSlotList", timeSlotDAO.getTimeSlotList());

        // Được chuyển về kèm ngày và khung giờ thì tìm lại luôn
        if (request.getParameter("reservationDate") != null && request.getParameter("timeSlotId") != null) {
            searchTable(request, response);
            return;
        }
        session.removeAttribute("tableList");
        request.getRequestDispatcher("/view/customer/SearchTableView8.jsp").forward(request, response);
    }

    // POST: bấm nút "Tìm bàn trống"
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        if (session.getAttribute("timeSlotList") == null) {
            session.setAttribute("timeSlotList", timeSlotDAO.getTimeSlotList());
        }
        searchTable(request, response);
    }

    // Kiểm tra ngày và khung giờ, rồi tìm các bàn còn trống
    private void searchTable(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String dateText = request.getParameter("reservationDate");
        String timeSlotId = request.getParameter("timeSlotId");

        // Ngoại lệ 3.1: chưa chọn đủ ngày và khung giờ
        if (dateText == null || dateText.isEmpty() || timeSlotId == null || timeSlotId.isEmpty()) {
            backWithError(request, response, "Vui lòng chọn đầy đủ ngày sử dụng và khung giờ.");
            return;
        }

        Date reservationDate;
        try {
            SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd");
            f.setLenient(false);
            reservationDate = f.parse(dateText);
        } catch (Exception e) {
            backWithError(request, response, "Ngày sử dụng không hợp lệ.");
            return;
        }

        TimeSlot8 timeSlot = findTimeSlot((TimeSlot8[]) session.getAttribute("timeSlotList"),
                Integer.parseInt(timeSlotId));
        if (timeSlot == null) {
            backWithError(request, response, "Khung giờ không hợp lệ.");
            return;
        }

        // Ngoại lệ 3.2: ngày trong quá khứ, hoặc khung giờ đã bắt đầu trong hôm nay
        if (isPast(reservationDate, timeSlot)) {
            backWithError(request, response, "Chỉ được đặt bàn cho các khung giờ chưa bắt đầu.");
            return;
        }

        Table8[] tableList = tableDAO.getAvailableTableList(reservationDate, timeSlot.getId());
        session.setAttribute("searchDate", reservationDate);
        session.setAttribute("searchTimeSlot", timeSlot);
        session.setAttribute("tableList", tableList);

        // Ngoại lệ 4.1: không còn bàn trống
        if (tableList.length == 0) {
            request.setAttribute("errorMessage", "Không còn bàn trống trong khung giờ đã chọn. "
                    + "Vui lòng chọn ngày hoặc khung giờ khác.");
        }
        request.getRequestDispatcher("/view/customer/SearchTableView8.jsp").forward(request, response);
    }

    private TimeSlot8 findTimeSlot(TimeSlot8[] list, int id) {
        if (list == null) {
            return null;
        }
        for (TimeSlot8 t : list) {
            if (t.getId() == id) {
                return t;
            }
        }
        return null;
    }

    // Ghép ngày đã chọn với giờ bắt đầu của khung giờ rồi so với thời điểm hiện tại
    private boolean isPast(Date date, TimeSlot8 timeSlot) {
        Calendar start = Calendar.getInstance();
        start.setTime(date);
        Calendar time = Calendar.getInstance();
        time.setTime(timeSlot.getStartTime());
        start.set(Calendar.HOUR_OF_DAY, time.get(Calendar.HOUR_OF_DAY));
        start.set(Calendar.MINUTE, time.get(Calendar.MINUTE));
        start.set(Calendar.SECOND, 0);
        return !start.getTime().after(new Date());
    }

    private void backWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.getSession().removeAttribute("tableList");
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/view/customer/SearchTableView8.jsp").forward(request, response);
    }
}
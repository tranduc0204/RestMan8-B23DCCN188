<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.Table8, model.TimeSlot8, model.Customer8, model.Reservation8, java.util.Date, java.text.SimpleDateFormat"%>
<%! private String h(Object o){ if(o==null) return ""; return o.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); } %>
<%
    // Đặt bàn thành công thì servlet đã xóa bàn khỏi session, lấy lại thông tin từ phiếu vừa lưu
    Reservation8 saved = (Reservation8) request.getAttribute("savedReservation");
    Table8 table = saved != null ? saved.getTable() : (Table8) session.getAttribute("table");
    TimeSlot8 timeSlot = saved != null ? saved.getTimeSlot() : (TimeSlot8) session.getAttribute("timeSlot");
    Date reservationDate = saved != null ? saved.getReservationDate() : (Date) session.getAttribute("reservationDate");
    Customer8 customer = saved != null ? saved.getCustomer() : (Customer8) session.getAttribute("customer");
    // Chưa chọn bàn thì quay về trang tìm bàn
    if (table == null) { response.sendRedirect(request.getContextPath() + "/SearchTableServlet8"); return; }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String notFoundPhone = (String) request.getAttribute("notFoundPhone");
    SimpleDateFormat dmy = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat hm = new SimpleDateFormat("HH:mm");

    // Số điện thoại: sai định dạng thì xóa (7.2), còn lại giữ số vừa nhập hoặc số của khách đã tìm thấy
    String vPhone = request.getParameter("phoneNumber");
    if (request.getAttribute("clearPhone") != null) vPhone = "";
    else if (vPhone == null && customer != null) vPhone = customer.getPhoneNumber();
    String vNote = saved == null && request.getParameter("note") != null ? request.getParameter("note") : "";

    // Nội dung popup thông báo lỗi (nếu servlet gửi sang)
    String tieuDeThongBao = "Thông báo";
    String noiDungThongBao = errorMessage;
    if (notFoundPhone != null) {
        // Ngoại lệ 8.1: không tìm thấy khách hàng
        tieuDeThongBao = "Không tìm thấy khách hàng";
        noiDungThongBao = "Chưa có khách hàng nào dùng số điện thoại " + notFoundPhone + ".";
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Đặt bàn trực tuyến – RestMan</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap">
<link rel="stylesheet" href="${pageContext.request.contextPath}/view/customer/customer.css?v=1">
</head>
<body>
<header class="thanh-tren">
  <div class="thanh-tren-ben-trong">
    <a class="logo" href="${pageContext.request.contextPath}/index.jsp"><div class="logo-bieu-tuong">R</div><div class="logo-ten">RestMan</div></a>
  </div>
</header>
<main class="trang">
  <h1>Đặt bàn trực tuyến</h1>

  <section class="khung">
    <h2>Thông tin giữ chỗ</h2>
    <div class="khung-bang">
      <table>
        <thead><tr><th>Ngày sử dụng</th><th>Khung giờ</th><th>Bàn</th><th>Sức chứa</th><th>Vị trí</th></tr></thead>
        <tbody>
          <tr>
            <td><%= reservationDate != null ? dmy.format(reservationDate) : "" %></td>
            <td><%= timeSlot != null ? hm.format(timeSlot.getStartTime()) + " – " + hm.format(timeSlot.getEndTime()) : "" %></td>
            <td><%= h(table.getTableNumber()) %></td>
            <td><%= table.getCapacity() %> người</td>
            <td><%= h(table.getLocation()) %></td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <form class="khung" method="post" action="${pageContext.request.contextPath}/BookTableServlet8">
    <h2>Thông tin khách hàng</h2>
    <div class="hang">
      <div class="o-nhap">
        <label for="phoneNumber">Số điện thoại</label>
        <input id="phoneNumber" type="tel" name="phoneNumber" value="<%= h(vPhone) %>" maxlength="10" placeholder="Ví dụ 0912345678">
      </div>
      <button class="nut nut-chinh" type="submit" name="action" value="searchCustomer" id="btnSearchCustomer">Tìm khách hàng</button>
      <a class="nut nut-vien" href="${pageContext.request.contextPath}/AddCustomerServlet8">Thêm khách hàng mới</a>
    </div>

    <div class="hang">
      <div class="o-nhap">
        <label for="customerId">Mã khách hàng</label>
        <input id="customerId" type="text" value="<%= customer != null ? String.valueOf(customer.getId()) : "" %>" readonly tabindex="-1">
      </div>
      <div class="o-nhap">
        <label for="customerName">Họ và tên</label>
        <input id="customerName" type="text" value="<%= customer != null ? h(customer.getName()) : "" %>" readonly tabindex="-1">
      </div>
    </div>
    <div class="hang">
      <div class="o-nhap">
        <label for="customerEmail">Email</label>
        <input id="customerEmail" type="text" value="<%= customer != null ? h(customer.getEmail()) : "" %>" readonly tabindex="-1">
      </div>
      <div class="o-nhap">
        <label for="customerDob">Ngày sinh</label>
        <input id="customerDob" type="text" value="<%= customer != null && customer.getDateOfBirth() != null ? dmy.format(customer.getDateOfBirth()) : "" %>" readonly tabindex="-1">
      </div>
    </div>
    <div class="o-nhap">
      <label for="customerAddress">Địa chỉ</label>
      <input id="customerAddress" type="text" value="<%= customer != null ? h(customer.getAddress()) : "" %>" readonly tabindex="-1">
    </div>

    <div class="o-nhap">
      <label for="note">Ghi chú</label>
      <textarea id="note" name="note" rows="3" maxlength="255"><%= h(vNote) %></textarea>
    </div>

    <div class="nhom-nut nhom-nut-giua">
      <a class="nut" href="${pageContext.request.contextPath}/view/customer/CustomerHomeView8.jsp">Hủy</a>
      <button class="nut nut-chinh" type="submit" name="action" value="confirm" id="btnConfirm">Xác nhận đặt bàn</button>
    </div>
  </form>
</main>

<%-- Popup thông báo lỗi: hiện ngay nếu BookTableServlet8 gửi lỗi sang, nếu không thì ẩn chờ JavaScript dùng --%>
<div class="lop-phu" id="hopThongBao" role="alertdialog" aria-modal="true" aria-labelledby="tieuDeThongBao" <%= noiDungThongBao == null ? "hidden" : "" %>>
  <div class="hop-thoai">
    <div class="bieu-tuong-canh-bao" aria-hidden="true">!</div>
    <h2 id="tieuDeThongBao"><%= h(tieuDeThongBao) %></h2>
    <p id="noiDungThongBao"><%= h(noiDungThongBao) %></p>
    <div class="hop-thoai-nut"><button class="nut nut-chinh" type="button" id="nutOk">OK</button></div>
  </div>
</div>

<%-- Popup đặt bàn thành công: bấm OK về trang chủ khách hàng --%>
<% if (saved != null) { %>
<div class="lop-phu" role="alertdialog" aria-modal="true" aria-labelledby="tieuDeThanhCong">
  <div class="hop-thoai">
    <div class="bieu-tuong-thanh-cong" aria-hidden="true">✓</div>
    <h2 id="tieuDeThanhCong">Đặt bàn thành công</h2>
    <p>Mã phiếu đặt bàn của bạn là <strong><%= saved.getId() %></strong>.</p>
    <div class="hop-thoai-nut"><a class="nut nut-chinh" href="${pageContext.request.contextPath}/view/customer/CustomerHomeView8.jsp" autofocus>OK</a></div>
  </div>
</div>
<% } %>

<script>
  var hopThongBao = document.getElementById('hopThongBao');
  var nutOk = document.getElementById('nutOk');
  var oCanChon = null;

  // ===== Popup thông báo: hiện nội dung lỗi; bấm OK thì đóng và đưa con trỏ về ô bị lỗi =====
  function hienThongBao(noiDung, oNhap) {
    document.getElementById('tieuDeThongBao').textContent = 'Thông báo';
    document.getElementById('noiDungThongBao').textContent = noiDung;
    oCanChon = oNhap || null;
    hopThongBao.hidden = false;
    nutOk.focus();
  }
  nutOk.addEventListener('click', function () {
    hopThongBao.hidden = true;
    if (oCanChon) oCanChon.focus();
  });
  if (!hopThongBao.hidden) nutOk.focus();

  var oSoDienThoai = document.getElementById('phoneNumber');

  // ===== Nút "Tìm khách hàng": kiểm tra số điện thoại trước khi gửi =====
  // (Nhấn Enter trong ô số điện thoại cũng chạy vào đây vì đây là nút gửi đầu tiên của form)
  document.getElementById('btnSearchCustomer').addEventListener('click', function (e) {
    var so = oSoDienThoai.value.trim();
    // Ngoại lệ 7.1: để trống số điện thoại
    if (so === '') { e.preventDefault(); hienThongBao('Vui lòng nhập số điện thoại.', oSoDienThoai); return; }
    // Ngoại lệ 7.2: sai định dạng (10 chữ số, bắt đầu bằng 0) thì xóa trống ô
    if (!/^0\d{9}$/.test(so)) {
      e.preventDefault();
      oSoDienThoai.value = '';
      hienThongBao('Số điện thoại không đúng định dạng (10 chữ số, bắt đầu bằng 0).', oSoDienThoai);
    }
  });

  // ===== Nút "Xác nhận đặt bàn": phải xác định khách hàng trước =====
  document.getElementById('btnConfirm').addEventListener('click', function (e) {
    // Ngoại lệ 9.3: chưa tìm hoặc thêm khách hàng (ô mã khách hàng còn trống)
    if (document.getElementById('customerId').value === '') {
      e.preventDefault();
      hienThongBao('Vui lòng tìm khách hàng theo số điện thoại trước khi xác nhận.', oSoDienThoai);
    }
    // Ngoại lệ 9.1 (bàn vừa bị người khác đặt) phải hỏi CSDL nên do BookTableServlet8 kiểm tra
  });
</script>
</body>
</html>

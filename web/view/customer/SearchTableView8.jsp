<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.TimeSlot8, model.Table8, java.util.Date, java.text.SimpleDateFormat"%>
<%! private String h(Object o){ if(o==null) return ""; return o.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); } %>
<%
    // Mở thẳng trang mà chưa qua SearchTableServlet8 thì chưa có khung giờ, chuyển qua servlet để lấy
    TimeSlot8[] timeSlotList = (TimeSlot8[]) session.getAttribute("timeSlotList");
    if (timeSlotList == null) { response.sendRedirect(request.getContextPath() + "/SearchTableServlet8"); return; }
    Table8[] tableList = (Table8[]) session.getAttribute("tableList");

    // Lỗi của lần tìm này, hoặc thông báo BookTableServlet8 gửi sang khi bàn vừa bị người khác đặt (9.1)
    String message = (String) request.getAttribute("errorMessage");
    String flashMessage = (String) session.getAttribute("flashMessage");
    session.removeAttribute("flashMessage");
    if (flashMessage != null) message = flashMessage;

    // Điền lại ngày và khung giờ đã chọn
    SimpleDateFormat iso = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat hm = new SimpleDateFormat("HH:mm");
    String vDate = request.getParameter("reservationDate");
    String vSlot = request.getParameter("timeSlotId");
    if (vDate == null && tableList != null && session.getAttribute("searchDate") != null) {
        vDate = iso.format((Date) session.getAttribute("searchDate"));
    }
    if (vSlot == null && tableList != null && session.getAttribute("searchTimeSlot") != null) {
        vSlot = String.valueOf(((TimeSlot8) session.getAttribute("searchTimeSlot")).getId());
    }
    String today = iso.format(new Date());
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

  <form class="khung" id="formTimBan" method="post" action="${pageContext.request.contextPath}/SearchTableServlet8">
    <h2>Chọn thời gian sử dụng</h2>
    <div class="hang">
      <div class="o-nhap">
        <label for="reservationDate">Ngày sử dụng</label>
        <input id="reservationDate" type="date" name="reservationDate" min="<%= today %>" value="<%= h(vDate) %>">
      </div>
      <div class="o-nhap">
        <label for="timeSlotId">Khung giờ</label>
        <select id="timeSlotId" name="timeSlotId">
          <option value="">-- Chọn khung giờ --</option>
          <%-- data-bat-dau: giờ bắt đầu, để JavaScript kiểm tra khung giờ hôm nay đã qua chưa --%>
          <% for (TimeSlot8 t : timeSlotList) { %>
            <option value="<%= t.getId() %>" data-bat-dau="<%= hm.format(t.getStartTime()) %>" <%= String.valueOf(t.getId()).equals(vSlot) ? "selected" : "" %>><%= hm.format(t.getStartTime()) %> – <%= hm.format(t.getEndTime()) %></option>
          <% } %>
        </select>
      </div>
      <button class="nut nut-chinh" type="submit">Tìm bàn trống</button>
    </div>
  </form>

  <% if (tableList != null && tableList.length > 0) { %>
  <section class="khung">
    <h2>Bàn còn trống</h2>
    <div class="khung-bang">
      <table>
        <thead><tr><th style="width:64px">STT</th><th>Số bàn</th><th>Sức chứa</th><th>Vị trí</th><th class="can-giua" style="width:120px"></th></tr></thead>
        <tbody>
        <% for (int i = 0; i < tableList.length; i++) { Table8 t = tableList[i]; %>
          <tr>
            <td><%= i + 1 %></td>
            <td><%= h(t.getTableNumber()) %></td>
            <td><%= t.getCapacity() %> người</td>
            <td><%= h(t.getLocation()) %></td>
            <td class="can-giua"><a class="nut nut-vien nut-nho" href="${pageContext.request.contextPath}/BookTableServlet8?tableId=<%= t.getId() %>">Chọn</a></td>
          </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  </section>
  <% } %>
</main>

<%-- Popup thông báo: hiện ngay nếu servlet gửi thông báo sang, nếu không thì ẩn chờ JavaScript dùng --%>
<div class="lop-phu" id="hopThongBao" role="alertdialog" aria-modal="true" aria-labelledby="tieuDeThongBao" <%= message == null ? "hidden" : "" %>>
  <div class="hop-thoai">
    <div class="bieu-tuong-canh-bao" aria-hidden="true">!</div>
    <h2 id="tieuDeThongBao">Thông báo</h2>
    <p id="noiDungThongBao"><%= h(message) %></p>
    <div class="hop-thoai-nut"><button class="nut nut-chinh" type="button" id="nutOk">OK</button></div>
  </div>
</div>

<script>
  var hopThongBao = document.getElementById('hopThongBao');
  var nutOk = document.getElementById('nutOk');
  var oCanChon = null;

  // ===== Popup thông báo: hiện nội dung lỗi; bấm OK thì đóng và đưa con trỏ về ô bị lỗi =====
  function hienThongBao(noiDung, oNhap) {
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

  // ===== Nút "Tìm bàn trống": kiểm tra trước khi gửi lên SearchTableServlet8 =====
  document.getElementById('formTimBan').addEventListener('submit', function (e) {
    var oNgay = document.getElementById('reservationDate');
    var oKhungGio = document.getElementById('timeSlotId');

    // Ngoại lệ 3.1: chưa chọn ngày hoặc khung giờ
    if (!oNgay.value) { e.preventDefault(); hienThongBao('Vui lòng chọn ngày sử dụng.', oNgay); return; }
    if (!oKhungGio.value) { e.preventDefault(); hienThongBao('Vui lòng chọn khung giờ.', oKhungGio); return; }

    // Ngoại lệ 3.2: ngày đã qua, hoặc chọn hôm nay mà khung giờ đã bắt đầu
    var bayGio = new Date();
    var homNay = bayGio.getFullYear() + '-' + String(bayGio.getMonth() + 1).padStart(2, '0') + '-' + String(bayGio.getDate()).padStart(2, '0');
    var gioHienTai = String(bayGio.getHours()).padStart(2, '0') + ':' + String(bayGio.getMinutes()).padStart(2, '0');
    var gioBatDau = oKhungGio.options[oKhungGio.selectedIndex].getAttribute('data-bat-dau');
    if (oNgay.value < homNay || (oNgay.value === homNay && gioBatDau <= gioHienTai)) {
      e.preventDefault();
      hienThongBao('Chỉ được đặt bàn cho các khung giờ chưa bắt đầu.', oNgay);
    }
    // Ngoại lệ 4.1 (không còn bàn trống) phải hỏi CSDL nên do SearchTableServlet8 báo về
  });
</script>
</body>
</html>

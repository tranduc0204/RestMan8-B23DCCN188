<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Date, java.text.SimpleDateFormat"%>
<%! private String h(Object o){ if(o==null) return ""; return o.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); } %>
<%
    if (session.getAttribute("table") == null) { response.sendRedirect(request.getContextPath() + "/SearchTableServlet8"); return; }
    String errorMessage = (String) request.getAttribute("errorMessage");
    String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Thêm khách hàng mới – RestMan</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap">
<link rel="stylesheet" href="${pageContext.request.contextPath}/view/customer/customer.css?v=1">
</head>
<body>
<header class="thanh-tren">
  <div class="thanh-tren-ben-trong">
    <a class="logo" href="${pageContext.request.contextPath}/index.jsp"><div class="logo-bieu-tuong">R</div><div class="logo-ten">RestMan</div></a>
  </div>
</header>
<main class="trang trang-hep">
  <h1>Thêm khách hàng mới</h1>

  <form class="khung" id="formThemKhach" method="post" action="${pageContext.request.contextPath}/AddCustomerServlet8">
    <div class="o-nhap">
      <label for="name">Họ và tên <span class="bat-buoc">*</span></label>
      <input id="name" type="text" name="name" value="<%= h(request.getParameter("name")) %>" maxlength="255">
    </div>
    <div class="hang">
      <div class="o-nhap">
        <label for="phoneNumber">Số điện thoại <span class="bat-buoc">*</span></label>
        <input id="phoneNumber" type="tel" name="phoneNumber" value="<%= h(request.getParameter("phoneNumber")) %>" maxlength="10" placeholder="Ví dụ 0912345678">
      </div>
      <div class="o-nhap">
        <label for="dateOfBirth">Ngày sinh</label>
        <input id="dateOfBirth" type="date" name="dateOfBirth" max="<%= today %>" value="<%= h(request.getParameter("dateOfBirth")) %>">
      </div>
    </div>
    <div class="o-nhap">
      <label for="email">Email</label>
      <input id="email" type="email" name="email" value="<%= h(request.getParameter("email")) %>" maxlength="255">
    </div>
    <div class="o-nhap">
      <label for="address">Địa chỉ</label>
      <input id="address" type="text" name="address" value="<%= h(request.getParameter("address")) %>" maxlength="255">
    </div>
    <div class="nhom-nut">
      <button class="nut nut-chinh" type="submit">Thêm khách hàng</button>
    </div>
  </form>
</main>

<%-- Popup thông báo lỗi: hiện ngay nếu AddCustomerServlet8 gửi lỗi sang, nếu không thì ẩn chờ JavaScript dùng --%>
<div class="lop-phu" id="hopThongBao" role="alertdialog" aria-modal="true" aria-labelledby="tieuDeThongBao" <%= errorMessage == null ? "hidden" : "" %>>
  <div class="hop-thoai">
    <div class="bieu-tuong-canh-bao" aria-hidden="true">!</div>
    <h2 id="tieuDeThongBao">Thông báo</h2>
    <p id="noiDungThongBao"><%= h(errorMessage) %></p>
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

  // ===== Nút "Thêm khách hàng": kiểm tra trước khi gửi lên AddCustomerServlet8 =====
  document.getElementById('formThemKhach').addEventListener('submit', function (e) {
    var oTen = document.getElementById('name');
    var oSo = document.getElementById('phoneNumber');
    var oEmail = document.getElementById('email');
    var oNgaySinh = document.getElementById('dateOfBirth');

    if (oTen.value.trim() === '') { e.preventDefault(); hienThongBao('Vui lòng nhập họ và tên.', oTen); return; }
    if (oSo.value.trim() === '') { e.preventDefault(); hienThongBao('Vui lòng nhập số điện thoại.', oSo); return; }
    if (!/^0\d{9}$/.test(oSo.value.trim())) {
      e.preventDefault();
      hienThongBao('Số điện thoại không đúng định dạng (10 chữ số, bắt đầu bằng 0).', oSo);
      return;
    }
    if (oEmail.value.trim() !== '' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(oEmail.value.trim())) {
      e.preventDefault();
      hienThongBao('Email không đúng định dạng.', oEmail);
      return;
    }
    if (oNgaySinh.value && oNgaySinh.value > oNgaySinh.max) {
      e.preventDefault();
      hienThongBao('Ngày sinh không được sau ngày hôm nay.', oNgaySinh);
    }
    // Ngoại lệ 7.3.1 (số điện thoại đã có khách dùng) phải hỏi CSDL nên do AddCustomerServlet8 kiểm tra
  });
</script>
</body>
</html>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%! private String h(Object o){ if(o==null) return ""; return o.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); } %>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Đăng nhập – RestMan</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap">
<link rel="stylesheet" href="${pageContext.request.contextPath}/view/employee/employee.css?v=1">
</head>
<body>
<div class="khung-giua-man-hinh">
  <main class="dang-nhap">
    <form class="khung" id="formDangNhap" method="post" action="${pageContext.request.contextPath}/LoginServlet8">
      <a class="logo" href="${pageContext.request.contextPath}/index.jsp">
        <div class="logo-bieu-tuong">R</div>
        <div><div class="logo-ten">RestMan</div><div class="logo-mo-ta">Đăng nhập nhân viên</div></div>
      </a>
      <div class="o-nhap">
        <label for="username">Tên đăng nhập</label>
        <input id="username" type="text" name="username" value="<%= h(request.getParameter("username")) %>" autocomplete="username">
      </div>
      <div class="o-nhap">
        <label for="password">Mật khẩu</label>
        <input id="password" type="password" name="password" autocomplete="current-password">
      </div>
      <button class="nut nut-chinh nut-rong" type="submit">Đăng nhập</button>
    </form>
  </main>
</div>

<%-- Popup thông báo: hiện ngay nếu LoginServlet8 gửi lỗi sang, nếu không thì ẩn chờ JavaScript dùng --%>
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

  // Hiện popup với nội dung lỗi; bấm OK thì đóng và đưa con trỏ về ô bị lỗi
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

  // Kiểm tra trước khi gửi: không để trống tên đăng nhập và mật khẩu
  document.getElementById('formDangNhap').addEventListener('submit', function (e) {
    var oTen = document.getElementById('username');
    var oMatKhau = document.getElementById('password');
    if (oTen.value.trim() === '') {
      e.preventDefault();
      hienThongBao('Vui lòng nhập tên đăng nhập.', oTen);
    } else if (oMatKhau.value === '') {
      e.preventDefault();
      hienThongBao('Vui lòng nhập mật khẩu.', oMatKhau);
    }
  });
</script>
</body>
</html>

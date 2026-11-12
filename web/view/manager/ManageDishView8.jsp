<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.Employee8"%>
<%! private String h(Object o){ if(o==null) return ""; return o.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); } %>
<%
    // Chưa đăng nhập thì quay về trang đăng nhập
    Employee8 employee = (Employee8) session.getAttribute("employee");
    if (employee == null) { response.sendRedirect(request.getContextPath() + "/LoginServlet8"); return; }
    // Chữ cái đầu của tên, ví dụ "Trần Văn Quản" -> "Q"
    String initials = employee.getName().trim().substring(employee.getName().trim().lastIndexOf(' ') + 1).substring(0, 1);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Quản lí món ăn – RestMan</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap">
<link rel="stylesheet" href="${pageContext.request.contextPath}/view/manager/manager.css?v=1">
</head>
<body>
<header class="thanh-tren">
  <div class="thanh-tren-ben-trong">
    <a class="logo" href="${pageContext.request.contextPath}/index.jsp"><div class="logo-bieu-tuong">R</div><div class="logo-ten">RestMan</div></a>
    <div class="nguoi-dung">
      <div class="nguoi-dung-chu">
        <div class="nguoi-dung-ten"><%= h(employee.getName()) %></div>
        <div class="nguoi-dung-vai-tro"><%= h(employee.getCurrentRoleName()) %></div>
      </div>
      <div class="anh-dai-dien" aria-hidden="true"><%= h(initials) %></div>
    </div>
  </div>
</header>
<main class="trang">
  <h1>Quản lí món ăn</h1>
  <div class="danh-sach-o">
    <a class="o-chuc-nang" href="${pageContext.request.contextPath}/AddDishServlet8">
      <span class="o-chuc-nang-ten">Thêm món ăn</span>
      <span class="o-chuc-nang-mo-ta">Khai báo món mới cùng các kích cỡ và đơn giá</span>
    </a>
    <div class="o-chuc-nang bi-khoa" aria-disabled="true">
      <span class="o-chuc-nang-ten">Sửa món ăn</span>
      <span class="o-chuc-nang-mo-ta">Cập nhật thông tin món ăn đã có</span>
    </div>
    <div class="o-chuc-nang bi-khoa" aria-disabled="true">
      <span class="o-chuc-nang-ten">Xóa món ăn</span>
      <span class="o-chuc-nang-mo-ta">Xóa món ăn khỏi thực đơn</span>
    </div>
  </div>
</main>

</body>
</html>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Trang chủ khách hàng – RestMan</title>
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
  <section class="trang-chu-noi-dung">
    <h1>Trang chủ khách hàng</h1>
    <a class="nut-trang-chu" href="${pageContext.request.contextPath}/SearchTableServlet8">Đặt bàn trực tuyến</a>
  </section>
</main>
</body>
</html>

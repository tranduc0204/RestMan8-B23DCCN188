<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>RestMan</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap">
<style>
  /* ===== Màu dùng trong trang ===== */
  :root {
    --nen-trang: #F2F1EC;      /* nền cả trang */
    --nen-khung: #FFFFFF;      /* nền các ô */
    --mau-chu: #1C1B19;        /* chữ chính */
    --mau-chu-phu: #5E5B55;    /* chữ phụ, mô tả */
    --vien: #E2DFD8;           /* đường viền */
    --mau-chinh: #1E5B4F;      /* màu xanh chủ đạo */
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; background: var(--nen-trang); color: var(--mau-chu);
    font-family: 'Be Vietnam Pro', system-ui, -apple-system, 'Segoe UI', sans-serif; font-size: 15px; line-height: 1.5;
  }
  :focus-visible { outline: 3px solid #7FB3A6; outline-offset: 2px; }
  h1 { margin: 0; font-size: 28px; font-weight: 700; letter-spacing: -0.02em; line-height: 1.2; }

  /* ===== Bố cục: nội dung nằm giữa màn hình ===== */
  .khung-giua-man-hinh { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }
  .trang { width: 100%; max-width: 720px; display: flex; flex-direction: column; gap: 22px; }

  /* ===== Logo ===== */
  .logo { display: flex; align-items: center; gap: 12px; }
  .logo-bieu-tuong {
    width: 36px; height: 36px; border-radius: 8px; background: var(--mau-chinh); color: #fff;
    display: flex; align-items: center; justify-content: center; font-weight: 700;
  }
  .logo-ten { font-weight: 700; font-size: 18px; letter-spacing: -0.01em; }
  .logo-mo-ta { font-size: 13px; color: var(--mau-chu-phu); }

  .loi-dan { margin: 4px 0 0; color: var(--mau-chu-phu); }

  /* ===== Hai ô chọn vai trò ===== */
  .danh-sach-o { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; }
  .o-chuc-nang {
    display: flex; flex-direction: column; gap: 6px; padding: 22px; border-radius: 12px; background: var(--nen-khung);
    border: 1px solid var(--vien); text-decoration: none; color: var(--mau-chu);
  }
  .o-chuc-nang:hover { border-color: var(--mau-chinh); }
  .o-chuc-nang-ten { font-weight: 600; font-size: 17px; }
  .o-chuc-nang-mo-ta { font-size: 14px; color: var(--mau-chu-phu); }

  @media (max-width: 600px) { h1 { font-size: 24px; } }
</style>
</head>
<body>
<div class="khung-giua-man-hinh">
  <main class="trang">
    <div class="logo">
      <div class="logo-bieu-tuong">R</div>
      <div><div class="logo-ten">RestMan</div><div class="logo-mo-ta">Hệ thống quản lí nhà hàng</div></div>
    </div>
    <div>
      <h1>Bạn đang dùng hệ thống với vai trò nào?</h1>
      <p class="loi-dan">Khách hàng đặt bàn không cần đăng nhập.</p>
    </div>
    <div class="danh-sach-o">
      <a class="o-chuc-nang" href="${pageContext.request.contextPath}/view/customer/CustomerHomeView8.jsp">
        <span class="o-chuc-nang-ten">Khách hàng</span>
        <span class="o-chuc-nang-mo-ta">Đặt bàn trực tuyến theo ngày và khung giờ</span>
      </a>
      <a class="o-chuc-nang" href="${pageContext.request.contextPath}/LoginServlet8">
        <span class="o-chuc-nang-ten">Nhân viên</span>
        <span class="o-chuc-nang-mo-ta">Đăng nhập để quản lí món ăn</span>
      </a>
    </div>
  </main>
</div>
</body>
</html>

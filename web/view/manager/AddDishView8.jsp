<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.Employee8, model.DishCategory8, model.Size8, java.text.DecimalFormat, java.text.DecimalFormatSymbols"%>
<%! private String h(Object o){ if(o==null) return ""; return o.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); } %>
<%
    // Chưa đăng nhập thì quay về trang đăng nhập
    Employee8 employee = (Employee8) session.getAttribute("employee");
    if (employee == null) { response.sendRedirect(request.getContextPath() + "/LoginServlet8"); return; }
    String initials = employee.getName().trim().substring(employee.getName().trim().lastIndexOf(' ') + 1).substring(0, 1);

    // Mở thẳng trang mà chưa qua AddDishServlet8 thì chưa có danh sách, chuyển qua servlet để lấy
    DishCategory8[] categoryList = (DishCategory8[]) session.getAttribute("categoryList");
    Size8[] sizeList = (Size8[]) session.getAttribute("sizeList");
    if (categoryList == null || sizeList == null) { response.sendRedirect(request.getContextPath() + "/AddDishServlet8"); return; }

    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");

    // Có lỗi thì điền lại dữ liệu vừa nhập, thành công thì để trống
    boolean refill = errorMessage != null;
    String vName = refill ? request.getParameter("dishName") : "";
    String vCategory = refill ? request.getParameter("categoryId") : "";
    String vDescription = refill ? request.getParameter("description") : "";
    String vStatus = refill ? request.getParameter("servingStatus") : "Đang phục vụ";
    String[] vSizeIds = refill ? request.getParameterValues("sizeId") : null;
    String[] vPrices = refill ? request.getParameterValues("unitPrice") : null;

    // Định dạng tiền: 65000 -> 65.000
    DecimalFormatSymbols sym = new DecimalFormatSymbols();
    sym.setGroupingSeparator('.');
    DecimalFormat money = new DecimalFormat("#,###", sym);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Thêm món ăn – RestMan</title>
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
  <h1>Thêm món ăn</h1>

  <form id="dishForm" method="post" action="${pageContext.request.contextPath}/AddDishServlet8" enctype="multipart/form-data">
    <div class="chia-cot">
      <section class="khung cot-chinh">
        <h2>Thông tin món ăn</h2>
        <div class="o-nhap">
          <label for="dishName">Tên món ăn <span class="bat-buoc">*</span></label>
          <input id="dishName" type="text" name="dishName" value="<%= h(vName) %>" maxlength="255">
        </div>
        <div class="o-nhap">
          <label for="categoryId">Loại món ăn <span class="bat-buoc">*</span></label>
          <select id="categoryId" name="categoryId">
            <option value="">-- Chọn loại món ăn --</option>
            <% for (DishCategory8 c : categoryList) { %>
              <option value="<%= c.getId() %>" <%= String.valueOf(c.getId()).equals(vCategory) ? "selected" : "" %>><%= h(c.getCategoryName()) %></option>
            <% } %>
          </select>
        </div>
        <div class="o-nhap">
          <label for="servingStatus">Trạng thái phục vụ</label>
          <select id="servingStatus" name="servingStatus">
            <option value="Đang phục vụ" <%= "Đang phục vụ".equals(vStatus) ? "selected" : "" %>>Đang phục vụ</option>
            <option value="Ngừng phục vụ" <%= "Ngừng phục vụ".equals(vStatus) ? "selected" : "" %>>Ngừng phục vụ</option>
          </select>
        </div>
        <div class="o-nhap">
          <label for="description">Mô tả</label>
          <textarea id="description" name="description" rows="4" maxlength="255"><%= h(vDescription) %></textarea>
        </div>
      </section>

      <section class="khung cot-phu">
        <h2>Hình ảnh</h2>
        <div class="xem-truoc-anh" id="preview">Chưa chọn hình ảnh</div>
        <label class="nut" for="image">Chọn hình ảnh</label>
        <input class="an-di" id="image" type="file" name="image" accept="image/png, image/jpeg">
      </section>
    </div>

    <section class="khung cach-tren">
      <h2>Kích cỡ và đơn giá <span class="bat-buoc">*</span></h2>
      <div class="hang">
        <div class="o-nhap">
          <label for="sizeSelect">Kích cỡ</label>
          <select id="sizeSelect">
            <option value="">-- Chọn kích cỡ --</option>
            <% for (Size8 s : sizeList) { %>
              <option value="<%= s.getId() %>"><%= h(s.getSizeName()) %></option>
            <% } %>
          </select>
        </div>
        <div class="o-nhap">
          <label for="priceInput">Đơn giá</label>
          <div class="o-don-vi"><input id="priceInput" type="text" inputmode="numeric" placeholder="Ví dụ 65000"><span>VNĐ</span></div>
        </div>
        <button class="nut nut-vien" type="button" id="btnAddSize">Thêm kích cỡ</button>
      </div>

      <div class="khung-bang">
        <table>
          <thead><tr><th style="width:64px">STT</th><th>Kích cỡ</th><th class="cot-so">Đơn giá (VNĐ)</th><th class="can-giua" style="width:90px">Xóa</th></tr></thead>
          <tbody id="sizeRows">
          <%-- Có lỗi thì in lại các dòng kích cỡ đã thêm trước đó --%>
          <%
            int soKichCo = 0;
            if (vSizeIds != null && vPrices != null) {
              soKichCo = Math.min(vSizeIds.length, vPrices.length);
              for (int i = 0; i < vSizeIds.length && i < vPrices.length; i++) {
                String sizeName = "";
                for (Size8 s : sizeList) { if (String.valueOf(s.getId()).equals(vSizeIds[i])) sizeName = s.getSizeName(); }
                String priceText;
                try { priceText = money.format(Double.parseDouble(vPrices[i])); } catch (NumberFormatException e) { priceText = vPrices[i]; }
          %>
            <tr>
              <td><%= i + 1 %></td>
              <td><%= h(sizeName) %><input type="hidden" name="sizeId" value="<%= h(vSizeIds[i]) %>"></td>
              <td class="cot-so"><%= h(priceText) %><input type="hidden" name="unitPrice" value="<%= h(vPrices[i]) %>"></td>
              <td class="can-giua"><button type="button" class="nut nut-xoa" data-delete aria-label="Xóa kích cỡ <%= h(sizeName) %>">✕</button></td>
            </tr>
          <% } } %>
          </tbody>
        </table>
      </div>
      <div class="ghi-chu-nho">Đã khai báo <strong id="soKichCo"><%= soKichCo %></strong> kích cỡ</div>
    </section>

    <div class="nhom-nut cach-tren">
      <a class="nut" href="${pageContext.request.contextPath}/view/manager/ManagerHomeView8.jsp">Hủy</a>
      <button class="nut nut-chinh" type="submit">Thêm món ăn</button>
    </div>
  </form>
</main>

<%-- Popup thông báo lỗi: hiện ngay nếu AddDishServlet8 gửi lỗi sang, nếu không thì ẩn chờ JavaScript dùng --%>
<div class="lop-phu" id="hopThongBao" role="alertdialog" aria-modal="true" aria-labelledby="tieuDeThongBao" <%= errorMessage == null ? "hidden" : "" %>>
  <div class="hop-thoai">
    <div class="bieu-tuong-canh-bao" aria-hidden="true">!</div>
    <h2 id="tieuDeThongBao">Thông báo</h2>
    <p id="noiDungThongBao"><%= h(errorMessage) %></p>
    <div class="hop-thoai-nut"><button class="nut nut-chinh" type="button" id="nutOk">OK</button></div>
  </div>
</div>

<%-- Popup thêm món ăn thành công: bấm OK về trang chủ quản lí --%>
<% if (successMessage != null) { %>
<div class="lop-phu" role="alertdialog" aria-modal="true" aria-labelledby="tieuDeThanhCong">
  <div class="hop-thoai">
    <div class="bieu-tuong-thanh-cong" aria-hidden="true">✓</div>
    <h2 id="tieuDeThanhCong"><%= h(successMessage) %></h2>
    <div class="hop-thoai-nut"><a class="nut nut-chinh" href="${pageContext.request.contextPath}/view/manager/ManagerHomeView8.jsp" autofocus>OK</a></div>
  </div>
</div>
<% } %>

<script>
  var bangKichCo = document.getElementById('sizeRows');
  var oKichCo = document.getElementById('sizeSelect');
  var oDonGia = document.getElementById('priceInput');
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

  // Đánh lại STT các dòng và cập nhật dòng "Đã khai báo ... kích cỡ" sau mỗi lần thêm/xóa
  function danhLaiSoThuTu() {
    var dong = bangKichCo.querySelectorAll('tr');
    for (var i = 0; i < dong.length; i++) { dong[i].cells[0].textContent = i + 1; }
    document.getElementById('soKichCo').textContent = dong.length;
  }

  function escapeHtml(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  // ===== Nút "Thêm kích cỡ": kiểm tra rồi thêm một dòng vào bảng, không gọi server =====
  document.getElementById('btnAddSize').addEventListener('click', function () {
    var sizeId = oKichCo.value;
    var giaNhap = oDonGia.value.replace(/[.\s]/g, '');
    // Ngoại lệ 6.1: chưa chọn kích cỡ
    if (!sizeId) { hienThongBao('Vui lòng chọn kích cỡ.', oKichCo); return; }
    // Ngoại lệ 6.2: chưa nhập đơn giá
    if (giaNhap === '') { hienThongBao('Vui lòng nhập đơn giá.', oDonGia); return; }
    // Ngoại lệ 6.3: đơn giá có kí tự lạ hoặc không lớn hơn 0
    if (!/^\d+$/.test(giaNhap) || parseInt(giaNhap, 10) <= 0) { hienThongBao('Đơn giá phải là số nguyên lớn hơn 0.', oDonGia); return; }
    // Ngoại lệ 6.4: kích cỡ đã có trong bảng
    var daCo = bangKichCo.querySelectorAll('input[name=sizeId]');
    for (var i = 0; i < daCo.length; i++) {
      if (daCo[i].value === sizeId) { hienThongBao('Kích cỡ này đã có trong bảng.', oKichCo); return; }
    }
    var tenKichCo = oKichCo.options[oKichCo.selectedIndex].text;
    var donGia = parseInt(giaNhap, 10);
    var tr = document.createElement('tr');
    tr.innerHTML = '<td></td>'
      + '<td>' + escapeHtml(tenKichCo) + '<input type="hidden" name="sizeId" value="' + sizeId + '"></td>'
      + '<td class="cot-so">' + donGia.toLocaleString('vi-VN') + '<input type="hidden" name="unitPrice" value="' + donGia + '"></td>'
      + '<td class="can-giua"><button type="button" class="nut nut-xoa" data-delete aria-label="Xóa kích cỡ ' + escapeHtml(tenKichCo) + '">✕</button></td>';
    bangKichCo.appendChild(tr);
    oKichCo.value = '';
    oDonGia.value = '';
    danhLaiSoThuTu();
  });

  // ===== Nút "Xóa" trên từng dòng kích cỡ =====
  bangKichCo.addEventListener('click', function (e) {
    var nut = e.target.closest('[data-delete]');
    if (nut) { nut.closest('tr').remove(); danhLaiSoThuTu(); }
  });

  // ===== Ngoại lệ 5.1: ảnh sai định dạng hoặc quá 5 MB (chỉ kiểm tra khi có chọn ảnh) =====
  document.getElementById('image').addEventListener('change', function () {
    var khungAnh = document.getElementById('preview');
    var file = this.files && this.files[0];
    if (!file) return;
    var dungDinhDang = file.type === 'image/jpeg' || file.type === 'image/png';
    if (!dungDinhDang || file.size > 5 * 1024 * 1024) {
      this.value = '';
      khungAnh.textContent = 'Chưa chọn hình ảnh';
      hienThongBao('Hình ảnh không hợp lệ. Chỉ nhận file JPG hoặc PNG, tối đa 5 MB.');
      return;
    }
    khungAnh.textContent = '';
    var img = document.createElement('img');
    img.alt = 'Xem trước hình ảnh món ăn';
    img.src = URL.createObjectURL(file);
    khungAnh.appendChild(img);
  });

  // ===== Nút "Thêm món ăn": kiểm tra trước khi gửi lên AddDishServlet8 =====
  document.getElementById('dishForm').addEventListener('submit', function (e) {
    var oTenMon = document.getElementById('dishName');
    var oLoaiMon = document.getElementById('categoryId');
    // Ngoại lệ 8.1: trống tên món hoặc chưa chọn loại
    if (oTenMon.value.trim() === '') { e.preventDefault(); hienThongBao('Vui lòng nhập tên món ăn.', oTenMon); return; }
    if (!oLoaiMon.value) { e.preventDefault(); hienThongBao('Vui lòng chọn loại món ăn.', oLoaiMon); return; }
    // Ngoại lệ 8.3: chưa có kích cỡ nào
    if (bangKichCo.querySelectorAll('tr').length === 0) {
      e.preventDefault();
      hienThongBao('Món ăn phải có ít nhất một kích cỡ kèm đơn giá.', oKichCo);
    }
    // Ngoại lệ 8.2 (trùng tên món đang phục vụ) phải hỏi CSDL nên do AddDishServlet8 kiểm tra
  });
</script>
</body>
</html>

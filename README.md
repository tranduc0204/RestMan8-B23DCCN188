# RestMan8 – Hệ thống quản lí nhà hàng (Đề 18)

**Sinh viên:** Trần Anh Đức – B23DCCN188
**Môn:** Phân tích và thiết kế hệ thống hướng đối tượng

Bài tập lớn cài đặt **2 module** của hệ thống RestMan:

| Module | Tác nhân | Chức năng |
|---|---|---|
| 1. Thêm thông tin món ăn | Nhân viên quản lí | Đăng nhập → Quản lí món ăn → Thêm món ăn (thông tin, hình ảnh, các kích cỡ kèm đơn giá) |
| 2. Đặt bàn trực tuyến | Khách hàng | Chọn ngày và khung giờ → Tìm bàn trống → Chọn bàn → Tìm hoặc thêm khách hàng → Xác nhận đặt bàn |

Các chức năng khác của đề (sửa/xóa món, combo, thống kê, kho, gọi món, thanh toán…) nằm ngoài phạm vi và không được cài đặt.

---

## 1. Công nghệ sử dụng

| Thành phần | Phiên bản |
|---|---|
| JDK | 24 |
| Web server | Apache Tomcat **9.0** (dùng gói `javax.servlet`, **không** chạy được trên Tomcat 10 trở lên) |
| Servlet / JSP | Servlet 4.0, JSP (scriptlet + EL), không dùng JSTL |
| Cơ sở dữ liệu | MySQL Server 8.0 |
| JDBC driver | MySQL Connector/J 9.5.0 (thư viện ngoài duy nhất) |
| IDE | Apache NetBeans (project dạng Ant) |

Kiến trúc 3 tầng theo mô hình MVC: **view** (JSP) – **controller** (Servlet) – **dao** (truy cập CSDL) – **model** (lớp thực thể).

---

## 2. Cấu trúc thư mục

```
NhaHangRestMan/
├── sql/
│   └── restman8.sql                 ← script tạo CSDL + dữ liệu mẫu
├── src/java/
│   ├── controller/                  ← Servlet
│   │   ├── LoginServlet8.java              (đăng nhập, hỗ trợ module 1)
│   │   ├── AddDishServlet8.java            (module 1)
│   │   ├── SearchTableServlet8.java        (module 2)
│   │   ├── BookTableServlet8.java          (module 2)
│   │   └── AddCustomerServlet8.java        (module 2)
│   ├── dao/                         ← truy cập CSDL (DAO8 là lớp cha, giữ kết nối)
│   └── model/                       ← lớp thực thể (Dish8, Table8, Reservation8, ...)
└── web/
    ├── index.jsp                    ← trang chọn vai trò (trang đầu tiên)
    ├── WEB-INF/web.xml
    └── view/
        ├── employee/    login.jsp, employee.css
        ├── manager/     ManagerHomeView8.jsp, ManageDishView8.jsp, AddDishView8.jsp, manager.css
        │   └── images/  ← ảnh món ăn tải lên được lưu ở đây
        ├── customer/    CustomerHomeView8.jsp, SearchTableView8.jsp, BookTableView8.jsp,
        │                AddCustomerView8.jsp, customer.css
        ├── waiter/          (để trống)
        └── warehousestaff/  (để trống)
```

---

## 3. Hướng dẫn cài đặt và chạy

### Bước 1. Cài phần mềm

1. **JDK 24**.
2. **Apache Tomcat 9.0**: tải bản zip tại <https://tomcat.apache.org/download-90.cgi> và giải nén, ví dụ vào `C:\apache-tomcat-9.0.113`.
3. **MySQL Server 8.0** và **MySQL Workbench**.
4. **MySQL Connector/J 9.5.0**: tải tại <https://dev.mysql.com/downloads/connector/j/> (chọn *Platform Independent*), giải nén để có file `mysql-connector-j-9.5.0.jar`.
5. **Apache NetBeans** có hỗ trợ Java Web (Java EE / Jakarta EE).

### Bước 2. Tạo cơ sở dữ liệu

1. Mở **MySQL Workbench** và kết nối tới MySQL trên máy.
2. Chọn **File → Open SQL Script…** rồi mở file `sql/restman8.sql`.
3. Bấm **Execute** (biểu tượng tia sét ⚡).

Script sẽ tạo database `restman8` (bảng mã `utf8mb4`), toàn bộ các bảng và dữ liệu mẫu.
⚠️ Nếu máy đã có database tên `restman8`, script sẽ **xóa đi và tạo lại**.

### Bước 3. Khai báo tài khoản MySQL

Tài khoản MySQL được đọc từ file `src/java/dao/db.properties`. File này không có trên GitHub vì chứa mật khẩu riêng của máy sinh viên. Chọn **một** trong hai cách:

**Cách 1 (khuyên dùng):** trong thư mục `src/java/dao/`, chép file `db.properties.example` thành `db.properties`, rồi điền tài khoản MySQL của máy:

```properties
user=root
password=mat_khau_mysql_cua_may
```

**Cách 2:** mở `src/java/dao/DAO8.java`, sửa giá trị mặc định `"your_password"` thành mật khẩu MySQL của máy (và `"root"` nếu dùng tài khoản khác):

```java
String user = config.getProperty("user", "root");
String password = config.getProperty("password", "your_password");
```

Nếu MySQL không chạy ở cổng 3306 thì sửa cổng trong `URL` ở đầu file `DAO8.java`.

### Bước 4. Mở project trong NetBeans

1. **File → Open Project…** → chọn thư mục `NhaHangRestMan`.
2. Nếu NetBeans báo *“Resolve Problems”* (do thư viện và server được cấu hình theo đường dẫn trên máy sinh viên), bấm chuột phải vào project → **Resolve Problems…**:
   - **Thư viện MySQL Connector/J:** chọn lại file `mysql-connector-j-9.5.0.jar` vừa tải. Cách khác: chép file jar vào đúng đường dẫn `C:\mysql-connector-j-9.5.0\mysql-connector-j-9.5.0.jar`.
   - **Server:** chọn Tomcat 9.0. Nếu NetBeans chưa có Tomcat thì vào **Tools → Servers → Add Server… → Apache Tomcat or TomEE**, trỏ tới thư mục Tomcat 9 đã giải nén và đặt tên đăng nhập/mật khẩu quản trị tùy ý.
3. Kiểm tra lại: chuột phải vào project → **Properties**:
   - **Libraries → Compile:** có `mysql-connector-j-9.5.0.jar` (được đóng gói vào `WEB-INF/lib`).
   - **Run → Server:** Apache Tomcat 9.0.
   - **Sources → Source/Binary Format:** 24.

### Bước 5. Chạy chương trình

1. Chuột phải vào project → **Clean and Build**.
2. Chuột phải vào project → **Run**. Trình duyệt sẽ mở địa chỉ:

   **<http://localhost:8080/NhaHangRestMan/>**

3. Trang đầu tiên cho chọn vai trò: **Khách hàng** (đặt bàn, không cần đăng nhập) hoặc **Nhân viên** (đăng nhập để thêm món ăn).
   Bấm logo **RestMan** ở bất kì trang nào để quay về trang chọn vai trò.

---

## 4. Dữ liệu mẫu để chạy thử

| Dữ liệu | Giá trị |
|---|---|
| Tài khoản quản lí | **quanli / 123456** (Trần Văn Quản – Quản lí nhà hàng) |
| Tài khoản không có quyền quản lí | banhang / 123456, kho / 123456 (dùng để thử báo lỗi không có quyền) |
| Loại món ăn đang dùng | Món khai vị, Món chính, Đồ uống |
| Kích cỡ đang dùng | Nhỏ, Vừa, Lớn |
| Món ăn có sẵn | Phở bò tái, Nem rán |
| Khung giờ | 10:00–12:00, 12:00–14:00, 18:00–20:00, 20:00–22:00 |
| Bàn đang dùng | B01, B02, B03 (Tầng 1); B05, B09 (Tầng 2) |
| Khách hàng có sẵn | Nguyễn Văn B – **0364978258** (mã 135); Trần Thị C – 0977111222 (mã 136) |
| Phiếu đặt bàn có sẵn | B01 và B02 đã được đặt ngày **20/12/2026**, khung 18:00–20:00 |

---

## 5. Kịch bản chạy thử

### Module 1 – Thêm thông tin món ăn

1. Trang đầu → **Nhân viên** → đăng nhập `quanli / 123456`.
2. **Quản lí món ăn** → **Thêm món ăn**.
3. Nhập: tên **Gà rán**, loại **Món chính**, trạng thái **Đang phục vụ**, mô tả **Gà rán nguyên con**, chọn ảnh (không bắt buộc, JPG/PNG ≤ 5 MB).
4. Chọn kích cỡ **Vừa**, nhập đơn giá **89000** → **Thêm kích cỡ**. Có thể thêm nhiều kích cỡ.
5. Bấm **Thêm món ăn** → hiện thông báo *“Thêm món ăn thành công”* → **OK** về trang chủ quản lí.
6. Kiểm tra CSDL: `tblDish8` có món mới, `tblDishSize8` có các dòng kích cỡ tương ứng.

Thử các ngoại lệ:
- Để trống tên món hoặc chưa chọn loại món.
- Chưa thêm kích cỡ nào mà bấm Thêm món ăn.
- Thêm kích cỡ khi chưa chọn kích cỡ, đơn giá để trống, có chữ hoặc ≤ 0, hoặc kích cỡ đã có trong bảng.
- Chọn file ảnh không phải JPG/PNG hoặc lớn hơn 5 MB.
- Nhập tên **Phở bò tái** → báo trùng tên với món đang phục vụ.
- Bấm **Hủy** → về trang chủ quản lí, không lưu gì.

Món ăn và các kích cỡ được lưu trong **một transaction**: nếu lưu kích cỡ bị lỗi thì món ăn cũng không được lưu.

### Module 2 – Đặt bàn trực tuyến

1. Trang đầu → **Khách hàng** → **Đặt bàn trực tuyến**.
2. Chọn ngày **20/12/2026**, khung giờ **18:00 – 20:00** → **Tìm bàn trống**. Bảng hiện **B03, B05, B09** (B01, B02 đã có người đặt).
3. Bấm **Chọn** ở bàn **B05**.
4. Nhập số điện thoại **0364978258** → **Tìm khách hàng** → hiện thông tin khách *Nguyễn Văn B* (mã 135).
5. Nhập ghi chú *“Cần một ghế trẻ em”* → **Xác nhận đặt bàn** → hiện thông báo *“Đặt bàn thành công”* kèm mã phiếu → **OK** về trang chủ khách hàng.
6. Kiểm tra CSDL: `tblReservation8` có phiếu mới với `status = 'Chờ xác nhận'` và `tblEmployee8id = NULL` (chưa có nhân viên xác nhận).

Thử các ngoại lệ:
- Chưa chọn ngày hoặc khung giờ; chọn ngày đã qua hoặc khung giờ hôm nay đã bắt đầu.
- Số điện thoại để trống, hoặc sai định dạng (phải đủ 10 chữ số, bắt đầu bằng 0).
- Số điện thoại chưa có trong hệ thống, ví dụ 0911000111 → báo *“Không tìm thấy khách hàng”*. Bấm **Thêm khách hàng mới**, nhập thông tin rồi bấm **Thêm khách hàng** → quay lại trang đặt bàn với khách vừa thêm.
- Khi thêm khách hàng, nhập số điện thoại đã có (ví dụ 0977111222) → báo trùng.
- Bấm **Xác nhận đặt bàn** khi chưa tìm khách hàng.
- Bàn vừa bị người khác đặt: mở 2 trình duyệt khác nhau (hoặc 1 cửa sổ thường + 1 cửa sổ ẩn danh, vì 2 tab cùng trình duyệt dùng chung phiên làm việc). Ở cả hai, cùng chọn một bàn và tìm khách hàng. Xác nhận ở trình duyệt thứ nhất, rồi xác nhận ở trình duyệt thứ hai → trình duyệt thứ hai báo bàn vừa được khách khác đặt và quay về danh sách bàn trống.
- Bấm **Hủy** → về trang chủ khách hàng, không lưu gì.

> Phiếu đặt bàn mẫu dùng ngày 20/12/2026. Nếu chạy thử sau ngày này, hãy sửa ngày trong phần dữ liệu mẫu của `sql/restman8.sql` (2 dòng `INSERT INTO tblReservation8`) sang một ngày trong tương lai rồi chạy lại script.

---

## 6. Lỗi thường gặp

| Hiện tượng | Nguyên nhân và cách xử lí |
|---|---|
| `Communications link failure` trong cửa sổ Output | MySQL chưa chạy, hoặc sai cổng trong `URL` của `DAO8.java`. |
| `Access denied for user 'root'@'localhost'` | Sai `USER` hoặc `PASSWORD` trong `DAO8.java` (Bước 3). |
| `ClassNotFoundException: com.mysql.cj.jdbc.Driver` | Chưa thêm thư viện MySQL Connector/J vào project (Bước 4). |
| `Unknown database 'restman8'` | Chưa chạy `sql/restman8.sql` (Bước 2). |
| Lỗi `jakarta.servlet` / `ClassNotFoundException: javax.servlet...` khi deploy | Đang dùng Tomcat 10 trở lên. Project cần **Tomcat 9.0**. |
| Lỗi 404 | Sai địa chỉ. Địa chỉ đúng là `http://localhost:8080/NhaHangRestMan/`. |
| Chữ tiếng Việt bị lỗi font trong CSDL | Database chưa được tạo bằng script (script đã đặt `utf8mb4`). Chạy lại `sql/restman8.sql`. |
| Sửa giao diện mà trình duyệt vẫn hiện kiểu cũ | Trình duyệt dùng CSS cũ trong bộ nhớ đệm: bấm **Ctrl + F5**. |

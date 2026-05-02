# BÁO CÁO THIẾT KẾ CƠ SỞ DỮ LIỆU HỆ THỐNG RIKKEI-STORE

## 1. PHÂN TÍCH NGHIỆP VỤ & TÍNH TOÀN VẸN DỮ LIỆU

### Vấn đề: Tại sao không dùng trực tiếp địa chỉ và giá hiện tại của sản phẩm?
Trong thương mại điện tử, dữ liệu được chia làm hai loại:
*   **Dữ liệu thực tế (Linh hoạt):** Giá sản phẩm hôm nay có thể thay đổi, User hôm sau có thể chuyển nhà.
*   **Dữ liệu hóa đơn (Cố định):** Một khi đơn hàng đã chốt, giá tiền và địa chỉ giao hàng tại thời điểm đó phải được "đóng băng".

**Giải pháp:** 
Tôi thiết kế bảng `Order_Details` có cột `unit_price` và bảng `Orders` có cột `shipping_address` riêng. Khi khách bấm đặt hàng, hệ thống sẽ sao chép (copy) dữ liệu từ bảng Sản phẩm và bảng User sang. Điều này đảm bảo báo cáo doanh thu năm sau vẫn chính xác dù giá sản phẩm có tăng hay giảm.



## 2. QUY TRÌNH XỬ LÝ ĐƠN HÀNG (LOGIC)

Để hệ thống vận hành ổn định, tôi tập trung vào 2 quy tắc:
1.  **Kiểm tra tồn kho (Stock Check):** Trước khi tạo đơn, hệ thống phải kiểm tra `stock_quantity >= quantity`. Nếu đủ hàng mới tiến hành trừ kho và tạo hóa đơn. Việc này giúp tránh tình trạng khách đã trả tiền nhưng kho lại hết hàng.
2.  **Quan hệ dữ liệu:** Sử dụng bảng trung gian `Order_Details` để giải quyết quan hệ Nhiều - Nhiều giữa Sản phẩm và Đơn hàng, giúp quản lý chi tiết từng món hàng trong một giỏ hàng lớn.



## 3. GIẢI PHÁP TỐI ƯU KHI DỮ LIỆU LỚN

Khi hệ thống đạt đến hàng triệu đơn hàng, tôi đề xuất 3 phương án xử lý đơn giản nhưng hiệu quả cao:

### A. Tối ưu truy vấn với Index
Sử dụng **B-Tree Index** cho các cột thường xuyên dùng để tìm kiếm và lọc như: `user_id`, `order_date` và `status`. 
*   **Hiệu quả:** Giúp database tìm đích danh dữ liệu mà không cần quét toàn bộ bảng, tăng tốc độ phản hồi từ vài giây xuống vài mili giây.

### B. Chia nhỏ bảng theo tháng 
Thay vì để 1 triệu đơn hàng vào một bảng duy nhất, tôi thực hiện **chia nhỏ bảng `Orders` theo tháng**. 
*   **Hiệu quả:** Khi cần xem lại đơn hàng của tháng 5, hệ thống chỉ cần tìm trong vùng dữ liệu của tháng 5, giúp giảm tải đáng kể cho bộ nhớ và CPU.

### C. Bộ nhớ đệm cho dữ liệu ít thay đổi
Các thông tin như **Danh mục (Categories)** và **Thông tin sản phẩm (Products)** thường được xem rất nhiều nhưng ít khi cập nhật.
*   **Giải pháp:** Đưa các thông tin này lên bộ nhớ đệm . 
*   **Hiệu quả:** Giảm bớt số lượng truy vấn thừa vào database, giúp hệ thống chịu tải tốt hơn khi có nhiều người cùng vào xem hàng một lúc.


**Người thực hiện:** Nguyễn Minh Hiếu  
**Mã sinh viên:** B25DTCN240
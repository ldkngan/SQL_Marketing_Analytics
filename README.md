# SQL_Marketing_Analytics
SQL project analyzing Google Analytics sample data on BigQuery to uncover marketing performance, user behavior, and revenue insights.

# Google Analytics SQL Project

## 📌 Giới thiệu
Đây là project phân tích dữ liệu **Google Analytics sample dataset** trên BigQuery bằng SQL.  
Mục tiêu của project là thực hành kỹ năng truy vấn dữ liệu, tính toán các chỉ số quan trọng trong phân tích hành vi người dùng và thương mại điện tử, đồng thời rút ra insight từ dữ liệu thực tế.  

## 🗂 Dataset
- Nguồn: [Google Analytics Sample Dataset](https://console.cloud.google.com/marketplace/product/google/ga360-data) (BigQuery Public Data)  
- Nội dung: Dữ liệu session năm 2017 của Google Merchandise Store (bao gồm thông tin truy cập, hành vi, giao dịch mua hàng).  
- Bảng chính: `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`

## 🎯 Câu hỏi phân tích & SQL Query

### Q1. Tổng số lượt truy cập (visits), số trang xem (pageviews), và số giao dịch (transactions) trong **tháng 1–3/2017**
**Insight:** Lượt truy cập và số trang xem tăng đều qua từng tháng, cho thấy lưu lượng truy cập đầu năm 2017 có xu hướng tăng trưởng ổn định.

---

### Q2. Tính **bounce rate** (tỷ lệ thoát) theo từng nguồn traffic trong **tháng 7/2017**
**Insight:** Một số nguồn traffic có bounce rate cao bất thường, gợi ý cần tối ưu landing page hoặc cải thiện chất lượng traffic từ nguồn đó.

---

### Q3. Doanh thu (revenue) theo nguồn traffic, theo **tuần** và theo **tháng 6/2017**
**Insight:** Một số nguồn traffic đem lại doanh thu ổn định theo tuần, nhưng có xu hướng khác biệt theo từng tháng → có thể liên quan đến chiến dịch marketing theo thời điểm.

---

### Q4. Trung bình số trang xem theo **loại người dùng (người mua vs không mua)** trong tháng 6–7/2017
**Insight:** Người mua hàng có số trang xem cao hơn rõ rệt so với người không mua → cho thấy mức độ tương tác cao hơn dẫn đến khả năng mua hàng.

---

### Q5. Trung bình số giao dịch trên mỗi người dùng đã mua hàng trong **tháng 7/2017**
**Insight:** Người mua hàng thường thực hiện nhiều hơn 1 giao dịch → có tiềm năng khách hàng trung thành (repeat buyers).

---

### Q6. Trung bình số tiền chi tiêu trên mỗi session của người mua hàng trong **tháng 7/2017**
**Insight:** Giá trị trung bình trên mỗi session của người mua hàng khá cao → cho thấy mức chi tiêu đáng kể cho từng lần ghé thăm.

---

### Q7. Các sản phẩm khác được mua bởi khách hàng đã mua **"YouTube Men's Vintage Henley"** trong **tháng 7/2017**
**Insight:** Khách hàng mua Henley thường có xu hướng mua kèm thêm các sản phẩm khác, gợi ý khả năng cross-sell.

---

### Q8. Tính **cohort map** từ product view → add to cart → purchase trong tháng 1–3/2017
**Insight:** Tỷ lệ chuyển đổi từ product view sang add-to-cart và từ view sang purchase còn thấp, là điểm cần tối ưu trong funnel mua hàng.

---

## 📊 Kỹ năng thể hiện
- SQL: Window functions, CTEs, UNION, JOIN, Aggregate functions  
- Phân tích hành vi khách hàng: bounce rate, funnel conversion, cohort  
- Business insight: hành vi mua hàng, giá trị khách hàng, hiệu quả nguồn traffic  

## 🚀 Hướng phát triển
- Trực quan hóa dữ liệu bằng Power BI/Tableau để làm nổi bật insight  
- Mở rộng phân tích theo cohort dài hạn (LTV, retention rate)  
- Kết hợp thêm mô hình phân tích RFM để phân khúc khách hàng

---

# WMS Pro - Hệ thống Quản lý Kho Chuyên nghiệp

Hệ thống WMS (Warehouse Management System) được phát triển với Vue 3, TypeScript và Element Plus, cung cấp giải pháp quản lý kho hàng toàn diện cho doanh nghiệp.

## 🚀 Tính năng chính

### 📊 Dashboard & Analytics
- **Dashboard tổng quan**: Theo dõi KPI và metrics quan trọng
- **KPI Dashboard**: Phân tích hiệu suất chi tiết với các chỉ số:
  - Vòng quay tồn kho
  - Tỷ lệ hoàn thành đơn hàng  
  - Thời gian picking trung bình
  - Độ chính xác tồn kho
- **Báo cáo phân tích ABC**: Phân loại sản phẩm theo giá trị
- **Dự báo nhu cầu**: Hỗ trợ quyết định mua hàng

### 🏢 Quản lý Kho
- **Multi-warehouse**: Hỗ trợ quản lý nhiều kho
- **Zones & Locations**: Phân chia khu vực và vị trí lưu trữ chi tiết
- **Capacity Management**: Theo dõi công suất sử dụng kho

### 📦 Quản lý Tồn kho
- **Tổng quan tồn kho**: Xem toàn bộ tình trạng tồn kho
- **Phiếu kho**: Quản lý phiếu nhập/xuất/chuyển/điều chỉnh
- **Batch & Serial tracking**: Theo dõi lô hàng và serial number
- **Cycle counting**: Kiểm kê chu kỳ tự động
- **FIFO/LIFO costing**: Tính giá linh hoạt

### 🛒 Quản lý Đơn hàng & Picking  
- **Sales Orders**: Quản lý đơn hàng bán
- **Purchase Orders**: Quản lý đơn đặt hàng
- **Intelligent Picking**: Tối ưu hóa lộ trình picking
- **Task Management**: Giao việc và theo dõi tiến độ
- **Kanban View**: Giao diện trực quan cho picking tasks

### 🚚 Shipping & Logistics
- **Shipment Management**: Quản lý lô hàng xuất
- **Carrier Integration**: Tích hợp đơn vị vận chuyển
- **Package Tracking**: Theo dõi kiện hàng
- **Multi-packaging**: Hỗ trợ nhiều loại đóng gói

### 🔍 Quality Control
- **Inspection Standards**: Thiết lập tiêu chuẩn kiểm tra
- **Quality Workflows**: Quy trình kiểm soát chất lượng
- **Quarantine Management**: Quản lý khu cách ly

### 👥 Partners & Users
- **Supplier Management**: Quản lý nhà cung cấp
- **Customer Management**: Quản lý khách hàng
- **User & Role Management**: Phân quyền chi tiết

### 💰 Cost Management
- **Cost Centers**: Trung tâm chi phí
- **Activity-based Costing**: Tính chi phí theo hoạt động
- **Budget Tracking**: Theo dõi ngân sách

### 📱 Integration & Mobile
- **API Framework**: Tích hợp dễ dàng với hệ thống khác
- **Mobile Support**: Hỗ trợ thiết bị di động
- **Barcode/QR Printing**: In mã vạch tự động
- **Webhook Integration**: Đồng bộ real-time

## 🛠️ Tech Stack

- **Frontend**: Vue 3 + TypeScript + Element Plus
- **State Management**: Pinia
- **Router**: Vue Router 4
- **Build Tool**: Vite
- **Database**: MySQL (thiết kế sẵn)
- **Styling**: SCSS/CSS3 với responsive design

## 📁 Cấu trúc thư mục

```
wms-frontend/
├── src/
│   ├── components/          # Shared components
│   │   ├── Sidebar.vue     # Navigation sidebar
│   │   └── icons/          # Icon components
│   ├── views/              # Page components
│   │   ├── HomeView.vue           # Dashboard chính
│   │   ├── InventoryOverview.vue  # Tổng quan tồn kho
│   │   ├── WarehouseTransactions.vue # Phiếu kho
│   │   ├── PickingTasksView.vue   # Nhiệm vụ picking  
│   │   ├── KPIDashboard.vue       # KPI Analytics
│   │   └── ...                    # Các views khác
│   ├── stores/             # Pinia stores
│   │   ├── warehouse.ts    # Warehouse state management
│   │   └── counter.ts      # Example store
│   ├── router/             # Vue Router config
│   │   └── index.ts        # Route definitions
│   ├── assets/             # Static assets
│   └── main.ts             # App entry point
├── public/                 # Public assets
└── package.json           # Dependencies
```

## 🎨 UI/UX Features

### Design System
- **Modern Interface**: Thiết kế hiện đại, chuyên nghiệp
- **Responsive Design**: Tương thích mọi thiết bị
- **Dark/Light Theme**: Hỗ trợ chế độ sáng/tối
- **Accessible**: Tuân thủ chuẩn accessibility

### Interactive Components
- **Real-time Updates**: Cập nhật dữ liệu thời gian thực
- **Advanced Tables**: Bảng dữ liệu với filter, sort, pagination
- **Interactive Charts**: Biểu đồ tương tác (sẵn sàng tích hợp Chart.js/ECharts)
- **Modal Dialogs**: Dialog chi tiết với UX tốt
- **Kanban Boards**: Giao diện Kanban cho workflow

### Visual Indicators
- **Status Tags**: Thẻ trạng thái màu sắc
- **Progress Bars**: Thanh tiến độ trực quan  
- **Trend Indicators**: Biểu tượng xu hướng tăng/giảm
- **Alert System**: Hệ thống cảnh báo thông minh

## 🚀 Quick Start

### Prerequisites
- Node.js >= 20.19.0
- npm hoặc yarn

### Installation

```bash
# Clone repository
git clone <repository-url>
cd wms-frontend

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Development Commands

```bash
# Development server với hot reload
npm run dev

# Type checking
npm run type-check

# Linting
npm run lint

# Formatting
npm run format

# Unit tests
npm run test:unit
```

## 📊 Demo Data

Hệ thống đã được tích hợp sẵn dữ liệu demo để trải nghiệm:

### Warehouses
- **Kho Hà Nội - Cầu Giấy**: Kho chính miền Bắc
- **Kho TP.HCM - Quận 7**: Kho chính miền Nam  
- **Kho Đà Nẵng - Hải Châu**: Kho chính miền Trung

### Sample Products
- Thực phẩm tươi sống (Sữa, thịt, rau củ)
- Thực phẩm đóng gói (Bánh kẹo, đồ hộp)
- Đồ uống (Nước khoáng, nước ngọt)
- Hóa mỹ phẩm (Dầu gội, kem đánh răng)
- Điện tử (Smartphone, laptop)

### Transaction Types
- **Phiếu nhập**: Nhập hàng từ supplier
- **Phiếu xuất**: Xuất hàng cho customer
- **Phiếu chuyển**: Chuyển kho nội bộ
- **Điều chỉnh**: Điều chỉnh tồn kho
- **Kiểm kê**: Kiểm kê chu kỳ

## 🏗️ Database Integration

Hệ thống được thiết kế để tích hợp với database MySQL hoàn chỉnh:

### Core Tables
- **warehouses**: Thông tin kho
- **products**: Sản phẩm & danh mục
- **inventory_summary**: Tổng kết tồn kho
- **warehouse_transactions**: Phiếu kho
- **picking_tasks**: Nhiệm vụ picking
- **sales_orders**: Đơn hàng bán

### Advanced Features
- **Stored Procedures**: Tối ưu business logic
- **Views**: Báo cáo nhanh
- **Triggers**: Tự động cập nhật
- **Indexes**: Hiệu suất cao

## 🎯 Roadmap

### Phase 1 (Completed ✅)
- [x] Core dashboard với KPI metrics
- [x] Inventory management module
- [x] Warehouse transactions
- [x] Picking tasks với Kanban view
- [x] Advanced analytics dashboard
- [x] Responsive design

### Phase 2 (Planning)
- [ ] Chart integration (Chart.js/ECharts)
- [ ] Real-time notifications
- [ ] Mobile PWA version
- [ ] Advanced reporting exports
- [ ] Multi-language support

### Phase 3 (Future)
- [ ] AI-powered demand forecasting
- [ ] IoT device integration
- [ ] Advanced warehouse automation
- [ ] Machine learning optimization

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

Nếu bạn gặp vấn đề hoặc cần hỗ trợ:

1. Kiểm tra [Issues](../../issues) hiện có
2. Tạo issue mới với mô tả chi tiết
3. Liên hệ team phát triển

---

**WMS Pro** - Giải pháp quản lý kho thông minh cho doanh nghiệp hiện đại! 🚀
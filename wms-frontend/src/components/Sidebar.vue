<template>
  <el-menu
    active-text-color="#ffd04b"
    background-color="#304156"
    class="el-menu-vertical-demo"
    default-active="/"
    text-color="#fff"
    router
    :collapse="isCollapsed"
  >
    <div class="logo-container">
      <img src="@/assets/logo.svg" class="sidebar-logo" />
      <h1 v-if="!isCollapsed" class="sidebar-title">WMS Pro</h1>
    </div>

    <!-- Dashboard -->
    <el-menu-item index="/">
      <el-icon><DataBoard /></el-icon>
      <span>Dashboard</span>
    </el-menu-item>

    <!-- Warehouse Operations -->
    <el-sub-menu index="warehouse">
      <template #title>
        <el-icon><OfficeBuilding /></el-icon>
        <span>Quản lý kho</span>
      </template>
      <el-menu-item index="/warehouses">Danh sách kho</el-menu-item>
      <el-menu-item index="/warehouse-zones">Khu vực kho</el-menu-item>
      <el-menu-item index="/storage-locations">Vị trí lưu trữ</el-menu-item>
    </el-sub-menu>

    <!-- Inventory Management -->
    <el-sub-menu index="inventory">
      <template #title>
        <el-icon><Box /></el-icon>
        <span>Quản lý tồn kho</span>
      </template>
      <el-menu-item index="/inventory/overview">Tổng quan tồn kho</el-menu-item>
      <el-menu-item index="/inventory/transactions">Phiếu kho</el-menu-item>
      <el-menu-item index="/inventory/inbound">Nhập kho</el-menu-item>
      <el-menu-item index="/inventory/outbound">Xuất kho</el-menu-item>
      <el-menu-item index="/inventory/transfer">Chuyển kho</el-menu-item>
      <el-menu-item index="/inventory/adjustments">Điều chỉnh tồn kho</el-menu-item>
      <el-menu-item index="/inventory/cycle-counts">Kiểm kê chu kỳ</el-menu-item>
    </el-sub-menu>

    <!-- Product Management -->
    <el-sub-menu index="products">
      <template #title>
        <el-icon><Goods /></el-icon>
        <span>Quản lý sản phẩm</span>
      </template>
      <el-menu-item index="/products/list">Danh sách sản phẩm</el-menu-item>
      <el-menu-item index="/products/categories">Danh mục sản phẩm</el-menu-item>
      <el-menu-item index="/products/units">Đơn vị tính</el-menu-item>
      <el-menu-item index="/products/suppliers">Nhà cung cấp sản phẩm</el-menu-item>
    </el-sub-menu>

    <!-- Order Management -->
    <el-sub-menu index="orders">
      <template #title>
        <el-icon><Document /></el-icon>
        <span>Quản lý đơn hàng</span>
      </template>
      <el-menu-item index="/orders/sales">Đơn hàng bán</el-menu-item>
      <el-menu-item index="/orders/purchase">Đơn đặt hàng</el-menu-item>
      <el-menu-item index="/orders/allocations">Phân bổ hàng</el-menu-item>
    </el-sub-menu>

    <!-- Picking & Shipping -->
    <el-sub-menu index="picking">
      <template #title>
        <el-icon><TakeawayBox /></el-icon>
        <span>Picking & Vận chuyển</span>
      </template>
      <el-menu-item index="/picking/tasks">Nhiệm vụ picking</el-menu-item>
      <el-menu-item index="/picking/optimization">Tối ưu picking</el-menu-item>
      <el-menu-item index="/shipping/shipments">Lô hàng xuất</el-menu-item>
      <el-menu-item index="/shipping/carriers">Đơn vị vận chuyển</el-menu-item>
      <el-menu-item index="/shipping/packaging">Đóng gói</el-menu-item>
    </el-sub-menu>

    <!-- Quality Control -->
    <el-sub-menu index="quality">
      <template #title>
        <el-icon><Medal /></el-icon>
        <span>Kiểm soát chất lượng</span>
      </template>
      <el-menu-item index="/quality/standards">Tiêu chuẩn chất lượng</el-menu-item>
      <el-menu-item index="/quality/inspections">Kiểm tra chất lượng</el-menu-item>
      <el-menu-item index="/quality/quarantine">Khu cách ly</el-menu-item>
    </el-sub-menu>

    <!-- Partners -->
    <el-sub-menu index="partners">
      <template #title>
        <el-icon><User /></el-icon>
        <span>Đối tác</span>
      </template>
      <el-menu-item index="/suppliers">Nhà cung cấp</el-menu-item>
      <el-menu-item index="/customers">Khách hàng</el-menu-item>
      <el-menu-item index="/carriers">Đơn vị vận chuyển</el-menu-item>
    </el-sub-menu>

    <!-- Analytics & Reports -->
    <el-sub-menu index="analytics">
      <template #title>
        <el-icon><PieChart /></el-icon>
        <span>Phân tích & Báo cáo</span>
      </template>
      <el-menu-item index="/analytics/kpi">KPI Dashboard</el-menu-item>
      <el-menu-item index="/analytics/abc">Phân tích ABC</el-menu-item>
      <el-menu-item index="/analytics/forecasting">Dự báo nhu cầu</el-menu-item>
      <el-menu-item index="/analytics/performance">Hiệu suất hoạt động</el-menu-item>
      <el-menu-item index="/reports/inventory">Báo cáo tồn kho</el-menu-item>
      <el-menu-item index="/reports/sales">Báo cáo bán hàng</el-menu-item>
      <el-menu-item index="/reports/cost">Báo cáo chi phí</el-menu-item>
    </el-sub-menu>

    <!-- Cost Management -->
    <el-sub-menu index="costs">
      <template #title>
        <el-icon><Money /></el-icon>
        <span>Quản lý chi phí</span>
      </template>
      <el-menu-item index="/costs/centers">Trung tâm chi phí</el-menu-item>
      <el-menu-item index="/costs/operations">Chi phí hoạt động</el-menu-item>
      <el-menu-item index="/costs/analysis">Phân tích chi phí</el-menu-item>
    </el-sub-menu>

    <!-- Integration & Mobile -->
    <el-sub-menu index="integration">
      <template #title>
        <el-icon><Connection /></el-icon>
        <span>Tích hợp & Mobile</span>
      </template>
      <el-menu-item index="/integration/api">API tích hợp</el-menu-item>
      <el-menu-item index="/integration/webhooks">Webhook logs</el-menu-item>
      <el-menu-item index="/mobile/devices">Thiết bị di động</el-menu-item>
      <el-menu-item index="/mobile/barcode">In mã vạch</el-menu-item>
    </el-sub-menu>

    <!-- System Settings -->
    <el-sub-menu index="system">
      <template #title>
        <el-icon><Setting /></el-icon>
        <span>Cấu hình hệ thống</span>
      </template>
      <el-menu-item index="/system/users">Quản lý người dùng</el-menu-item>
      <el-menu-item index="/system/roles">Phân quyền</el-menu-item>
      <el-menu-item index="/system/settings">Cài đặt chung</el-menu-item>
      <el-menu-item index="/system/sequences">Số sequence</el-menu-item>
      <el-menu-item index="/system/backup">Sao lưu & Khôi phục</el-menu-item>
    </el-sub-menu>
  </el-menu>
</template>

<script setup lang="ts">
import {
  DataBoard,
  Box,
  Goods,
  PieChart,
  Setting,
  User,
  Avatar,
  OfficeBuilding,
  Document,
  TakeawayBox,
  Medal,
  Money,
  Connection,
} from '@element-plus/icons-vue'

defineProps({
  isCollapsed: {
    type: Boolean,
    default: false,
  },
})
</script>

<style scoped>
.el-menu-vertical-demo {
  min-height: 100vh;
}
.el-menu {
  border-right: none;
}
.logo-container {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background-color: #2b3a4a;
}
.sidebar-logo {
  width: 32px;
  height: 32px;
  margin-right: 12px;
}
.sidebar-title {
  color: #fff;
  font-size: 18px;
  font-weight: 600;
  margin: 0;
  white-space: nowrap;
  transition: opacity 0.3s;
}
</style>

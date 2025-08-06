<template>
  <div class="dashboard-container">
    <!-- Header with warehouse selector -->
    <div class="dashboard-header">
      <h1 class="page-title">Dashboard WMS</h1>
      <div class="header-controls">
        <el-select v-model="selectedWarehouse" placeholder="Chọn kho" style="width: 200px">
          <el-option
            v-for="warehouse in warehouses"
            :key="warehouse.id"
            :label="warehouse.name"
            :value="warehouse.id"
          />
        </el-select>
        <el-button type="primary" @click="refreshData">
          <el-icon><Refresh /></el-icon>
          Làm mới
        </el-button>
      </div>
    </div>

    <!-- KPI Cards -->
    <el-row :gutter="20" class="kpi-cards">
      <el-col :span="6">
        <el-card shadow="hover" class="kpi-card">
          <div class="kpi-content">
            <div class="kpi-icon bg-blue">
              <el-icon size="28"><Box /></el-icon>
            </div>
            <div class="kpi-details">
              <div class="kpi-value">{{ dashboardData.totalProducts.toLocaleString() }}</div>
              <div class="kpi-title">Tổng SKU</div>
              <div class="kpi-trend positive">
                <el-icon><ArrowUp /></el-icon>
                +12 sản phẩm mới
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="kpi-card">
          <div class="kpi-content">
            <div class="kpi-icon bg-green">
              <el-icon size="28"><Download /></el-icon>
            </div>
            <div class="kpi-details">
              <div class="kpi-value">{{ dashboardData.todayInbound.toLocaleString() }}</div>
              <div class="kpi-title">Nhập kho hôm nay</div>
              <div class="kpi-trend positive">
                <el-icon><ArrowUp /></el-icon>
                +18% so với hôm qua
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="kpi-card">
          <div class="kpi-content">
            <div class="kpi-icon bg-orange">
              <el-icon size="28"><Upload /></el-icon>
            </div>
            <div class="kpi-details">
              <div class="kpi-value">{{ dashboardData.todayOutbound.toLocaleString() }}</div>
              <div class="kpi-title">Xuất kho hôm nay</div>
              <div class="kpi-trend negative">
                <el-icon><ArrowDown /></el-icon>
                -5% so với hôm qua
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="kpi-card">
          <div class="kpi-content">
            <div class="kpi-icon bg-red">
              <el-icon size="28"><Warning /></el-icon>
            </div>
            <div class="kpi-details">
              <div class="kpi-value">{{ dashboardData.lowStock }}</div>
              <div class="kpi-title">Cảnh báo tồn kho</div>
              <div class="kpi-trend neutral">
                {{ dashboardData.lowStock }} sản phẩm dưới mức tối thiểu
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Main content row -->
    <el-row :gutter="20" class="content-row">
      <!-- Inventory Overview Chart -->
      <el-col :span="16">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="card-header">
              <span class="card-title">Biểu đồ nhập xuất 30 ngày</span>
              <el-button-group size="small">
                <el-button :type="chartPeriod === '7d' ? 'primary' : ''" @click="chartPeriod = '7d'">7 ngày</el-button>
                <el-button :type="chartPeriod === '30d' ? 'primary' : ''" @click="chartPeriod = '30d'">30 ngày</el-button>
                <el-button :type="chartPeriod === '90d' ? 'primary' : ''" @click="chartPeriod = '90d'">90 ngày</el-button>
              </el-button-group>
            </div>
          </template>
          <div class="chart-container">
            <!-- Chart placeholder - would integrate with a chart library -->
            <div class="chart-content">
              <div class="chart-placeholder">
                <el-icon size="48" color="#ddd"><TrendCharts /></el-icon>
                <p>Biểu đồ sẽ hiển thị thống kê nhập/xuất kho theo thời gian</p>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- Warehouse Status -->
      <el-col :span="8">
        <el-card shadow="never" class="status-card">
          <template #header>
            <span class="card-title">Trạng thái kho</span>
          </template>
          <div class="warehouse-status">
            <div class="status-item">
              <div class="status-label">Tỷ lệ sử dụng</div>
              <el-progress
                :percentage="dashboardData.warehouseUtilization"
                :color="getUtilizationColor(dashboardData.warehouseUtilization)"
                :stroke-width="8"
              />
              <div class="status-detail">
                {{ dashboardData.usedCapacity }}m³ / {{ dashboardData.totalCapacity }}m³
              </div>
            </div>

            <div class="status-item">
              <div class="status-label">Giá trị tồn kho</div>
              <div class="status-value">{{ formatCurrency(dashboardData.inventoryValue) }}</div>
            </div>

            <div class="status-item">
              <div class="status-label">Tổng đơn hàng đang xử lý</div>
              <div class="status-value">{{ dashboardData.activeOrders }}</div>
            </div>

            <div class="status-item">
              <div class="status-label">Nhiệm vụ picking</div>
              <div class="status-value">{{ dashboardData.activePicking }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Bottom row -->
    <el-row :gutter="20" class="bottom-row">
      <!-- Recent Activities -->
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <span class="card-title">Hoạt động gần đây</span>
          </template>
          <div class="activity-list">
            <div
              v-for="activity in recentActivities"
              :key="activity.id"
              class="activity-item"
            >
              <div class="activity-icon" :class="`activity-${activity.type}`">
                <el-icon><component :is="getActivityIcon(activity.type)" /></el-icon>
              </div>
              <div class="activity-content">
                <div class="activity-title">{{ activity.title }}</div>
                <div class="activity-desc">{{ activity.description }}</div>
                <div class="activity-time">{{ formatTime(activity.timestamp) }}</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- Expiring Products -->
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-title">Sản phẩm sắp hết hạn</span>
              <el-button type="text" @click="viewAllExpiring">Xem tất cả</el-button>
            </div>
          </template>
          <div class="expiring-list">
            <div
              v-for="item in expiringProducts"
              :key="item.id"
              class="expiring-item"
            >
              <div class="expiring-info">
                <div class="product-sku">{{ item.sku }}</div>
                <div class="product-name">{{ item.name }}</div>
                <div class="batch-info">Lô: {{ item.batchNumber }}</div>
              </div>
              <div class="expiring-details">
                <div class="quantity">{{ item.quantity.toLocaleString() }} {{ item.unit }}</div>
                <div class="expiry-date" :class="getExpiryClass(item.daysToExpiry)">
                  {{ item.daysToExpiry }} ngày
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import {
  Refresh, Box, Download, Upload, Warning, ArrowUp, ArrowDown,
  TrendCharts, Plus, Minus, Clock, Check
} from '@element-plus/icons-vue'

// Reactive data
const selectedWarehouse = ref(1)
const chartPeriod = ref('30d')

const warehouses = ref([
  { id: 1, name: 'Kho Hà Nội - Cầu Giấy', code: 'WH-HN01' },
  { id: 2, name: 'Kho TP.HCM - Quận 7', code: 'WH-HCM01' },
  { id: 3, name: 'Kho Đà Nẵng - Hải Châu', code: 'WH-DN01' }
])

const dashboardData = reactive({
  totalProducts: 1847,
  todayInbound: 68,
  todayOutbound: 45,
  lowStock: 23,
  warehouseUtilization: 78,
  usedCapacity: 3420,
  totalCapacity: 4380,
  inventoryValue: 2850000000,
  activeOrders: 156,
  activePicking: 23
})

const recentActivities = ref([
  {
    id: 1,
    type: 'inbound',
    title: 'Nhập kho PO-2024001234',
    description: 'Nhận 150 sản phẩm từ nhà cung cấp ABC Corp',
    timestamp: new Date(Date.now() - 30 * 60 * 1000)
  },
  {
    id: 2,
    type: 'outbound',
    title: 'Xuất kho SO-2024005678',
    description: 'Giao 85 sản phẩm cho khách hàng XYZ Ltd',
    timestamp: new Date(Date.now() - 45 * 60 * 1000)
  },
  {
    id: 3,
    type: 'picking',
    title: 'Hoàn thành picking PK-001234',
    description: 'Picking 12 đơn hàng trong khu vực A-Zone',
    timestamp: new Date(Date.now() - 60 * 60 * 1000)
  },
  {
    id: 4,
    type: 'adjustment',
    title: 'Điều chỉnh tồn kho',
    description: 'Cập nhật 5 sản phẩm sau kiểm kê',
    timestamp: new Date(Date.now() - 90 * 60 * 1000)
  }
])

const expiringProducts = ref([
  {
    id: 1,
    sku: 'PRD-001234',
    name: 'Sữa tươi Vinamilk 1L',
    batchNumber: 'BT20241215',
    quantity: 150,
    unit: 'hộp',
    daysToExpiry: 3
  },
  {
    id: 2,
    sku: 'PRD-005678',
    name: 'Bánh mì sandwich',
    batchNumber: 'BT20241220',
    quantity: 80,
    unit: 'gói',
    daysToExpiry: 7
  },
  {
    id: 3,
    sku: 'PRD-009012',
    name: 'Thịt bò tươi',
    batchNumber: 'BT20241218',
    quantity: 25,
    unit: 'kg',
    daysToExpiry: 5
  },
  {
    id: 4,
    sku: 'PRD-003456',
    name: 'Rau xanh hữu cơ',
    batchNumber: 'BT20241216',
    quantity: 200,
    unit: 'kg',
    daysToExpiry: 2
  }
])

// Methods
const refreshData = () => {
  // Simulate data refresh
  console.log('Refreshing dashboard data...')
}

const getUtilizationColor = (percentage: number) => {
  if (percentage >= 90) return '#F56C6C'
  if (percentage >= 75) return '#E6A23C'
  return '#67C23A'
}

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(value)
}

const formatTime = (date: Date) => {
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)

  if (minutes < 60) return `${minutes} phút trước`
  if (hours < 24) return `${hours} giờ trước`
  return date.toLocaleDateString('vi-VN')
}

const getActivityIcon = (type: string) => {
  const iconMap: Record<string, any> = {
    inbound: Download,
    outbound: Upload,
    picking: Check,
    adjustment: Plus
  }
  return iconMap[type] || Clock
}

const getExpiryClass = (days: number) => {
  if (days <= 3) return 'expiry-critical'
  if (days <= 7) return 'expiry-warning'
  return 'expiry-normal'
}

const viewAllExpiring = () => {
  // Navigate to expiring products page
  console.log('Navigate to expiring products page')
}

onMounted(() => {
  // Load initial data
  console.log('Dashboard mounted')
})
</script>

<style scoped>
.dashboard-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 0;
}

/* Dashboard Header */
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  margin: 0;
  color: #303133;
  font-size: 28px;
  font-weight: 600;
}

.header-controls {
  display: flex;
  gap: 12px;
  align-items: center;
}

/* KPI Cards */
.kpi-cards {
  margin-bottom: 20px;
}

.kpi-card {
  border: none;
  transition: all 0.3s ease;
}

.kpi-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.kpi-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.kpi-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.bg-blue {
  background: linear-gradient(135deg, #409EFF 0%, #337ecc 100%);
}
.bg-green {
  background: linear-gradient(135deg, #67C23A 0%, #529b2e 100%);
}
.bg-orange {
  background: linear-gradient(135deg, #E6A23C 0%, #b88230 100%);
}
.bg-red {
  background: linear-gradient(135deg, #F56C6C 0%, #c45656 100%);
}

.kpi-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.kpi-value {
  font-size: 32px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}

.kpi-title {
  color: #606266;
  font-size: 14px;
  font-weight: 500;
  margin: 0;
}

.kpi-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 500;
}

.kpi-trend.positive { color: #67C23A; }
.kpi-trend.negative { color: #F56C6C; }
.kpi-trend.neutral { color: #909399; }

/* Content rows */
.content-row, .bottom-row {
  margin-bottom: 20px;
}

/* Card headers */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

/* Chart card */
.chart-card {
  height: 400px;
}

.chart-container {
  height: 320px;
  position: relative;
}

.chart-content {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chart-placeholder {
  text-align: center;
  color: #909399;
}

.chart-placeholder p {
  margin: 12px 0 0 0;
  font-size: 14px;
}

/* Warehouse Status */
.status-card {
  height: 400px;
}

.warehouse-status {
  display: flex;
  flex-direction: column;
  gap: 24px;
  height: 320px;
}

.status-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.status-label {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
}

.status-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
}

.status-detail {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

/* Activity List */
.activity-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-height: 400px;
  overflow-y: auto;
}

.activity-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  border-radius: 8px;
  background-color: #fafafa;
  border: 1px solid #f0f0f0;
  transition: all 0.2s ease;
}

.activity-item:hover {
  background-color: #f5f7fa;
  transform: translateX(4px);
}

.activity-icon {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.activity-inbound { background-color: #67C23A; }
.activity-outbound { background-color: #E6A23C; }
.activity-picking { background-color: #409EFF; }
.activity-adjustment { background-color: #909399; }

.activity-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.activity-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.activity-desc {
  font-size: 13px;
  color: #606266;
}

.activity-time {
  font-size: 12px;
  color: #909399;
}

/* Expiring Products */
.expiring-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 400px;
  overflow-y: auto;
}

.expiring-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #f0f0f0;
  background-color: #fafafa;
  transition: all 0.2s ease;
}

.expiring-item:hover {
  background-color: #f5f7fa;
  border-color: #e4e7ed;
}

.expiring-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.product-sku {
  font-size: 13px;
  color: #909399;
  font-weight: 500;
}

.product-name {
  font-size: 14px;
  color: #303133;
  font-weight: 600;
}

.batch-info {
  font-size: 12px;
  color: #606266;
}

.expiring-details {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 4px;
}

.quantity {
  font-size: 13px;
  color: #606266;
  font-weight: 500;
}

.expiry-date {
  font-size: 12px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 12px;
}

.expiry-critical {
  background-color: #fef0f0;
  color: #F56C6C;
}

.expiry-warning {
  background-color: #fdf6ec;
  color: #E6A23C;
}

.expiry-normal {
  background-color: #f0f9ff;
  color: #409EFF;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .kpi-cards .el-col {
    margin-bottom: 12px;
  }

  .content-row .el-col,
  .bottom-row .el-col {
    margin-bottom: 20px;
  }
}

@media (max-width: 768px) {
  .dashboard-header {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }

  .header-controls {
    width: 100%;
    justify-content: space-between;
  }

  .page-title {
    font-size: 24px;
  }

  .kpi-content {
    gap: 12px;
  }

  .kpi-icon {
    width: 48px;
    height: 48px;
  }

  .kpi-value {
    font-size: 24px;
  }
}
</style>

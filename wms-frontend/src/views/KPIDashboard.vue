<template>
  <div class="kpi-dashboard">
    <!-- Page Header -->
    <div class="page-header">
      <div class="header-left">
        <h1 class="page-title">KPI Dashboard</h1>
        <p class="page-description">Theo dõi các chỉ số hiệu suất quan trọng của hệ thống kho</p>
      </div>
      <div class="header-actions">
        <el-select v-model="selectedWarehouse" placeholder="Chọn kho" style="width: 200px">
          <el-option
            v-for="warehouse in warehouses"
            :key="warehouse.id"
            :label="warehouse.name"
            :value="warehouse.id"
          />
        </el-select>
        <el-select v-model="selectedPeriod" placeholder="Thời gian" style="width: 150px">
          <el-option label="Hôm nay" value="today" />
          <el-option label="7 ngày" value="7days" />
          <el-option label="30 ngày" value="30days" />
          <el-option label="90 ngày" value="90days" />
          <el-option label="Năm nay" value="year" />
        </el-select>
        <el-button type="primary" @click="refreshData">
          <el-icon><Refresh /></el-icon>
          Làm mới
        </el-button>
        <el-button @click="exportReport">
          <el-icon><Download /></el-icon>
          Xuất báo cáo
        </el-button>
      </div>
    </div>

    <!-- Core KPIs -->
    <div class="kpi-section">
      <h2 class="section-title">Chỉ số hiệu suất cốt lõi</h2>
      <el-row :gutter="20" class="core-kpis">
        <el-col :span="6">
          <el-card shadow="hover" class="kpi-card">
            <div class="kpi-content">
              <div class="kpi-header">
                <div class="kpi-icon bg-blue">
                  <el-icon size="32"><TrendCharts /></el-icon>
                </div>
                <div class="kpi-trend" :class="getTrendClass(kpiData.inventoryTurnover.trend)">
                  <el-icon><component :is="getTrendIcon(kpiData.inventoryTurnover.trend)" /></el-icon>
                  {{ Math.abs(kpiData.inventoryTurnover.change) }}%
                </div>
              </div>
              <div class="kpi-details">
                <div class="kpi-value">{{ kpiData.inventoryTurnover.value.toFixed(2) }}</div>
                <div class="kpi-label">Vòng quay tồn kho</div>
                <div class="kpi-target">
                  Mục tiêu: {{ kpiData.inventoryTurnover.target }} lần/năm
                </div>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :span="6">
          <el-card shadow="hover" class="kpi-card">
            <div class="kpi-content">
              <div class="kpi-header">
                <div class="kpi-icon bg-green">
                  <el-icon size="32"><Check /></el-icon>
                </div>
                <div class="kpi-trend" :class="getTrendClass(kpiData.orderFulfillment.trend)">
                  <el-icon><component :is="getTrendIcon(kpiData.orderFulfillment.trend)" /></el-icon>
                  {{ Math.abs(kpiData.orderFulfillment.change) }}%
                </div>
              </div>
              <div class="kpi-details">
                <div class="kpi-value">{{ kpiData.orderFulfillment.value.toFixed(1) }}%</div>
                <div class="kpi-label">Tỷ lệ hoàn thành đơn hàng</div>
                <div class="kpi-target">
                  Mục tiêu: {{ kpiData.orderFulfillment.target }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :span="6">
          <el-card shadow="hover" class="kpi-card">
            <div class="kpi-content">
              <div class="kpi-header">
                <div class="kpi-icon bg-orange">
                  <el-icon size="32"><Timer /></el-icon>
                </div>
                <div class="kpi-trend" :class="getTrendClass(kpiData.avgPickTime.trend)">
                  <el-icon><component :is="getTrendIcon(kpiData.avgPickTime.trend)" /></el-icon>
                  {{ Math.abs(kpiData.avgPickTime.change) }}%
                </div>
              </div>
              <div class="kpi-details">
                <div class="kpi-value">{{ kpiData.avgPickTime.value.toFixed(1) }}m</div>
                <div class="kpi-label">Thời gian picking TB</div>
                <div class="kpi-target">
                  Mục tiêu: ≤ {{ kpiData.avgPickTime.target }}m
                </div>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :span="6">
          <el-card shadow="hover" class="kpi-card">
            <div class="kpi-content">
              <div class="kpi-header">
                <div class="kpi-icon bg-purple">
                  <el-icon size="32"><Aim /></el-icon>
                </div>
                <div class="kpi-trend" :class="getTrendClass(kpiData.inventoryAccuracy.trend)">
                  <el-icon><component :is="getTrendIcon(kpiData.inventoryAccuracy.trend)" /></el-icon>
                  {{ Math.abs(kpiData.inventoryAccuracy.change) }}%
                </div>
              </div>
              <div class="kpi-details">
                <div class="kpi-value">{{ kpiData.inventoryAccuracy.value.toFixed(1) }}%</div>
                <div class="kpi-label">Độ chính xác tồn kho</div>
                <div class="kpi-target">
                  Mục tiêu: ≥ {{ kpiData.inventoryAccuracy.target }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Operational KPIs -->
    <div class="kpi-section">
      <h2 class="section-title">Chỉ số hoạt động</h2>
      <el-row :gutter="20" class="operational-kpis">
        <el-col :span="8">
          <el-card shadow="never" class="metric-card">
            <template #header>
              <span class="metric-title">Hiệu suất kho</span>
            </template>
            <div class="metrics-grid">
              <div class="metric-item">
                <div class="metric-label">Tỷ lệ sử dụng kho</div>
                <div class="metric-value">
                  <el-progress
                    :percentage="operationalKPIs.warehouseUtilization"
                    :color="getUtilizationColor(operationalKPIs.warehouseUtilization)"
                    :stroke-width="8"
                  />
                  <span class="metric-number">{{ operationalKPIs.warehouseUtilization }}%</span>
                </div>
              </div>
              <div class="metric-item">
                <div class="metric-label">Số lần chuyển động/ngày</div>
                <div class="metric-value">
                  <span class="metric-number large">{{ operationalKPIs.dailyMovements.toLocaleString() }}</span>
                  <span class="metric-trend positive">+12%</span>
                </div>
              </div>
              <div class="metric-item">
                <div class="metric-label">Giá trị tồn kho</div>
                <div class="metric-value">
                  <span class="metric-number large">{{ formatCurrency(operationalKPIs.inventoryValue) }}</span>
                  <span class="metric-trend positive">+3.2%</span>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :span="8">
          <el-card shadow="never" class="metric-card">
            <template #header>
              <span class="metric-title">Hiệu suất nhân sự</span>
            </template>
            <div class="metrics-grid">
              <div class="metric-item">
                <div class="metric-label">Năng suất picking (items/h)</div>
                <div class="metric-value">
                  <span class="metric-number large">{{ operationalKPIs.pickingProductivity }}</span>
                  <span class="metric-trend positive">+8%</span>
                </div>
              </div>
              <div class="metric-item">
                <div class="metric-label">Tỷ lệ lỗi picking</div>
                <div class="metric-value">
                  <span class="metric-number large">{{ operationalKPIs.pickingErrorRate }}%</span>
                  <span class="metric-trend negative">-0.3%</span>
                </div>
              </div>
              <div class="metric-item">
                <div class="metric-label">Số nhân viên active</div>
                <div class="metric-value">
                  <span class="metric-number large">{{ operationalKPIs.activeStaff }}</span>
                  <span class="metric-trend neutral">{{ operationalKPIs.totalStaff }} total</span>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :span="8">
          <el-card shadow="never" class="metric-card">
            <template #header>
              <span class="metric-title">Chất lượng dịch vụ</span>
            </template>
            <div class="metrics-grid">
              <div class="metric-item">
                <div class="metric-label">On-time delivery rate</div>
                <div class="metric-value">
                  <span class="metric-number large">{{ operationalKPIs.onTimeDelivery }}%</span>
                  <span class="metric-trend positive">+2.1%</span>
                </div>
              </div>
              <div class="metric-item">
                <div class="metric-label">Customer satisfaction</div>
                <div class="metric-value">
                  <el-rate
                    v-model="operationalKPIs.customerSatisfaction"
                    disabled
                    show-score
                    text-color="#ff9900"
                    score-template="{value}"
                  />
                </div>
              </div>
              <div class="metric-item">
                <div class="metric-label">Damage rate</div>
                <div class="metric-value">
                  <span class="metric-number large">{{ operationalKPIs.damageRate }}%</span>
                  <span class="metric-trend positive">-0.2%</span>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Charts Section -->
    <div class="charts-section">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card shadow="never" class="chart-card">
            <template #header>
              <div class="chart-header">
                <span class="chart-title">Xu hướng KPI theo thời gian</span>
                <el-select v-model="trendChartMetric" size="small" style="width: 180px">
                  <el-option label="Vòng quay tồn kho" value="turnover" />
                  <el-option label="Order fulfillment" value="fulfillment" />
                  <el-option label="Thời gian picking" value="picktime" />
                  <el-option label="Độ chính xác" value="accuracy" />
                </el-select>
              </div>
            </template>
            <div class="chart-container">
              <div class="chart-placeholder">
                <el-icon size="48" color="#ddd"><TrendCharts /></el-icon>
                <p>Biểu đồ xu hướng KPI sẽ hiển thị ở đây</p>
                <p class="chart-note">Tích hợp với thư viện chart như Chart.js hoặc ECharts</p>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :span="12">
          <el-card shadow="never" class="chart-card">
            <template #header>
              <div class="chart-header">
                <span class="chart-title">So sánh hiệu suất theo kho</span>
                <el-select v-model="compareMetric" size="small" style="width: 180px">
                  <el-option label="Vòng quay tồn kho" value="turnover" />
                  <el-option label="Năng suất picking" value="productivity" />
                  <el-option label="Tỷ lệ sử dụng" value="utilization" />
                  <el-option label="Độ chính xác" value="accuracy" />
                </el-select>
              </div>
            </template>
            <div class="chart-container">
              <div class="warehouse-comparison">
                <div
                  v-for="warehouse in warehouseComparison"
                  :key="warehouse.id"
                  class="warehouse-item"
                >
                  <div class="warehouse-info">
                    <span class="warehouse-name">{{ warehouse.name }}</span>
                    <span class="warehouse-value">{{ warehouse.value }}{{ warehouse.unit }}</span>
                  </div>
                  <el-progress
                    :percentage="warehouse.percentage"
                    :color="warehouse.color"
                    :stroke-width="12"
                    :show-text="false"
                  />
                  <div class="warehouse-rank">
                    <el-tag :type="getRankTagType(warehouse.rank)" size="small">
                      #{{ warehouse.rank }}
                    </el-tag>
                  </div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Alert & Issues Section -->
    <div class="alerts-section">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card shadow="never" class="alerts-card">
            <template #header>
              <div class="alerts-header">
                <span class="alerts-title">Cảnh báo KPI</span>
                <el-badge :value="kpiAlerts.length" class="alerts-badge" />
              </div>
            </template>
            <div class="alerts-list">
              <div
                v-for="alert in kpiAlerts"
                :key="alert.id"
                class="alert-item"
                :class="`alert-${alert.severity}`"
              >
                <div class="alert-icon">
                  <el-icon><component :is="getAlertIcon(alert.severity)" /></el-icon>
                </div>
                <div class="alert-content">
                  <div class="alert-title">{{ alert.title }}</div>
                  <div class="alert-description">{{ alert.description }}</div>
                  <div class="alert-time">{{ formatTime(alert.timestamp) }}</div>
                </div>
                <div class="alert-actions">
                  <el-button size="small" type="primary" @click="handleAlert(alert)">
                    Xử lý
                  </el-button>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :span="12">
          <el-card shadow="never" class="recommendations-card">
            <template #header>
              <span class="recommendations-title">Khuyến nghị cải thiện</span>
            </template>
            <div class="recommendations-list">
              <div
                v-for="recommendation in recommendations"
                :key="recommendation.id"
                class="recommendation-item"
              >
                <div class="recommendation-icon">
                  <el-icon><Lightning /></el-icon>
                </div>
                <div class="recommendation-content">
                  <div class="recommendation-title">{{ recommendation.title }}</div>
                  <div class="recommendation-description">{{ recommendation.description }}</div>
                  <div class="recommendation-impact">
                    Tác động ước tính: <span class="impact-value">{{ recommendation.impact }}</span>
                  </div>
                </div>
                <div class="recommendation-priority">
                  <el-tag :type="getPriorityTagType(recommendation.priority)" size="small">
                    {{ recommendation.priority }}
                  </el-tag>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import {
  Refresh, Download, TrendCharts, Check, Timer, Aim, ArrowUp,
  ArrowDown, Minus, Warning, CircleClose, Lightning
} from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

// Reactive data
const selectedWarehouse = ref(1)
const selectedPeriod = ref('30days')
const trendChartMetric = ref('turnover')
const compareMetric = ref('turnover')

const warehouses = ref([
  { id: 1, name: 'Tất cả kho' },
  { id: 2, name: 'Kho Hà Nội - Cầu Giấy' },
  { id: 3, name: 'Kho TP.HCM - Quận 7' },
  { id: 4, name: 'Kho Đà Nẵng - Hải Châu' }
])

const kpiData = reactive({
  inventoryTurnover: {
    value: 8.5,
    target: 12,
    trend: 'up',
    change: 15.2
  },
  orderFulfillment: {
    value: 96.8,
    target: 98,
    trend: 'up',
    change: 2.1
  },
  avgPickTime: {
    value: 12.3,
    target: 10,
    trend: 'down',
    change: -8.5
  },
  inventoryAccuracy: {
    value: 99.2,
    target: 99.5,
    trend: 'up',
    change: 0.3
  }
})

const operationalKPIs = reactive({
  warehouseUtilization: 78,
  dailyMovements: 2847,
  inventoryValue: 2850000000,
  pickingProductivity: 145,
  pickingErrorRate: 0.8,
  activeStaff: 24,
  totalStaff: 32,
  onTimeDelivery: 94.5,
  customerSatisfaction: 4.2,
  damageRate: 0.3
})

const warehouseComparison = ref([
  {
    id: 1,
    name: 'Kho Hà Nội',
    value: 9.2,
    unit: ' lần/năm',
    percentage: 92,
    color: '#67C23A',
    rank: 1
  },
  {
    id: 2,
    name: 'Kho TP.HCM',
    value: 8.8,
    unit: ' lần/năm',
    percentage: 88,
    color: '#409EFF',
    rank: 2
  },
  {
    id: 3,
    name: 'Kho Đà Nẵng',
    value: 7.1,
    unit: ' lần/năm',
    percentage: 71,
    color: '#E6A23C',
    rank: 3
  }
])

const kpiAlerts = ref([
  {
    id: 1,
    severity: 'critical',
    title: 'Vòng quay tồn kho thấp',
    description: 'Kho Đà Nẵng có vòng quay tồn kho chỉ 7.1 lần/năm, thấp hơn mục tiêu 40%',
    timestamp: new Date(Date.now() - 30 * 60 * 1000)
  },
  {
    id: 2,
    severity: 'warning',
    title: 'Thời gian picking tăng',
    description: 'Thời gian picking trung bình tăng 12% so với tuần trước',
    timestamp: new Date(Date.now() - 60 * 60 * 1000)
  },
  {
    id: 3,
    severity: 'info',
    title: 'Cần kiểm kê chu kỳ',
    description: '15 sản phẩm chưa được kiểm kê trong 3 tháng qua',
    timestamp: new Date(Date.now() - 120 * 60 * 1000)
  }
])

const recommendations = ref([
  {
    id: 1,
    title: 'Tối ưu hóa layout kho',
    description: 'Sắp xếp lại vị trí sản phẩm theo tần suất xuất để giảm thời gian picking',
    impact: '+15% năng suất picking',
    priority: 'High'
  },
  {
    id: 2,
    title: 'Tăng cường training nhân viên',
    description: 'Đào tạo kỹ năng picking và sử dụng thiết bị di động hiệu quả hơn',
    impact: '+8% độ chính xác',
    priority: 'Medium'
  },
  {
    id: 3,
    title: 'Đầu tư hệ thống WMS nâng cao',
    description: 'Nâng cấp tính năng tự động tối ưu lộ trình và dự báo nhu cầu',
    impact: '+20% hiệu suất tổng thể',
    priority: 'High'
  }
])

// Methods
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

const getTrendClass = (trend: string) => {
  return {
    'trend-up': trend === 'up',
    'trend-down': trend === 'down',
    'trend-stable': trend === 'stable'
  }
}

const getTrendIcon = (trend: string) => {
  const iconMap: Record<string, any> = {
    up: ArrowUp,
    down: ArrowDown,
    stable: Minus
  }
  return iconMap[trend] || Minus
}

const getUtilizationColor = (percentage: number) => {
  if (percentage >= 90) return '#F56C6C'
  if (percentage >= 75) return '#E6A23C'
  return '#67C23A'
}

const getRankTagType = (rank: number) => {
  if (rank === 1) return 'success'
  if (rank === 2) return 'warning'
  return 'danger'
}

const getAlertIcon = (severity: string) => {
  const iconMap: Record<string, any> = {
    critical: CircleClose,
    warning: Warning,
    info: Lightning
  }
  return iconMap[severity] || Warning
}

const getPriorityTagType = (priority: string) => {
  const priorityMap: Record<string, string> = {
    High: 'danger',
    Medium: 'warning',
    Low: 'info'
  }
  return priorityMap[priority] || ''
}

const refreshData = () => {
  ElMessage.success('Dữ liệu KPI đã được cập nhật')
}

const exportReport = () => {
  ElMessage.success('Đang xuất báo cáo KPI...')
}

const handleAlert = (alert: any) => {
  ElMessage.info(`Xử lý cảnh báo: ${alert.title}`)
}

onMounted(() => {
  // Load KPI data
  console.log('KPI Dashboard mounted')
})
</script>

<style scoped>
.kpi-dashboard {
  padding: 0;
}

/* Page Header */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
}

.header-left {
  flex: 1;
}

.page-title {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 600;
  color: #303133;
}

.page-description {
  margin: 0;
  color: #606266;
  font-size: 14px;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

/* KPI Sections */
.kpi-section {
  margin-bottom: 32px;
}

.section-title {
  margin: 0 0 20px 0;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

/* Core KPIs */
.core-kpis .kpi-card {
  border: none;
  transition: all 0.3s ease;
}

.core-kpis .kpi-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1);
}

.kpi-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.kpi-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.kpi-icon {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.bg-blue { background: linear-gradient(135deg, #409EFF 0%, #337ecc 100%); }
.bg-green { background: linear-gradient(135deg, #67C23A 0%, #529b2e 100%); }
.bg-orange { background: linear-gradient(135deg, #E6A23C 0%, #b88230 100%); }
.bg-purple { background: linear-gradient(135deg, #9C27B0 0%, #7B1FA2 100%); }

.kpi-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
  font-weight: 600;
  padding: 4px 8px;
  border-radius: 12px;
}

.trend-up {
  color: #67C23A;
  background-color: #f0f9ff;
}

.trend-down {
  color: #F56C6C;
  background-color: #fef0f0;
}

.trend-stable {
  color: #909399;
  background-color: #f4f4f5;
}

.kpi-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.kpi-value {
  font-size: 36px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}

.kpi-label {
  font-size: 16px;
  font-weight: 600;
  color: #606266;
}

.kpi-target {
  font-size: 13px;
  color: #909399;
}

/* Operational KPIs */
.metric-card {
  height: 300px;
}

.metric-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.metrics-grid {
  display: flex;
  flex-direction: column;
  gap: 20px;
  height: 220px;
}

.metric-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.metric-label {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
}

.metric-value {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.metric-number {
  font-size: 18px;
  font-weight: 700;
  color: #303133;
}

.metric-number.large {
  font-size: 24px;
}

.metric-trend {
  font-size: 12px;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 8px;
}

.metric-trend.positive {
  color: #67C23A;
  background-color: #f0f9ff;
}

.metric-trend.negative {
  color: #F56C6C;
  background-color: #fef0f0;
}

.metric-trend.neutral {
  color: #909399;
  background-color: #f4f4f5;
}

/* Charts Section */
.charts-section {
  margin-bottom: 32px;
}

.chart-card {
  height: 400px;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.chart-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.chart-container {
  height: 320px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chart-placeholder {
  text-align: center;
  color: #909399;
}

.chart-placeholder p {
  margin: 12px 0;
  font-size: 14px;
}

.chart-note {
  font-size: 12px;
  color: #C0C4CC;
}

/* Warehouse Comparison */
.warehouse-comparison {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.warehouse-item {
  display: flex;
  align-items: center;
  gap: 16px;
}

.warehouse-info {
  min-width: 120px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.warehouse-name {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
}

.warehouse-value {
  font-size: 16px;
  color: #303133;
  font-weight: 700;
}

.warehouse-rank {
  min-width: 40px;
}

/* Alerts Section */
.alerts-section {
  margin-bottom: 32px;
}

.alerts-card, .recommendations-card {
  height: 400px;
}

.alerts-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.alerts-title, .recommendations-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.alerts-list, .recommendations-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  height: 320px;
  overflow-y: auto;
}

.alert-item, .recommendation-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 16px;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  background-color: #fafafa;
}

.alert-critical {
  border-color: #F56C6C;
  background-color: #fef0f0;
}

.alert-warning {
  border-color: #E6A23C;
  background-color: #fdf6ec;
}

.alert-info {
  border-color: #409EFF;
  background-color: #ecf5ff;
}

.alert-icon, .recommendation-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.alert-critical .alert-icon {
  background-color: #F56C6C;
}

.alert-warning .alert-icon {
  background-color: #E6A23C;
}

.alert-info .alert-icon {
  background-color: #409EFF;
}

.recommendation-icon {
  background-color: #67C23A;
}

.alert-content, .recommendation-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.alert-title, .recommendation-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.alert-description, .recommendation-description {
  font-size: 13px;
  color: #606266;
  line-height: 1.4;
}

.alert-time {
  font-size: 12px;
  color: #909399;
}

.recommendation-impact {
  font-size: 12px;
  color: #606266;
}

.impact-value {
  color: #67C23A;
  font-weight: 600;
}

.alert-actions, .recommendation-priority {
  flex-shrink: 0;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .core-kpis .el-col,
  .operational-kpis .el-col {
    margin-bottom: 16px;
  }

  .charts-section .el-col,
  .alerts-section .el-col {
    margin-bottom: 20px;
  }
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }

  .header-actions {
    flex-wrap: wrap;
    gap: 8px;
  }

  .kpi-content {
    gap: 12px;
  }

  .kpi-header {
    flex-direction: column;
    gap: 12px;
    align-items: center;
  }

  .kpi-icon {
    width: 48px;
    height: 48px;
  }

  .kpi-value {
    font-size: 28px;
  }

  .metric-card,
  .chart-card,
  .alerts-card,
  .recommendations-card {
    height: auto;
    min-height: 250px;
  }
}
</style>

<template>
  <div class="performance-analytics-page">
    <!-- Header Section -->
    <div class="page-header">
      <div class="header-content">
        <div class="title-section">
          <h1 class="page-title">Phân tích Hiệu suất</h1>
          <p class="page-description">Phân tích và đánh giá hiệu suất hoạt động warehouse với KPI chuyên sâu</p>
        </div>
        <div class="header-actions">
          <el-button type="primary" @click="generateReport" :loading="generating">
            <el-icon><DataAnalysis /></el-icon>
            Tạo báo cáo
          </el-button>
          <el-button @click="exportDashboard">
            <el-icon><Download /></el-icon>
            Xuất dashboard
          </el-button>
          <el-button @click="scheduledReports">
            <el-icon><Timer /></el-icon>
            Báo cáo định kỳ
          </el-button>
        </div>
      </div>
    </div>

    <!-- Time Range & Filters -->
    <div class="filters-section">
      <el-card>
        <div class="filters-row">
          <div class="filter-item">
            <label>Thời gian:</label>
            <el-date-picker
              v-model="dateRange"
              type="daterange"
              range-separator="đến"
              start-placeholder="Ngày bắt đầu"
              end-placeholder="Ngày kết thúc"
              @change="updateAnalytics"
            />
          </div>
          <div class="filter-item">
            <label>Kho:</label>
            <el-select v-model="selectedWarehouse" @change="updateAnalytics" multiple collapse-tags>
              <el-option label="Tất cả kho" :value="0" />
              <el-option
                v-for="warehouse in warehouses"
                :key="warehouse.id"
                :label="warehouse.name"
                :value="warehouse.id"
              />
            </el-select>
          </div>
          <div class="filter-item">
            <label>Phân tích:</label>
            <el-select v-model="analysisType" @change="updateAnalytics">
              <el-option label="Tổng quan" value="overview" />
              <el-option label="Hiệu suất kho" value="warehouse" />
              <el-option label="Hiệu suất nhân viên" value="staff" />
              <el-option label="Hiệu suất thiết bị" value="equipment" />
              <el-option label="Đơn hàng" value="orders" />
            </el-select>
          </div>
          <div class="filter-item">
            <label>So sánh:</label>
            <el-select v-model="comparisonPeriod">
              <el-option label="Không so sánh" value="" />
              <el-option label="Tháng trước" value="previous_month" />
              <el-option label="Quý trước" value="previous_quarter" />
              <el-option label="Năm trước" value="previous_year" />
              <el-option label="Tùy chỉnh" value="custom" />
            </el-select>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Performance Overview -->
    <div class="overview-section">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card class="kpi-card efficiency">
            <div class="kpi-content">
              <div class="kpi-icon">
                <el-icon><TrendCharts /></el-icon>
              </div>
              <div class="kpi-details">
                <div class="kpi-value">{{ overviewMetrics.efficiency }}%</div>
                <div class="kpi-label">Hiệu suất tổng thể</div>
                <div class="kpi-trend" :class="overviewMetrics.efficiency_trend">
                  <el-icon v-if="overviewMetrics.efficiency_trend === 'up'"><ArrowUp /></el-icon>
                  <el-icon v-else-if="overviewMetrics.efficiency_trend === 'down'"><ArrowDown /></el-icon>
                  <el-icon v-else><Minus /></el-icon>
                  {{ overviewMetrics.efficiency_change }}%
                </div>
              </div>
            </div>
            <div class="kpi-chart">
              <el-progress
                type="circle"
                :percentage="overviewMetrics.efficiency"
                :width="60"
                :color="getEfficiencyColor(overviewMetrics.efficiency)"
                :show-text="false"
              />
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="kpi-card throughput">
            <div class="kpi-content">
              <div class="kpi-icon">
                <el-icon><Odometer /></el-icon>
              </div>
              <div class="kpi-details">
                <div class="kpi-value">{{ formatNumber(overviewMetrics.throughput) }}</div>
                <div class="kpi-label">Throughput (đơn/ngày)</div>
                <div class="kpi-trend" :class="overviewMetrics.throughput_trend">
                  <el-icon v-if="overviewMetrics.throughput_trend === 'up'"><ArrowUp /></el-icon>
                  <el-icon v-else-if="overviewMetrics.throughput_trend === 'down'"><ArrowDown /></el-icon>
                  <el-icon v-else><Minus /></el-icon>
                  {{ overviewMetrics.throughput_change }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="kpi-card accuracy">
            <div class="kpi-content">
              <div class="kpi-icon">
                <el-icon><Aim /></el-icon>
              </div>
              <div class="kpi-details">
                <div class="kpi-value">{{ overviewMetrics.accuracy }}%</div>
                <div class="kpi-label">Độ chính xác</div>
                <div class="kpi-trend" :class="overviewMetrics.accuracy_trend">
                  <el-icon v-if="overviewMetrics.accuracy_trend === 'up'"><ArrowUp /></el-icon>
                  <el-icon v-else-if="overviewMetrics.accuracy_trend === 'down'"><ArrowDown /></el-icon>
                  <el-icon v-else><Minus /></el-icon>
                  {{ overviewMetrics.accuracy_change }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="kpi-card utilization">
            <div class="kpi-content">
              <div class="kpi-icon">
                <el-icon><PieChart /></el-icon>
              </div>
              <div class="kpi-details">
                <div class="kpi-value">{{ overviewMetrics.utilization }}%</div>
                <div class="kpi-label">Tỷ lệ sử dụng</div>
                <div class="kpi-trend" :class="overviewMetrics.utilization_trend">
                  <el-icon v-if="overviewMetrics.utilization_trend === 'up'"><ArrowUp /></el-icon>
                  <el-icon v-else-if="overviewMetrics.utilization_trend === 'down'"><ArrowDown /></el-icon>
                  <el-icon v-else><Minus /></el-icon>
                  {{ overviewMetrics.utilization_change }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Detailed KPI Dashboard -->
    <div class="kpi-dashboard">
      <el-row :gutter="20">
        <el-col :span="16">
          <el-card>
            <template #header>
              <div class="chart-header">
                <span>Biểu đồ Hiệu suất Theo thời gian</span>
                <div class="chart-controls">
                  <el-button-group>
                    <el-button size="small" @click="chartPeriod = 'day'" :type="chartPeriod === 'day' ? 'primary' : ''">
                      Ngày
                    </el-button>
                    <el-button size="small" @click="chartPeriod = 'week'" :type="chartPeriod === 'week' ? 'primary' : ''">
                      Tuần
                    </el-button>
                    <el-button size="small" @click="chartPeriod = 'month'" :type="chartPeriod === 'month' ? 'primary' : ''">
                      Tháng
                    </el-button>
                  </el-button-group>
                  <el-select v-model="chartMetric" size="small" style="width: 150px; margin-left: 8px;">
                    <el-option label="Hiệu suất" value="efficiency" />
                    <el-option label="Throughput" value="throughput" />
                    <el-option label="Độ chính xác" value="accuracy" />
                    <el-option label="Utilization" value="utilization" />
                  </el-select>
                </div>
              </div>
            </template>
            <div class="performance-chart">
              <canvas ref="performanceCanvas" width="600" height="300"></canvas>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Top Performers</span>
            </template>
            <div class="top-performers">
              <div class="performer-item" v-for="performer in topPerformers" :key="performer.id">
                <div class="performer-rank">{{ performer.rank }}</div>
                <div class="performer-info">
                  <div class="performer-name">{{ performer.name }}</div>
                  <div class="performer-type">{{ performer.type }}</div>
                </div>
                <div class="performer-score">
                  <div class="score-value">{{ performer.score }}</div>
                  <div class="score-unit">{{ performer.unit }}</div>
                </div>
                <div class="performer-trend">
                  <el-icon v-if="performer.trend === 'up'" color="#67C23A"><ArrowUp /></el-icon>
                  <el-icon v-else-if="performer.trend === 'down'" color="#F56C6C"><ArrowDown /></el-icon>
                  <el-icon v-else color="#909399"><Minus /></el-icon>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Advanced Analytics -->
    <div class="advanced-analytics">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Phân tích Bottleneck</span>
            </template>
            <div class="bottleneck-analysis">
              <div class="bottleneck-item" v-for="bottleneck in bottlenecks" :key="bottleneck.id">
                <div class="bottleneck-header">
                  <div class="bottleneck-icon" :class="bottleneck.severity">
                    <el-icon v-if="bottleneck.severity === 'critical'"><CircleClose /></el-icon>
                    <el-icon v-else-if="bottleneck.severity === 'high'"><Warning /></el-icon>
                    <el-icon v-else><InfoFilled /></el-icon>
                  </div>
                  <div class="bottleneck-info">
                    <div class="bottleneck-process">{{ bottleneck.process }}</div>
                    <div class="bottleneck-impact">Tác động: {{ bottleneck.impact }}%</div>
                  </div>
                </div>
                <div class="bottleneck-details">
                  <div class="bottleneck-cause">{{ bottleneck.cause }}</div>
                  <div class="bottleneck-recommendation">{{ bottleneck.recommendation }}</div>
                </div>
                <div class="bottleneck-metrics">
                  <div class="metric">
                    <span class="metric-label">Thời gian chờ:</span>
                    <span class="metric-value">{{ bottleneck.waiting_time }}h</span>
                  </div>
                  <div class="metric">
                    <span class="metric-label">Tần suất:</span>
                    <span class="metric-value">{{ bottleneck.frequency }}%</span>
                  </div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Productivity Analysis</span>
            </template>
            <div class="productivity-analysis">
              <div class="productivity-chart">
                <canvas ref="productivityCanvas" width="300" height="200"></canvas>
              </div>
              <div class="productivity-metrics">
                <div class="metric-row" v-for="metric in productivityMetrics" :key="metric.name">
                  <div class="metric-name">{{ metric.name }}</div>
                  <div class="metric-progress">
                    <el-progress
                      :percentage="metric.value"
                      :color="getMetricColor(metric.value)"
                      :stroke-width="6"
                    />
                  </div>
                  <div class="metric-target">Target: {{ metric.target }}%</div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Cost Efficiency</span>
            </template>
            <div class="cost-efficiency">
              <div class="cost-overview">
                <div class="cost-metric">
                  <div class="cost-label">Chi phí/đơn hàng</div>
                  <div class="cost-value">{{ formatCurrency(costMetrics.cost_per_order) }}</div>
                  <div class="cost-trend" :class="costMetrics.cost_trend">
                    <el-icon v-if="costMetrics.cost_trend === 'down'"><ArrowDown /></el-icon>
                    <el-icon v-else-if="costMetrics.cost_trend === 'up'"><ArrowUp /></el-icon>
                    <el-icon v-else><Minus /></el-icon>
                    {{ costMetrics.cost_change }}%
                  </div>
                </div>
                <div class="cost-metric">
                  <div class="cost-label">Chi phí/m³</div>
                  <div class="cost-value">{{ formatCurrency(costMetrics.cost_per_unit) }}</div>
                  <div class="cost-trend" :class="costMetrics.unit_trend">
                    <el-icon v-if="costMetrics.unit_trend === 'down'"><ArrowDown /></el-icon>
                    <el-icon v-else-if="costMetrics.unit_trend === 'up'"><ArrowUp /></el-icon>
                    <el-icon v-else><Minus /></el-icon>
                    {{ costMetrics.unit_change }}%
                  </div>
                </div>
              </div>
              <div class="cost-breakdown">
                <canvas ref="costCanvas" width="300" height="150"></canvas>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Detailed Performance Table -->
    <el-card class="performance-table">
      <template #header>
        <div class="table-header">
          <span>Chi tiết Hiệu suất {{ getAnalysisTypeLabel(analysisType) }}</span>
          <div class="table-actions">
            <el-input
              v-model="searchText"
              placeholder="Tìm kiếm..."
              style="width: 200px; margin-right: 12px"
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
            <el-select v-model="performanceFilter" placeholder="Lọc hiệu suất" style="width: 120px; margin-right: 12px">
              <el-option label="Tất cả" value="" />
              <el-option label="Xuất sắc" value="excellent" />
              <el-option label="Tốt" value="good" />
              <el-option label="Trung bình" value="average" />
              <el-option label="Cần cải thiện" value="poor" />
            </el-select>
            <el-button @click="refreshTable">
              <el-icon><Refresh /></el-icon>
            </el-button>
          </div>
        </div>
      </template>

      <el-table
        :data="paginatedPerformanceData"
        v-loading="loading"
        height="400"
        @sort-change="handleSort"
        row-class-name="performance-row"
      >
        <el-table-column type="index" label="#" width="50" />
        <el-table-column prop="name" label="Tên" min-width="200" sortable="custom" />
        <el-table-column prop="type" label="Loại" width="120">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.type)" size="small">{{ getTypeLabel(row.type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="efficiency" label="Hiệu suất" width="120" sortable="custom">
          <template #default="{ row }">
            <div class="efficiency-cell">
              <el-progress
                :percentage="row.efficiency"
                :color="getEfficiencyColor(row.efficiency)"
                :stroke-width="6"
                :show-text="false"
              />
              <span class="efficiency-text">{{ row.efficiency }}%</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="throughput" label="Throughput" width="120" sortable="custom">
          <template #default="{ row }">
            {{ formatNumber(row.throughput) }} {{ row.throughput_unit }}
          </template>
        </el-table-column>
        <el-table-column prop="accuracy" label="Độ chính xác" width="120" sortable="custom">
          <template #default="{ row }">
            {{ row.accuracy }}%
          </template>
        </el-table-column>
        <el-table-column prop="utilization" label="Tỷ lệ sử dụng" width="120" sortable="custom">
          <template #default="{ row }">
            {{ row.utilization }}%
          </template>
        </el-table-column>
        <el-table-column prop="cost_per_unit" label="Chi phí/đơn vị" width="140" sortable="custom">
          <template #default="{ row }">
            {{ formatCurrency(row.cost_per_unit) }}
          </template>
        </el-table-column>
        <el-table-column prop="trend" label="Xu hướng" width="100">
          <template #default="{ row }">
            <div class="trend-cell" :class="row.trend">
              <el-icon v-if="row.trend === 'up'"><ArrowUp /></el-icon>
              <el-icon v-else-if="row.trend === 'down'"><ArrowDown /></el-icon>
              <el-icon v-else><Minus /></el-icon>
              <span>{{ row.trend_value }}%</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="rating" label="Đánh giá" width="120">
          <template #default="{ row }">
            <el-tag :type="getRatingTagType(row.rating)">{{ getRatingLabel(row.rating) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="Thao tác" width="160" fixed="right">
          <template #default="{ row }">
            <el-button-group>
              <el-button size="small" @click="viewDetails(row)">
                <el-icon><View /></el-icon>
              </el-button>
              <el-button size="small" type="primary" @click="optimizePerformance(row)">
                <el-icon><Tools /></el-icon>
              </el-button>
              <el-button size="small" type="warning" @click="createAlert(row)">
                <el-icon><Bell /></el-icon>
              </el-button>
            </el-button-group>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[20, 50, 100]"
          :total="totalPerformanceItems"
          layout="total, sizes, prev, pager, next, jumper"
        />
      </div>
    </el-card>

    <!-- Performance Details Dialog -->
    <el-dialog
      v-model="showDetailsDialog"
      :title="selectedItem?.name || 'Chi tiết Hiệu suất'"
      width="900px"
    >
      <div v-if="selectedItem" class="performance-details">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-card>
              <template #header>
                <span>Thông tin Cơ bản</span>
              </template>
              <el-descriptions :column="1">
                <el-descriptions-item label="Tên">{{ selectedItem.name }}</el-descriptions-item>
                <el-descriptions-item label="Loại">{{ getTypeLabel(selectedItem.type) }}</el-descriptions-item>
                <el-descriptions-item label="Hiệu suất">{{ selectedItem.efficiency }}%</el-descriptions-item>
                <el-descriptions-item label="Throughput">{{ formatNumber(selectedItem.throughput) }} {{ selectedItem.throughput_unit }}</el-descriptions-item>
                <el-descriptions-item label="Độ chính xác">{{ selectedItem.accuracy }}%</el-descriptions-item>
                <el-descriptions-item label="Tỷ lệ sử dụng">{{ selectedItem.utilization }}%</el-descriptions-item>
                <el-descriptions-item label="Đánh giá">
                  <el-tag :type="getRatingTagType(selectedItem.rating)">
                    {{ getRatingLabel(selectedItem.rating) }}
                  </el-tag>
                </el-descriptions-item>
              </el-descriptions>
            </el-card>
          </el-col>
          <el-col :span="12">
            <el-card>
              <template #header>
                <span>Metrics Chi tiết</span>
              </template>
              <div class="detailed-metrics">
                <div class="metric-item" v-for="metric in selectedItem.detailed_metrics" :key="metric.name">
                  <div class="metric-header">
                    <span class="metric-name">{{ metric.name }}</span>
                    <span class="metric-value">{{ metric.value }} {{ metric.unit }}</span>
                  </div>
                  <div class="metric-bar">
                    <el-progress
                      :percentage="metric.percentage"
                      :color="getMetricColor(metric.percentage)"
                      :stroke-width="6"
                    />
                  </div>
                  <div class="metric-benchmark">
                    Benchmark: {{ metric.benchmark }} {{ metric.unit }}
                  </div>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <el-card style="margin-top: 20px;">
          <template #header>
            <span>Biểu đồ Hiệu suất Theo thời gian</span>
          </template>
          <div class="detail-chart">
            <canvas ref="detailCanvas" width="800" height="300"></canvas>
          </div>
        </el-card>

        <el-card style="margin-top: 20px;">
          <template #header>
            <span>Khuyến nghị Cải thiện</span>
          </template>
          <div class="recommendations">
            <div v-for="rec in selectedItem.recommendations" :key="rec.id" class="recommendation">
              <div class="rec-priority" :class="rec.priority">
                {{ rec.priority.toUpperCase() }}
              </div>
              <div class="rec-content">
                <div class="rec-title">{{ rec.title }}</div>
                <div class="rec-description">{{ rec.description }}</div>
                <div class="rec-impact">Tác động dự kiến: {{ rec.impact }}</div>
              </div>
              <div class="rec-actions">
                <el-button size="small" type="primary">Thực hiện</el-button>
                <el-button size="small">Bỏ qua</el-button>
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  DataAnalysis, Download, Timer, TrendCharts, Odometer, Aim, PieChart,
  ArrowUp, ArrowDown, Minus, CircleClose, Warning, InfoFilled,
  Search, Refresh, View, Tools, Bell
} from '@element-plus/icons-vue'

// Reactive data
const generating = ref(false)
const loading = ref(false)
const searchText = ref('')
const performanceFilter = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const showDetailsDialog = ref(false)
const selectedItem = ref<any>(null)
const dateRange = ref([])
const selectedWarehouse = ref([0])
const analysisType = ref('overview')
const comparisonPeriod = ref('')
const chartPeriod = ref('day')
const chartMetric = ref('efficiency')

// Sample data
const warehouses = ref([
  { id: 1, name: 'Kho Thành Phẩm Hà Nội' },
  { id: 2, name: 'Kho Nguyên Liệu TP.HCM' },
  { id: 3, name: 'Kho Lạnh Đà Nẵng' }
])

const overviewMetrics = reactive({
  efficiency: 87.5,
  efficiency_trend: 'up',
  efficiency_change: 5.2,
  throughput: 1248,
  throughput_trend: 'up',
  throughput_change: 8.7,
  accuracy: 94.2,
  accuracy_trend: 'stable',
  accuracy_change: 0.5,
  utilization: 78.9,
  utilization_trend: 'down',
  utilization_change: -2.1
})

const topPerformers = ref([
  {
    id: 1,
    rank: 1,
    name: 'Nguyễn Văn A',
    type: 'Nhân viên',
    score: 95.8,
    unit: '%',
    trend: 'up'
  },
  {
    id: 2,
    rank: 2,
    name: 'Kho Hà Nội',
    type: 'Kho',
    score: 92.3,
    unit: '%',
    trend: 'up'
  },
  {
    id: 3,
    rank: 3,
    name: 'Máy Picking 01',
    type: 'Thiết bị',
    score: 89.7,
    unit: '%',
    trend: 'stable'
  },
  {
    id: 4,
    rank: 4,
    name: 'Trần Thị B',
    type: 'Nhân viên',
    score: 88.1,
    unit: '%',
    trend: 'up'
  },
  {
    id: 5,
    rank: 5,
    name: 'Zone A-01',
    type: 'Khu vực',
    score: 85.4,
    unit: '%',
    trend: 'down'
  }
])

const bottlenecks = ref([
  {
    id: 1,
    process: 'Picking Process',
    severity: 'critical',
    impact: 35,
    cause: 'Thiếu nhân viên picking vào giờ cao điểm',
    recommendation: 'Tăng 2-3 nhân viên shift 2, sắp xếp lại layout picking',
    waiting_time: 2.5,
    frequency: 78
  },
  {
    id: 2,
    process: 'Receiving',
    severity: 'high',
    impact: 22,
    cause: 'Quy trình kiểm tra hàng nhập chậm',
    recommendation: 'Tự động hóa quá trình scan barcode, tối ưu workflow',
    waiting_time: 1.8,
    frequency: 45
  },
  {
    id: 3,
    process: 'Packing',
    severity: 'medium',
    impact: 15,
    cause: 'Thiếu vật tư đóng gói',
    recommendation: 'Cải thiện quản lý tồn kho vật tư, dự báo nhu cầu',
    waiting_time: 0.7,
    frequency: 32
  }
])

const productivityMetrics = ref([
  { name: 'Pick Rate', value: 87, target: 90 },
  { name: 'Pack Rate', value: 92, target: 95 },
  { name: 'Put-away Rate', value: 78, target: 85 },
  { name: 'Cycle Count Accuracy', value: 96, target: 98 },
  { name: 'Order Fulfillment', value: 89, target: 95 }
])

const costMetrics = reactive({
  cost_per_order: 45000,
  cost_trend: 'down',
  cost_change: -3.2,
  cost_per_unit: 12000,
  unit_trend: 'up',
  unit_change: 1.8
})

const performanceData = ref([
  {
    id: 1,
    name: 'Nguyễn Văn A',
    type: 'staff',
    efficiency: 95.8,
    throughput: 145,
    throughput_unit: 'đơn/ngày',
    accuracy: 98.5,
    utilization: 87.2,
    cost_per_unit: 35000,
    trend: 'up',
    trend_value: 5.2,
    rating: 'excellent',
    detailed_metrics: [
      { name: 'Pick Rate', value: 125, unit: 'items/hour', percentage: 95, benchmark: 120 },
      { name: 'Error Rate', value: 0.5, unit: '%', percentage: 98, benchmark: 1.0 },
      { name: 'Attendance', value: 98, unit: '%', percentage: 98, benchmark: 95 }
    ],
    recommendations: [
      {
        id: 1,
        priority: 'low',
        title: 'Tiếp tục duy trì hiệu suất',
        description: 'Nhân viên đang có hiệu suất xuất sắc, cần duy trì và chia sẻ kinh nghiệm',
        impact: 'Cải thiện team performance 10%'
      }
    ]
  },
  {
    id: 2,
    name: 'Kho Hà Nội',
    type: 'warehouse',
    efficiency: 92.3,
    throughput: 1200,
    throughput_unit: 'đơn/ngày',
    accuracy: 94.7,
    utilization: 85.6,
    cost_per_unit: 42000,
    trend: 'up',
    trend_value: 3.8,
    rating: 'excellent',
    detailed_metrics: [
      { name: 'Space Utilization', value: 85, unit: '%', percentage: 85, benchmark: 80 },
      { name: 'Order Cycle Time', value: 2.5, unit: 'hours', percentage: 88, benchmark: 3.0 },
      { name: 'Inventory Accuracy', value: 99, unit: '%', percentage: 99, benchmark: 98 }
    ],
    recommendations: [
      {
        id: 1,
        priority: 'medium',
        title: 'Tối ưu layout kho',
        description: 'Cải thiện bố trí kho để tăng hiệu suất picking',
        impact: 'Giảm 15% thời gian picking'
      }
    ]
  },
  {
    id: 3,
    name: 'Máy Picking 01',
    type: 'equipment',
    efficiency: 89.7,
    throughput: 350,
    throughput_unit: 'items/hour',
    accuracy: 99.2,
    utilization: 76.3,
    cost_per_unit: 25000,
    trend: 'stable',
    trend_value: 0.2,
    rating: 'good',
    detailed_metrics: [
      { name: 'Uptime', value: 95, unit: '%', percentage: 95, benchmark: 92 },
      { name: 'Speed', value: 350, unit: 'items/hour', percentage: 87, benchmark: 400 },
      { name: 'Accuracy', value: 99.2, unit: '%', percentage: 99, benchmark: 98 }
    ],
    recommendations: []
  }
])

// Canvas refs
const performanceCanvas = ref<HTMLCanvasElement>()
const productivityCanvas = ref<HTMLCanvasElement>()
const costCanvas = ref<HTMLCanvasElement>()
const detailCanvas = ref<HTMLCanvasElement>()

// Computed properties
const filteredPerformanceData = computed(() => {
  let filtered = performanceData.value

  if (searchText.value) {
    const search = searchText.value.toLowerCase()
    filtered = filtered.filter(item =>
      item.name.toLowerCase().includes(search)
    )
  }

  if (performanceFilter.value) {
    filtered = filtered.filter(item => item.rating === performanceFilter.value)
  }

  return filtered
})

const paginatedPerformanceData = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredPerformanceData.value.slice(start, end)
})

const totalPerformanceItems = computed(() => filteredPerformanceData.value.length)

// Methods
const getEfficiencyColor = (efficiency: number) => {
  if (efficiency >= 90) return '#67C23A'
  if (efficiency >= 70) return '#E6A23C'
  return '#F56C6C'
}

const getMetricColor = (value: number) => {
  if (value >= 90) return '#67C23A'
  if (value >= 70) return '#E6A23C'
  return '#F56C6C'
}

const getTypeTagType = (type: string) => {
  const types: Record<string, string> = {
    staff: 'success',
    warehouse: 'primary',
    equipment: 'warning',
    zone: 'info'
  }
  return types[type] || ''
}

const getTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    staff: 'Nhân viên',
    warehouse: 'Kho',
    equipment: 'Thiết bị',
    zone: 'Khu vực'
  }
  return labels[type] || type
}

const getRatingTagType = (rating: string) => {
  const types: Record<string, string> = {
    excellent: 'success',
    good: 'primary',
    average: 'warning',
    poor: 'danger'
  }
  return types[rating] || ''
}

const getRatingLabel = (rating: string) => {
  const labels: Record<string, string> = {
    excellent: 'Xuất sắc',
    good: 'Tốt',
    average: 'Trung bình',
    poor: 'Cần cải thiện'
  }
  return labels[rating] || rating
}

const getAnalysisTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    overview: 'Tổng quan',
    warehouse: 'Kho',
    staff: 'Nhân viên',
    equipment: 'Thiết bị',
    orders: 'Đơn hàng'
  }
  return labels[type] || type
}

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(amount)
}

const formatNumber = (num: number) => {
  return new Intl.NumberFormat('vi-VN').format(num)
}

const updateAnalytics = () => {
  loading.value = true
  setTimeout(() => {
    loading.value = false
    drawCharts()
  }, 1000)
}

const generateReport = async () => {
  generating.value = true
  try {
    await new Promise(resolve => setTimeout(resolve, 2000))
    ElMessage.success('Báo cáo hiệu suất đã được tạo')
  } finally {
    generating.value = false
  }
}

const exportDashboard = () => {
  ElMessage.success('Đang xuất dashboard...')
}

const scheduledReports = () => {
  ElMessage.info('Chức năng báo cáo định kỳ đang phát triển')
}

const refreshTable = () => {
  loading.value = true
  setTimeout(() => {
    loading.value = false
  }, 1000)
}

const handleSort = (sort: any) => {
  console.log('Sort:', sort)
}

const viewDetails = (item: any) => {
  selectedItem.value = item
  showDetailsDialog.value = true
  nextTick(() => {
    drawDetailChart()
  })
}

const optimizePerformance = (item: any) => {
  ElMessage.info(`Tối ưu hiệu suất cho: ${item.name}`)
}

const createAlert = (item: any) => {
  ElMessage.info(`Tạo cảnh báo cho: ${item.name}`)
}

// Chart drawing functions
const drawCharts = () => {
  drawPerformanceChart()
  drawProductivityChart()
  drawCostChart()
}

const drawPerformanceChart = () => {
  if (!performanceCanvas.value) return
  const ctx = performanceCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 600, 300)

  // Draw performance trend
  ctx.strokeStyle = '#409EFF'
  ctx.lineWidth = 3
  ctx.beginPath()
  ctx.moveTo(50, 150)

  // Sample performance data points
  const points = [150, 145, 160, 155, 170, 165, 180, 175, 190, 185]
  points.forEach((y, i) => {
    ctx.lineTo(50 + i * 55, y)
  })
  ctx.stroke()

  // Draw target line
  ctx.strokeStyle = '#67C23A'
  ctx.lineWidth = 2
  ctx.setLineDash([5, 5])
  ctx.beginPath()
  ctx.moveTo(50, 120)
  ctx.lineTo(545, 120)
  ctx.stroke()
  ctx.setLineDash([])

  // Labels
  ctx.fillStyle = '#303133'
  ctx.font = '12px Arial'
  ctx.fillText('Target: 90%', 450, 115)

  // Add data points
  ctx.fillStyle = '#409EFF'
  points.forEach((y, i) => {
    ctx.beginPath()
    ctx.arc(50 + i * 55, y, 4, 0, Math.PI * 2)
    ctx.fill()
  })
}

const drawProductivityChart = () => {
  if (!productivityCanvas.value) return
  const ctx = productivityCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 300, 200)

  // Draw radar chart for productivity metrics
  const centerX = 150
  const centerY = 100
  const radius = 70
  const angles = productivityMetrics.value.map((_, i) => (i * 2 * Math.PI) / productivityMetrics.value.length)

  // Draw background grid
  ctx.strokeStyle = '#E4E7ED'
  ctx.lineWidth = 1
  for (let r = 20; r <= radius; r += 20) {
    ctx.beginPath()
    ctx.arc(centerX, centerY, r, 0, Math.PI * 2)
    ctx.stroke()
  }

  // Draw data polygon
  ctx.strokeStyle = '#409EFF'
  ctx.fillStyle = 'rgba(64, 158, 255, 0.2)'
  ctx.lineWidth = 2
  ctx.beginPath()
  productivityMetrics.value.forEach((metric, i) => {
    const angle = angles[i]
    const r = (metric.value / 100) * radius
    const x = centerX + Math.cos(angle - Math.PI / 2) * r
    const y = centerY + Math.sin(angle - Math.PI / 2) * r

    if (i === 0) ctx.moveTo(x, y)
    else ctx.lineTo(x, y)
  })
  ctx.closePath()
  ctx.fill()
  ctx.stroke()
}

const drawCostChart = () => {
  if (!costCanvas.value) return
  const ctx = costCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 300, 150)

  // Draw cost breakdown pie chart
  const centerX = 150
  const centerY = 75
  const radius = 50

  const costs = [
    { label: 'Labor', value: 40, color: '#409EFF' },
    { label: 'Equipment', value: 25, color: '#67C23A' },
    { label: 'Space', value: 20, color: '#E6A23C' },
    { label: 'Utilities', value: 15, color: '#F56C6C' }
  ]

  let currentAngle = 0
  costs.forEach(cost => {
    const sliceAngle = (cost.value / 100) * 2 * Math.PI

    ctx.beginPath()
    ctx.moveTo(centerX, centerY)
    ctx.arc(centerX, centerY, radius, currentAngle, currentAngle + sliceAngle)
    ctx.fillStyle = cost.color
    ctx.fill()

    currentAngle += sliceAngle
  })
}

const drawDetailChart = () => {
  if (!detailCanvas.value) return
  const ctx = detailCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 800, 300)

  // Draw detailed performance over time
  ctx.strokeStyle = '#409EFF'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.moveTo(50, 150)

  // Sample detailed data
  const detailPoints = [150, 145, 155, 160, 165, 170, 175, 180, 185, 190, 195, 200]
  detailPoints.forEach((y, i) => {
    ctx.lineTo(50 + i * 60, y)
  })
  ctx.stroke()

  // Add data points
  ctx.fillStyle = '#409EFF'
  detailPoints.forEach((y, i) => {
    ctx.beginPath()
    ctx.arc(50 + i * 60, y, 3, 0, Math.PI * 2)
    ctx.fill()
  })
}

onMounted(() => {
  updateAnalytics()
})
</script>

<style scoped>
.performance-analytics-page {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title-section h1 {
  margin: 0 0 5px 0;
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
}

.filters-section {
  margin-bottom: 20px;
}

.filters-row {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.filter-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-item label {
  font-size: 14px;
  color: #606266;
  white-space: nowrap;
  min-width: 80px;
}

.overview-section {
  margin-bottom: 20px;
}

.kpi-card {
  height: 120px;
  position: relative;
}

.kpi-card.efficiency { border-left: 4px solid #409EFF; }
.kpi-card.throughput { border-left: 4px solid #67C23A; }
.kpi-card.accuracy { border-left: 4px solid #E6A23C; }
.kpi-card.utilization { border-left: 4px solid #F56C6C; }

.kpi-content {
  display: flex;
  align-items: center;
  gap: 16px;
  height: 100%;
}

.kpi-icon {
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
}

.kpi-details {
  flex: 1;
}

.kpi-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
  margin-bottom: 4px;
}

.kpi-label {
  font-size: 14px;
  color: #606266;
  margin-bottom: 4px;
}

.kpi-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 600;
}

.kpi-trend.up { color: #67C23A; }
.kpi-trend.down { color: #F56C6C; }
.kpi-trend.stable { color: #909399; }

.kpi-chart {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
}

.kpi-dashboard {
  margin-bottom: 20px;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.performance-chart {
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
}

.top-performers {
  padding: 16px 0;
}

.performer-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-bottom: 1px solid #f0f0f0;
  transition: all 0.3s ease;
}

.performer-item:hover {
  background: #f8f9fa;
}

.performer-rank {
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #409eff;
  color: white;
  border-radius: 50%;
  font-size: 12px;
  font-weight: 600;
}

.performer-info {
  flex: 1;
}

.performer-name {
  font-weight: 600;
  color: #303133;
  margin-bottom: 2px;
}

.performer-type {
  font-size: 12px;
  color: #909399;
}

.performer-score {
  text-align: right;
}

.score-value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.score-unit {
  font-size: 12px;
  color: #909399;
}

.performer-trend {
  width: 20px;
  display: flex;
  justify-content: center;
}

.advanced-analytics {
  margin-bottom: 20px;
}

.bottleneck-analysis {
  padding: 16px 0;
}

.bottleneck-item {
  margin-bottom: 20px;
  padding: 16px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
}

.bottleneck-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.bottleneck-icon {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
}

.bottleneck-icon.critical {
  background: #fef0f0;
  color: #f56c6c;
}

.bottleneck-icon.high {
  background: #fdf6ec;
  color: #e6a23c;
}

.bottleneck-icon.medium {
  background: #f0f9ff;
  color: #409eff;
}

.bottleneck-info {
  flex: 1;
}

.bottleneck-process {
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.bottleneck-impact {
  font-size: 12px;
  color: #f56c6c;
  font-weight: 600;
}

.bottleneck-details {
  margin-bottom: 12px;
}

.bottleneck-cause {
  font-size: 14px;
  color: #606266;
  margin-bottom: 8px;
}

.bottleneck-recommendation {
  font-size: 14px;
  color: #67c23a;
  font-style: italic;
}

.bottleneck-metrics {
  display: flex;
  gap: 20px;
}

.metric {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.metric-label {
  font-size: 12px;
  color: #909399;
}

.metric-value {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.productivity-analysis {
  padding: 16px 0;
}

.productivity-chart {
  margin-bottom: 20px;
  display: flex;
  justify-content: center;
}

.productivity-metrics {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.metric-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.metric-name {
  width: 80px;
  font-size: 12px;
  color: #606266;
}

.metric-progress {
  flex: 1;
}

.metric-target {
  width: 70px;
  font-size: 10px;
  color: #909399;
  text-align: right;
}

.cost-efficiency {
  padding: 16px 0;
}

.cost-overview {
  margin-bottom: 20px;
}

.cost-metric {
  margin-bottom: 16px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
}

.cost-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.cost-value {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.cost-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 600;
}

.cost-trend.up { color: #f56c6c; }
.cost-trend.down { color: #67c23a; }
.cost-trend.stable { color: #909399; }

.cost-breakdown {
  display: flex;
  justify-content: center;
}

.performance-table {
  margin-bottom: 20px;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.table-actions {
  display: flex;
  align-items: center;
}

.efficiency-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.efficiency-text {
  font-size: 12px;
  color: #606266;
  min-width: 35px;
}

.trend-cell {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 600;
}

.trend-cell.up { color: #67C23A; }
.trend-cell.down { color: #F56C6C; }
.trend-cell.stable { color: #909399; }

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.performance-details {
  padding: 0 16px;
}

.detailed-metrics {
  padding: 16px 0;
}

.metric-item {
  margin-bottom: 16px;
  padding: 12px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
}

.metric-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.metric-name {
  font-weight: 600;
  color: #303133;
}

.metric-value {
  font-weight: 600;
  color: #409eff;
}

.metric-bar {
  margin-bottom: 4px;
}

.metric-benchmark {
  font-size: 12px;
  color: #909399;
}

.detail-chart {
  padding: 20px;
  display: flex;
  justify-content: center;
}

.recommendations {
  padding: 16px 0;
}

.recommendation {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  margin-bottom: 12px;
}

.rec-priority {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
}

.rec-priority.high {
  background: #fef0f0;
  color: #f56c6c;
}

.rec-priority.medium {
  background: #fdf6ec;
  color: #e6a23c;
}

.rec-priority.low {
  background: #f0f9ff;
  color: #409eff;
}

.rec-content {
  flex: 1;
}

.rec-title {
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.rec-description {
  font-size: 14px;
  color: #606266;
  margin-bottom: 4px;
}

.rec-impact {
  font-size: 12px;
  color: #67c23a;
}

.rec-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .overview-section .el-col {
    margin-bottom: 12px;
  }

  .advanced-analytics .el-col {
    margin-bottom: 20px;
  }
}

@media (max-width: 768px) {
  .performance-analytics-page {
    padding: 12px;
  }

  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .filters-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .filter-item {
    width: 100%;
  }

  .filter-item label {
    min-width: 100px;
  }

  .kpi-content {
    flex-direction: column;
    text-align: center;
  }

  .kpi-chart {
    position: static;
    transform: none;
    margin-top: 12px;
  }

  .table-actions {
    flex-direction: column;
    gap: 8px;
    align-items: flex-end;
  }

  .chart-controls {
    flex-direction: column;
    gap: 8px;
  }

  .bottleneck-metrics {
    flex-direction: column;
    gap: 8px;
  }
}

/* Animation effects */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.kpi-card {
  animation: fadeInUp 0.5s ease;
}

.performer-item {
  animation: fadeInUp 0.5s ease;
}

.bottleneck-item {
  animation: fadeInUp 0.5s ease;
}

.recommendation {
  animation: fadeInUp 0.5s ease;
}
</style>

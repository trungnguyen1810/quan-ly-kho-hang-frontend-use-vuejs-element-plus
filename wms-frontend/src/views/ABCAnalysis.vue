<template>
  <div class="abc-analysis-page">
    <!-- Header Section -->
    <div class="page-header">
      <div class="header-content">
        <div class="title-section">
          <h1 class="page-title">Phân tích ABC</h1>
          <p class="page-description">Phân loại sản phẩm theo giá trị và tần suất xuất kho</p>
        </div>
        <div class="header-actions">
          <el-button type="primary" @click="runAnalysis" :loading="analyzing">
            <el-icon><TrendCharts /></el-icon>
            Chạy phân tích
          </el-button>
          <el-button @click="exportAnalysis">
            <el-icon><Download /></el-icon>
            Xuất báo cáo
          </el-button>
          <el-button @click="scheduleAnalysis">
            <el-icon><Timer /></el-icon>
            Lập lịch
          </el-button>
        </div>
      </div>
    </div>

    <!-- Analysis Configuration -->
    <div class="config-section">
      <el-card>
        <template #header>
          <span>Cấu hình Phân tích</span>
        </template>
        <div class="config-row">
          <div class="config-item">
            <label>Kho phân tích:</label>
            <el-select v-model="analysisConfig.warehouse_id" @change="updateAnalysis">
              <el-option label="Tất cả kho" :value="0" />
              <el-option
                v-for="warehouse in warehouses"
                :key="warehouse.id"
                :label="warehouse.name"
                :value="warehouse.id"
              />
            </el-select>
          </div>
          <div class="config-item">
            <label>Thời gian phân tích:</label>
            <el-date-picker
              v-model="analysisConfig.date_range"
              type="daterange"
              range-separator="đến"
              start-placeholder="Ngày bắt đầu"
              end-placeholder="Ngày kết thúc"
              @change="updateAnalysis"
            />
          </div>
          <div class="config-item">
            <label>Tiêu chí phân loại:</label>
            <el-select v-model="analysisConfig.criteria" @change="updateAnalysis">
              <el-option label="Doanh thu" value="revenue" />
              <el-option label="Số lượng xuất" value="quantity" />
              <el-option label="Tần suất xuất" value="frequency" />
              <el-option label="Kết hợp" value="combined" />
            </el-select>
          </div>
          <div class="config-item">
            <label>Tỷ lệ ABC:</label>
            <div class="abc-ratio">
              <el-input-number v-model="analysisConfig.a_ratio" :min="0" :max="100" size="small" />%
              <span>A</span>
              <el-input-number v-model="analysisConfig.b_ratio" :min="0" :max="100" size="small" />%
              <span>B</span>
              <span>{{ 100 - analysisConfig.a_ratio - analysisConfig.b_ratio }}% C</span>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Analysis Summary -->
    <div class="summary-section">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card class="summary-card category-a">
            <div class="summary-content">
              <div class="summary-icon">
                <el-icon><Star /></el-icon>
              </div>
              <div class="summary-details">
                <div class="summary-value">{{ summaryData.categoryA.count }}</div>
                <div class="summary-label">Sản phẩm A</div>
                <div class="summary-subtitle">{{ summaryData.categoryA.percentage }}% tổng giá trị</div>
              </div>
            </div>
            <div class="summary-chart">
              <el-progress
                type="circle"
                :percentage="summaryData.categoryA.percentage"
                :width="60"
                color="#f56c6c"
                :show-text="false"
              />
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card category-b">
            <div class="summary-content">
              <div class="summary-icon">
                <el-icon><Medal /></el-icon>
              </div>
              <div class="summary-details">
                <div class="summary-value">{{ summaryData.categoryB.count }}</div>
                <div class="summary-label">Sản phẩm B</div>
                <div class="summary-subtitle">{{ summaryData.categoryB.percentage }}% tổng giá trị</div>
              </div>
            </div>
            <div class="summary-chart">
              <el-progress
                type="circle"
                :percentage="summaryData.categoryB.percentage"
                :width="60"
                color="#e6a23c"
                :show-text="false"
              />
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card category-c">
            <div class="summary-content">
              <div class="summary-icon">
                <el-icon><Collection /></el-icon>
              </div>
              <div class="summary-details">
                <div class="summary-value">{{ summaryData.categoryC.count }}</div>
                <div class="summary-label">Sản phẩm C</div>
                <div class="summary-subtitle">{{ summaryData.categoryC.percentage }}% tổng giá trị</div>
              </div>
            </div>
            <div class="summary-chart">
              <el-progress
                type="circle"
                :percentage="summaryData.categoryC.percentage"
                :width="60"
                color="#67c23a"
                :show-text="false"
              />
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card total">
            <div class="summary-content">
              <div class="summary-icon">
                <el-icon><PieChart /></el-icon>
              </div>
              <div class="summary-details">
                <div class="summary-value">{{ summaryData.total.count }}</div>
                <div class="summary-label">Tổng sản phẩm</div>
                <div class="summary-subtitle">{{ formatCurrency(summaryData.total.value) }}</div>
              </div>
            </div>
            <div class="summary-chart">
              <el-progress
                type="circle"
                :percentage="100"
                :width="60"
                color="#409eff"
                :show-text="false"
              />
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Charts Section -->
    <div class="charts-section">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card>
            <template #header>
              <div class="chart-header">
                <span>Biểu đồ Pareto - Phân bố Giá trị</span>
                <el-button-group>
                  <el-button size="small" @click="chartType = 'pareto'" :type="chartType === 'pareto' ? 'primary' : ''">
                    Pareto
                  </el-button>
                  <el-button size="small" @click="chartType = 'pie'" :type="chartType === 'pie' ? 'primary' : ''">
                    Tròn
                  </el-button>
                </el-button-group>
              </div>
            </template>
            <div class="chart-container">
              <div v-if="chartType === 'pareto'" class="pareto-chart">
                <canvas ref="paretoCanvas" width="400" height="300"></canvas>
              </div>
              <div v-else class="pie-chart">
                <canvas ref="pieCanvas" width="400" height="300"></canvas>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>Xu hướng ABC theo Thời gian</span>
            </template>
            <div class="chart-container">
              <div class="trend-chart">
                <canvas ref="trendCanvas" width="400" height="300"></canvas>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Advanced Analytics -->
    <div class="advanced-section">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Phân tích Velocity</span>
            </template>
            <div class="velocity-analysis">
              <div class="velocity-item" v-for="item in velocityData" :key="item.category">
                <div class="velocity-header">
                  <span class="velocity-category">{{ item.category }}</span>
                  <el-tag :type="getVelocityTagType(item.velocity)">{{ item.velocity }}</el-tag>
                </div>
                <div class="velocity-metrics">
                  <div class="metric">
                    <span class="metric-label">Avg Days On Hand:</span>
                    <span class="metric-value">{{ item.avgDaysOnHand }}</span>
                  </div>
                  <div class="metric">
                    <span class="metric-label">Turnover Rate:</span>
                    <span class="metric-value">{{ item.turnoverRate }}x</span>
                  </div>
                  <div class="metric">
                    <span class="metric-label">Service Level:</span>
                    <span class="metric-value">{{ item.serviceLevel }}%</span>
                  </div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Recommendations</span>
            </template>
            <div class="recommendations">
              <div class="recommendation-item" v-for="rec in recommendations" :key="rec.id">
                <div class="rec-header">
                  <el-icon :class="getRecIcon(rec.type)"><Lightning /></el-icon>
                  <span class="rec-title">{{ rec.title }}</span>
                  <el-tag :type="getRecPriority(rec.priority)" size="small">{{ rec.priority }}</el-tag>
                </div>
                <div class="rec-content">
                  <p class="rec-description">{{ rec.description }}</p>
                  <div class="rec-impact">
                    <span class="impact-label">Tác động dự kiến:</span>
                    <span class="impact-value">{{ rec.impact }}</span>
                  </div>
                </div>
                <div class="rec-actions">
                  <el-button size="small" type="primary" @click="applyRecommendation(rec)">
                    Áp dụng
                  </el-button>
                  <el-button size="small" @click="dismissRecommendation(rec)">
                    Bỏ qua
                  </el-button>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Inventory Strategy</span>
            </template>
            <div class="strategy-matrix">
              <div class="matrix-header">
                <div class="matrix-title">Chiến lược Tồn kho</div>
                <div class="matrix-legend">
                  <div class="legend-item">
                    <div class="legend-color color-high"></div>
                    <span>Cao</span>
                  </div>
                  <div class="legend-item">
                    <div class="legend-color color-medium"></div>
                    <span>Trung bình</span>
                  </div>
                  <div class="legend-item">
                    <div class="legend-color color-low"></div>
                    <span>Thấp</span>
                  </div>
                </div>
              </div>
              <div class="matrix-grid">
                <div class="matrix-row" v-for="strategy in strategyMatrix" :key="strategy.category">
                  <div class="strategy-category">{{ strategy.category }}</div>
                  <div class="strategy-cells">
                    <div
                      class="strategy-cell"
                      :class="strategy.stockLevel"
                      @click="showStrategyDetails(strategy)"
                    >
                      <div class="cell-title">Stock Level</div>
                      <div class="cell-value">{{ strategy.stockLevelValue }}%</div>
                    </div>
                    <div
                      class="strategy-cell"
                      :class="strategy.reorderFreq"
                      @click="showStrategyDetails(strategy)"
                    >
                      <div class="cell-title">Reorder Frequency</div>
                      <div class="cell-value">{{ strategy.reorderFreqValue }}</div>
                    </div>
                    <div
                      class="strategy-cell"
                      :class="strategy.monitoring"
                      @click="showStrategyDetails(strategy)"
                    >
                      <div class="cell-title">Monitoring</div>
                      <div class="cell-value">{{ strategy.monitoringValue }}</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Detailed Analysis Table -->
    <el-card class="table-card">
      <template #header>
        <div class="table-header">
          <span>Chi tiết Phân tích ABC</span>
          <div class="table-actions">
            <el-input
              v-model="searchText"
              placeholder="Tìm kiếm sản phẩm..."
              style="width: 200px; margin-right: 12px"
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
            <el-select v-model="filterCategory" placeholder="Lọc theo ABC" style="width: 120px; margin-right: 12px">
              <el-option label="Tất cả" value="" />
              <el-option label="A" value="A" />
              <el-option label="B" value="B" />
              <el-option label="C" value="C" />
            </el-select>
            <el-button @click="refreshTable">
              <el-icon><Refresh /></el-icon>
            </el-button>
          </div>
        </div>
      </template>

      <el-table
        :data="paginatedProducts"
        v-loading="loading"
        height="500"
        @sort-change="handleSort"
        row-class-name="table-row"
      >
        <el-table-column type="index" label="#" width="50" />
        <el-table-column prop="code" label="Mã SP" width="120" sortable="custom" />
        <el-table-column prop="name" label="Tên sản phẩm" min-width="200" sortable="custom" show-overflow-tooltip />
        <el-table-column prop="category" label="Danh mục" width="120" />
        <el-table-column prop="abc_category" label="ABC" width="80" sortable="custom">
          <template #default="{ row }">
            <el-tag :type="getAbcTagType(row.abc_category)" effect="dark" size="large">
              {{ row.abc_category }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="annual_usage_value" label="Giá trị sử dụng/năm" width="160" sortable="custom">
          <template #default="{ row }">
            {{ formatCurrency(row.annual_usage_value) }}
          </template>
        </el-table-column>
        <el-table-column prop="annual_usage_qty" label="SL sử dụng/năm" width="140" sortable="custom">
          <template #default="{ row }">
            {{ formatNumber(row.annual_usage_qty) }}
          </template>
        </el-table-column>
        <el-table-column prop="unit_cost" label="Đơn giá" width="120" sortable="custom">
          <template #default="{ row }">
            {{ formatCurrency(row.unit_cost) }}
          </template>
        </el-table-column>
        <el-table-column prop="current_stock" label="Tồn kho hiện tại" width="130" sortable="custom">
          <template #default="{ row }">
            <div class="stock-cell">
              <span>{{ formatNumber(row.current_stock) }}</span>
              <el-tag v-if="row.stock_status" :type="getStockStatusType(row.stock_status)" size="small">
                {{ row.stock_status }}
              </el-tag>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="turnover_rate" label="Vòng quay" width="100" sortable="custom">
          <template #default="{ row }">
            {{ row.turnover_rate }}x
          </template>
        </el-table-column>
        <el-table-column prop="cumulative_percentage" label="% Tích lũy" width="100" sortable="custom">
          <template #default="{ row }">
            <div class="cumulative-cell">
              <el-progress
                :percentage="row.cumulative_percentage"
                :stroke-width="6"
                :show-text="false"
                :color="getCumulativeColor(row.cumulative_percentage)"
              />
              <span class="cumulative-text">{{ row.cumulative_percentage }}%</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="Thao tác" width="150" fixed="right">
          <template #default="{ row }">
            <el-button-group>
              <el-button size="small" @click="viewProductDetails(row)">
                <el-icon><View /></el-icon>
              </el-button>
              <el-button size="small" type="primary" @click="optimizeProduct(row)">
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
          :page-sizes="[20, 50, 100, 200]"
          :total="totalProducts"
          layout="total, sizes, prev, pager, next, jumper"
        />
      </div>
    </el-card>

    <!-- Product Details Dialog -->
    <el-dialog
      v-model="showProductDialog"
      :title="selectedProduct?.name || 'Chi tiết Sản phẩm'"
      width="800px"
    >
      <div v-if="selectedProduct" class="product-details">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-card>
              <template #header>
                <span>Thông tin Cơ bản</span>
              </template>
              <el-descriptions :column="1">
                <el-descriptions-item label="Mã sản phẩm">{{ selectedProduct.code }}</el-descriptions-item>
                <el-descriptions-item label="Tên sản phẩm">{{ selectedProduct.name }}</el-descriptions-item>
                <el-descriptions-item label="Danh mục">{{ selectedProduct.category }}</el-descriptions-item>
                <el-descriptions-item label="Phân loại ABC">
                  <el-tag :type="getAbcTagType(selectedProduct.abc_category)" effect="dark">
                    {{ selectedProduct.abc_category }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="Đơn giá">{{ formatCurrency(selectedProduct.unit_cost) }}</el-descriptions-item>
              </el-descriptions>
            </el-card>
          </el-col>
          <el-col :span="12">
            <el-card>
              <template #header>
                <span>Phân tích ABC</span>
              </template>
              <el-descriptions :column="1">
                <el-descriptions-item label="Giá trị sử dụng/năm">
                  {{ formatCurrency(selectedProduct.annual_usage_value) }}
                </el-descriptions-item>
                <el-descriptions-item label="Số lượng sử dụng/năm">
                  {{ formatNumber(selectedProduct.annual_usage_qty) }}
                </el-descriptions-item>
                <el-descriptions-item label="Vòng quay kho">{{ selectedProduct.turnover_rate }}x</el-descriptions-item>
                <el-descriptions-item label="% Tích lũy">{{ selectedProduct.cumulative_percentage }}%</el-descriptions-item>
                <el-descriptions-item label="Tồn kho hiện tại">
                  {{ formatNumber(selectedProduct.current_stock) }}
                </el-descriptions-item>
              </el-descriptions>
            </el-card>
          </el-col>
        </el-row>

        <el-card style="margin-top: 20px;">
          <template #header>
            <span>Lịch sử Xuất nhập (30 ngày gần nhất)</span>
          </template>
          <div class="product-history-chart">
            <canvas ref="productHistoryCanvas" width="700" height="200"></canvas>
          </div>
        </el-card>

        <el-card style="margin-top: 20px;">
          <template #header>
            <span>Khuyến nghị Tối ưu</span>
          </template>
          <div class="product-recommendations">
            <div v-for="rec in selectedProduct.recommendations" :key="rec.id" class="rec-item">
              <div class="rec-icon">
                <el-icon><Lightning /></el-icon>
              </div>
              <div class="rec-content">
                <div class="rec-title">{{ rec.title }}</div>
                <div class="rec-desc">{{ rec.description }}</div>
                <div class="rec-impact">Tác động: {{ rec.impact }}</div>
              </div>
              <div class="rec-actions">
                <el-button size="small" type="primary">Áp dụng</el-button>
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </el-dialog>

    <!-- Schedule Analysis Dialog -->
    <el-dialog v-model="showScheduleDialog" title="Lập lịch Phân tích ABC" width="500px">
      <el-form :model="scheduleForm" label-width="120px">
        <el-form-item label="Tần suất">
          <el-select v-model="scheduleForm.frequency">
            <el-option label="Hàng ngày" value="daily" />
            <el-option label="Hàng tuần" value="weekly" />
            <el-option label="Hàng tháng" value="monthly" />
            <el-option label="Hàng quý" value="quarterly" />
          </el-select>
        </el-form-item>
        <el-form-item label="Thời gian chạy">
          <el-time-picker v-model="scheduleForm.run_time" />
        </el-form-item>
        <el-form-item label="Email báo cáo">
          <el-input v-model="scheduleForm.email" type="email" />
        </el-form-item>
        <el-form-item label="Kích hoạt">
          <el-switch v-model="scheduleForm.enabled" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showScheduleDialog = false">Hủy</el-button>
          <el-button type="primary" @click="saveSchedule">Lưu lịch</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  TrendCharts, Download, Timer, Star, Medal, Collection, PieChart,
  Lightning, Search, Refresh, View, Tools, Bell
} from '@element-plus/icons-vue'

// Reactive data
const analyzing = ref(false)
const loading = ref(false)
const searchText = ref('')
const filterCategory = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const chartType = ref('pareto')
const showProductDialog = ref(false)
const showScheduleDialog = ref(false)
const selectedProduct = ref<any>(null)

// Configuration
const analysisConfig = reactive({
  warehouse_id: 0,
  date_range: [],
  criteria: 'revenue',
  a_ratio: 80,
  b_ratio: 15
})

// Schedule form
const scheduleForm = reactive({
  frequency: 'monthly',
  run_time: null,
  email: '',
  enabled: true
})

// Sample data
const warehouses = ref([
  { id: 1, name: 'Kho Thành Phẩm Hà Nội' },
  { id: 2, name: 'Kho Nguyên Liệu TP.HCM' },
  { id: 3, name: 'Kho Lạnh Đà Nẵng' }
])

const products = ref([
  {
    id: 1,
    code: 'SP001',
    name: 'iPhone 15 Pro Max 256GB',
    category: 'Điện thoại',
    abc_category: 'A',
    annual_usage_value: 2500000000,
    annual_usage_qty: 1000,
    unit_cost: 25000000,
    current_stock: 45,
    stock_status: 'low',
    turnover_rate: 12.5,
    cumulative_percentage: 35.2,
    recommendations: [
      {
        id: 1,
        title: 'Tăng tần suất đặt hàng',
        description: 'Nên đặt hàng mỗi 2 tuần thay vì hàng tháng để giảm rủi ro hết hàng',
        impact: 'Giảm 25% tình trạng thiếu hàng'
      }
    ]
  },
  {
    id: 2,
    code: 'SP002',
    name: 'Samsung Galaxy S24 Ultra',
    category: 'Điện thoại',
    abc_category: 'A',
    annual_usage_value: 1800000000,
    annual_usage_qty: 720,
    unit_cost: 25000000,
    current_stock: 32,
    stock_status: 'normal',
    turnover_rate: 10.2,
    cumulative_percentage: 60.8,
    recommendations: []
  },
  {
    id: 3,
    code: 'SP003',
    name: 'MacBook Pro M3 14 inch',
    category: 'Laptop',
    abc_category: 'A',
    annual_usage_value: 1200000000,
    annual_usage_qty: 240,
    unit_cost: 50000000,
    current_stock: 18,
    stock_status: 'normal',
    turnover_rate: 8.5,
    cumulative_percentage: 77.1,
    recommendations: []
  },
  {
    id: 4,
    code: 'SP004',
    name: 'iPad Air M2 256GB',
    category: 'Tablet',
    abc_category: 'B',
    annual_usage_value: 600000000,
    annual_usage_qty: 300,
    unit_cost: 20000000,
    current_stock: 28,
    stock_status: 'normal',
    turnover_rate: 6.2,
    cumulative_percentage: 85.6,
    recommendations: []
  },
  {
    id: 5,
    code: 'SP005',
    name: 'AirPods Pro Gen 3',
    category: 'Phụ kiện',
    abc_category: 'B',
    annual_usage_value: 450000000,
    annual_usage_qty: 900,
    unit_cost: 5000000,
    current_stock: 85,
    stock_status: 'high',
    turnover_rate: 15.3,
    cumulative_percentage: 92.0,
    recommendations: [
      {
        id: 2,
        title: 'Giảm mức tồn kho',
        description: 'Tồn kho hiện tại quá cao so với nhu cầu',
        impact: 'Tiết kiệm 15% chi phí lưu kho'
      }
    ]
  },
  {
    id: 6,
    code: 'SP006',
    name: 'Ốp lưng iPhone 15',
    category: 'Phụ kiện',
    abc_category: 'C',
    annual_usage_value: 180000000,
    annual_usage_qty: 1800,
    unit_cost: 100000,
    current_stock: 450,
    stock_status: 'high',
    turnover_rate: 4.0,
    cumulative_percentage: 95.5,
    recommendations: []
  },
  {
    id: 7,
    code: 'SP007',
    name: 'Cáp Lightning 1m',
    category: 'Phụ kiện',
    abc_category: 'C',
    annual_usage_value: 120000000,
    annual_usage_qty: 2400,
    unit_cost: 50000,
    current_stock: 680,
    stock_status: 'high',
    turnover_rate: 3.5,
    cumulative_percentage: 97.2,
    recommendations: []
  },
  {
    id: 8,
    code: 'SP008',
    name: 'Bao da iPad Air',
    category: 'Phụ kiện',
    abc_category: 'C',
    annual_usage_value: 90000000,
    annual_usage_qty: 450,
    unit_cost: 200000,
    current_stock: 120,
    stock_status: 'normal',
    turnover_rate: 3.8,
    cumulative_percentage: 99.1,
    recommendations: []
  }
])

// Computed properties
const summaryData = computed(() => {
  const categoryA = products.value.filter(p => p.abc_category === 'A')
  const categoryB = products.value.filter(p => p.abc_category === 'B')
  const categoryC = products.value.filter(p => p.abc_category === 'C')
  const total = products.value

  const totalValue = total.reduce((sum, p) => sum + p.annual_usage_value, 0)
  const aValue = categoryA.reduce((sum, p) => sum + p.annual_usage_value, 0)
  const bValue = categoryB.reduce((sum, p) => sum + p.annual_usage_value, 0)
  const cValue = categoryC.reduce((sum, p) => sum + p.annual_usage_value, 0)

  return {
    categoryA: {
      count: categoryA.length,
      percentage: Math.round((aValue / totalValue) * 100)
    },
    categoryB: {
      count: categoryB.length,
      percentage: Math.round((bValue / totalValue) * 100)
    },
    categoryC: {
      count: categoryC.length,
      percentage: Math.round((cValue / totalValue) * 100)
    },
    total: {
      count: total.length,
      value: totalValue
    }
  }
})

const filteredProducts = computed(() => {
  let filtered = products.value

  if (searchText.value) {
    const search = searchText.value.toLowerCase()
    filtered = filtered.filter(p =>
      p.name.toLowerCase().includes(search) ||
      p.code.toLowerCase().includes(search)
    )
  }

  if (filterCategory.value) {
    filtered = filtered.filter(p => p.abc_category === filterCategory.value)
  }

  return filtered
})

const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredProducts.value.slice(start, end)
})

const totalProducts = computed(() => filteredProducts.value.length)

// Sample data for advanced analytics
const velocityData = ref([
  {
    category: 'A',
    velocity: 'Fast',
    avgDaysOnHand: 15,
    turnoverRate: 24.3,
    serviceLevel: 98.5
  },
  {
    category: 'B',
    velocity: 'Medium',
    avgDaysOnHand: 45,
    turnoverRate: 8.1,
    serviceLevel: 95.2
  },
  {
    category: 'C',
    velocity: 'Slow',
    avgDaysOnHand: 120,
    turnoverRate: 3.0,
    serviceLevel: 88.7
  }
])

const recommendations = ref([
  {
    id: 1,
    type: 'optimization',
    priority: 'High',
    title: 'Tối ưu tồn kho sản phẩm A',
    description: 'Giảm 20% safety stock cho sản phẩm A để tiết kiệm chi phí',
    impact: 'Tiết kiệm 2.5 tỷ VNĐ/năm'
  },
  {
    id: 2,
    type: 'reorder',
    priority: 'Medium',
    title: 'Điều chỉnh chu kỳ đặt hàng',
    description: 'Tăng tần suất đặt hàng cho nhóm A, giảm cho nhóm C',
    impact: 'Giảm 15% chi phí carrying'
  },
  {
    id: 3,
    type: 'clearance',
    priority: 'Low',
    title: 'Thanh lý sản phẩm C',
    description: 'Xem xét thanh lý hoặc giảm giá sản phẩm C chậm xoay',
    impact: 'Giải phóng 30% diện tích kho'
  }
])

const strategyMatrix = ref([
  {
    category: 'A',
    stockLevel: 'high',
    stockLevelValue: 95,
    reorderFreq: 'high',
    reorderFreqValue: 'Weekly',
    monitoring: 'high',
    monitoringValue: 'Daily'
  },
  {
    category: 'B',
    stockLevel: 'medium',
    stockLevelValue: 75,
    reorderFreq: 'medium',
    reorderFreqValue: 'Bi-weekly',
    monitoring: 'medium',
    monitoringValue: 'Weekly'
  },
  {
    category: 'C',
    stockLevel: 'low',
    stockLevelValue: 50,
    reorderFreq: 'low',
    reorderFreqValue: 'Monthly',
    monitoring: 'low',
    monitoringValue: 'Monthly'
  }
])

// Canvas refs
const paretoCanvas = ref<HTMLCanvasElement>()
const pieCanvas = ref<HTMLCanvasElement>()
const trendCanvas = ref<HTMLCanvasElement>()
const productHistoryCanvas = ref<HTMLCanvasElement>()

// Methods
const getAbcTagType = (category: string) => {
  const types: Record<string, string> = {
    A: 'danger',
    B: 'warning',
    C: 'success'
  }
  return types[category] || ''
}

const getStockStatusType = (status: string) => {
  const types: Record<string, string> = {
    low: 'danger',
    normal: 'success',
    high: 'warning'
  }
  return types[status] || ''
}

const getVelocityTagType = (velocity: string) => {
  const types: Record<string, string> = {
    Fast: 'danger',
    Medium: 'warning',
    Slow: 'success'
  }
  return types[velocity] || ''
}

const getRecIcon = (type: string) => {
  return 'rec-icon-' + type
}

const getRecPriority = (priority: string) => {
  const types: Record<string, string> = {
    High: 'danger',
    Medium: 'warning',
    Low: 'info'
  }
  return types[priority] || ''
}

const getCumulativeColor = (percentage: number) => {
  if (percentage <= 80) return '#f56c6c'
  if (percentage <= 95) return '#e6a23c'
  return '#67c23a'
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

const runAnalysis = async () => {
  analyzing.value = true
  try {
    // Simulate analysis
    await new Promise(resolve => setTimeout(resolve, 2000))
    ElMessage.success('Phân tích ABC hoàn thành')
    await nextTick()
    drawCharts()
  } finally {
    analyzing.value = false
  }
}

const updateAnalysis = () => {
  // Update analysis based on config changes
  console.log('Updating analysis with config:', analysisConfig)
}

const exportAnalysis = () => {
  ElMessage.success('Đang xuất báo cáo ABC...')
}

const scheduleAnalysis = () => {
  showScheduleDialog.value = true
}

const saveSchedule = () => {
  ElMessage.success('Đã lưu lịch phân tích')
  showScheduleDialog.value = false
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

const viewProductDetails = (product: any) => {
  selectedProduct.value = product
  showProductDialog.value = true
  nextTick(() => {
    drawProductHistoryChart()
  })
}

const optimizeProduct = (product: any) => {
  ElMessage.info(`Tối ưu sản phẩm: ${product.name}`)
}

const createAlert = (product: any) => {
  ElMessage.info(`Tạo cảnh báo cho: ${product.name}`)
}

const applyRecommendation = (rec: any) => {
  ElMessage.success(`Đã áp dụng: ${rec.title}`)
}

const dismissRecommendation = (rec: any) => {
  ElMessage.info(`Đã bỏ qua: ${rec.title}`)
}

const showStrategyDetails = (strategy: any) => {
  ElMessage.info(`Chi tiết chiến lược cho nhóm ${strategy.category}`)
}

// Chart drawing functions
const drawCharts = () => {
  drawParetoChart()
  drawPieChart()
  drawTrendChart()
}

const drawParetoChart = () => {
  if (!paretoCanvas.value) return
  const ctx = paretoCanvas.value.getContext('2d')
  if (!ctx) return

  // Clear canvas
  ctx.clearRect(0, 0, 400, 300)

  // Sample Pareto chart drawing
  ctx.fillStyle = '#409EFF'
  ctx.fillRect(50, 250, 60, -180) // A category
  ctx.fillStyle = '#E6A23C'
  ctx.fillRect(120, 250, 60, -80)  // B category
  ctx.fillStyle = '#67C23A'
  ctx.fillRect(190, 250, 60, -40)  // C category

  // Labels
  ctx.fillStyle = '#303133'
  ctx.font = '12px Arial'
  ctx.fillText('A (80%)', 55, 270)
  ctx.fillText('B (15%)', 125, 270)
  ctx.fillText('C (5%)', 195, 270)
}

const drawPieChart = () => {
  if (!pieCanvas.value) return
  const ctx = pieCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 400, 300)

  const centerX = 200
  const centerY = 150
  const radius = 80

  // A slice (80%)
  ctx.beginPath()
  ctx.moveTo(centerX, centerY)
  ctx.arc(centerX, centerY, radius, 0, Math.PI * 1.6)
  ctx.fillStyle = '#F56C6C'
  ctx.fill()

  // B slice (15%)
  ctx.beginPath()
  ctx.moveTo(centerX, centerY)
  ctx.arc(centerX, centerY, radius, Math.PI * 1.6, Math.PI * 1.9)
  ctx.fillStyle = '#E6A23C'
  ctx.fill()

  // C slice (5%)
  ctx.beginPath()
  ctx.moveTo(centerX, centerY)
  ctx.arc(centerX, centerY, radius, Math.PI * 1.9, Math.PI * 2)
  ctx.fillStyle = '#67C23A'
  ctx.fill()
}

const drawTrendChart = () => {
  if (!trendCanvas.value) return
  const ctx = trendCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 400, 300)

  // Draw trend lines for ABC over time
  ctx.strokeStyle = '#F56C6C'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.moveTo(50, 100)
  ctx.lineTo(150, 90)
  ctx.lineTo(250, 95)
  ctx.lineTo(350, 85)
  ctx.stroke()

  ctx.strokeStyle = '#E6A23C'
  ctx.beginPath()
  ctx.moveTo(50, 150)
  ctx.lineTo(150, 145)
  ctx.lineTo(250, 155)
  ctx.lineTo(350, 150)
  ctx.stroke()

  ctx.strokeStyle = '#67C23A'
  ctx.beginPath()
  ctx.moveTo(50, 200)
  ctx.lineTo(150, 210)
  ctx.lineTo(250, 205)
  ctx.lineTo(350, 215)
  ctx.stroke()
}

const drawProductHistoryChart = () => {
  if (!productHistoryCanvas.value) return
  const ctx = productHistoryCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 700, 200)

  // Draw sample product movement history
  ctx.strokeStyle = '#409EFF'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.moveTo(50, 150)

  // Sample data points
  const points = [150, 140, 160, 145, 155, 135, 165, 150, 140, 160]
  points.forEach((y, i) => {
    ctx.lineTo(50 + i * 60, y)
  })
  ctx.stroke()

  // Add dots
  ctx.fillStyle = '#409EFF'
  points.forEach((y, i) => {
    ctx.beginPath()
    ctx.arc(50 + i * 60, y, 3, 0, Math.PI * 2)
    ctx.fill()
  })
}

onMounted(() => {
  runAnalysis()
})
</script>

<style scoped>
.abc-analysis-page {
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

.config-section {
  margin-bottom: 20px;
}

.config-row {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.config-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.config-item label {
  font-size: 14px;
  color: #606266;
  white-space: nowrap;
  min-width: 120px;
}

.abc-ratio {
  display: flex;
  align-items: center;
  gap: 8px;
}

.abc-ratio span {
  font-weight: 600;
  color: #303133;
}

.summary-section {
  margin-bottom: 20px;
}

.summary-card {
  height: 120px;
  position: relative;
  overflow: hidden;
}

.summary-card.category-a {
  border-left: 4px solid #f56c6c;
}

.summary-card.category-b {
  border-left: 4px solid #e6a23c;
}

.summary-card.category-c {
  border-left: 4px solid #67c23a;
}

.summary-card.total {
  border-left: 4px solid #409eff;
}

.summary-content {
  display: flex;
  align-items: center;
  gap: 16px;
  height: 100%;
}

.summary-icon {
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
}

.summary-details {
  flex: 1;
}

.summary-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
  margin-bottom: 4px;
}

.summary-label {
  font-size: 14px;
  color: #606266;
  margin-bottom: 2px;
}

.summary-subtitle {
  font-size: 12px;
  color: #909399;
}

.summary-chart {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
}

.charts-section {
  margin-bottom: 20px;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-container {
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
}

.advanced-section {
  margin-bottom: 20px;
}

.velocity-analysis {
  padding: 16px 0;
}

.velocity-item {
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
}

.velocity-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.velocity-category {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.velocity-metrics {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.metric {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
}

.metric-label {
  color: #606266;
}

.metric-value {
  font-weight: 600;
  color: #303133;
}

.recommendations {
  padding: 16px 0;
}

.recommendation-item {
  margin-bottom: 16px;
  padding: 16px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.recommendation-item:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.1);
}

.rec-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.rec-title {
  flex: 1;
  font-weight: 600;
  color: #303133;
}

.rec-content {
  margin-bottom: 12px;
}

.rec-description {
  font-size: 14px;
  color: #606266;
  margin: 0 0 8px 0;
  line-height: 1.5;
}

.rec-impact {
  font-size: 12px;
  color: #909399;
}

.impact-label {
  font-weight: 500;
}

.impact-value {
  color: #67c23a;
  font-weight: 600;
}

.rec-actions {
  display: flex;
  gap: 8px;
}

.strategy-matrix {
  padding: 16px 0;
}

.matrix-header {
  margin-bottom: 16px;
}

.matrix-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 8px;
}

.matrix-legend {
  display: flex;
  gap: 16px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #606266;
}

.legend-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
}

.color-high { background: #f56c6c; }
.color-medium { background: #e6a23c; }
.color-low { background: #67c23a; }

.matrix-grid {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.matrix-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.strategy-category {
  width: 60px;
  font-weight: 600;
  color: #303133;
  text-align: center;
}

.strategy-cells {
  display: flex;
  gap: 8px;
  flex: 1;
}

.strategy-cell {
  flex: 1;
  padding: 8px;
  border-radius: 4px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
}

.strategy-cell:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.strategy-cell.high {
  background: #fef0f0;
  border: 1px solid #fbc4c4;
}

.strategy-cell.medium {
  background: #fdf6ec;
  border: 1px solid #f5dab1;
}

.strategy-cell.low {
  background: #f0f9ff;
  border: 1px solid #b3d8ff;
}

.cell-title {
  font-size: 10px;
  color: #909399;
  margin-bottom: 4px;
}

.cell-value {
  font-size: 12px;
  font-weight: 600;
  color: #303133;
}

.table-card {
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

.stock-cell {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.cumulative-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.cumulative-text {
  font-size: 12px;
  color: #606266;
  min-width: 35px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.product-details {
  padding: 0 16px;
}

.product-history-chart {
  padding: 20px;
  display: flex;
  justify-content: center;
}

.product-recommendations {
  padding: 16px 0;
}

.rec-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  margin-bottom: 12px;
}

.rec-icon {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
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

.rec-desc {
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

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .config-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .summary-section .el-col {
    margin-bottom: 12px;
  }

  .advanced-section .el-col {
    margin-bottom: 20px;
  }
}

@media (max-width: 768px) {
  .abc-analysis-page {
    padding: 12px;
  }

  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .config-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .abc-ratio {
    flex-wrap: wrap;
  }

  .summary-content {
    flex-direction: column;
    text-align: center;
  }

  .summary-chart {
    position: static;
    transform: none;
    margin-top: 12px;
  }

  .velocity-metrics {
    font-size: 12px;
  }

  .strategy-cells {
    flex-direction: column;
  }

  .table-actions {
    flex-direction: column;
    gap: 8px;
    align-items: flex-end;
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

.summary-card {
  animation: fadeInUp 0.5s ease;
}

.recommendation-item {
  animation: fadeInUp 0.5s ease;
}

.strategy-cell {
  animation: fadeInUp 0.5s ease;
}
</style>

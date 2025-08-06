<template>
  <div class="demand-forecasting-page">
    <!-- Header Section -->
    <div class="page-header">
      <div class="header-content">
        <div class="title-section">
          <h1 class="page-title">Dự báo Nhu cầu</h1>
          <p class="page-description">Dự báo nhu cầu sản phẩm sử dụng Machine Learning và phân tích xu hướng</p>
        </div>
        <div class="header-actions">
          <el-button type="primary" @click="runForecast" :loading="forecasting">
            <el-icon><TrendCharts /></el-icon>
            Chạy dự báo
          </el-button>
          <el-button @click="trainModel" :loading="training">
            <el-icon><Cpu /></el-icon>
            Huấn luyện model
          </el-button>
          <el-button @click="exportForecast">
            <el-icon><Download /></el-icon>
            Xuất dự báo
          </el-button>
        </div>
      </div>
    </div>

    <!-- Model Configuration -->
    <div class="config-section">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>Cấu hình Model Dự báo</span>
            </template>
            <div class="config-form">
              <div class="config-item">
                <label>Model Algorithm:</label>
                <el-select v-model="modelConfig.algorithm" @change="updateModelInfo">
                  <el-option label="ARIMA" value="arima" />
                  <el-option label="Exponential Smoothing" value="exponential" />
                  <el-option label="Linear Regression" value="linear" />
                  <el-option label="Random Forest" value="random_forest" />
                  <el-option label="LSTM Neural Network" value="lstm" />
                  <el-option label="Prophet" value="prophet" />
                </el-select>
              </div>
              <div class="config-item">
                <label>Chu kỳ dự báo:</label>
                <el-select v-model="modelConfig.forecast_period">
                  <el-option label="7 ngày" :value="7" />
                  <el-option label="14 ngày" :value="14" />
                  <el-option label="30 ngày" :value="30" />
                  <el-option label="60 ngày" :value="60" />
                  <el-option label="90 ngày" :value="90" />
                </el-select>
              </div>
              <div class="config-item">
                <label>Dữ liệu training:</label>
                <el-select v-model="modelConfig.training_period">
                  <el-option label="3 tháng" :value="90" />
                  <el-option label="6 tháng" :value="180" />
                  <el-option label="12 tháng" :value="365" />
                  <el-option label="24 tháng" :value="730" />
                </el-select>
              </div>
              <div class="config-item">
                <label>Confidence Level:</label>
                <el-slider
                  v-model="modelConfig.confidence_level"
                  :min="80"
                  :max="99"
                  :step="1"
                  show-input
                  input-size="small"
                />
              </div>
              <div class="config-item">
                <label>Include External Factors:</label>
                <el-checkbox-group v-model="modelConfig.external_factors">
                  <el-checkbox value="seasonality">Tính mùa vụ</el-checkbox>
                  <el-checkbox value="promotions">Khuyến mãi</el-checkbox>
                  <el-checkbox value="holidays">Ngày lễ</el-checkbox>
                  <el-checkbox value="weather">Thời tiết</el-checkbox>
                  <el-checkbox value="economic">Kinh tế</el-checkbox>
                </el-checkbox-group>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>Thông tin Model</span>
            </template>
            <div class="model-info">
              <div class="info-item">
                <span class="info-label">Algorithm:</span>
                <span class="info-value">{{ getAlgorithmName(modelConfig.algorithm) }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Accuracy Score:</span>
                <div class="accuracy-display">
                  <el-progress
                    :percentage="modelInfo.accuracy"
                    :color="getAccuracyColor(modelInfo.accuracy)"
                    :stroke-width="8"
                  />
                  <span class="accuracy-text">{{ modelInfo.accuracy }}%</span>
                </div>
              </div>
              <div class="info-item">
                <span class="info-label">MAPE (Mean Absolute Percentage Error):</span>
                <span class="info-value">{{ modelInfo.mape }}%</span>
              </div>
              <div class="info-item">
                <span class="info-label">Last Training:</span>
                <span class="info-value">{{ modelInfo.last_training }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Training Data Points:</span>
                <span class="info-value">{{ formatNumber(modelInfo.data_points) }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Model Status:</span>
                <el-tag :type="getStatusTagType(modelInfo.status)">{{ modelInfo.status }}</el-tag>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Forecast Summary -->
    <div class="summary-section">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="summary-content">
              <div class="summary-icon">
                <el-icon color="#409EFF"><TrendCharts /></el-icon>
              </div>
              <div class="summary-details">
                <div class="summary-value">{{ formatNumber(forecastSummary.total_demand) }}</div>
                <div class="summary-label">Tổng nhu cầu dự báo</div>
                <div class="summary-trend" :class="forecastSummary.demand_trend">
                  <el-icon v-if="forecastSummary.demand_trend === 'up'"><ArrowUp /></el-icon>
                  <el-icon v-else-if="forecastSummary.demand_trend === 'down'"><ArrowDown /></el-icon>
                  <el-icon v-else><Minus /></el-icon>
                  {{ forecastSummary.demand_change }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="summary-content">
              <div class="summary-icon">
                <el-icon color="#67C23A"><ShoppingCart /></el-icon>
              </div>
              <div class="summary-details">
                <div class="summary-value">{{ formatNumber(forecastSummary.products_forecasted) }}</div>
                <div class="summary-label">Sản phẩm được dự báo</div>
                <div class="summary-subtitle">{{ forecastSummary.high_confidence }}% độ tin cậy cao</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="summary-content">
              <div class="summary-icon">
                <el-icon color="#E6A23C"><Warning /></el-icon>
              </div>
              <div class="summary-details">
                <div class="summary-value">{{ forecastSummary.alerts }}</div>
                <div class="summary-label">Cảnh báo thiếu hàng</div>
                <div class="summary-subtitle">{{ forecastSummary.critical_alerts }} cảnh báo nghiêm trọng</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="summary-content">
              <div class="summary-icon">
                <el-icon color="#F56C6C"><Money /></el-icon>
              </div>
              <div class="summary-details">
                <div class="summary-value">{{ formatCurrency(forecastSummary.revenue_impact) }}</div>
                <div class="summary-label">Tác động doanh thu</div>
                <div class="summary-subtitle">{{ forecastSummary.revenue_change }}% so với kỳ trước</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Forecast Charts -->
    <div class="charts-section">
      <el-row :gutter="20">
        <el-col :span="16">
          <el-card>
            <template #header>
              <div class="chart-header">
                <span>Biểu đồ Dự báo Tổng quan</span>
                <div class="chart-controls">
                  <el-select v-model="chartConfig.timeframe" size="small" style="width: 120px;">
                    <el-option label="7 ngày" value="7d" />
                    <el-option label="30 ngày" value="30d" />
                    <el-option label="90 ngày" value="90d" />
                  </el-select>
                  <el-select v-model="chartConfig.view_type" size="small" style="width: 120px;">
                    <el-option label="Số lượng" value="quantity" />
                    <el-option label="Doanh thu" value="revenue" />
                    <el-option label="Cả hai" value="both" />
                  </el-select>
                </div>
              </div>
            </template>
            <div class="chart-container">
              <canvas ref="forecastCanvas" width="600" height="400"></canvas>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Độ chính xác theo Sản phẩm</span>
            </template>
            <div class="accuracy-chart">
              <canvas ref="accuracyCanvas" width="300" height="400"></canvas>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Advanced Analysis -->
    <div class="analysis-section">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Seasonal Patterns</span>
            </template>
            <div class="seasonal-analysis">
              <div class="seasonal-item" v-for="pattern in seasonalPatterns" :key="pattern.period">
                <div class="pattern-header">
                  <span class="pattern-period">{{ pattern.period }}</span>
                  <el-tag :type="getPatternTagType(pattern.strength)" size="small">
                    {{ pattern.strength }}
                  </el-tag>
                </div>
                <div class="pattern-details">
                  <div class="pattern-metric">
                    <span class="metric-label">Peak:</span>
                    <span class="metric-value">{{ pattern.peak }}</span>
                  </div>
                  <div class="pattern-metric">
                    <span class="metric-label">Low:</span>
                    <span class="metric-value">{{ pattern.low }}</span>
                  </div>
                  <div class="pattern-metric">
                    <span class="metric-label">Variability:</span>
                    <el-progress
                      :percentage="pattern.variability"
                      :stroke-width="4"
                      :show-text="false"
                      :color="getVariabilityColor(pattern.variability)"
                    />
                  </div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>External Factors Impact</span>
            </template>
            <div class="factors-analysis">
              <div class="factor-item" v-for="factor in externalFactors" :key="factor.name">
                <div class="factor-header">
                  <span class="factor-name">{{ factor.name }}</span>
                  <span class="factor-impact" :class="factor.impact_type">
                    {{ factor.impact }}%
                  </span>
                </div>
                <div class="factor-description">{{ factor.description }}</div>
                <div class="factor-confidence">
                  <span class="confidence-label">Độ tin cậy:</span>
                  <el-progress
                    :percentage="factor.confidence"
                    :stroke-width="4"
                    :show-text="false"
                    color="#67c23a"
                  />
                  <span class="confidence-value">{{ factor.confidence }}%</span>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card>
            <template #header>
              <span>Model Performance</span>
            </template>
            <div class="performance-metrics">
              <div class="metric-card" v-for="metric in performanceMetrics" :key="metric.name">
                <div class="metric-name">{{ metric.name }}</div>
                <div class="metric-value" :class="metric.status">{{ metric.value }}</div>
                <div class="metric-benchmark">
                  <span>Benchmark: {{ metric.benchmark }}</span>
                  <el-icon v-if="metric.status === 'good'" color="#67c23a"><Check /></el-icon>
                  <el-icon v-else-if="metric.status === 'warning'" color="#e6a23c"><Warning /></el-icon>
                  <el-icon v-else color="#f56c6c"><Close /></el-icon>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Product Forecast Table -->
    <el-card class="table-card">
      <template #header>
        <div class="table-header">
          <span>Dự báo chi tiết theo Sản phẩm</span>
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
            <el-select v-model="filterRisk" placeholder="Rủi ro" style="width: 120px; margin-right: 12px">
              <el-option label="Tất cả" value="" />
              <el-option label="Cao" value="high" />
              <el-option label="Trung bình" value="medium" />
              <el-option label="Thấp" value="low" />
            </el-select>
            <el-select v-model="filterConfidence" placeholder="Độ tin cậy" style="width: 120px; margin-right: 12px">
              <el-option label="Tất cả" value="" />
              <el-option label=">90%" value="high" />
              <el-option label="70-90%" value="medium" />
              <el-option label="<70%" value="low" />
            </el-select>
            <el-button @click="refreshForecast">
              <el-icon><Refresh /></el-icon>
            </el-button>
          </div>
        </div>
      </template>

      <el-table
        :data="paginatedForecasts"
        v-loading="loading"
        height="500"
        @sort-change="handleSort"
        row-class-name="forecast-row"
      >
        <el-table-column type="index" label="#" width="50" />
        <el-table-column prop="product_code" label="Mã SP" width="120" sortable="custom" />
        <el-table-column prop="product_name" label="Tên sản phẩm" min-width="200" show-overflow-tooltip />
        <el-table-column prop="current_stock" label="Tồn kho hiện tại" width="130" sortable="custom">
          <template #default="{ row }">
            {{ formatNumber(row.current_stock) }}
          </template>
        </el-table-column>
        <el-table-column prop="forecast_7d" label="Dự báo 7 ngày" width="130" sortable="custom">
          <template #default="{ row }">
            <div class="forecast-cell">
              <span>{{ formatNumber(row.forecast_7d) }}</span>
              <div class="confidence-bar">
                <el-progress
                  :percentage="row.confidence_7d"
                  :stroke-width="3"
                  :show-text="false"
                  :color="getConfidenceColor(row.confidence_7d)"
                />
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="forecast_30d" label="Dự báo 30 ngày" width="130" sortable="custom">
          <template #default="{ row }">
            <div class="forecast-cell">
              <span>{{ formatNumber(row.forecast_30d) }}</span>
              <div class="confidence-bar">
                <el-progress
                  :percentage="row.confidence_30d"
                  :stroke-width="3"
                  :show-text="false"
                  :color="getConfidenceColor(row.confidence_30d)"
                />
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="stockout_risk" label="Rủi ro hết hàng" width="120" sortable="custom">
          <template #default="{ row }">
            <el-tag :type="getRiskTagType(row.stockout_risk)">
              {{ getRiskLabel(row.stockout_risk) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="recommended_order" label="Đề xuất đặt hàng" width="140" sortable="custom">
          <template #default="{ row }">
            <div class="order-recommendation">
              <span class="order-qty">{{ formatNumber(row.recommended_order) }}</span>
              <span class="order-date">{{ row.recommended_date }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="trend" label="Xu hướng" width="100">
          <template #default="{ row }">
            <div class="trend-indicator" :class="row.trend">
              <el-icon v-if="row.trend === 'up'"><ArrowUp /></el-icon>
              <el-icon v-else-if="row.trend === 'down'"><ArrowDown /></el-icon>
              <el-icon v-else><Minus /></el-icon>
              <span>{{ row.trend_value }}%</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="Thao tác" width="160" fixed="right">
          <template #default="{ row }">
            <el-button-group>
              <el-button size="small" @click="viewForecastDetails(row)">
                <el-icon><View /></el-icon>
              </el-button>
              <el-button size="small" type="primary" @click="createPurchaseOrder(row)">
                <el-icon><ShoppingCart /></el-icon>
              </el-button>
              <el-button size="small" type="warning" @click="setAlert(row)">
                <el-icon><Bell /></el-icon>
              </el-button>
              <el-button size="small" @click="adjustForecast(row)">
                <el-icon><Edit /></el-icon>
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
          :total="totalForecasts"
          layout="total, sizes, prev, pager, next, jumper"
        />
      </div>
    </el-card>

    <!-- Forecast Details Dialog -->
    <el-dialog
      v-model="showDetailsDialog"
      :title="selectedForecast?.product_name || 'Chi tiết Dự báo'"
      width="900px"
    >
      <div v-if="selectedForecast" class="forecast-details">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-card>
              <template #header>
                <span>Thông tin Dự báo</span>
              </template>
              <el-descriptions :column="1">
                <el-descriptions-item label="Sản phẩm">{{ selectedForecast.product_name }}</el-descriptions-item>
                <el-descriptions-item label="Mã sản phẩm">{{ selectedForecast.product_code }}</el-descriptions-item>
                <el-descriptions-item label="Tồn kho hiện tại">{{ formatNumber(selectedForecast.current_stock) }}</el-descriptions-item>
                <el-descriptions-item label="Algorithm sử dụng">{{ selectedForecast.algorithm }}</el-descriptions-item>
                <el-descriptions-item label="Độ chính xác">{{ selectedForecast.model_accuracy }}%</el-descriptions-item>
                <el-descriptions-item label="Rủi ro hết hàng">
                  <el-tag :type="getRiskTagType(selectedForecast.stockout_risk)">
                    {{ getRiskLabel(selectedForecast.stockout_risk) }}
                  </el-tag>
                </el-descriptions-item>
              </el-descriptions>
            </el-card>
          </el-col>
          <el-col :span="12">
            <el-card>
              <template #header>
                <span>Dự báo chi tiết</span>
              </template>
              <div class="detailed-forecast">
                <div class="forecast-period" v-for="period in selectedForecast.detailed_forecast" :key="period.days">
                  <div class="period-header">
                    <span class="period-label">{{ period.days }} ngày</span>
                    <span class="period-confidence">{{ period.confidence }}%</span>
                  </div>
                  <div class="period-values">
                    <div class="forecast-range">
                      <span class="range-label">Dự báo:</span>
                      <span class="range-value">{{ formatNumber(period.forecast) }} ± {{ formatNumber(period.margin) }}</span>
                    </div>
                    <div class="forecast-range">
                      <span class="range-label">Min - Max:</span>
                      <span class="range-value">{{ formatNumber(period.min) }} - {{ formatNumber(period.max) }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <el-card style="margin-top: 20px;">
          <template #header>
            <span>Biểu đồ Dự báo chi tiết</span>
          </template>
          <div class="detail-chart">
            <canvas ref="detailCanvas" width="800" height="300"></canvas>
          </div>
        </el-card>

        <el-card style="margin-top: 20px;">
          <template #header>
            <span>Khuyến nghị Hành động</span>
          </template>
          <div class="recommendations">
            <div v-for="rec in selectedForecast.recommendations" :key="rec.id" class="recommendation">
              <div class="rec-icon">
                <el-icon><Lightning /></el-icon>
              </div>
              <div class="rec-content">
                <div class="rec-title">{{ rec.title }}</div>
                <div class="rec-description">{{ rec.description }}</div>
                <div class="rec-impact">Tác động: {{ rec.impact }}</div>
              </div>
              <div class="rec-actions">
                <el-button size="small" type="primary">Thực hiện</el-button>
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </el-dialog>

    <!-- Model Training Dialog -->
    <el-dialog v-model="showTrainingDialog" title="Huấn luyện Model" width="600px">
      <div class="training-form">
        <el-form :model="trainingForm" label-width="150px">
          <el-form-item label="Training Dataset:">
            <el-select v-model="trainingForm.dataset" style="width: 100%">
              <el-option label="Historical Sales (2 years)" value="sales_2y" />
              <el-option label="Historical Sales (1 year)" value="sales_1y" />
              <el-option label="Historical + External Data" value="combined" />
            </el-select>
          </el-form-item>
          <el-form-item label="Cross Validation:">
            <el-switch v-model="trainingForm.cross_validation" />
          </el-form-item>
          <el-form-item label="Feature Selection:">
            <el-checkbox-group v-model="trainingForm.features">
              <el-checkbox value="price">Giá bán</el-checkbox>
              <el-checkbox value="promotions">Khuyến mãi</el-checkbox>
              <el-checkbox value="seasonality">Tính mùa vụ</el-checkbox>
              <el-checkbox value="competitor">Đối thủ cạnh tranh</el-checkbox>
            </el-checkbox-group>
          </el-form-item>
          <el-form-item label="Hyperparameters:">
            <el-input v-model="trainingForm.hyperparameters" type="textarea" :rows="3" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showTrainingDialog = false">Hủy</el-button>
          <el-button type="primary" @click="startTraining" :loading="training">
            Bắt đầu Training
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  TrendCharts, Cpu, Download, ArrowUp, ArrowDown, Minus, ShoppingCart,
  Warning, Money, Search, Refresh, View, Bell, Edit, Check, Close, Lightning
} from '@element-plus/icons-vue'

// Reactive data
const forecasting = ref(false)
const training = ref(false)
const loading = ref(false)
const searchText = ref('')
const filterRisk = ref('')
const filterConfidence = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const showDetailsDialog = ref(false)
const showTrainingDialog = ref(false)
const selectedForecast = ref<any>(null)

// Configuration
const modelConfig = reactive({
  algorithm: 'arima',
  forecast_period: 30,
  training_period: 365,
  confidence_level: 95,
  external_factors: ['seasonality', 'promotions']
})

const chartConfig = reactive({
  timeframe: '30d',
  view_type: 'quantity'
})

const trainingForm = reactive({
  dataset: 'sales_1y',
  cross_validation: true,
  features: ['price', 'seasonality'],
  hyperparameters: '{"learning_rate": 0.01, "epochs": 100}'
})

// Model information
const modelInfo = reactive({
  accuracy: 87.5,
  mape: 12.3,
  last_training: '2024-12-15 14:30:00',
  data_points: 18500,
  status: 'Ready'
})

// Sample data
const forecastSummary = reactive({
  total_demand: 125800,
  demand_trend: 'up',
  demand_change: 8.5,
  products_forecasted: 1247,
  high_confidence: 78,
  alerts: 23,
  critical_alerts: 5,
  revenue_impact: 2850000000,
  revenue_change: 12.3
})

const seasonalPatterns = ref([
  {
    period: 'Quarterly',
    strength: 'Strong',
    peak: 'Q4',
    low: 'Q1',
    variability: 85
  },
  {
    period: 'Monthly',
    strength: 'Medium',
    peak: 'December',
    low: 'February',
    variability: 65
  },
  {
    period: 'Weekly',
    strength: 'Weak',
    peak: 'Friday',
    low: 'Tuesday',
    variability: 35
  }
])

const externalFactors = ref([
  {
    name: 'Tính mùa vụ',
    impact: 15.8,
    impact_type: 'positive',
    confidence: 92,
    description: 'Xu hướng tăng mạnh vào cuối năm'
  },
  {
    name: 'Khuyến mãi',
    impact: 23.5,
    impact_type: 'positive',
    confidence: 88,
    description: 'Các chương trình khuyến mãi có tác động tích cực'
  },
  {
    name: 'Ngày lễ',
    impact: 8.2,
    impact_type: 'positive',
    confidence: 75,
    description: 'Tăng nhu cầu trong các dịp lễ tết'
  },
  {
    name: 'Kinh tế',
    impact: -5.1,
    impact_type: 'negative',
    confidence: 68,
    description: 'Tình hình kinh tế có ảnh hưởng nhẹ'
  }
])

const performanceMetrics = ref([
  {
    name: 'MAPE',
    value: '12.3%',
    benchmark: '<15%',
    status: 'good'
  },
  {
    name: 'RMSE',
    value: '145.2',
    benchmark: '<200',
    status: 'good'
  },
  {
    name: 'MAE',
    value: '98.7',
    benchmark: '<120',
    status: 'good'
  },
  {
    name: 'R²',
    value: '0.875',
    benchmark: '>0.8',
    status: 'good'
  },
  {
    name: 'Bias',
    value: '3.2%',
    benchmark: '<5%',
    status: 'good'
  },
  {
    name: 'Coverage',
    value: '94.1%',
    benchmark: '>90%',
    status: 'good'
  }
])

const forecasts = ref([
  {
    id: 1,
    product_code: 'SP001',
    product_name: 'iPhone 15 Pro Max 256GB',
    current_stock: 45,
    forecast_7d: 28,
    confidence_7d: 92,
    forecast_30d: 125,
    confidence_30d: 87,
    stockout_risk: 'high',
    recommended_order: 150,
    recommended_date: '2024-12-20',
    trend: 'up',
    trend_value: 15.2,
    algorithm: 'LSTM',
    model_accuracy: 91.5,
    detailed_forecast: [
      { days: 7, forecast: 28, confidence: 92, margin: 3, min: 25, max: 31 },
      { days: 14, forecast: 58, confidence: 89, margin: 7, min: 51, max: 65 },
      { days: 30, forecast: 125, confidence: 87, margin: 15, min: 110, max: 140 }
    ],
    recommendations: [
      {
        id: 1,
        title: 'Đặt hàng khẩn cấp',
        description: 'Nên đặt hàng ngay lập tức để tránh hết hàng',
        impact: 'Giảm 95% rủi ro thiếu hàng'
      },
      {
        id: 2,
        title: 'Tăng safety stock',
        description: 'Tăng mức tồn kho an toàn lên 20% cho sản phẩm này',
        impact: 'Cải thiện service level lên 99%'
      }
    ]
  },
  {
    id: 2,
    product_code: 'SP002',
    product_name: 'Samsung Galaxy S24 Ultra',
    current_stock: 32,
    forecast_7d: 18,
    confidence_7d: 89,
    forecast_30d: 78,
    confidence_30d: 84,
    stockout_risk: 'medium',
    recommended_order: 80,
    recommended_date: '2024-12-25',
    trend: 'up',
    trend_value: 8.7,
    algorithm: 'Prophet',
    model_accuracy: 88.2,
    detailed_forecast: [
      { days: 7, forecast: 18, confidence: 89, margin: 2, min: 16, max: 20 },
      { days: 14, forecast: 38, confidence: 86, margin: 4, min: 34, max: 42 },
      { days: 30, forecast: 78, confidence: 84, margin: 8, min: 70, max: 86 }
    ],
    recommendations: []
  },
  {
    id: 3,
    product_code: 'SP003',
    product_name: 'MacBook Pro M3 14 inch',
    current_stock: 18,
    forecast_7d: 12,
    confidence_7d: 94,
    forecast_30d: 48,
    confidence_30d: 91,
    stockout_risk: 'medium',
    recommended_order: 60,
    recommended_date: '2024-12-28',
    trend: 'stable',
    trend_value: 2.1,
    algorithm: 'ARIMA',
    model_accuracy: 89.7,
    detailed_forecast: [
      { days: 7, forecast: 12, confidence: 94, margin: 1, min: 11, max: 13 },
      { days: 14, forecast: 24, confidence: 92, margin: 2, min: 22, max: 26 },
      { days: 30, forecast: 48, confidence: 91, margin: 4, min: 44, max: 52 }
    ],
    recommendations: []
  }
])

// Canvas refs
const forecastCanvas = ref<HTMLCanvasElement>()
const accuracyCanvas = ref<HTMLCanvasElement>()
const detailCanvas = ref<HTMLCanvasElement>()

// Computed properties
const filteredForecasts = computed(() => {
  let filtered = forecasts.value

  if (searchText.value) {
    const search = searchText.value.toLowerCase()
    filtered = filtered.filter(f =>
      f.product_name.toLowerCase().includes(search) ||
      f.product_code.toLowerCase().includes(search)
    )
  }

  if (filterRisk.value) {
    filtered = filtered.filter(f => f.stockout_risk === filterRisk.value)
  }

  if (filterConfidence.value) {
    filtered = filtered.filter(f => {
      const confidence = f.confidence_30d
      if (filterConfidence.value === 'high') return confidence > 90
      if (filterConfidence.value === 'medium') return confidence >= 70 && confidence <= 90
      if (filterConfidence.value === 'low') return confidence < 70
      return true
    })
  }

  return filtered
})

const paginatedForecasts = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredForecasts.value.slice(start, end)
})

const totalForecasts = computed(() => filteredForecasts.value.length)

// Methods
const getAlgorithmName = (algorithm: string) => {
  const names: Record<string, string> = {
    arima: 'ARIMA (AutoRegressive Integrated Moving Average)',
    exponential: 'Exponential Smoothing',
    linear: 'Linear Regression',
    random_forest: 'Random Forest',
    lstm: 'LSTM Neural Network',
    prophet: 'Facebook Prophet'
  }
  return names[algorithm] || algorithm
}

const getAccuracyColor = (accuracy: number) => {
  if (accuracy >= 90) return '#67C23A'
  if (accuracy >= 80) return '#E6A23C'
  return '#F56C6C'
}

const getStatusTagType = (status: string) => {
  const types: Record<string, string> = {
    Ready: 'success',
    Training: 'warning',
    Error: 'danger'
  }
  return types[status] || 'info'
}

const getPatternTagType = (strength: string) => {
  const types: Record<string, string> = {
    Strong: 'danger',
    Medium: 'warning',
    Weak: 'info'
  }
  return types[strength] || ''
}

const getVariabilityColor = (variability: number) => {
  if (variability >= 70) return '#F56C6C'
  if (variability >= 40) return '#E6A23C'
  return '#67C23A'
}

const getConfidenceColor = (confidence: number) => {
  if (confidence >= 90) return '#67C23A'
  if (confidence >= 70) return '#E6A23C'
  return '#F56C6C'
}

const getRiskTagType = (risk: string) => {
  const types: Record<string, string> = {
    high: 'danger',
    medium: 'warning',
    low: 'success'
  }
  return types[risk] || ''
}

const getRiskLabel = (risk: string) => {
  const labels: Record<string, string> = {
    high: 'Cao',
    medium: 'Trung bình',
    low: 'Thấp'
  }
  return labels[risk] || risk
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

const updateModelInfo = () => {
  // Update model info based on algorithm selection
  console.log('Updating model info for:', modelConfig.algorithm)
}

const runForecast = async () => {
  forecasting.value = true
  try {
    await new Promise(resolve => setTimeout(resolve, 3000))
    ElMessage.success('Dự báo hoàn thành')
    await nextTick()
    drawCharts()
  } finally {
    forecasting.value = false
  }
}

const trainModel = () => {
  showTrainingDialog.value = true
}

const startTraining = async () => {
  training.value = true
  try {
    await new Promise(resolve => setTimeout(resolve, 5000))
    modelInfo.accuracy = 89.2
    modelInfo.mape = 11.8
    modelInfo.last_training = new Date().toLocaleString('vi-VN')
    ElMessage.success('Huấn luyện model hoàn thành')
    showTrainingDialog.value = false
  } finally {
    training.value = false
  }
}

const exportForecast = () => {
  ElMessage.success('Đang xuất báo cáo dự báo...')
}

const refreshForecast = () => {
  loading.value = true
  setTimeout(() => {
    loading.value = false
  }, 1000)
}

const handleSort = (sort: any) => {
  console.log('Sort:', sort)
}

const viewForecastDetails = (forecast: any) => {
  selectedForecast.value = forecast
  showDetailsDialog.value = true
  nextTick(() => {
    drawDetailChart()
  })
}

const createPurchaseOrder = (forecast: any) => {
  ElMessage.success(`Tạo đơn đặt hàng cho ${forecast.product_name}: ${forecast.recommended_order} sản phẩm`)
}

const setAlert = (forecast: any) => {
  ElMessage.info(`Thiết lập cảnh báo cho ${forecast.product_name}`)
}

const adjustForecast = (forecast: any) => {
  ElMessage.info(`Điều chỉnh dự báo cho ${forecast.product_name}`)
}

// Chart drawing functions
const drawCharts = () => {
  drawForecastChart()
  drawAccuracyChart()
}

const drawForecastChart = () => {
  if (!forecastCanvas.value) return
  const ctx = forecastCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 600, 400)

  // Draw forecast trend
  ctx.strokeStyle = '#409EFF'
  ctx.lineWidth = 3
  ctx.beginPath()
  ctx.moveTo(50, 200)

  // Sample forecast line
  const points = [200, 190, 210, 195, 220, 215, 235, 225, 250, 240]
  points.forEach((y, i) => {
    ctx.lineTo(50 + i * 55, y)
  })
  ctx.stroke()

  // Draw confidence interval
  ctx.fillStyle = 'rgba(64, 158, 255, 0.2)'
  ctx.beginPath()
  ctx.moveTo(50, 180)
  points.forEach((y, i) => {
    ctx.lineTo(50 + i * 55, y - 20)
  })
  for (let i = points.length - 1; i >= 0; i--) {
    ctx.lineTo(50 + i * 55, points[i] + 20)
  }
  ctx.closePath()
  ctx.fill()

  // Labels
  ctx.fillStyle = '#303133'
  ctx.font = '12px Arial'
  ctx.fillText('Historical', 30, 380)
  ctx.fillText('Forecast', 300, 380)

  // Draw vertical line separating historical and forecast
  ctx.strokeStyle = '#E4E7ED'
  ctx.setLineDash([5, 5])
  ctx.beginPath()
  ctx.moveTo(275, 50)
  ctx.lineTo(275, 350)
  ctx.stroke()
  ctx.setLineDash([])
}

const drawAccuracyChart = () => {
  if (!accuracyCanvas.value) return
  const ctx = accuracyCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 300, 400)

  // Draw accuracy bars
  const products = ['iPhone', 'Samsung', 'MacBook', 'iPad', 'AirPods']
  const accuracies = [92, 89, 94, 87, 85]

  products.forEach((product, i) => {
    const barHeight = (accuracies[i] / 100) * 300
    const y = 350 - barHeight

    // Bar
    ctx.fillStyle = getAccuracyColor(accuracies[i])
    ctx.fillRect(30 + i * 45, y, 35, barHeight)

    // Accuracy text
    ctx.fillStyle = '#303133'
    ctx.font = '10px Arial'
    ctx.fillText(`${accuracies[i]}%`, 32 + i * 45, y - 5)

    // Product label
    ctx.save()
    ctx.translate(47 + i * 45, 380)
    ctx.rotate(-Math.PI / 4)
    ctx.fillText(product, 0, 0)
    ctx.restore()
  })
}

const drawDetailChart = () => {
  if (!detailCanvas.value) return
  const ctx = detailCanvas.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, 800, 300)

  // Draw detailed forecast with confidence intervals
  ctx.strokeStyle = '#409EFF'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.moveTo(50, 150)

  // Sample detailed forecast
  const detailPoints = [150, 145, 155, 140, 160, 165, 170, 175, 180, 185, 190, 195]
  detailPoints.forEach((y, i) => {
    ctx.lineTo(50 + i * 60, y)
  })
  ctx.stroke()

  // Add confidence bands
  ctx.fillStyle = 'rgba(64, 158, 255, 0.2)'
  ctx.beginPath()
  ctx.moveTo(50, 130)
  detailPoints.forEach((y, i) => {
    ctx.lineTo(50 + i * 60, y - 20)
  })
  for (let i = detailPoints.length - 1; i >= 0; i--) {
    ctx.lineTo(50 + i * 60, detailPoints[i] + 20)
  }
  ctx.closePath()
  ctx.fill()
}

onMounted(() => {
  runForecast()
})
</script>

<style scoped>
.demand-forecasting-page {
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

.config-form {
  padding: 16px 0;
}

.config-item {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
}

.config-item label {
  min-width: 140px;
  font-size: 14px;
  color: #606266;
}

.model-info {
  padding: 16px 0;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.info-label {
  font-size: 14px;
  color: #606266;
}

.info-value {
  font-weight: 600;
  color: #303133;
}

.accuracy-display {
  display: flex;
  align-items: center;
  gap: 12px;
}

.accuracy-text {
  font-weight: 600;
  color: #303133;
}

.summary-section {
  margin-bottom: 20px;
}

.summary-card {
  height: 120px;
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

.summary-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 600;
}

.summary-trend.up { color: #67C23A; }
.summary-trend.down { color: #F56C6C; }
.summary-trend.stable { color: #909399; }

.charts-section {
  margin-bottom: 20px;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-controls {
  display: flex;
  gap: 8px;
}

.chart-container {
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.accuracy-chart {
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.analysis-section {
  margin-bottom: 20px;
}

.seasonal-analysis {
  padding: 16px 0;
}

.seasonal-item {
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
}

.pattern-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.pattern-period {
  font-weight: 600;
  color: #303133;
}

.pattern-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.pattern-metric {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}

.metric-label {
  color: #606266;
}

.metric-value {
  font-weight: 600;
  color: #303133;
}

.factors-analysis {
  padding: 16px 0;
}

.factor-item {
  margin-bottom: 20px;
  padding: 16px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
}

.factor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.factor-name {
  font-weight: 600;
  color: #303133;
}

.factor-impact {
  font-weight: 600;
}

.factor-impact.positive { color: #67C23A; }
.factor-impact.negative { color: #F56C6C; }

.factor-description {
  font-size: 14px;
  color: #606266;
  margin-bottom: 12px;
}

.factor-confidence {
  display: flex;
  align-items: center;
  gap: 8px;
}

.confidence-label {
  font-size: 12px;
  color: #909399;
}

.confidence-value {
  font-size: 12px;
  color: #303133;
  font-weight: 600;
}

.performance-metrics {
  padding: 16px 0;
}

.metric-card {
  margin-bottom: 16px;
  padding: 12px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  text-align: center;
}

.metric-name {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.metric-value {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 4px;
}

.metric-value.good { color: #67C23A; }
.metric-value.warning { color: #E6A23C; }
.metric-value.bad { color: #F56C6C; }

.metric-benchmark {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  font-size: 10px;
  color: #909399;
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

.forecast-cell {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.confidence-bar {
  width: 100%;
}

.order-recommendation {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.order-qty {
  font-weight: 600;
  color: #303133;
}

.order-date {
  font-size: 12px;
  color: #909399;
}

.trend-indicator {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 600;
}

.trend-indicator.up { color: #67C23A; }
.trend-indicator.down { color: #F56C6C; }
.trend-indicator.stable { color: #909399; }

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.forecast-details {
  padding: 0 16px;
}

.detailed-forecast {
  padding: 16px 0;
}

.forecast-period {
  margin-bottom: 16px;
  padding: 12px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
}

.period-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.period-label {
  font-weight: 600;
  color: #303133;
}

.period-confidence {
  font-size: 12px;
  color: #67C23A;
  font-weight: 600;
}

.period-values {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.forecast-range {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
}

.range-label {
  color: #606266;
}

.range-value {
  font-weight: 600;
  color: #303133;
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

.training-form {
  padding: 16px 0;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .summary-section .el-col {
    margin-bottom: 12px;
  }

  .analysis-section .el-col {
    margin-bottom: 20px;
  }
}

@media (max-width: 768px) {
  .demand-forecasting-page {
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

  .config-item label {
    min-width: auto;
    margin-bottom: 4px;
  }

  .summary-content {
    flex-direction: column;
    text-align: center;
  }

  .table-actions {
    flex-direction: column;
    gap: 8px;
    align-items: flex-end;
  }

  .chart-controls {
    flex-direction: column;
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

.forecast-period {
  animation: fadeInUp 0.5s ease;
}

.recommendation {
  animation: fadeInUp 0.5s ease;
}
</style>

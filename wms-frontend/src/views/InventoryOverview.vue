<template>
  <div class="inventory-overview">
    <!-- Page Header -->
    <div class="page-header">
      <div class="header-left">
        <h1 class="page-title">Tổng quan tồn kho</h1>
        <p class="page-description">Quản lý và theo dõi tình trạng tồn kho toàn hệ thống</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="exportData">
          <el-icon><Download /></el-icon>
          Xuất dữ liệu
        </el-button>
        <el-button @click="refreshData">
          <el-icon><Refresh /></el-icon>
          Làm mới
        </el-button>
      </div>
    </div>

    <!-- Filter Section -->
    <el-card shadow="never" class="filter-card">
      <div class="filters">
        <el-row :gutter="20">
          <el-col :span="4">
            <el-select v-model="filters.warehouse" placeholder="Chọn kho" clearable>
              <el-option
                v-for="warehouse in warehouses"
                :key="warehouse.id"
                :label="warehouse.name"
                :value="warehouse.id"
              />
            </el-select>
          </el-col>
          <el-col :span="4">
            <el-select v-model="filters.category" placeholder="Danh mục" clearable>
              <el-option
                v-for="category in categories"
                :key="category.id"
                :label="category.name"
                :value="category.id"
              />
            </el-select>
          </el-col>
          <el-col :span="4">
            <el-select v-model="filters.stockStatus" placeholder="Trạng thái tồn kho" clearable>
              <el-option label="Tồn kho tốt" value="good" />
              <el-option label="Dưới mức tối thiểu" value="low" />
              <el-option label="Hết hàng" value="out" />
              <el-option label="Vượt mức tối đa" value="over" />
            </el-select>
          </el-col>
          <el-col :span="6">
            <el-input
              v-model="filters.search"
              placeholder="Tìm kiếm SKU, tên sản phẩm..."
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </el-col>
          <el-col :span="6">
            <el-button type="primary" @click="applyFilters">
              <el-icon><Search /></el-icon>
              Tìm kiếm
            </el-button>
            <el-button @click="resetFilters">Đặt lại</el-button>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- Summary Cards -->
    <el-row :gutter="20" class="summary-section">
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-content">
            <div class="summary-icon bg-blue">
              <el-icon size="32"><Box /></el-icon>
            </div>
            <div class="summary-details">
              <div class="summary-value">{{ summaryData.totalSKUs.toLocaleString() }}</div>
              <div class="summary-label">Tổng SKU</div>
              <div class="summary-trend positive">
                <el-icon><ArrowUp /></el-icon>
                +{{ summaryData.newSKUs }} mới
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-content">
            <div class="summary-icon bg-green">
              <el-icon size="32"><Money /></el-icon>
            </div>
            <div class="summary-details">
              <div class="summary-value">{{ formatCurrency(summaryData.totalValue) }}</div>
              <div class="summary-label">Tổng giá trị</div>
              <div class="summary-trend positive">
                <el-icon><ArrowUp /></el-icon>
                +2.5% tuần qua
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-content">
            <div class="summary-icon bg-orange">
              <el-icon size="32"><Warning /></el-icon>
            </div>
            <div class="summary-details">
              <div class="summary-value">{{ summaryData.lowStock }}</div>
              <div class="summary-label">Tồn kho thấp</div>
              <div class="summary-trend negative">
                <el-icon><ArrowDown /></el-icon>
                Cần bổ sung
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-content">
            <div class="summary-icon bg-red">
              <el-icon size="32"><Clock /></el-icon>
            </div>
            <div class="summary-details">
              <div class="summary-value">{{ summaryData.expiringSoon }}</div>
              <div class="summary-label">Sắp hết hạn</div>
              <div class="summary-trend warning">
                <el-icon><Clock /></el-icon>
                Trong 30 ngày
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Data Table -->
    <el-card shadow="never" class="table-card">
      <template #header>
        <div class="table-header">
          <span class="table-title">Chi tiết tồn kho</span>
          <div class="table-actions">
            <el-button size="small" @click="showBulkActions = !showBulkActions">
              Thao tác hàng loạt
            </el-button>
            <el-button size="small" type="primary" @click="addNewProduct">
              <el-icon><Plus /></el-icon>
              Thêm sản phẩm
            </el-button>
          </div>
        </div>
      </template>

      <!-- Bulk Actions Bar -->
      <div v-if="showBulkActions && selectedRows.length > 0" class="bulk-actions-bar">
        <div class="bulk-info">
          Đã chọn {{ selectedRows.length }} sản phẩm
        </div>
        <div class="bulk-buttons">
          <el-button size="small" type="warning" @click="bulkAdjustStock">
            Điều chỉnh tồn kho
          </el-button>
          <el-button size="small" type="success" @click="bulkExport">
            Xuất dữ liệu
          </el-button>
          <el-button size="small" @click="clearSelection">
            Bỏ chọn
          </el-button>
        </div>
      </div>

      <el-table
        :data="inventoryData"
        v-loading="loading"
        @selection-change="handleSelectionChange"
        style="width: 100%"
        height="600"
      >
        <el-table-column type="selection" width="55" />

        <el-table-column prop="sku" label="SKU" width="120" fixed>
          <template #default="{ row }">
            <el-button type="text" @click="viewProductDetail(row)">
              {{ row.sku }}
            </el-button>
          </template>
        </el-table-column>

        <el-table-column prop="name" label="Tên sản phẩm" min-width="200">
          <template #default="{ row }">
            <div class="product-info">
              <div class="product-name">{{ row.name }}</div>
              <div class="product-category">{{ row.categoryName }}</div>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="warehouseName" label="Kho" width="150" />

        <el-table-column prop="availableQuantity" label="Tồn khả dụng" width="120" align="right">
          <template #default="{ row }">
            <span :class="getStockStatusClass(row)">
              {{ formatQuantity(row.availableQuantity) }}
            </span>
          </template>
        </el-table-column>

        <el-table-column prop="reservedQuantity" label="Đã bảo lưu" width="120" align="right">
          <template #default="{ row }">
            {{ formatQuantity(row.reservedQuantity) }}
          </template>
        </el-table-column>

        <el-table-column prop="unit" label="Đơn vị" width="80" />

        <el-table-column prop="averageCost" label="Giá trung bình" width="120" align="right">
          <template #default="{ row }">
            {{ formatCurrency(row.averageCost) }}
          </template>
        </el-table-column>

        <el-table-column prop="totalValue" label="Tổng giá trị" width="150" align="right">
          <template #default="{ row }">
            {{ formatCurrency(row.totalValue) }}
          </template>
        </el-table-column>

        <el-table-column prop="stockStatus" label="Trạng thái" width="120">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.stockStatus)" size="small">
              {{ getStatusText(row.stockStatus) }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="lastMovementDate" label="Chuyển động cuối" width="130">
          <template #default="{ row }">
            {{ formatDate(row.lastMovementDate) }}
          </template>
        </el-table-column>

        <el-table-column label="Thao tác" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="adjustStock(row)">
              Điều chỉnh
            </el-button>
            <el-button size="small" @click="viewMovements(row)">
              Lịch sử
            </el-button>
            <el-dropdown>
              <el-button size="small">
                Khác <el-icon><ArrowDown /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item @click="createInbound(row)">Tạo phiếu nhập</el-dropdown-item>
                  <el-dropdown-item @click="createOutbound(row)">Tạo phiếu xuất</el-dropdown-item>
                  <el-dropdown-item @click="scheduleCount(row)">Lên lịch kiểm kê</el-dropdown-item>
                  <el-dropdown-item divided @click="viewBatches(row)">Xem lô hàng</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
      </el-table>

      <!-- Pagination -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.currentPage"
          v-model:page-size="pagination.pageSize"
          :page-sizes="[20, 50, 100, 200]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- Stock Adjustment Dialog -->
    <el-dialog
      v-model="adjustmentDialog.visible"
      title="Điều chỉnh tồn kho"
      width="600px"
    >
      <el-form
        :model="adjustmentForm"
        :rules="adjustmentRules"
        ref="adjustmentFormRef"
        label-width="120px"
      >
        <el-form-item label="Sản phẩm">
          <el-input v-model="adjustmentForm.productInfo" disabled />
        </el-form-item>

        <el-form-item label="Loại điều chỉnh" prop="adjustmentType">
          <el-radio-group v-model="adjustmentForm.adjustmentType">
            <el-radio value="increase">Tăng tồn kho</el-radio>
            <el-radio value="decrease">Giảm tồn kho</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="Số lượng" prop="quantity">
          <el-input-number
            v-model="adjustmentForm.quantity"
            :min="0"
            :precision="3"
            style="width: 200px"
          />
        </el-form-item>

        <el-form-item label="Lý do" prop="reason">
          <el-select v-model="adjustmentForm.reason" placeholder="Chọn lý do">
            <el-option label="Kiểm kê phát hiện chênh lệch" value="cycle_count" />
            <el-option label="Hàng bị hỏng/mất" value="damaged" />
            <el-option label="Nhập nhầm số liệu" value="data_error" />
            <el-option label="Khác" value="other" />
          </el-select>
        </el-form-item>

        <el-form-item label="Ghi chú">
          <el-input
            v-model="adjustmentForm.notes"
            type="textarea"
            :rows="3"
            placeholder="Nhập ghi chú chi tiết..."
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="adjustmentDialog.visible = false">Hủy</el-button>
        <el-button type="primary" @click="submitAdjustment">Xác nhận</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import {
  Download, Refresh, Search, Box, Money, Warning, Clock, Plus,
  ArrowUp, ArrowDown
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// Reactive data
const loading = ref(false)
const showBulkActions = ref(false)
const selectedRows = ref([])

const filters = reactive({
  warehouse: null,
  category: null,
  stockStatus: null,
  search: ''
})

const pagination = reactive({
  currentPage: 1,
  pageSize: 50,
  total: 0
})

const adjustmentDialog = reactive({
  visible: false,
  currentProduct: null
})

const adjustmentForm = reactive({
  productInfo: '',
  adjustmentType: 'increase',
  quantity: 0,
  reason: '',
  notes: ''
})

const adjustmentRules = {
  adjustmentType: [{ required: true, message: '请选择调整类型', trigger: 'change' }],
  quantity: [{ required: true, type: 'number', min: 0.001, message: '请输入有效数量', trigger: 'blur' }],
  reason: [{ required: true, message: '请选择调整原因', trigger: 'change' }]
}

// Sample data
const warehouses = ref([
  { id: 1, name: 'Kho Hà Nội - Cầu Giấy', code: 'WH-HN01' },
  { id: 2, name: 'Kho TP.HCM - Quận 7', code: 'WH-HCM01' },
  { id: 3, name: 'Kho Đà Nẵng - Hải Châu', code: 'WH-DN01' }
])

const categories = ref([
  { id: 1, name: 'Thực phẩm tươi sống' },
  { id: 2, name: 'Thực phẩm đóng gói' },
  { id: 3, name: 'Đồ uống' },
  { id: 4, name: 'Hóa mỹ phẩm' },
  { id: 5, name: 'Điện tử' }
])

const summaryData = reactive({
  totalSKUs: 1847,
  newSKUs: 23,
  totalValue: 2850000000,
  lowStock: 45,
  expiringSoon: 12
})

const inventoryData = ref([
  {
    id: 1,
    sku: 'PRD-001234',
    name: 'Sữa tươi Vinamilk 1L',
    categoryName: 'Thực phẩm tươi sống',
    warehouseName: 'Kho Hà Nội',
    availableQuantity: 1250,
    reservedQuantity: 150,
    unit: 'hộp',
    averageCost: 28000,
    totalValue: 35000000,
    stockStatus: 'good',
    minStockLevel: 200,
    maxStockLevel: 2000,
    lastMovementDate: new Date('2024-12-15T10:30:00')
  },
  {
    id: 2,
    sku: 'PRD-005678',
    name: 'Bánh mì sandwich 500g',
    categoryName: 'Thực phẩm đóng gói',
    warehouseName: 'Kho TP.HCM',
    availableQuantity: 85,
    reservedQuantity: 25,
    unit: 'gói',
    averageCost: 45000,
    totalValue: 3825000,
    stockStatus: 'low',
    minStockLevel: 100,
    maxStockLevel: 500,
    lastMovementDate: new Date('2024-12-14T14:20:00')
  },
  {
    id: 3,
    sku: 'PRD-009012',
    name: 'Nước khoáng Lavie 500ml',
    categoryName: 'Đồ uống',
    warehouseName: 'Kho Đà Nẵng',
    availableQuantity: 2500,
    reservedQuantity: 200,
    unit: 'chai',
    averageCost: 8000,
    totalValue: 20000000,
    stockStatus: 'good',
    minStockLevel: 500,
    maxStockLevel: 3000,
    lastMovementDate: new Date('2024-12-15T16:45:00')
  },
  {
    id: 4,
    sku: 'PRD-003456',
    name: 'Dầu gội Head & Shoulders 400ml',
    categoryName: 'Hóa mỹ phẩm',
    warehouseName: 'Kho Hà Nội',
    availableQuantity: 0,
    reservedQuantity: 0,
    unit: 'chai',
    averageCost: 125000,
    totalValue: 0,
    stockStatus: 'out',
    minStockLevel: 50,
    maxStockLevel: 300,
    lastMovementDate: new Date('2024-12-10T09:15:00')
  },
  {
    id: 5,
    sku: 'PRD-007890',
    name: 'Smartphone Samsung Galaxy A54',
    categoryName: 'Điện tử',
    warehouseName: 'Kho TP.HCM',
    availableQuantity: 450,
    reservedQuantity: 50,
    unit: 'cái',
    averageCost: 8500000,
    totalValue: 3825000000,
    stockStatus: 'over',
    minStockLevel: 20,
    maxStockLevel: 100,
    lastMovementDate: new Date('2024-12-15T11:00:00')
  }
])

// Methods
const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(value)
}

const formatQuantity = (value: number) => {
  return value.toLocaleString('vi-VN', { maximumFractionDigits: 3 })
}

const formatDate = (date: Date) => {
  return date.toLocaleDateString('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
}

const getStockStatusClass = (row: any) => {
  if (row.availableQuantity <= 0) return 'stock-out'
  if (row.availableQuantity <= row.minStockLevel) return 'stock-low'
  if (row.availableQuantity >= row.maxStockLevel) return 'stock-over'
  return 'stock-good'
}

const getStatusTagType = (status: string) => {
  const statusMap: Record<string, string> = {
    good: 'success',
    low: 'warning',
    out: 'danger',
    over: 'info'
  }
  return statusMap[status] || ''
}

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    good: 'Tồn kho tốt',
    low: 'Tồn kho thấp',
    out: 'Hết hàng',
    over: 'Vượt mức'
  }
  return statusMap[status] || status
}

const refreshData = () => {
  loading.value = true
  // Simulate API call
  setTimeout(() => {
    loading.value = false
    ElMessage.success('Dữ liệu đã được làm mới')
  }, 1000)
}

const exportData = () => {
  ElMessage.success('Đang xuất dữ liệu...')
}

const applyFilters = () => {
  // Apply filters logic
  ElMessage.info('Áp dụng bộ lọc')
}

const resetFilters = () => {
  Object.assign(filters, {
    warehouse: null,
    category: null,
    stockStatus: null,
    search: ''
  })
}

const handleSelectionChange = (selection: any[]) => {
  selectedRows.value = selection
}

const clearSelection = () => {
  selectedRows.value = []
}

const adjustStock = (row: any) => {
  adjustmentDialog.currentProduct = row
  adjustmentForm.productInfo = `${row.sku} - ${row.name}`
  adjustmentForm.adjustmentType = 'increase'
  adjustmentForm.quantity = 0
  adjustmentForm.reason = ''
  adjustmentForm.notes = ''
  adjustmentDialog.visible = true
}

const submitAdjustment = () => {
  ElMessage.success('Điều chỉnh tồn kho thành công')
  adjustmentDialog.visible = false
}

const viewProductDetail = (row: any) => {
  ElMessage.info(`Xem chi tiết sản phẩm: ${row.sku}`)
}

const viewMovements = (row: any) => {
  ElMessage.info(`Xem lịch sử chuyển động: ${row.sku}`)
}

const addNewProduct = () => {
  ElMessage.info('Chuyển đến trang thêm sản phẩm mới')
}

const handleSizeChange = (size: number) => {
  pagination.pageSize = size
  // Reload data
}

const handleCurrentChange = (page: number) => {
  pagination.currentPage = page
  // Reload data
}

// Bulk actions
const bulkAdjustStock = () => {
  ElMessage.info(`Điều chỉnh ${selectedRows.value.length} sản phẩm`)
}

const bulkExport = () => {
  ElMessage.info(`Xuất dữ liệu ${selectedRows.value.length} sản phẩm`)
}

// Additional actions
const createInbound = (row: any) => {
  ElMessage.info(`Tạo phiếu nhập cho ${row.sku}`)
}

const createOutbound = (row: any) => {
  ElMessage.info(`Tạo phiếu xuất cho ${row.sku}`)
}

const scheduleCount = (row: any) => {
  ElMessage.info(`Lên lịch kiểm kê cho ${row.sku}`)
}

const viewBatches = (row: any) => {
  ElMessage.info(`Xem lô hàng cho ${row.sku}`)
}

onMounted(() => {
  pagination.total = inventoryData.value.length
})
</script>

<style scoped>
.inventory-overview {
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
}

/* Filter Section */
.filter-card {
  margin-bottom: 20px;
}

.filters {
  padding: 4px 0;
}

/* Summary Section */
.summary-section {
  margin-bottom: 20px;
}

.summary-card {
  border: none;
  transition: all 0.3s ease;
}

.summary-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.summary-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.summary-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.bg-blue { background: linear-gradient(135deg, #409EFF 0%, #337ecc 100%); }
.bg-green { background: linear-gradient(135deg, #67C23A 0%, #529b2e 100%); }
.bg-orange { background: linear-gradient(135deg, #E6A23C 0%, #b88230 100%); }
.bg-red { background: linear-gradient(135deg, #F56C6C 0%, #c45656 100%); }

.summary-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.summary-value {
  font-size: 28px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}

.summary-label {
  color: #606266;
  font-size: 14px;
  font-weight: 500;
}

.summary-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 500;
}

.summary-trend.positive { color: #67C23A; }
.summary-trend.negative { color: #F56C6C; }
.summary-trend.warning { color: #E6A23C; }

/* Table Section */
.table-card {
  margin-bottom: 20px;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.table-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.table-actions {
  display: flex;
  gap: 8px;
}

/* Bulk Actions */
.bulk-actions-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background-color: #f0f9ff;
  border: 1px solid #b3d8ff;
  border-radius: 4px;
  margin-bottom: 16px;
}

.bulk-info {
  color: #409EFF;
  font-weight: 500;
}

.bulk-buttons {
  display: flex;
  gap: 8px;
}

/* Table Content */
.product-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.product-name {
  font-weight: 500;
  color: #303133;
}

.product-category {
  font-size: 12px;
  color: #909399;
}

/* Stock Status Classes */
.stock-good { color: #67C23A; font-weight: 600; }
.stock-low { color: #E6A23C; font-weight: 600; }
.stock-out { color: #F56C6C; font-weight: 600; }
.stock-over { color: #409EFF; font-weight: 600; }

/* Pagination */
.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .summary-section .el-col {
    margin-bottom: 12px;
  }
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }

  .header-actions {
    justify-content: flex-start;
  }

  .filters .el-col {
    margin-bottom: 12px;
  }

  .summary-content {
    gap: 12px;
  }

  .summary-icon {
    width: 48px;
    height: 48px;
  }

  .summary-value {
    font-size: 20px;
  }
}
</style>

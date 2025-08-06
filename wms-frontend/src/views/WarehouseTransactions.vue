<template>
  <div class="warehouse-transactions">
    <!-- Page Header -->
    <div class="page-header">
      <div class="header-left">
        <h1 class="page-title">Quản lý phiếu kho</h1>
        <p class="page-description">Theo dõi và quản lý tất cả các giao dịch nhập/xuất kho</p>
      </div>
      <div class="header-actions">
        <el-button type="success" @click="createInboundTransaction">
          <el-icon><Download /></el-icon>
          Tạo phiếu nhập
        </el-button>
        <el-button type="warning" @click="createOutboundTransaction">
          <el-icon><Upload /></el-icon>
          Tạo phiếu xuất
        </el-button>
        <el-button type="primary" @click="createTransferTransaction">
          <el-icon><Switch /></el-icon>
          Tạo phiếu chuyển
        </el-button>
      </div>
    </div>

    <!-- Transaction Stats -->
    <el-row :gutter="20" class="stats-section">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-green">
              <el-icon size="28"><Download /></el-icon>
            </div>
            <div class="stat-details">
              <div class="stat-value">{{ stats.todayInbound }}</div>
              <div class="stat-label">Phiếu nhập hôm nay</div>
              <div class="stat-sublabel">Tổng: {{ stats.totalInboundValue }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-orange">
              <el-icon size="28"><Upload /></el-icon>
            </div>
            <div class="stat-details">
              <div class="stat-value">{{ stats.todayOutbound }}</div>
              <div class="stat-label">Phiếu xuất hôm nay</div>
              <div class="stat-sublabel">Tổng: {{ stats.totalOutboundValue }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-blue">
              <el-icon size="28"><Switch /></el-icon>
            </div>
            <div class="stat-details">
              <div class="stat-value">{{ stats.todayTransfer }}</div>
              <div class="stat-label">Phiếu chuyển hôm nay</div>
              <div class="stat-sublabel">Giữa các kho</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-purple">
              <el-icon size="28"><Clock /></el-icon>
            </div>
            <div class="stat-details">
              <div class="stat-value">{{ stats.pendingApproval }}</div>
              <div class="stat-label">Chờ phê duyệt</div>
              <div class="stat-sublabel">Cần xử lý</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Filters -->
    <el-card shadow="never" class="filter-card">
      <div class="filters">
        <el-row :gutter="20">
          <el-col :span="3">
            <el-select v-model="filters.transactionType" placeholder="Loại phiếu" clearable>
              <el-option label="Phiếu nhập" value="inbound" />
              <el-option label="Phiếu xuất" value="outbound" />
              <el-option label="Phiếu chuyển" value="transfer" />
              <el-option label="Điều chỉnh" value="adjustment" />
              <el-option label="Kiểm kê" value="cycle_count" />
            </el-select>
          </el-col>
          <el-col :span="3">
            <el-select v-model="filters.status" placeholder="Trạng thái" clearable>
              <el-option label="Nháp" value="draft" />
              <el-option label="Đã xác nhận" value="confirmed" />
              <el-option label="Đang xử lý" value="in_progress" />
              <el-option label="Hoàn thành" value="completed" />
              <el-option label="Đã hủy" value="cancelled" />
            </el-select>
          </el-col>
          <el-col :span="3">
            <el-select v-model="filters.warehouse" placeholder="Kho" clearable>
              <el-option
                v-for="warehouse in warehouses"
                :key="warehouse.id"
                :label="warehouse.name"
                :value="warehouse.id"
              />
            </el-select>
          </el-col>
          <el-col :span="4">
            <el-date-picker
              v-model="filters.dateRange"
              type="daterange"
              range-separator="đến"
              start-placeholder="Từ ngày"
              end-placeholder="Đến ngày"
              format="DD/MM/YYYY"
            />
          </el-col>
          <el-col :span="5">
            <el-input
              v-model="filters.search"
              placeholder="Tìm mã phiếu, tham chiếu..."
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
            <el-button @click="exportTransactions">
              <el-icon><Download /></el-icon>
              Xuất Excel
            </el-button>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- Transactions Table -->
    <el-card shadow="never" class="table-card">
      <template #header>
        <div class="table-header">
          <span class="table-title">Danh sách phiếu kho</span>
          <div class="table-actions">
            <el-button size="small" @click="refreshData">
              <el-icon><Refresh /></el-icon>
              Làm mới
            </el-button>
          </div>
        </div>
      </template>

      <el-table
        :data="transactionData"
        v-loading="loading"
        style="width: 100%"
        height="600"
        @row-click="viewTransactionDetail"
      >
        <el-table-column prop="transactionCode" label="Mã phiếu" width="140" fixed>
          <template #default="{ row }">
            <el-button type="text" @click="viewTransactionDetail(row)">
              {{ row.transactionCode }}
            </el-button>
          </template>
        </el-table-column>

        <el-table-column prop="transactionType" label="Loại phiếu" width="120">
          <template #default="{ row }">
            <el-tag :type="getTransactionTypeTagType(row.transactionType)" size="small">
              {{ getTransactionTypeText(row.transactionType) }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="warehouseName" label="Kho" width="150" />

        <el-table-column prop="partnerName" label="Đối tác" width="180">
          <template #default="{ row }">
            <div v-if="row.partnerName" class="partner-info">
              <div class="partner-name">{{ row.partnerName }}</div>
              <div class="partner-type">{{ getPartnerTypeText(row.partnerType) }}</div>
            </div>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>

        <el-table-column prop="referenceCode" label="Tham chiếu" width="130">
          <template #default="{ row }">
            <span v-if="row.referenceCode" class="reference-code">
              {{ row.referenceCode }}
            </span>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>

        <el-table-column prop="transactionDate" label="Ngày tạo" width="120">
          <template #default="{ row }">
            {{ formatDate(row.transactionDate) }}
          </template>
        </el-table-column>

        <el-table-column prop="status" label="Trạng thái" width="120">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="totalItems" label="Số mặt hàng" width="100" align="center" />

        <el-table-column prop="totalValue" label="Tổng giá trị" width="150" align="right">
          <template #default="{ row }">
            <span v-if="row.totalValue" class="total-value">
              {{ formatCurrency(row.totalValue) }}
            </span>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>

        <el-table-column prop="createdBy" label="Người tạo" width="120" />

        <el-table-column prop="processedBy" label="Người xử lý" width="120">
          <template #default="{ row }">
            <span v-if="row.processedBy">{{ row.processedBy }}</span>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>

        <el-table-column label="Thao tác" width="200" fixed="right">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button size="small" type="primary" @click="viewTransactionDetail(row)">
                Xem
              </el-button>

              <el-button
                v-if="canEdit(row)"
                size="small"
                type="warning"
                @click="editTransaction(row)"
              >
                Sửa
              </el-button>

              <el-dropdown v-if="hasMoreActions(row)">
                <el-button size="small">
                  Khác <el-icon><ArrowDown /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item
                      v-if="canConfirm(row)"
                      @click="confirmTransaction(row)"
                    >
                      Xác nhận
                    </el-dropdown-item>
                    <el-dropdown-item
                      v-if="canProcess(row)"
                      @click="processTransaction(row)"
                    >
                      Xử lý
                    </el-dropdown-item>
                    <el-dropdown-item
                      v-if="canComplete(row)"
                      @click="completeTransaction(row)"
                    >
                      Hoàn thành
                    </el-dropdown-item>
                    <el-dropdown-item
                      v-if="canCancel(row)"
                      divided
                      @click="cancelTransaction(row)"
                    >
                      Hủy phiếu
                    </el-dropdown-item>
                    <el-dropdown-item @click="printTransaction(row)">
                      In phiếu
                    </el-dropdown-item>
                    <el-dropdown-item @click="duplicateTransaction(row)">
                      Sao chép
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
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

    <!-- Transaction Detail Dialog -->
    <el-dialog
      v-model="detailDialog.visible"
      :title="`Chi tiết phiếu: ${detailDialog.transaction?.transactionCode}`"
      width="80%"
      top="5vh"
    >
      <div v-if="detailDialog.transaction" class="transaction-detail">
        <!-- Transaction Header Info -->
        <el-card shadow="never" class="detail-header">
          <el-row :gutter="20">
            <el-col :span="8">
              <div class="detail-group">
                <label>Mã phiếu:</label>
                <span class="detail-value">{{ detailDialog.transaction.transactionCode }}</span>
              </div>
              <div class="detail-group">
                <label>Loại phiếu:</label>
                <el-tag :type="getTransactionTypeTagType(detailDialog.transaction.transactionType)">
                  {{ getTransactionTypeText(detailDialog.transaction.transactionType) }}
                </el-tag>
              </div>
              <div class="detail-group">
                <label>Kho:</label>
                <span class="detail-value">{{ detailDialog.transaction.warehouseName }}</span>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="detail-group">
                <label>Ngày tạo:</label>
                <span class="detail-value">{{ formatDateTime(detailDialog.transaction.transactionDate) }}</span>
              </div>
              <div class="detail-group">
                <label>Trạng thái:</label>
                <el-tag :type="getStatusTagType(detailDialog.transaction.status)">
                  {{ getStatusText(detailDialog.transaction.status) }}
                </el-tag>
              </div>
              <div class="detail-group">
                <label>Người tạo:</label>
                <span class="detail-value">{{ detailDialog.transaction.createdBy }}</span>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="detail-group" v-if="detailDialog.transaction.partnerName">
                <label>Đối tác:</label>
                <span class="detail-value">{{ detailDialog.transaction.partnerName }}</span>
              </div>
              <div class="detail-group" v-if="detailDialog.transaction.referenceCode">
                <label>Tham chiếu:</label>
                <span class="detail-value">{{ detailDialog.transaction.referenceCode }}</span>
              </div>
              <div class="detail-group" v-if="detailDialog.transaction.notes">
                <label>Ghi chú:</label>
                <span class="detail-value">{{ detailDialog.transaction.notes }}</span>
              </div>
            </el-col>
          </el-row>
        </el-card>

        <!-- Transaction Items -->
        <el-card shadow="never" class="detail-items">
          <template #header>
            <span class="detail-section-title">Chi tiết sản phẩm</span>
          </template>

          <el-table :data="detailDialog.transaction.items" style="width: 100%">
            <el-table-column prop="productSku" label="SKU" width="120" />
            <el-table-column prop="productName" label="Tên sản phẩm" min-width="200" />
            <el-table-column prop="batchNumber" label="Số lô" width="120" />
            <el-table-column prop="location" label="Vị trí" width="120" />
            <el-table-column prop="plannedQuantity" label="SL Kế hoạch" width="120" align="right" />
            <el-table-column prop="actualQuantity" label="SL Thực tế" width="120" align="right" />
            <el-table-column prop="unit" label="Đơn vị" width="80" />
            <el-table-column prop="unitCost" label="Đơn giá" width="120" align="right">
              <template #default="{ row }">
                {{ formatCurrency(row.unitCost) }}
              </template>
            </el-table-column>
            <el-table-column prop="totalCost" label="Thành tiền" width="150" align="right">
              <template #default="{ row }">
                {{ formatCurrency(row.totalCost) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="detailDialog.visible = false">Đóng</el-button>
          <el-button type="primary" @click="printTransaction(detailDialog.transaction)">
            In phiếu
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import {
  Download, Upload, Switch, Clock, Search, Refresh, ArrowDown
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// Reactive data
const loading = ref(false)

const filters = reactive({
  transactionType: '',
  status: '',
  warehouse: null,
  dateRange: null,
  search: ''
})

const pagination = reactive({
  currentPage: 1,
  pageSize: 50,
  total: 0
})

const detailDialog = reactive({
  visible: false,
  transaction: null
})

const stats = reactive({
  todayInbound: 15,
  totalInboundValue: '2.5 tỷ VND',
  todayOutbound: 23,
  totalOutboundValue: '1.8 tỷ VND',
  todayTransfer: 8,
  pendingApproval: 12
})

// Sample data
const warehouses = ref([
  { id: 1, name: 'Kho Hà Nội - Cầu Giấy', code: 'WH-HN01' },
  { id: 2, name: 'Kho TP.HCM - Quận 7', code: 'WH-HCM01' },
  { id: 3, name: 'Kho Đà Nẵng - Hải Châu', code: 'WH-DN01' }
])

const transactionData = ref([
  {
    id: 1,
    transactionCode: 'WI2412150001',
    transactionType: 'inbound',
    warehouseName: 'Kho Hà Nội - Cầu Giấy',
    partnerType: 'supplier',
    partnerName: 'Công ty ABC Corp',
    referenceCode: 'PO-2024001234',
    transactionDate: new Date('2024-12-15T08:30:00'),
    status: 'completed',
    totalItems: 15,
    totalValue: 125000000,
    createdBy: 'Nguyễn Văn A',
    processedBy: 'Trần Thị B',
    notes: 'Nhập hàng theo đơn đặt hàng PO-2024001234',
    items: [
      {
        productSku: 'PRD-001234',
        productName: 'Sữa tươi Vinamilk 1L',
        batchNumber: 'BT20241215001',
        location: 'A-01-02',
        plannedQuantity: 500,
        actualQuantity: 500,
        unit: 'hộp',
        unitCost: 28000,
        totalCost: 14000000
      },
      {
        productSku: 'PRD-005678',
        productName: 'Bánh mì sandwich 500g',
        batchNumber: 'BT20241215002',
        location: 'B-02-03',
        plannedQuantity: 200,
        actualQuantity: 195,
        unit: 'gói',
        unitCost: 45000,
        totalCost: 8775000
      }
    ]
  },
  {
    id: 2,
    transactionCode: 'WO2412150002',
    transactionType: 'outbound',
    warehouseName: 'Kho TP.HCM - Quận 7',
    partnerType: 'customer',
    partnerName: 'Siêu thị Big C',
    referenceCode: 'SO-2024005678',
    transactionDate: new Date('2024-12-15T10:15:00'),
    status: 'in_progress',
    totalItems: 8,
    totalValue: 85000000,
    createdBy: 'Lê Văn C',
    processedBy: 'Phạm Thị D',
    notes: 'Xuất hàng theo đơn bán SO-2024005678'
  },
  {
    id: 3,
    transactionCode: 'TF2412150003',
    transactionType: 'transfer',
    warehouseName: 'Kho Hà Nội → Đà Nẵng',
    partnerType: 'warehouse',
    partnerName: 'Kho Đà Nẵng - Hải Châu',
    referenceCode: 'TRF-2024000123',
    transactionDate: new Date('2024-12-15T14:20:00'),
    status: 'confirmed',
    totalItems: 12,
    totalValue: 65000000,
    createdBy: 'Hoàng Văn E',
    processedBy: null,
    notes: 'Chuyển hàng bổ sung cho kho Đà Nẵng'
  },
  {
    id: 4,
    transactionCode: 'ADJ2412150004',
    transactionType: 'adjustment',
    warehouseName: 'Kho Hà Nội - Cầu Giấy',
    partnerType: null,
    partnerName: null,
    referenceCode: 'CC-2024000045',
    transactionDate: new Date('2024-12-15T16:45:00'),
    status: 'draft',
    totalItems: 3,
    totalValue: -2500000,
    createdBy: 'Ngô Thị F',
    processedBy: null,
    notes: 'Điều chỉnh sau kiểm kê chu kỳ'
  }
])

// Methods
const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(value)
}

const formatDate = (date: Date) => {
  return date.toLocaleDateString('vi-VN')
}

const formatDateTime = (date: Date) => {
  return date.toLocaleString('vi-VN')
}

const getTransactionTypeTagType = (type: string) => {
  const typeMap: Record<string, string> = {
    inbound: 'success',
    outbound: 'warning',
    transfer: 'info',
    adjustment: 'danger',
    cycle_count: ''
  }
  return typeMap[type] || ''
}

const getTransactionTypeText = (type: string) => {
  const typeMap: Record<string, string> = {
    inbound: 'Nhập kho',
    outbound: 'Xuất kho',
    transfer: 'Chuyển kho',
    adjustment: 'Điều chỉnh',
    cycle_count: 'Kiểm kê'
  }
  return typeMap[type] || type
}

const getStatusTagType = (status: string) => {
  const statusMap: Record<string, string> = {
    draft: 'info',
    confirmed: 'warning',
    in_progress: 'primary',
    completed: 'success',
    cancelled: 'danger'
  }
  return statusMap[status] || ''
}

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    draft: 'Nháp',
    confirmed: 'Đã xác nhận',
    in_progress: 'Đang xử lý',
    completed: 'Hoàn thành',
    cancelled: 'Đã hủy'
  }
  return statusMap[status] || status
}

const getPartnerTypeText = (type: string) => {
  const typeMap: Record<string, string> = {
    supplier: 'Nhà cung cấp',
    customer: 'Khách hàng',
    warehouse: 'Kho'
  }
  return typeMap[type] || type
}

// Action methods
const canEdit = (row: any) => {
  return row.status === 'draft'
}

const canConfirm = (row: any) => {
  return row.status === 'draft'
}

const canProcess = (row: any) => {
  return row.status === 'confirmed'
}

const canComplete = (row: any) => {
  return row.status === 'in_progress'
}

const canCancel = (row: any) => {
  return ['draft', 'confirmed'].includes(row.status)
}

const hasMoreActions = (row: any) => {
  return canConfirm(row) || canProcess(row) || canComplete(row) || canCancel(row)
}

const createInboundTransaction = () => {
  ElMessage.info('Chuyển đến trang tạo phiếu nhập')
}

const createOutboundTransaction = () => {
  ElMessage.info('Chuyển đến trang tạo phiếu xuất')
}

const createTransferTransaction = () => {
  ElMessage.info('Chuyển đến trang tạo phiếu chuyển')
}

const viewTransactionDetail = (row: any) => {
  detailDialog.transaction = row
  detailDialog.visible = true
}

const editTransaction = (row: any) => {
  ElMessage.info(`Chỉnh sửa phiếu: ${row.transactionCode}`)
}

const confirmTransaction = (row: any) => {
  ElMessageBox.confirm(
    `Bạn có chắc chắn muốn xác nhận phiếu ${row.transactionCode}?`,
    'Xác nhận phiếu',
    {
      confirmButtonText: 'Xác nhận',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    row.status = 'confirmed'
    ElMessage.success('Phiếu đã được xác nhận')
  })
}

const processTransaction = (row: any) => {
  ElMessage.info(`Bắt đầu xử lý phiếu: ${row.transactionCode}`)
  row.status = 'in_progress'
}

const completeTransaction = (row: any) => {
  ElMessageBox.confirm(
    `Bạn có chắc chắn muốn hoàn thành phiếu ${row.transactionCode}?`,
    'Hoàn thành phiếu',
    {
      confirmButtonText: 'Hoàn thành',
      cancelButtonText: 'Hủy',
      type: 'success'
    }
  ).then(() => {
    row.status = 'completed'
    ElMessage.success('Phiếu đã được hoàn thành')
  })
}

const cancelTransaction = (row: any) => {
  ElMessageBox.confirm(
    `Bạn có chắc chắn muốn hủy phiếu ${row.transactionCode}?`,
    'Hủy phiếu',
    {
      confirmButtonText: 'Hủy phiếu',
      cancelButtonText: 'Không',
      type: 'error'
    }
  ).then(() => {
    row.status = 'cancelled'
    ElMessage.success('Phiếu đã được hủy')
  })
}

const printTransaction = (row: any) => {
  ElMessage.info(`In phiếu: ${row.transactionCode}`)
}

const duplicateTransaction = (row: any) => {
  ElMessage.info(`Sao chép phiếu: ${row.transactionCode}`)
}

const refreshData = () => {
  loading.value = true
  setTimeout(() => {
    loading.value = false
    ElMessage.success('Dữ liệu đã được làm mới')
  }, 1000)
}

const applyFilters = () => {
  ElMessage.info('Áp dụng bộ lọc')
}

const resetFilters = () => {
  Object.assign(filters, {
    transactionType: '',
    status: '',
    warehouse: null,
    dateRange: null,
    search: ''
  })
}

const exportTransactions = () => {
  ElMessage.success('Đang xuất dữ liệu Excel...')
}

const handleSizeChange = (size: number) => {
  pagination.pageSize = size
}

const handleCurrentChange = (page: number) => {
  pagination.currentPage = page
}

onMounted(() => {
  pagination.total = transactionData.value.length
})
</script>

<style scoped>
.warehouse-transactions {
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

/* Stats Section */
.stats-section {
  margin-bottom: 20px;
}

.stat-card {
  border: none;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.bg-green { background: linear-gradient(135deg, #67C23A 0%, #529b2e 100%); }
.bg-orange { background: linear-gradient(135deg, #E6A23C 0%, #b88230 100%); }
.bg-blue { background: linear-gradient(135deg, #409EFF 0%, #337ecc 100%); }
.bg-purple { background: linear-gradient(135deg, #9C27B0 0%, #7B1FA2 100%); }

.stat-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}

.stat-label {
  color: #606266;
  font-size: 14px;
  font-weight: 500;
}

.stat-sublabel {
  color: #909399;
  font-size: 12px;
}

/* Filter Section */
.filter-card {
  margin-bottom: 20px;
}

.filters {
  padding: 4px 0;
}

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

/* Table Content */
.partner-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.partner-name {
  font-weight: 500;
  color: #303133;
}

.partner-type {
  font-size: 12px;
  color: #909399;
}

.reference-code {
  color: #409EFF;
  font-weight: 500;
}

.total-value {
  font-weight: 600;
  color: #303133;
}

.text-muted {
  color: #C0C4CC;
}

.action-buttons {
  display: flex;
  gap: 4px;
}

/* Pagination */
.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

/* Detail Dialog */
.transaction-detail {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-header {
  background-color: #fafafa;
}

.detail-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 16px;
}

.detail-group label {
  font-size: 12px;
  color: #909399;
  font-weight: 500;
}

.detail-value {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
}

.detail-section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .stats-section .el-col {
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
    flex-direction: column;
    gap: 8px;
  }

  .filters .el-col {
    margin-bottom: 12px;
  }

  .stat-content {
    gap: 12px;
  }

  .stat-icon {
    width: 48px;
    height: 48px;
  }

  .stat-value {
    font-size: 20px;
  }
}
</style>

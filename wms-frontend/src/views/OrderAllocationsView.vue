<template>
  <div class="order-allocations-container">
    <!-- Header -->
    <div class="page-header">
      <div class="header-left">
        <h1>Phân bổ đơn hàng</h1>
        <p class="subtitle">Quản lý việc phân bổ sản phẩm cho đơn hàng và tối ưu hóa kho</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="showAllocationDialog = true">
          <el-icon><Plus /></el-icon>
          Tạo phân bổ mới
        </el-button>
        <el-button @click="autoAllocate">
          <el-icon><MagicStick /></el-icon>
          Tự động phân bổ
        </el-button>
      </div>
    </div>

    <!-- Statistics Cards -->
    <div class="stats-cards">
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon pending">
            <el-icon><Clock /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.pending }}</h3>
            <p>Chờ phân bổ</p>
          </div>
        </div>
      </el-card>
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon partial">
            <el-icon><Loading /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.partial }}</h3>
            <p>Phân bổ một phần</p>
          </div>
        </div>
      </el-card>
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon completed">
            <el-icon><Check /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.completed }}</h3>
            <p>Đã phân bổ hoàn toàn</p>
          </div>
        </div>
      </el-card>
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon shortage">
            <el-icon><Warning /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.shortage }}</h3>
            <p>Thiếu hàng</p>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Allocations Table -->
    <el-card class="table-card">
      <template #header>
        <div class="table-header">
          <span>Danh sách phân bổ ({{ allocations.length }})</span>
        </div>
      </template>

      <el-table :data="allocations" style="width: 100%">
        <el-table-column prop="orderNumber" label="Mã đơn hàng" width="150" />
        <el-table-column prop="orderType" label="Loại đơn hàng" width="120">
          <template #default="{ row }">
            <el-tag :type="row.orderType === 'sales' ? 'success' : 'warning'" size="small">
              {{ row.orderType === 'sales' ? 'Bán' : 'Mua' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="customerName" label="Khách hàng/NCC" width="200" />
        <el-table-column prop="productName" label="Sản phẩm" width="200" />
        <el-table-column prop="requestedQty" label="Số lượng yêu cầu" width="150" />
        <el-table-column prop="allocatedQty" label="Số lượng phân bổ" width="150" />
        <el-table-column prop="availableQty" label="Tồn kho khả dụng" width="150" />
        <el-table-column prop="allocationRate" label="Tỷ lệ phân bổ" width="120">
          <template #default="{ row }">
            <el-progress
              :percentage="row.allocationRate"
              :color="getProgressColor(row.allocationRate)"
              :stroke-width="8"
            />
          </template>
        </el-table-column>
        <el-table-column prop="status" label="Trạng thái" width="120">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ getStatusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="Thao tác" width="200" fixed="right">
          <template #default="{ row }">
            <el-button-group>
              <el-button size="small" @click="viewAllocationDetails(row)">
                <el-icon><View /></el-icon>
              </el-button>
              <el-button size="small" type="success" @click="allocateItem(row)">
                <el-icon><Check /></el-icon>
              </el-button>
              <el-button size="small" type="warning" @click="releaseAllocation(row)">
                <el-icon><RefreshLeft /></el-icon>
              </el-button>
            </el-button-group>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Create Allocation Dialog -->
    <el-dialog
      v-model="showAllocationDialog"
      title="Tạo phân bổ mới"
      width="60%"
    >
      <el-form ref="allocationForm" :model="newAllocation" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Đơn hàng" prop="orderId">
              <el-select v-model="newAllocation.orderId" placeholder="Chọn đơn hàng" style="width: 100%">
                <el-option
                  v-for="order in availableOrders"
                  :key="order.id"
                  :label="`${order.orderNumber} - ${order.customerName}`"
                  :value="order.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Sản phẩm" prop="productId">
              <el-select v-model="newAllocation.productId" placeholder="Chọn sản phẩm" style="width: 100%">
                <el-option
                  v-for="product in products"
                  :key="product.id"
                  :label="product.name"
                  :value="product.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Số lượng yêu cầu" prop="requestedQty">
              <el-input-number v-model="newAllocation.requestedQty" :min="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Độ ưu tiên" prop="priority">
              <el-select v-model="newAllocation.priority" placeholder="Chọn độ ưu tiên" style="width: 100%">
                <el-option label="Cao" value="high" />
                <el-option label="Trung bình" value="medium" />
                <el-option label="Thấp" value="low" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAllocationDialog = false">Hủy</el-button>
          <el-button type="primary" @click="createAllocation">Tạo phân bổ</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  Plus,
  Clock,
  Loading,
  Check,
  Warning,
  View,
  RefreshLeft,
  MagicStick
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// Reactive data
const showAllocationDialog = ref(false)

const stats = ref({
  pending: 0,
  partial: 0,
  completed: 0,
  shortage: 0
})

const newAllocation = ref({
  orderId: '',
  productId: '',
  requestedQty: 1,
  priority: 'medium'
})

// Sample data
const allocations = ref([
  {
    id: 1,
    orderNumber: 'SO-2024-001',
    orderType: 'sales',
    customerName: 'Công ty ABC',
    productName: 'Laptop Dell XPS 13',
    requestedQty: 5,
    allocatedQty: 5,
    availableQty: 10,
    allocationRate: 100,
    status: 'completed',
    priority: 'high'
  },
  {
    id: 2,
    orderNumber: 'SO-2024-002',
    orderType: 'sales',
    customerName: 'Công ty XYZ',
    productName: 'Màn hình LG 27"',
    requestedQty: 3,
    allocatedQty: 2,
    availableQty: 2,
    allocationRate: 67,
    status: 'partial',
    priority: 'medium'
  },
  {
    id: 3,
    orderNumber: 'PO-2024-001',
    orderType: 'purchase',
    customerName: 'Công ty TNHH ABC',
    productName: 'Chuột không dây Logitech',
    requestedQty: 50,
    allocatedQty: 0,
    availableQty: 0,
    allocationRate: 0,
    status: 'shortage',
    priority: 'low'
  }
])

const availableOrders = ref([
  { id: 1, orderNumber: 'SO-2024-001', customerName: 'Công ty ABC' },
  { id: 2, orderNumber: 'SO-2024-002', customerName: 'Công ty XYZ' },
  { id: 3, orderNumber: 'PO-2024-001', customerName: 'Công ty TNHH ABC' }
])

const products = ref([
  { id: 1, name: 'Laptop Dell XPS 13' },
  { id: 2, name: 'Chuột không dây Logitech' },
  { id: 3, name: 'Màn hình LG 27"' },
  { id: 4, name: 'Bàn phím cơ' },
  { id: 5, name: 'Máy in HP LaserJet' }
])

// Methods
const updateStats = () => {
  stats.value.pending = allocations.value.filter(allocation => allocation.status === 'pending').length
  stats.value.partial = allocations.value.filter(allocation => allocation.status === 'partial').length
  stats.value.completed = allocations.value.filter(allocation => allocation.status === 'completed').length
  stats.value.shortage = allocations.value.filter(allocation => allocation.status === 'shortage').length
}

const getStatusType = (status: string) => {
  const types: Record<string, string> = {
    pending: 'warning',
    partial: 'primary',
    completed: 'success',
    shortage: 'danger'
  }
  return types[status] || 'info'
}

const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    pending: 'Chờ phân bổ',
    partial: 'Phân bổ một phần',
    completed: 'Đã phân bổ hoàn toàn',
    shortage: 'Thiếu hàng'
  }
  return labels[status] || status
}

const getProgressColor = (percentage: number) => {
  if (percentage >= 100) return '#67c23a'
  if (percentage >= 50) return '#e6a23c'
  return '#f56c6c'
}

const viewAllocationDetails = (allocation: any) => {
  ElMessage.info('Chi tiết phân bổ: ' + allocation.orderNumber)
}

const allocateItem = (allocation: any) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn phân bổ sản phẩm này?',
    'Xác nhận',
    {
      confirmButtonText: 'Phân bổ',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    if (allocation.availableQty >= allocation.requestedQty - allocation.allocatedQty) {
      allocation.allocatedQty = allocation.requestedQty
      allocation.allocationRate = 100
      allocation.status = 'completed'
    } else {
      allocation.allocatedQty += allocation.availableQty
      allocation.allocationRate = Math.round((allocation.allocatedQty / allocation.requestedQty) * 100)
      allocation.status = 'partial'
    }
    updateStats()
    ElMessage.success('Đã phân bổ sản phẩm thành công')
  })
}

const releaseAllocation = (allocation: any) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn giải phóng phân bổ này?',
    'Xác nhận',
    {
      confirmButtonText: 'Giải phóng',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    allocation.allocatedQty = 0
    allocation.allocationRate = 0
    allocation.status = 'pending'
    updateStats()
    ElMessage.success('Đã giải phóng phân bổ thành công')
  })
}

const autoAllocate = () => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn tự động phân bổ tất cả đơn hàng?',
    'Xác nhận',
    {
      confirmButtonText: 'Tự động phân bổ',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    allocations.value.forEach(allocation => {
      if (allocation.status === 'pending' && allocation.availableQty > 0) {
        const canAllocate = Math.min(allocation.requestedQty, allocation.availableQty)
        allocation.allocatedQty = canAllocate
        allocation.allocationRate = Math.round((canAllocate / allocation.requestedQty) * 100)
        allocation.status = canAllocate === allocation.requestedQty ? 'completed' : 'partial'
      }
    })
    updateStats()
    ElMessage.success('Đã tự động phân bổ thành công')
  })
}

const createAllocation = () => {
  if (!newAllocation.value.orderId || !newAllocation.value.productId) {
    ElMessage.error('Vui lòng chọn đơn hàng và sản phẩm')
    return
  }

  const order = availableOrders.value.find(o => o.id === Number(newAllocation.value.orderId))
  const product = products.value.find(p => p.id === Number(newAllocation.value.productId))

  if (!order || !product) {
    ElMessage.error('Không tìm thấy đơn hàng hoặc sản phẩm')
    return
  }

  const allocation = {
    id: allocations.value.length + 1,
    orderNumber: order.orderNumber,
    orderType: 'sales',
    customerName: order.customerName,
    productName: product.name,
    requestedQty: newAllocation.value.requestedQty,
    allocatedQty: 0,
    availableQty: Math.floor(Math.random() * 20) + 1,
    allocationRate: 0,
    status: 'pending',
    priority: newAllocation.value.priority
  }

  allocations.value.unshift(allocation)
  updateStats()
  showAllocationDialog.value = false
  newAllocation.value = {
    orderId: '',
    productId: '',
    requestedQty: 1,
    priority: 'medium'
  }
  ElMessage.success('Đã tạo phân bổ thành công')
}

// Lifecycle
onMounted(() => {
  updateStats()
})
</script>

<style scoped>
.order-allocations-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-left h1 {
  margin: 0;
  color: #303133;
  font-size: 24px;
  font-weight: 600;
}

.subtitle {
  margin: 5px 0 0 0;
  color: #909399;
  font-size: 14px;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 15px;
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.stat-icon.pending {
  background: linear-gradient(135deg, #ff9500, #ff6b35);
}

.stat-icon.partial {
  background: linear-gradient(135deg, #007aff, #5856d6);
}

.stat-icon.completed {
  background: linear-gradient(135deg, #34c759, #30d158);
}

.stat-icon.shortage {
  background: linear-gradient(135deg, #ff3b30, #ff453a);
}

.stat-info h3 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #303133;
}

.stat-info p {
  margin: 5px 0 0 0;
  color: #909399;
  font-size: 14px;
}

.table-card {
  margin-bottom: 20px;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>

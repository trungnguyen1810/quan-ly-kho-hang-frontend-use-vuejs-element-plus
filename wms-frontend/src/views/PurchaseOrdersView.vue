<template>
  <div class="purchase-orders-container">
    <!-- Header -->
    <div class="page-header">
      <div class="header-left">
        <h1>Quản lý đơn hàng mua</h1>
        <p class="subtitle">Quản lý toàn bộ workflow từ đơn hàng mua đến nhận hàng</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="showCreateOrderDialog = true">
          <el-icon><Plus /></el-icon>
          Tạo đơn hàng mua
        </el-button>
        <el-button @click="exportOrders">
          <el-icon><Download /></el-icon>
          Xuất báo cáo
        </el-button>
      </div>
    </div>

    <!-- Statistics Cards -->
    <div class="stats-cards">
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon draft">
            <el-icon><Document /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.draft }}</h3>
            <p>Đơn hàng nháp</p>
          </div>
        </div>
      </el-card>
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon submitted">
            <el-icon><Upload /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.submitted }}</h3>
            <p>Đã gửi nhà cung cấp</p>
          </div>
        </div>
      </el-card>
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon confirmed">
            <el-icon><Check /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.confirmed }}</h3>
            <p>Đã xác nhận</p>
          </div>
        </div>
      </el-card>
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon received">
            <el-icon><Box /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.received }}</h3>
            <p>Đã nhận hàng</p>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Filters and Search -->
    <el-card class="filter-card">
      <div class="filter-row">
        <div class="filter-group">
          <el-select v-model="filters.status" placeholder="Trạng thái" clearable>
            <el-option label="Tất cả" value="" />
            <el-option label="Nháp" value="draft" />
            <el-option label="Đã gửi" value="submitted" />
            <el-option label="Đã xác nhận" value="confirmed" />
            <el-option label="Đã nhận hàng" value="received" />
            <el-option label="Đã hủy" value="cancelled" />
          </el-select>
          <el-select v-model="filters.supplier" placeholder="Nhà cung cấp" clearable>
            <el-option label="Tất cả" value="" />
            <el-option
              v-for="supplier in suppliers"
              :key="supplier.id"
              :label="supplier.name"
              :value="supplier.id"
            />
          </el-select>
          <el-date-picker
            v-model="filters.dateRange"
            type="daterange"
            range-separator="đến"
            start-placeholder="Từ ngày"
            end-placeholder="Đến ngày"
            format="DD/MM/YYYY"
            value-format="YYYY-MM-DD"
          />
        </div>
        <div class="search-group">
          <el-input
            v-model="filters.search"
            placeholder="Tìm kiếm theo mã đơn hàng, nhà cung cấp..."
            clearable
            style="width: 300px"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
      </div>
    </el-card>

    <!-- Orders Table -->
    <el-card class="table-card">
      <template #header>
        <div class="table-header">
          <span>Danh sách đơn hàng mua ({{ filteredOrders.length }})</span>
          <div class="table-actions">
            <el-button-group>
              <el-button :type="viewMode === 'table' ? 'primary' : ''" @click="viewMode = 'table'">
                <el-icon><List /></el-icon>
              </el-button>
              <el-button :type="viewMode === 'kanban' ? 'primary' : ''" @click="viewMode = 'kanban'">
                <el-icon><Grid /></el-icon>
              </el-button>
            </el-button-group>
          </div>
        </div>
      </template>

      <!-- Table View -->
      <div v-if="viewMode === 'table'">
        <el-table :data="paginatedOrders" style="width: 100%" @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="55" />
          <el-table-column prop="orderNumber" label="Mã đơn hàng" width="150">
            <template #default="{ row }">
              <el-link type="primary" @click="viewOrderDetails(row)">{{ row.orderNumber }}</el-link>
            </template>
          </el-table-column>
          <el-table-column prop="supplierName" label="Nhà cung cấp" width="200" />
          <el-table-column prop="orderDate" label="Ngày đặt" width="120">
            <template #default="{ row }">
              {{ formatDate(row.orderDate) }}
            </template>
          </el-table-column>
          <el-table-column prop="expectedDate" label="Ngày nhận dự kiến" width="150">
            <template #default="{ row }">
              {{ formatDate(row.expectedDate) }}
            </template>
          </el-table-column>
          <el-table-column prop="totalAmount" label="Tổng tiền" width="150">
            <template #default="{ row }">
              {{ formatCurrency(row.totalAmount) }}
            </template>
          </el-table-column>
          <el-table-column prop="itemsCount" label="Số lượng SP" width="120" />
          <el-table-column prop="status" label="Trạng thái" width="120">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.status)" size="small">
                {{ getStatusLabel(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="priority" label="Ưu tiên" width="100">
            <template #default="{ row }">
              <el-tag :type="getPriorityType(row.priority)" size="small">
                {{ getPriorityLabel(row.priority) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="Thao tác" width="250" fixed="right">
            <template #default="{ row }">
              <el-button-group>
                <el-button size="small" @click="viewOrderDetails(row)">
                  <el-icon><View /></el-icon>
                </el-button>
                <el-button size="small" type="primary" @click="editOrder(row)">
                  <el-icon><Edit /></el-icon>
                </el-button>
                <el-button size="small" type="success" @click="submitOrder(row)">
                  <el-icon><Upload /></el-icon>
                </el-button>
                <el-button size="small" type="warning" @click="confirmOrder(row)">
                  <el-icon><Check /></el-icon>
                </el-button>
                <el-button size="small" type="info" @click="receiveOrder(row)">
                  <el-icon><Box /></el-icon>
                </el-button>
              </el-button-group>
            </template>
          </el-table-column>
        </el-table>

        <!-- Pagination -->
        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="filteredOrders.length"
            layout="total, sizes, prev, pager, next, jumper"
          />
        </div>
      </div>

      <!-- Kanban View -->
      <div v-else class="kanban-view">
        <div class="kanban-columns">
          <div class="kanban-column">
            <div class="column-header draft">
              <h3>Nháp ({{ getOrdersByStatus('draft').length }})</h3>
            </div>
            <div class="column-content">
              <div
                v-for="order in getOrdersByStatus('draft')"
                :key="order.id"
                class="kanban-card"
                @click="viewOrderDetails(order)"
              >
                <div class="card-header">
                  <span class="order-number">{{ order.orderNumber }}</span>
                  <el-tag :type="getPriorityType(order.priority)" size="small">
                    {{ getPriorityLabel(order.priority) }}
                  </el-tag>
                </div>
                <div class="card-body">
                  <p class="supplier-name">{{ order.supplierName }}</p>
                  <p class="order-info">{{ order.itemsCount }} sản phẩm</p>
                  <p class="order-amount">{{ formatCurrency(order.totalAmount) }}</p>
                </div>
                <div class="card-footer">
                  <span class="order-date">{{ formatDate(order.orderDate) }}</span>
                </div>
              </div>
            </div>
          </div>

          <div class="kanban-column">
            <div class="column-header submitted">
              <h3>Đã gửi ({{ getOrdersByStatus('submitted').length }})</h3>
            </div>
            <div class="column-content">
              <div
                v-for="order in getOrdersByStatus('submitted')"
                :key="order.id"
                class="kanban-card"
                @click="viewOrderDetails(order)"
              >
                <div class="card-header">
                  <span class="order-number">{{ order.orderNumber }}</span>
                  <el-tag :type="getPriorityType(order.priority)" size="small">
                    {{ getPriorityLabel(order.priority) }}
                  </el-tag>
                </div>
                <div class="card-body">
                  <p class="supplier-name">{{ order.supplierName }}</p>
                  <p class="order-info">{{ order.itemsCount }} sản phẩm</p>
                  <p class="order-amount">{{ formatCurrency(order.totalAmount) }}</p>
                </div>
                <div class="card-footer">
                  <span class="order-date">{{ formatDate(order.orderDate) }}</span>
                </div>
              </div>
            </div>
          </div>

          <div class="kanban-column">
            <div class="column-header confirmed">
              <h3>Đã xác nhận ({{ getOrdersByStatus('confirmed').length }})</h3>
            </div>
            <div class="column-content">
              <div
                v-for="order in getOrdersByStatus('confirmed')"
                :key="order.id"
                class="kanban-card"
                @click="viewOrderDetails(order)"
              >
                <div class="card-header">
                  <span class="order-number">{{ order.orderNumber }}</span>
                  <el-tag :type="getPriorityType(order.priority)" size="small">
                    {{ getPriorityLabel(order.priority) }}
                  </el-tag>
                </div>
                <div class="card-body">
                  <p class="supplier-name">{{ order.supplierName }}</p>
                  <p class="order-info">{{ order.itemsCount }} sản phẩm</p>
                  <p class="order-amount">{{ formatCurrency(order.totalAmount) }}</p>
                </div>
                <div class="card-footer">
                  <span class="order-date">{{ formatDate(order.orderDate) }}</span>
                </div>
              </div>
            </div>
          </div>

          <div class="kanban-column">
            <div class="column-header received">
              <h3>Đã nhận hàng ({{ getOrdersByStatus('received').length }})</h3>
            </div>
            <div class="column-content">
              <div
                v-for="order in getOrdersByStatus('received')"
                :key="order.id"
                class="kanban-card"
                @click="viewOrderDetails(order)"
              >
                <div class="card-header">
                  <span class="order-number">{{ order.orderNumber }}</span>
                  <el-tag :type="getPriorityType(order.priority)" size="small">
                    {{ getPriorityLabel(order.priority) }}
                  </el-tag>
                </div>
                <div class="card-body">
                  <p class="supplier-name">{{ order.supplierName }}</p>
                  <p class="order-info">{{ order.itemsCount }} sản phẩm</p>
                  <p class="order-amount">{{ formatCurrency(order.totalAmount) }}</p>
                </div>
                <div class="card-footer">
                  <span class="order-date">{{ formatDate(order.orderDate) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- Create Order Dialog -->
    <el-dialog
      v-model="showCreateOrderDialog"
      title="Tạo đơn hàng mua mới"
      width="80%"
      :before-close="handleCloseCreateDialog"
    >
      <el-form ref="createOrderForm" :model="newOrder" :rules="orderRules" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Nhà cung cấp" prop="supplierId">
              <el-select v-model="newOrder.supplierId" placeholder="Chọn nhà cung cấp" style="width: 100%">
                <el-option
                  v-for="supplier in suppliers"
                  :key="supplier.id"
                  :label="supplier.name"
                  :value="supplier.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Ngày nhận dự kiến" prop="expectedDate">
              <el-date-picker
                v-model="newOrder.expectedDate"
                type="date"
                placeholder="Chọn ngày nhận dự kiến"
                style="width: 100%"
                format="DD/MM/YYYY"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Độ ưu tiên" prop="priority">
              <el-select v-model="newOrder.priority" placeholder="Chọn độ ưu tiên" style="width: 100%">
                <el-option label="Cao" value="high" />
                <el-option label="Trung bình" value="medium" />
                <el-option label="Thấp" value="low" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Ghi chú">
              <el-input v-model="newOrder.notes" placeholder="Ghi chú đơn hàng" />
            </el-form-item>
          </el-col>
        </el-row>

        <!-- Order Items -->
        <el-form-item label="Sản phẩm">
          <div class="order-items">
            <div v-for="(item, index) in newOrder.items" :key="index" class="order-item">
              <el-row :gutter="10">
                <el-col :span="8">
                  <el-select v-model="item.productId" placeholder="Chọn sản phẩm" style="width: 100%">
                    <el-option
                      v-for="product in products"
                      :key="product.id"
                      :label="product.name"
                      :value="product.id"
                    />
                  </el-select>
                </el-col>
                <el-col :span="4">
                  <el-input-number v-model="item.quantity" :min="1" placeholder="SL" style="width: 100%" />
                </el-col>
                <el-col :span="4">
                  <el-input v-model="item.unitPrice" placeholder="Đơn giá" style="width: 100%" />
                </el-col>
                <el-col :span="4">
                  <el-input v-model="item.total" placeholder="Thành tiền" readonly style="width: 100%" />
                </el-col>
                <el-col :span="4">
                  <el-button type="danger" @click="removeOrderItem(index)">
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </el-col>
              </el-row>
            </div>
            <el-button type="primary" @click="addOrderItem">
              <el-icon><Plus /></el-icon>
              Thêm sản phẩm
            </el-button>
          </div>
        </el-form-item>

        <el-form-item label="Tổng tiền">
          <el-input v-model="newOrder.totalAmount" readonly style="width: 200px" />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showCreateOrderDialog = false">Hủy</el-button>
          <el-button type="primary" @click="createOrder">Tạo đơn hàng</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- Order Details Dialog -->
    <el-dialog
      v-model="showOrderDetailsDialog"
      title="Chi tiết đơn hàng mua"
      width="70%"
      :before-close="handleCloseDetailsDialog"
    >
      <div v-if="selectedOrder" class="order-details">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="Mã đơn hàng">{{ selectedOrder.orderNumber }}</el-descriptions-item>
          <el-descriptions-item label="Nhà cung cấp">{{ selectedOrder.supplierName }}</el-descriptions-item>
          <el-descriptions-item label="Ngày đặt hàng">{{ formatDate(selectedOrder.orderDate) }}</el-descriptions-item>
          <el-descriptions-item label="Ngày nhận dự kiến">{{ formatDate(selectedOrder.expectedDate) }}</el-descriptions-item>
          <el-descriptions-item label="Trạng thái">
            <el-tag :type="getStatusType(selectedOrder.status)">
              {{ getStatusLabel(selectedOrder.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="Độ ưu tiên">
            <el-tag :type="getPriorityType(selectedOrder.priority)">
              {{ getPriorityLabel(selectedOrder.priority) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="Tổng tiền">{{ formatCurrency(selectedOrder.totalAmount) }}</el-descriptions-item>
          <el-descriptions-item label="Số lượng sản phẩm">{{ selectedOrder.itemsCount }}</el-descriptions-item>
        </el-descriptions>

        <el-table :data="selectedOrder.items" style="width: 100%; margin-top: 20px">
          <el-table-column prop="productName" label="Sản phẩm" />
          <el-table-column prop="quantity" label="Số lượng" width="100" />
          <el-table-column prop="unitPrice" label="Đơn giá" width="120">
            <template #default="{ row }">
              {{ formatCurrency(row.unitPrice) }}
            </template>
          </el-table-column>
          <el-table-column prop="total" label="Thành tiền" width="120">
            <template #default="{ row }">
              {{ formatCurrency(row.total) }}
            </template>
          </el-table-column>
        </el-table>
      </div>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showOrderDetailsDialog = false">Đóng</el-button>
          <el-button type="primary" @click="editOrder(selectedOrder)">Chỉnh sửa</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  Plus,
  Download,
  Document,
  Upload,
  Check,
  Box,
  Search,
  List,
  Grid,
  View,
  Edit,
  Delete
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// Reactive data
const viewMode = ref('table')
const currentPage = ref(1)
const pageSize = ref(20)
const selectedOrders = ref([])
const showCreateOrderDialog = ref(false)
const showOrderDetailsDialog = ref(false)
const selectedOrder = ref(null)

const filters = ref({
  status: '',
  supplier: '',
  dateRange: [],
  search: ''
})

const stats = ref({
  draft: 0,
  submitted: 0,
  confirmed: 0,
  received: 0
})

const newOrder = ref({
  supplierId: '',
  expectedDate: '',
  priority: 'medium',
  notes: '',
  items: [],
  totalAmount: 0
})

const orderRules = {
  supplierId: [{ required: true, message: 'Vui lòng chọn nhà cung cấp', trigger: 'change' }],
  expectedDate: [{ required: true, message: 'Vui lòng chọn ngày nhận dự kiến', trigger: 'change' }],
  priority: [{ required: true, message: 'Vui lòng chọn độ ưu tiên', trigger: 'change' }]
}

// Sample data
const orders = ref([
  {
    id: 1,
    orderNumber: 'PO-2024-001',
    supplierName: 'Công ty TNHH ABC',
    orderDate: '2024-01-15',
    expectedDate: '2024-01-25',
    totalAmount: 50000000,
    itemsCount: 3,
    status: 'draft',
    priority: 'high',
    items: [
      { productName: 'Laptop Dell XPS 13', quantity: 10, unitPrice: 25000000, total: 250000000 },
      { productName: 'Chuột không dây Logitech', quantity: 50, unitPrice: 500000, total: 25000000 }
    ]
  },
  {
    id: 2,
    orderNumber: 'PO-2024-002',
    supplierName: 'Công ty TNHH XYZ',
    orderDate: '2024-01-16',
    expectedDate: '2024-01-28',
    totalAmount: 35000000,
    itemsCount: 2,
    status: 'submitted',
    priority: 'medium',
    items: [
      { productName: 'Màn hình LG 27"', quantity: 15, unitPrice: 2800000, total: 42000000 },
      { productName: 'Bàn phím cơ', quantity: 20, unitPrice: 500000, total: 10000000 }
    ]
  },
  {
    id: 3,
    orderNumber: 'PO-2024-003',
    supplierName: 'Công ty TNHH DEF',
    orderDate: '2024-01-14',
    expectedDate: '2024-01-22',
    totalAmount: 80000000,
    itemsCount: 1,
    status: 'confirmed',
    priority: 'low',
    items: [
      { productName: 'Máy in HP LaserJet', quantity: 5, unitPrice: 8000000, total: 40000000 },
      { productName: 'Giấy in A4', quantity: 200, unitPrice: 80000, total: 16000000 }
    ]
  },
  {
    id: 4,
    orderNumber: 'PO-2024-004',
    supplierName: 'Công ty TNHH GHI',
    orderDate: '2024-01-10',
    expectedDate: '2024-01-20',
    totalAmount: 120000000,
    itemsCount: 2,
    status: 'received',
    priority: 'high',
    items: [
      { productName: 'Server Dell PowerEdge', quantity: 3, unitPrice: 20000000, total: 60000000 },
      { productName: 'Switch Cisco Catalyst', quantity: 10, unitPrice: 2500000, total: 25000000 }
    ]
  },
  {
    id: 5,
    orderNumber: 'PO-2024-005',
    supplierName: 'Công ty TNHH JKL',
    orderDate: '2024-01-17',
    expectedDate: '2024-01-30',
    totalAmount: 25000000,
    itemsCount: 2,
    status: 'draft',
    priority: 'medium',
    items: [
      { productName: 'Tablet Samsung Galaxy', quantity: 20, unitPrice: 1200000, total: 24000000 },
      { productName: 'Tai nghe Sony WH-1000XM4', quantity: 20, unitPrice: 50000, total: 1000000 }
    ]
  }
])

const suppliers = ref([
  { id: 1, name: 'Công ty TNHH ABC' },
  { id: 2, name: 'Công ty TNHH XYZ' },
  { id: 3, name: 'Công ty TNHH DEF' },
  { id: 4, name: 'Công ty TNHH GHI' },
  { id: 5, name: 'Công ty TNHH JKL' }
])

const products = ref([
  { id: 1, name: 'Laptop Dell XPS 13', price: 25000000 },
  { id: 2, name: 'Chuột không dây Logitech', price: 500000 },
  { id: 3, name: 'Màn hình LG 27"', price: 2800000 },
  { id: 4, name: 'Bàn phím cơ', price: 500000 },
  { id: 5, name: 'Máy in HP LaserJet', price: 8000000 },
  { id: 6, name: 'Giấy in A4', price: 80000 },
  { id: 7, name: 'Server Dell PowerEdge', price: 20000000 },
  { id: 8, name: 'Switch Cisco Catalyst', price: 2500000 },
  { id: 9, name: 'Tablet Samsung Galaxy', price: 1200000 },
  { id: 10, name: 'Tai nghe Sony WH-1000XM4', price: 50000 }
])

// Computed properties
const filteredOrders = computed(() => {
  let filtered = orders.value

  if (filters.value.status) {
    filtered = filtered.filter(order => order.status === filters.value.status)
  }

  if (filters.value.supplier) {
    filtered = filtered.filter(order => order.supplierName === suppliers.value.find(s => s.id === filters.value.supplier)?.name)
  }

  if (filters.value.search) {
    const search = filters.value.search.toLowerCase()
    filtered = filtered.filter(order =>
      order.orderNumber.toLowerCase().includes(search) ||
      order.supplierName.toLowerCase().includes(search)
    )
  }

  if (filters.value.dateRange && filters.value.dateRange.length === 2) {
    filtered = filtered.filter(order => {
      const orderDate = new Date(order.orderDate)
      const startDate = new Date(filters.value.dateRange[0])
      const endDate = new Date(filters.value.dateRange[1])
      return orderDate >= startDate && orderDate <= endDate
    })
  }

  return filtered
})

const paginatedOrders = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredOrders.value.slice(start, end)
})

// Methods
const updateStats = () => {
  stats.value.draft = orders.value.filter(order => order.status === 'draft').length
  stats.value.submitted = orders.value.filter(order => order.status === 'submitted').length
  stats.value.confirmed = orders.value.filter(order => order.status === 'confirmed').length
  stats.value.received = orders.value.filter(order => order.status === 'received').length
}

const getOrdersByStatus = (status: string) => {
  return filteredOrders.value.filter(order => order.status === status)
}

const getStatusType = (status: string) => {
  const types = {
    draft: 'info',
    submitted: 'warning',
    confirmed: 'primary',
    received: 'success',
    cancelled: 'danger'
  }
  return types[status] || 'info'
}

const getStatusLabel = (status: string) => {
  const labels = {
    draft: 'Nháp',
    submitted: 'Đã gửi',
    confirmed: 'Đã xác nhận',
    received: 'Đã nhận hàng',
    cancelled: 'Đã hủy'
  }
  return labels[status] || status
}

const getPriorityType = (priority: string) => {
  const types = {
    high: 'danger',
    medium: 'warning',
    low: 'info'
  }
  return types[priority] || 'info'
}

const getPriorityLabel = (priority: string) => {
  const labels = {
    high: 'Cao',
    medium: 'Trung bình',
    low: 'Thấp'
  }
  return labels[priority] || priority
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('vi-VN')
}

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(amount)
}

const handleSelectionChange = (selection: any[]) => {
  selectedOrders.value = selection
}

const viewOrderDetails = (order: any) => {
  selectedOrder.value = order
  showOrderDetailsDialog.value = true
}

const editOrder = (order: any) => {
  ElMessage.info('Chức năng chỉnh sửa đơn hàng sẽ được phát triển')
}

const submitOrder = (order: any) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn gửi đơn hàng này cho nhà cung cấp?',
    'Xác nhận',
    {
      confirmButtonText: 'Gửi',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    order.status = 'submitted'
    updateStats()
    ElMessage.success('Đã gửi đơn hàng cho nhà cung cấp')
  })
}

const confirmOrder = (order: any) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn xác nhận đơn hàng này?',
    'Xác nhận',
    {
      confirmButtonText: 'Xác nhận',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    order.status = 'confirmed'
    updateStats()
    ElMessage.success('Đã xác nhận đơn hàng')
  })
}

const receiveOrder = (order: any) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn nhận hàng cho đơn hàng này?',
    'Xác nhận',
    {
      confirmButtonText: 'Nhận hàng',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    order.status = 'received'
    updateStats()
    ElMessage.success('Đã nhận hàng thành công')
  })
}

const exportOrders = () => {
  ElMessage.info('Chức năng xuất báo cáo sẽ được phát triển')
}

const addOrderItem = () => {
  newOrder.value.items.push({
    productId: '',
    quantity: 1,
    unitPrice: 0,
    total: 0
  })
}

const removeOrderItem = (index: number) => {
  newOrder.value.items.splice(index, 1)
}

const createOrder = () => {
  // Validate form
  if (newOrder.value.items.length === 0) {
    ElMessage.error('Vui lòng thêm ít nhất một sản phẩm')
    return
  }

  // Create new order
  const order = {
    id: orders.value.length + 1,
    orderNumber: `PO-2024-${String(orders.value.length + 1).padStart(3, '0')}`,
    supplierName: suppliers.value.find(s => s.id === newOrder.value.supplierId)?.name,
    orderDate: new Date().toISOString().split('T')[0],
    expectedDate: newOrder.value.expectedDate,
    totalAmount: newOrder.value.totalAmount,
    itemsCount: newOrder.value.items.length,
    status: 'draft',
    priority: newOrder.value.priority,
    items: newOrder.value.items.map(item => ({
      productName: products.value.find(p => p.id === item.productId)?.name,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      total: item.total
    }))
  }

  orders.value.unshift(order)
  updateStats()
  showCreateOrderDialog.value = false
  resetNewOrder()
  ElMessage.success('Đã tạo đơn hàng mua thành công')
}

const resetNewOrder = () => {
  newOrder.value = {
    supplierId: '',
    expectedDate: '',
    priority: 'medium',
    notes: '',
    items: [],
    totalAmount: 0
  }
}

const handleCloseCreateDialog = () => {
  showCreateOrderDialog.value = false
  resetNewOrder()
}

const handleCloseDetailsDialog = () => {
  showOrderDetailsDialog.value = false
  selectedOrder.value = null
}

// Lifecycle
onMounted(() => {
  updateStats()
})
</script>

<style scoped>
.purchase-orders-container {
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

.stat-icon.draft {
  background: linear-gradient(135deg, #909399, #606266);
}

.stat-icon.submitted {
  background: linear-gradient(135deg, #ff9500, #ff6b35);
}

.stat-icon.confirmed {
  background: linear-gradient(135deg, #007aff, #5856d6);
}

.stat-icon.received {
  background: linear-gradient(135deg, #34c759, #30d158);
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

.filter-card {
  margin-bottom: 20px;
}

.filter-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

.filter-group {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.search-group {
  display: flex;
  gap: 10px;
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
  gap: 10px;
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

/* Kanban View */
.kanban-view {
  margin-top: 20px;
}

.kanban-columns {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  min-height: 600px;
}

.kanban-column {
  background: #f5f7fa;
  border-radius: 8px;
  padding: 15px;
}

.column-header {
  padding: 10px;
  border-radius: 6px;
  margin-bottom: 15px;
}

.column-header h3 {
  margin: 0;
  color: white;
  font-size: 16px;
  font-weight: 600;
}

.column-header.draft {
  background: linear-gradient(135deg, #909399, #606266);
}

.column-header.submitted {
  background: linear-gradient(135deg, #ff9500, #ff6b35);
}

.column-header.confirmed {
  background: linear-gradient(135deg, #007aff, #5856d6);
}

.column-header.received {
  background: linear-gradient(135deg, #34c759, #30d158);
}

.column-content {
  min-height: 500px;
}

.kanban-card {
  background: white;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
}

.kanban-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.order-number {
  font-weight: 600;
  color: #303133;
  font-size: 14px;
}

.card-body {
  margin-bottom: 10px;
}

.supplier-name {
  margin: 0 0 5px 0;
  font-weight: 500;
  color: #606266;
  font-size: 13px;
}

.order-info {
  margin: 0 0 5px 0;
  color: #909399;
  font-size: 12px;
}

.order-amount {
  margin: 0;
  font-weight: 600;
  color: #409eff;
  font-size: 14px;
}

.card-footer {
  border-top: 1px solid #ebeef5;
  padding-top: 8px;
}

.order-date {
  color: #909399;
  font-size: 12px;
}

/* Order Items */
.order-items {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 15px;
  background: #fafafa;
}

.order-item {
  margin-bottom: 15px;
  padding: 10px;
  background: white;
  border-radius: 4px;
  border: 1px solid #ebeef5;
}

.order-item:last-child {
  margin-bottom: 0;
}

/* Responsive */
@media (max-width: 1200px) {
  .kanban-columns {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .kanban-columns {
    grid-template-columns: 1fr;
  }

  .filter-row {
    flex-direction: column;
    align-items: stretch;
  }

  .header-actions {
    flex-direction: column;
  }
}
</style>

<template>
  <div class="sales-orders-container">
    <!-- Header -->
    <div class="page-header">
      <div class="header-left">
        <h1>Quản lý đơn hàng bán</h1>
        <p class="subtitle">Quản lý toàn bộ workflow từ đơn hàng đến giao hàng</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="showCreateOrderDialog = true">
          <el-icon><Plus /></el-icon>
          Tạo đơn hàng mới
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
          <div class="stat-icon pending">
            <el-icon><Clock /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.pending }}</h3>
            <p>Đơn hàng chờ xử lý</p>
          </div>
        </div>
      </el-card>
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon processing">
            <el-icon><Loading /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.processing }}</h3>
            <p>Đang xử lý</p>
          </div>
        </div>
      </el-card>
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon shipped">
            <el-icon><Van /></el-icon>
          </div>
          <div class="stat-info">
            <h3>{{ stats.shipped }}</h3>
            <p>Đã giao hàng</p>
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
            <p>Hoàn thành</p>
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
            <el-option label="Chờ xử lý" value="pending" />
            <el-option label="Đang xử lý" value="processing" />
            <el-option label="Đã giao hàng" value="shipped" />
            <el-option label="Hoàn thành" value="completed" />
            <el-option label="Đã hủy" value="cancelled" />
          </el-select>
          <el-select v-model="filters.priority" placeholder="Độ ưu tiên" clearable>
            <el-option label="Tất cả" value="" />
            <el-option label="Cao" value="high" />
            <el-option label="Trung bình" value="medium" />
            <el-option label="Thấp" value="low" />
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
            placeholder="Tìm kiếm theo mã đơn hàng, khách hàng..."
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
          <span>Danh sách đơn hàng ({{ filteredOrders.length }})</span>
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
          <el-table-column prop="customerName" label="Khách hàng" width="200" />
          <el-table-column prop="orderDate" label="Ngày đặt" width="120">
            <template #default="{ row }">
              {{ formatDate(row.orderDate) }}
            </template>
          </el-table-column>
          <el-table-column prop="deliveryDate" label="Ngày giao" width="120">
            <template #default="{ row }">
              {{ formatDate(row.deliveryDate) }}
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
          <el-table-column label="Thao tác" width="200" fixed="right">
            <template #default="{ row }">
              <el-button-group>
                <el-button size="small" @click="viewOrderDetails(row)">
                  <el-icon><View /></el-icon>
                </el-button>
                <el-button size="small" type="primary" @click="editOrder(row)">
                  <el-icon><Edit /></el-icon>
                </el-button>
                <el-button size="small" type="success" @click="processOrder(row)">
                  <el-icon><Operation /></el-icon>
                </el-button>
                <el-button size="small" type="warning" @click="shipOrder(row)">
                  <el-icon><Van /></el-icon>
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
            <div class="column-header pending">
              <h3>Chờ xử lý ({{ getOrdersByStatus('pending').length }})</h3>
            </div>
            <div class="column-content">
              <div
                v-for="order in getOrdersByStatus('pending')"
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
                  <p class="customer-name">{{ order.customerName }}</p>
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
            <div class="column-header processing">
              <h3>Đang xử lý ({{ getOrdersByStatus('processing').length }})</h3>
            </div>
            <div class="column-content">
              <div
                v-for="order in getOrdersByStatus('processing')"
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
                  <p class="customer-name">{{ order.customerName }}</p>
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
            <div class="column-header shipped">
              <h3>Đã giao hàng ({{ getOrdersByStatus('shipped').length }})</h3>
            </div>
            <div class="column-content">
              <div
                v-for="order in getOrdersByStatus('shipped')"
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
                  <p class="customer-name">{{ order.customerName }}</p>
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
            <div class="column-header completed">
              <h3>Hoàn thành ({{ getOrdersByStatus('completed').length }})</h3>
            </div>
            <div class="column-content">
              <div
                v-for="order in getOrdersByStatus('completed')"
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
                  <p class="customer-name">{{ order.customerName }}</p>
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
      title="Tạo đơn hàng mới"
      width="80%"
      :before-close="handleCloseCreateDialog"
    >
      <el-form ref="createOrderForm" :model="newOrder" :rules="orderRules" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Khách hàng" prop="customerId">
              <el-select v-model="newOrder.customerId" placeholder="Chọn khách hàng" style="width: 100%">
                <el-option
                  v-for="customer in customers"
                  :key="customer.id"
                  :label="customer.name"
                  :value="customer.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Ngày giao hàng" prop="deliveryDate">
              <el-date-picker
                v-model="newOrder.deliveryDate"
                type="date"
                placeholder="Chọn ngày giao hàng"
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
      title="Chi tiết đơn hàng"
      width="70%"
      :before-close="handleCloseDetailsDialog"
    >
      <div v-if="selectedOrder" class="order-details">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="Mã đơn hàng">{{ selectedOrder.orderNumber }}</el-descriptions-item>
          <el-descriptions-item label="Khách hàng">{{ selectedOrder.customerName }}</el-descriptions-item>
          <el-descriptions-item label="Ngày đặt hàng">{{ formatDate(selectedOrder.orderDate) }}</el-descriptions-item>
          <el-descriptions-item label="Ngày giao hàng">{{ formatDate(selectedOrder.deliveryDate) }}</el-descriptions-item>
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
  Clock,
  Loading,
  Van,
  Check,
  Search,
  List,
  Grid,
  View,
  Edit,
  Operation,
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
  priority: '',
  dateRange: [],
  search: ''
})

const stats = ref({
  pending: 0,
  processing: 0,
  shipped: 0,
  completed: 0
})

const newOrder = ref({
  customerId: '',
  deliveryDate: '',
  priority: 'medium',
  notes: '',
  items: [],
  totalAmount: 0
})

const orderRules = {
  customerId: [{ required: true, message: 'Vui lòng chọn khách hàng', trigger: 'change' }],
  deliveryDate: [{ required: true, message: 'Vui lòng chọn ngày giao hàng', trigger: 'change' }],
  priority: [{ required: true, message: 'Vui lòng chọn độ ưu tiên', trigger: 'change' }]
}

// Sample data
const orders = ref([
  {
    id: 1,
    orderNumber: 'SO-2024-001',
    customerName: 'Công ty ABC',
    orderDate: '2024-01-15',
    deliveryDate: '2024-01-20',
    totalAmount: 15000000,
    itemsCount: 5,
    status: 'pending',
    priority: 'high',
    items: [
      { productName: 'Laptop Dell XPS 13', quantity: 2, unitPrice: 25000000, total: 50000000 },
      { productName: 'Chuột không dây Logitech', quantity: 10, unitPrice: 500000, total: 5000000 }
    ]
  },
  {
    id: 2,
    orderNumber: 'SO-2024-002',
    customerName: 'Công ty XYZ',
    orderDate: '2024-01-16',
    deliveryDate: '2024-01-22',
    totalAmount: 8500000,
    itemsCount: 3,
    status: 'processing',
    priority: 'medium',
    items: [
      { productName: 'Màn hình LG 27"', quantity: 3, unitPrice: 2800000, total: 8400000 },
      { productName: 'Bàn phím cơ', quantity: 2, unitPrice: 500000, total: 1000000 }
    ]
  },
  {
    id: 3,
    orderNumber: 'SO-2024-003',
    customerName: 'Công ty DEF',
    orderDate: '2024-01-14',
    deliveryDate: '2024-01-18',
    totalAmount: 12000000,
    itemsCount: 4,
    status: 'shipped',
    priority: 'low',
    items: [
      { productName: 'Máy in HP LaserJet', quantity: 1, unitPrice: 8000000, total: 8000000 },
      { productName: 'Giấy in A4', quantity: 50, unitPrice: 80000, total: 4000000 }
    ]
  },
  {
    id: 4,
    orderNumber: 'SO-2024-004',
    customerName: 'Công ty GHI',
    orderDate: '2024-01-10',
    deliveryDate: '2024-01-15',
    totalAmount: 25000000,
    itemsCount: 6,
    status: 'completed',
    priority: 'high',
    items: [
      { productName: 'Server Dell PowerEdge', quantity: 1, unitPrice: 20000000, total: 20000000 },
      { productName: 'Switch Cisco Catalyst', quantity: 2, unitPrice: 2500000, total: 5000000 }
    ]
  },
  {
    id: 5,
    orderNumber: 'SO-2024-005',
    customerName: 'Công ty JKL',
    orderDate: '2024-01-17',
    deliveryDate: '2024-01-25',
    totalAmount: 6500000,
    itemsCount: 2,
    status: 'pending',
    priority: 'medium',
    items: [
      { productName: 'Tablet Samsung Galaxy', quantity: 5, unitPrice: 1200000, total: 6000000 },
      { productName: 'Tai nghe Sony WH-1000XM4', quantity: 10, unitPrice: 50000, total: 500000 }
    ]
  }
])

const customers = ref([
  { id: 1, name: 'Công ty ABC' },
  { id: 2, name: 'Công ty XYZ' },
  { id: 3, name: 'Công ty DEF' },
  { id: 4, name: 'Công ty GHI' },
  { id: 5, name: 'Công ty JKL' }
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

  if (filters.value.priority) {
    filtered = filtered.filter(order => order.priority === filters.value.priority)
  }

  if (filters.value.search) {
    const search = filters.value.search.toLowerCase()
    filtered = filtered.filter(order =>
      order.orderNumber.toLowerCase().includes(search) ||
      order.customerName.toLowerCase().includes(search)
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
  stats.value.pending = orders.value.filter(order => order.status === 'pending').length
  stats.value.processing = orders.value.filter(order => order.status === 'processing').length
  stats.value.shipped = orders.value.filter(order => order.status === 'shipped').length
  stats.value.completed = orders.value.filter(order => order.status === 'completed').length
}

const getOrdersByStatus = (status: string) => {
  return filteredOrders.value.filter(order => order.status === status)
}

const getStatusType = (status: string) => {
  const types = {
    pending: 'warning',
    processing: 'primary',
    shipped: 'success',
    completed: 'success',
    cancelled: 'danger'
  }
  return types[status] || 'info'
}

const getStatusLabel = (status: string) => {
  const labels = {
    pending: 'Chờ xử lý',
    processing: 'Đang xử lý',
    shipped: 'Đã giao hàng',
    completed: 'Hoàn thành',
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

const processOrder = (order: any) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn xử lý đơn hàng này?',
    'Xác nhận',
    {
      confirmButtonText: 'Xử lý',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    order.status = 'processing'
    updateStats()
    ElMessage.success('Đã chuyển đơn hàng sang trạng thái xử lý')
  })
}

const shipOrder = (order: any) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn giao hàng cho đơn hàng này?',
    'Xác nhận',
    {
      confirmButtonText: 'Giao hàng',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    order.status = 'shipped'
    updateStats()
    ElMessage.success('Đã chuyển đơn hàng sang trạng thái giao hàng')
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
    orderNumber: `SO-2024-${String(orders.value.length + 1).padStart(3, '0')}`,
    customerName: customers.value.find(c => c.id === newOrder.value.customerId)?.name,
    orderDate: new Date().toISOString().split('T')[0],
    deliveryDate: newOrder.value.deliveryDate,
    totalAmount: newOrder.value.totalAmount,
    itemsCount: newOrder.value.items.length,
    status: 'pending',
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
  ElMessage.success('Đã tạo đơn hàng thành công')
}

const resetNewOrder = () => {
  newOrder.value = {
    customerId: '',
    deliveryDate: '',
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
.sales-orders-container {
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

.stat-icon.processing {
  background: linear-gradient(135deg, #007aff, #5856d6);
}

.stat-icon.shipped {
  background: linear-gradient(135deg, #34c759, #30d158);
}

.stat-icon.completed {
  background: linear-gradient(135deg, #5ac18e, #4cd964);
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

.column-header.pending {
  background: linear-gradient(135deg, #ff9500, #ff6b35);
}

.column-header.processing {
  background: linear-gradient(135deg, #007aff, #5856d6);
}

.column-header.shipped {
  background: linear-gradient(135deg, #34c759, #30d158);
}

.column-header.completed {
  background: linear-gradient(135deg, #5ac18e, #4cd964);
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

.customer-name {
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

<template>
  <div class="picking-tasks">
    <!-- Page Header -->
    <div class="page-header">
      <div class="header-left">
        <h1 class="page-title">Nhiệm vụ Picking</h1>
        <p class="page-description">Quản lý và theo dõi các nhiệm vụ picking trong kho</p>
      </div>
      <div class="header-actions">
        <el-button type="success" @click="createPickingTask">
          <el-icon><Plus /></el-icon>
          Tạo nhiệm vụ
        </el-button>
        <el-button type="primary" @click="optimizeRoutes">
          <el-icon><Operation /></el-icon>
          Tối ưu lộ trình
        </el-button>
      </div>
    </div>

    <!-- Picking Performance Cards -->
    <el-row :gutter="20" class="performance-section">
      <el-col :span="6">
        <el-card shadow="hover" class="performance-card">
          <div class="performance-content">
            <div class="performance-icon bg-blue">
              <el-icon size="28"><TakeawayBox /></el-icon>
            </div>
            <div class="performance-details">
              <div class="performance-value">{{ performanceData.activeTasks }}</div>
              <div class="performance-label">Nhiệm vụ đang thực hiện</div>
              <div class="performance-sublabel">{{ performanceData.pickersActive }} picker đang làm</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="performance-card">
          <div class="performance-content">
            <div class="performance-icon bg-green">
              <el-icon size="28"><SuccessFilled /></el-icon>
            </div>
            <div class="performance-details">
              <div class="performance-value">{{ performanceData.completedToday }}</div>
              <div class="performance-label">Hoàn thành hôm nay</div>
              <div class="performance-sublabel">{{ performanceData.itemsPicked.toLocaleString() }} sản phẩm</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="performance-card">
          <div class="performance-content">
            <div class="performance-icon bg-orange">
              <el-icon size="28"><Timer /></el-icon>
            </div>
            <div class="performance-details">
              <div class="performance-value">{{ performanceData.avgPickTime }}m</div>
              <div class="performance-label">Thời gian picking TB</div>
              <div class="performance-sublabel">{{ performanceData.efficiency }}% hiệu suất</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" class="performance-card">
          <div class="performance-content">
            <div class="performance-icon bg-purple">
              <el-icon size="28"><Warning /></el-icon>
            </div>
            <div class="performance-details">
              <div class="performance-value">{{ performanceData.urgentTasks }}</div>
              <div class="performance-label">Nhiệm vụ khẩn cấp</div>
              <div class="performance-sublabel">Cần xử lý ngay</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Filters and Actions -->
    <el-card shadow="never" class="filter-card">
      <div class="filters">
        <el-row :gutter="20">
          <el-col :span="3">
            <el-select v-model="filters.status" placeholder="Trạng thái" clearable>
              <el-option label="Đã tạo" value="created" />
              <el-option label="Đã giao" value="assigned" />
              <el-option label="Đang thực hiện" value="in_progress" />
              <el-option label="Hoàn thành" value="completed" />
              <el-option label="Đã hủy" value="cancelled" />
            </el-select>
          </el-col>
          <el-col :span="3">
            <el-select v-model="filters.priority" placeholder="Độ ưu tiên" clearable>
              <el-option label="Thấp" value="low" />
              <el-option label="Bình thường" value="normal" />
              <el-option label="Cao" value="high" />
              <el-option label="Khẩn cấp" value="urgent" />
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
          <el-col :span="3">
            <el-select v-model="filters.picker" placeholder="Picker" clearable>
              <el-option
                v-for="picker in pickers"
                :key="picker.id"
                :label="picker.name"
                :value="picker.id"
              />
            </el-select>
          </el-col>
          <el-col :span="4">
            <el-input
              v-model="filters.search"
              placeholder="Tìm mã nhiệm vụ, đơn hàng..."
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </el-col>
          <el-col :span="8">
            <el-button type="primary" @click="applyFilters">
              <el-icon><Search /></el-icon>
              Tìm kiếm
            </el-button>
            <el-button @click="resetFilters">Đặt lại</el-button>
            <el-button @click="bulkAssign" :disabled="selectedTasks.length === 0">
              Giao việc hàng loạt
            </el-button>
            <el-button @click="exportTasks">
              <el-icon><Download /></el-icon>
              Xuất Excel
            </el-button>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- Tasks Table -->
    <el-card shadow="never" class="table-card">
      <template #header>
        <div class="table-header">
          <span class="table-title">Danh sách nhiệm vụ picking</span>
          <div class="table-actions">
            <el-radio-group v-model="viewMode" size="small">
              <el-radio-button value="list">Danh sách</el-radio-button>
              <el-radio-button value="kanban">Kanban</el-radio-button>
            </el-radio-group>
            <el-button size="small" @click="refreshData">
              <el-icon><Refresh /></el-icon>
              Làm mới
            </el-button>
          </div>
        </div>
      </template>

      <!-- List View -->
      <div v-if="viewMode === 'list'">
        <el-table
          :data="pickingTasks"
          v-loading="loading"
          @selection-change="handleSelectionChange"
          style="width: 100%"
          height="600"
        >
          <el-table-column type="selection" width="55" />

          <el-table-column prop="taskNumber" label="Mã nhiệm vụ" width="140" fixed>
            <template #default="{ row }">
              <el-button type="text" @click="viewTaskDetail(row)">
                {{ row.taskNumber }}
              </el-button>
            </template>
          </el-table-column>

          <el-table-column prop="priority" label="Ưu tiên" width="100">
            <template #default="{ row }">
              <el-tag :type="getPriorityTagType(row.priority)" size="small">
                {{ getPriorityText(row.priority) }}
              </el-tag>
            </template>
          </el-table-column>

          <el-table-column prop="warehouseName" label="Kho" width="150" />
          <el-table-column prop="zoneName" label="Khu vực" width="120" />

          <el-table-column prop="orderCodes" label="Đơn hàng" width="180">
            <template #default="{ row }">
              <div class="order-codes">
                <el-tag
                  v-for="code in row.orderCodes.slice(0, 2)"
                  :key="code"
                  size="small"
                  class="order-tag"
                >
                  {{ code }}
                </el-tag>
                <span v-if="row.orderCodes.length > 2" class="more-orders">
                  +{{ row.orderCodes.length - 2 }} khác
                </span>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="totalItems" label="Số sản phẩm" width="100" align="center" />
          <el-table-column prop="pickedItems" label="Đã pick" width="100" align="center">
            <template #default="{ row }">
              <span :class="getProgressClass(row)">
                {{ row.pickedItems }}/{{ row.totalItems }}
              </span>
            </template>
          </el-table-column>

          <el-table-column prop="totalLocations" label="Vị trí" width="80" align="center" />

          <el-table-column prop="assignedTo" label="Picker" width="120">
            <template #default="{ row }">
              <div v-if="row.assignedTo" class="picker-info">
                <el-avatar :size="24" class="picker-avatar">
                  {{ row.assignedTo.charAt(0) }}
                </el-avatar>
                <span class="picker-name">{{ row.assignedTo }}</span>
              </div>
              <span v-else class="text-muted">Chưa giao</span>
            </template>
          </el-table-column>

          <el-table-column prop="status" label="Trạng thái" width="120">
            <template #default="{ row }">
              <el-tag :type="getStatusTagType(row.status)" size="small">
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>

          <el-table-column prop="createdDate" label="Ngày tạo" width="120">
            <template #default="{ row }">
              {{ formatDate(row.createdDate) }}
            </template>
          </el-table-column>

          <el-table-column prop="estimatedTime" label="Thời gian ước tính" width="130" align="center">
            <template #default="{ row }">
              {{ row.estimatedTime }}m
            </template>
          </el-table-column>

          <el-table-column label="Thao tác" width="200" fixed="right">
            <template #default="{ row }">
              <div class="action-buttons">
                <el-button size="small" type="primary" @click="viewTaskDetail(row)">
                  Xem
                </el-button>

                <el-dropdown>
                  <el-button size="small">
                    Khác <el-icon><ArrowDown /></el-icon>
                  </el-button>
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item
                        v-if="canAssign(row)"
                        @click="assignTask(row)"
                      >
                        Giao việc
                      </el-dropdown-item>
                      <el-dropdown-item
                        v-if="canStart(row)"
                        @click="startTask(row)"
                      >
                        Bắt đầu
                      </el-dropdown-item>
                      <el-dropdown-item
                        v-if="canComplete(row)"
                        @click="completeTask(row)"
                      >
                        Hoàn thành
                      </el-dropdown-item>
                      <el-dropdown-item
                        v-if="canCancel(row)"
                        divided
                        @click="cancelTask(row)"
                      >
                        Hủy nhiệm vụ
                      </el-dropdown-item>
                      <el-dropdown-item @click="printPickingList(row)">
                        In danh sách picking
                      </el-dropdown-item>
                      <el-dropdown-item @click="viewRouteMap(row)">
                        Xem bản đồ lộ trình
                      </el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
              </div>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- Kanban View -->
      <div v-else class="kanban-view">
        <div class="kanban-columns">
          <div
            v-for="status in kanbanStatuses"
            :key="status.value"
            class="kanban-column"
          >
            <div class="kanban-header">
              <h3 class="kanban-title">{{ status.label }}</h3>
              <el-badge :value="getTaskCountByStatus(status.value)" class="kanban-badge" />
            </div>
            <div class="kanban-content">
              <div
                v-for="task in getTasksByStatus(status.value)"
                :key="task.id"
                class="kanban-card"
                @click="viewTaskDetail(task)"
              >
                <div class="card-header">
                  <span class="task-number">{{ task.taskNumber }}</span>
                  <el-tag :type="getPriorityTagType(task.priority)" size="small">
                    {{ getPriorityText(task.priority) }}
                  </el-tag>
                </div>
                <div class="card-content">
                  <div class="task-info">
                    <span class="warehouse">{{ task.warehouseName }}</span>
                    <span class="zone">{{ task.zoneName }}</span>
                  </div>
                  <div class="task-progress">
                    <span>{{ task.pickedItems }}/{{ task.totalItems }} sản phẩm</span>
                    <el-progress
                      :percentage="Math.round((task.pickedItems / task.totalItems) * 100)"
                      :stroke-width="6"
                      :show-text="false"
                    />
                  </div>
                  <div class="task-picker" v-if="task.assignedTo">
                    <el-avatar :size="20">{{ task.assignedTo.charAt(0) }}</el-avatar>
                    <span>{{ task.assignedTo }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Pagination (for list view) -->
      <div v-if="viewMode === 'list'" class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.currentPage"
          v-model:page-size="pagination.pageSize"
          :page-sizes="[20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- Task Detail Dialog -->
    <el-dialog
      v-model="taskDetailDialog.visible"
      :title="`Chi tiết nhiệm vụ: ${taskDetailDialog.task?.taskNumber}`"
      width="90%"
      top="5vh"
    >
      <div v-if="taskDetailDialog.task" class="task-detail">
        <!-- Task Info -->
        <el-row :gutter="20" class="task-info-section">
          <el-col :span="12">
            <el-card shadow="never" class="task-info-card">
              <template #header>
                <span>Thông tin nhiệm vụ</span>
              </template>
              <div class="task-details">
                <div class="detail-row">
                  <label>Mã nhiệm vụ:</label>
                  <span>{{ taskDetailDialog.task.taskNumber }}</span>
                </div>
                <div class="detail-row">
                  <label>Kho:</label>
                  <span>{{ taskDetailDialog.task.warehouseName }}</span>
                </div>
                <div class="detail-row">
                  <label>Khu vực:</label>
                  <span>{{ taskDetailDialog.task.zoneName }}</span>
                </div>
                <div class="detail-row">
                  <label>Độ ưu tiên:</label>
                  <el-tag :type="getPriorityTagType(taskDetailDialog.task.priority)">
                    {{ getPriorityText(taskDetailDialog.task.priority) }}
                  </el-tag>
                </div>
                <div class="detail-row">
                  <label>Trạng thái:</label>
                  <el-tag :type="getStatusTagType(taskDetailDialog.task.status)">
                    {{ getStatusText(taskDetailDialog.task.status) }}
                  </el-tag>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="12">
            <el-card shadow="never" class="task-progress-card">
              <template #header>
                <span>Tiến độ thực hiện</span>
              </template>
              <div class="progress-details">
                <div class="progress-item">
                  <label>Sản phẩm:</label>
                  <div class="progress-value">
                    {{ taskDetailDialog.task.pickedItems }}/{{ taskDetailDialog.task.totalItems }}
                    <el-progress
                      :percentage="Math.round((taskDetailDialog.task.pickedItems / taskDetailDialog.task.totalItems) * 100)"
                      :stroke-width="8"
                    />
                  </div>
                </div>
                <div class="progress-item">
                  <label>Vị trí:</label>
                  <div class="progress-value">
                    {{ taskDetailDialog.task.visitedLocations }}/{{ taskDetailDialog.task.totalLocations }}
                    <el-progress
                      :percentage="Math.round((taskDetailDialog.task.visitedLocations / taskDetailDialog.task.totalLocations) * 100)"
                      :stroke-width="8"
                      color="#E6A23C"
                    />
                  </div>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <!-- Picking Items -->
        <el-card shadow="never" class="picking-items-card">
          <template #header>
            <span>Danh sách sản phẩm picking</span>
          </template>
          <el-table :data="taskDetailDialog.task.items" style="width: 100%" height="400">
            <el-table-column prop="sequenceNumber" label="STT" width="60" align="center" />
            <el-table-column prop="productSku" label="SKU" width="120" />
            <el-table-column prop="productName" label="Tên sản phẩm" min-width="200" />
            <el-table-column prop="location" label="Vị trí" width="120" />
            <el-table-column prop="batchNumber" label="Số lô" width="120" />
            <el-table-column prop="requiredQuantity" label="SL yêu cầu" width="100" align="right" />
            <el-table-column prop="pickedQuantity" label="SL đã pick" width="100" align="right" />
            <el-table-column prop="unit" label="Đơn vị" width="80" />
            <el-table-column prop="status" label="Trạng thái" width="100">
              <template #default="{ row }">
                <el-tag :type="getItemStatusTagType(row.status)" size="small">
                  {{ getItemStatusText(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="taskDetailDialog.visible = false">Đóng</el-button>
          <el-button type="primary" @click="printPickingList(taskDetailDialog.task)">
            In danh sách picking
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import {
  Plus, Operation, TakeawayBox, SuccessFilled, Timer, Warning,
  Search, Download, Refresh, ArrowDown
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// Reactive data
const loading = ref(false)
const viewMode = ref('list')
const selectedTasks = ref([])

const filters = reactive({
  status: '',
  priority: '',
  warehouse: null,
  picker: null,
  search: ''
})

const pagination = reactive({
  currentPage: 1,
  pageSize: 50,
  total: 0
})

const taskDetailDialog = reactive({
  visible: false,
  task: null
})

const performanceData = reactive({
  activeTasks: 23,
  pickersActive: 8,
  completedToday: 156,
  itemsPicked: 2847,
  avgPickTime: 12.5,
  efficiency: 87,
  urgentTasks: 5
})

// Sample data
const warehouses = ref([
  { id: 1, name: 'Kho Hà Nội - Cầu Giấy' },
  { id: 2, name: 'Kho TP.HCM - Quận 7' },
  { id: 3, name: 'Kho Đà Nẵng - Hải Châu' }
])

const pickers = ref([
  { id: 1, name: 'Nguyễn Văn A' },
  { id: 2, name: 'Trần Thị B' },
  { id: 3, name: 'Lê Văn C' },
  { id: 4, name: 'Phạm Thị D' }
])

const kanbanStatuses = [
  { value: 'created', label: 'Đã tạo' },
  { value: 'assigned', label: 'Đã giao' },
  { value: 'in_progress', label: 'Đang thực hiện' },
  { value: 'completed', label: 'Hoàn thành' }
]

const pickingTasks = ref([
  {
    id: 1,
    taskNumber: 'PK2412150001',
    priority: 'urgent',
    warehouseName: 'Kho Hà Nội - Cầu Giấy',
    zoneName: 'Zone A',
    orderCodes: ['SO-001234', 'SO-001235', 'SO-001236'],
    totalItems: 25,
    pickedItems: 18,
    totalLocations: 15,
    visitedLocations: 12,
    assignedTo: 'Nguyễn Văn A',
    status: 'in_progress',
    createdDate: new Date('2024-12-15T08:30:00'),
    estimatedTime: 35,
    items: [
      {
        sequenceNumber: 1,
        productSku: 'PRD-001234',
        productName: 'Sữa tươi Vinamilk 1L',
        location: 'A-01-02',
        batchNumber: 'BT20241215001',
        requiredQuantity: 10,
        pickedQuantity: 10,
        unit: 'hộp',
        status: 'picked'
      },
      {
        sequenceNumber: 2,
        productSku: 'PRD-005678',
        productName: 'Bánh mì sandwich 500g',
        location: 'A-02-03',
        batchNumber: 'BT20241215002',
        requiredQuantity: 8,
        pickedQuantity: 5,
        unit: 'gói',
        status: 'picking'
      }
    ]
  },
  {
    id: 2,
    taskNumber: 'PK2412150002',
    priority: 'high',
    warehouseName: 'Kho TP.HCM - Quận 7',
    zoneName: 'Zone B',
    orderCodes: ['SO-001237', 'SO-001238'],
    totalItems: 18,
    pickedItems: 0,
    totalLocations: 12,
    visitedLocations: 0,
    assignedTo: 'Trần Thị B',
    status: 'assigned',
    createdDate: new Date('2024-12-15T09:15:00'),
    estimatedTime: 28
  },
  {
    id: 3,
    taskNumber: 'PK2412150003',
    priority: 'normal',
    warehouseName: 'Kho Đà Nẵng - Hải Châu',
    zoneName: 'Zone C',
    orderCodes: ['SO-001239'],
    totalItems: 12,
    pickedItems: 12,
    totalLocations: 8,
    visitedLocations: 8,
    assignedTo: 'Lê Văn C',
    status: 'completed',
    createdDate: new Date('2024-12-15T07:45:00'),
    estimatedTime: 20
  },
  {
    id: 4,
    taskNumber: 'PK2412150004',
    priority: 'low',
    warehouseName: 'Kho Hà Nội - Cầu Giấy',
    zoneName: 'Zone D',
    orderCodes: ['SO-001240', 'SO-001241', 'SO-001242', 'SO-001243'],
    totalItems: 42,
    pickedItems: 0,
    totalLocations: 25,
    visitedLocations: 0,
    assignedTo: null,
    status: 'created',
    createdDate: new Date('2024-12-15T10:20:00'),
    estimatedTime: 65
  }
])

// Methods
const formatDate = (date: Date) => {
  return date.toLocaleDateString('vi-VN')
}

const getPriorityTagType = (priority: string) => {
  const priorityMap: Record<string, string> = {
    low: 'info',
    normal: '',
    high: 'warning',
    urgent: 'danger'
  }
  return priorityMap[priority] || ''
}

const getPriorityText = (priority: string) => {
  const priorityMap: Record<string, string> = {
    low: 'Thấp',
    normal: 'Bình thường',
    high: 'Cao',
    urgent: 'Khẩn cấp'
  }
  return priorityMap[priority] || priority
}

const getStatusTagType = (status: string) => {
  const statusMap: Record<string, string> = {
    created: 'info',
    assigned: 'warning',
    in_progress: 'primary',
    completed: 'success',
    cancelled: 'danger'
  }
  return statusMap[status] || ''
}

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    created: 'Đã tạo',
    assigned: 'Đã giao',
    in_progress: 'Đang thực hiện',
    completed: 'Hoàn thành',
    cancelled: 'Đã hủy'
  }
  return statusMap[status] || status
}

const getItemStatusTagType = (status: string) => {
  const statusMap: Record<string, string> = {
    pending: 'info',
    picking: 'warning',
    picked: 'success',
    short: 'danger'
  }
  return statusMap[status] || ''
}

const getItemStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    pending: 'Chờ pick',
    picking: 'Đang pick',
    picked: 'Đã pick',
    short: 'Thiếu hàng'
  }
  return statusMap[status] || status
}

const getProgressClass = (row: any) => {
  const progress = row.pickedItems / row.totalItems
  if (progress === 1) return 'progress-complete'
  if (progress >= 0.8) return 'progress-high'
  if (progress >= 0.5) return 'progress-medium'
  return 'progress-low'
}

// Kanban methods
const getTasksByStatus = (status: string) => {
  return pickingTasks.value.filter(task => task.status === status)
}

const getTaskCountByStatus = (status: string) => {
  return getTasksByStatus(status).length
}

// Action methods
const canAssign = (row: any) => {
  return row.status === 'created'
}

const canStart = (row: any) => {
  return row.status === 'assigned'
}

const canComplete = (row: any) => {
  return row.status === 'in_progress'
}

const canCancel = (row: any) => {
  return ['created', 'assigned'].includes(row.status)
}

const createPickingTask = () => {
  ElMessage.info('Chuyển đến trang tạo nhiệm vụ picking')
}

const optimizeRoutes = () => {
  ElMessage.info('Tối ưu lộ trình picking')
}

const viewTaskDetail = (row: any) => {
  taskDetailDialog.task = row
  taskDetailDialog.visible = true
}

const assignTask = (row: any) => {
  ElMessage.info(`Giao nhiệm vụ: ${row.taskNumber}`)
}

const startTask = (row: any) => {
  ElMessage.info(`Bắt đầu nhiệm vụ: ${row.taskNumber}`)
  row.status = 'in_progress'
}

const completeTask = (row: any) => {
  ElMessageBox.confirm(
    `Bạn có chắc chắn muốn hoàn thành nhiệm vụ ${row.taskNumber}?`,
    'Hoàn thành nhiệm vụ',
    {
      confirmButtonText: 'Hoàn thành',
      cancelButtonText: 'Hủy',
      type: 'success'
    }
  ).then(() => {
    row.status = 'completed'
    row.pickedItems = row.totalItems
    ElMessage.success('Nhiệm vụ đã được hoàn thành')
  })
}

const cancelTask = (row: any) => {
  ElMessageBox.confirm(
    `Bạn có chắc chắn muốn hủy nhiệm vụ ${row.taskNumber}?`,
    'Hủy nhiệm vụ',
    {
      confirmButtonText: 'Hủy nhiệm vụ',
      cancelButtonText: 'Không',
      type: 'error'
    }
  ).then(() => {
    row.status = 'cancelled'
    ElMessage.success('Nhiệm vụ đã được hủy')
  })
}

const printPickingList = (row: any) => {
  ElMessage.info(`In danh sách picking: ${row.taskNumber}`)
}

const viewRouteMap = (row: any) => {
  ElMessage.info(`Xem bản đồ lộ trình: ${row.taskNumber}`)
}

const handleSelectionChange = (selection: any[]) => {
  selectedTasks.value = selection
}

const bulkAssign = () => {
  ElMessage.info(`Giao việc hàng loạt cho ${selectedTasks.value.length} nhiệm vụ`)
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
    status: '',
    priority: '',
    warehouse: null,
    picker: null,
    search: ''
  })
}

const exportTasks = () => {
  ElMessage.success('Đang xuất dữ liệu Excel...')
}

const handleSizeChange = (size: number) => {
  pagination.pageSize = size
}

const handleCurrentChange = (page: number) => {
  pagination.currentPage = page
}

onMounted(() => {
  pagination.total = pickingTasks.value.length
})
</script>

<style scoped>
.picking-tasks {
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

/* Performance Section */
.performance-section {
  margin-bottom: 20px;
}

.performance-card {
  border: none;
  transition: all 0.3s ease;
}

.performance-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.performance-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.performance-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.bg-blue { background: linear-gradient(135deg, #409EFF 0%, #337ecc 100%); }
.bg-green { background: linear-gradient(135deg, #67C23A 0%, #529b2e 100%); }
.bg-orange { background: linear-gradient(135deg, #E6A23C 0%, #b88230 100%); }
.bg-purple { background: linear-gradient(135deg, #9C27B0 0%, #7B1FA2 100%); }

.performance-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.performance-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}

.performance-label {
  color: #606266;
  font-size: 14px;
  font-weight: 500;
}

.performance-sublabel {
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
  gap: 12px;
  align-items: center;
}

/* Table Content */
.order-codes {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
}

.order-tag {
  font-size: 11px;
}

.more-orders {
  font-size: 12px;
  color: #909399;
}

.picker-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.picker-avatar {
  background-color: #409EFF;
}

.picker-name {
  font-size: 13px;
  color: #303133;
}

.text-muted {
  color: #C0C4CC;
}

.progress-complete { color: #67C23A; font-weight: 600; }
.progress-high { color: #409EFF; font-weight: 600; }
.progress-medium { color: #E6A23C; font-weight: 600; }
.progress-low { color: #F56C6C; font-weight: 600; }

.action-buttons {
  display: flex;
  gap: 4px;
}

/* Kanban View */
.kanban-view {
  min-height: 600px;
}

.kanban-columns {
  display: flex;
  gap: 20px;
  overflow-x: auto;
  padding-bottom: 10px;
}

.kanban-column {
  flex: 1;
  min-width: 280px;
  background-color: #f5f7fa;
  border-radius: 8px;
  padding: 16px;
}

.kanban-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.kanban-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.kanban-badge {
  margin-left: 8px;
}

.kanban-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 500px;
  overflow-y: auto;
}

.kanban-card {
  background: white;
  border-radius: 8px;
  padding: 16px;
  border: 1px solid #e4e7ed;
  cursor: pointer;
  transition: all 0.2s ease;
}

.kanban-card:hover {
  border-color: #409EFF;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.task-number {
  font-weight: 600;
  color: #303133;
}

.card-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.task-info {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #606266;
}

.task-progress span {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.task-picker {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #606266;
}

/* Task Detail */
.task-detail {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.task-info-section {
  margin-bottom: 20px;
}

.task-details, .progress-details {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.detail-row, .progress-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.detail-row:last-child,
.progress-item:last-child {
  border-bottom: none;
}

.detail-row label,
.progress-item label {
  font-weight: 500;
  color: #606266;
  width: 120px;
}

.progress-value {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* Pagination */
.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .performance-section .el-col {
    margin-bottom: 12px;
  }

  .kanban-columns {
    flex-direction: column;
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

  .performance-content {
    gap: 12px;
  }

  .performance-icon {
    width: 48px;
    height: 48px;
  }

  .performance-value {
    font-size: 20px;
  }

  .kanban-column {
    min-width: 100%;
  }
}
</style>

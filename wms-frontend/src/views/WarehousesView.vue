<template>
  <div class="warehouses-page">
    <!-- Header Section -->
    <div class="page-header">
      <div class="header-content">
        <div class="title-section">
          <h1 class="page-title">Quản lý Kho</h1>
          <p class="page-description">Quản lý thông tin kho, capacity và cấu hình</p>
        </div>
        <div class="header-actions">
          <el-button type="primary" @click="showCreateDialog = true">
            <el-icon><Plus /></el-icon>
            Thêm Kho Mới
          </el-button>
          <el-button @click="exportData">
            <el-icon><Download /></el-icon>
            Xuất dữ liệu
          </el-button>
        </div>
      </div>
    </div>

    <!-- Filters Section -->
    <div class="filters-section">
      <el-card>
        <div class="filters-row">
          <div class="filter-item">
            <label>Tìm kiếm:</label>
            <el-input
              v-model="searchText"
              placeholder="Tên kho, mã kho..."
              style="width: 200px"
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>
          <div class="filter-item">
            <label>Trạng thái:</label>
            <el-select v-model="filterStatus" placeholder="Chọn trạng thái" style="width: 150px">
              <el-option label="Tất cả" value="" />
              <el-option label="Hoạt động" value="active" />
              <el-option label="Tạm dừng" value="inactive" />
              <el-option label="Bảo trì" value="maintenance" />
            </el-select>
          </div>
          <div class="filter-item">
            <label>Loại kho:</label>
            <el-select v-model="filterType" placeholder="Chọn loại" style="width: 150px">
              <el-option label="Tất cả" value="" />
              <el-option label="Kho thành phẩm" value="finished_goods" />
              <el-option label="Kho nguyên liệu" value="raw_materials" />
              <el-option label="Kho phụ tùng" value="spare_parts" />
              <el-option label="Kho lạnh" value="cold_storage" />
            </el-select>
          </div>
          <el-button type="primary" @click="applyFilters">
            <el-icon><Search /></el-icon>
            Lọc
          </el-button>
          <el-button @click="resetFilters">
            <el-icon><RefreshLeft /></el-icon>
            Đặt lại
          </el-button>
        </div>
      </el-card>
    </div>

    <!-- Statistics Cards -->
    <div class="stats-cards">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <el-icon color="#409EFF"><OfficeBuilding /></el-icon>
              </div>
              <div class="stat-details">
                <div class="stat-value">{{ statistics.totalWarehouses }}</div>
                <div class="stat-label">Tổng số kho</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <el-icon color="#67C23A"><CircleCheck /></el-icon>
              </div>
              <div class="stat-details">
                <div class="stat-value">{{ statistics.activeWarehouses }}</div>
                <div class="stat-label">Kho hoạt động</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <el-icon color="#E6A23C"><TakeawayBox /></el-icon>
              </div>
              <div class="stat-details">
                <div class="stat-value">{{ statistics.totalCapacity }}</div>
                <div class="stat-label">Tổng capacity (m³)</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <el-icon color="#F56C6C"><PieChart /></el-icon>
              </div>
              <div class="stat-details">
                <div class="stat-value">{{ statistics.averageUtilization }}%</div>
                <div class="stat-label">Tỷ lệ sử dụng TB</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- Warehouses Table -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>Danh sách Kho</span>
          <div class="table-actions">
            <el-button-group>
              <el-button :type="viewMode === 'table' ? 'primary' : ''" @click="viewMode = 'table'">
                <el-icon><List /></el-icon>
              </el-button>
              <el-button :type="viewMode === 'grid' ? 'primary' : ''" @click="viewMode = 'grid'">
                <el-icon><Grid /></el-icon>
              </el-button>
            </el-button-group>
          </div>
        </div>
      </template>

      <!-- Table View -->
      <div v-if="viewMode === 'table'">
        <el-table
          :data="filteredWarehouses"
          v-loading="loading"
          height="500"
          @sort-change="handleSort"
        >
          <el-table-column prop="code" label="Mã Kho" width="120" sortable="custom" />
          <el-table-column prop="name" label="Tên Kho" min-width="200" sortable="custom" />
          <el-table-column prop="type" label="Loại Kho" width="140">
            <template #default="{ row }">
              <el-tag :type="getTypeTagType(row.type)">{{ getTypeLabel(row.type) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="address" label="Địa chỉ" min-width="250" show-overflow-tooltip />
          <el-table-column prop="capacity" label="Capacity" width="120" sortable="custom">
            <template #default="{ row }">
              {{ formatNumber(row.capacity) }} m³
            </template>
          </el-table-column>
          <el-table-column prop="utilization" label="Sử dụng" width="140" sortable="custom">
            <template #default="{ row }">
              <div class="utilization-cell">
                <el-progress
                  :percentage="row.utilization"
                  :color="getUtilizationColor(row.utilization)"
                  :stroke-width="6"
                  :show-text="false"
                />
                <span class="utilization-text">{{ row.utilization }}%</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="Trạng thái" width="120">
            <template #default="{ row }">
              <el-tag :type="getStatusTagType(row.status)">{{ getStatusLabel(row.status) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="manager" label="Quản lý" width="150" />
          <el-table-column label="Thao tác" width="200" fixed="right">
            <template #default="{ row }">
              <el-button-group>
                <el-button size="small" @click="viewWarehouse(row)">
                  <el-icon><View /></el-icon>
                </el-button>
                <el-button size="small" type="primary" @click="editWarehouse(row)">
                  <el-icon><Edit /></el-icon>
                </el-button>
                <el-button size="small" type="warning" @click="configWarehouse(row)">
                  <el-icon><Setting /></el-icon>
                </el-button>
                <el-button size="small" type="danger" @click="deleteWarehouse(row)">
                  <el-icon><Delete /></el-icon>
                </el-button>
              </el-button-group>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- Grid View -->
      <div v-else class="grid-view">
        <el-row :gutter="20">
          <el-col :span="8" v-for="warehouse in filteredWarehouses" :key="warehouse.id">
            <el-card class="warehouse-card" @click="viewWarehouse(warehouse)">
              <template #header>
                <div class="warehouse-header">
                  <div class="warehouse-title">
                    <h3>{{ warehouse.name }}</h3>
                    <span class="warehouse-code">{{ warehouse.code }}</span>
                  </div>
                  <el-tag :type="getStatusTagType(warehouse.status)">
                    {{ getStatusLabel(warehouse.status) }}
                  </el-tag>
                </div>
              </template>

              <div class="warehouse-info">
                <div class="info-item">
                  <span class="info-label">Loại:</span>
                  <el-tag :type="getTypeTagType(warehouse.type)" size="small">
                    {{ getTypeLabel(warehouse.type) }}
                  </el-tag>
                </div>
                <div class="info-item">
                  <span class="info-label">Capacity:</span>
                  <span>{{ formatNumber(warehouse.capacity) }} m³</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Sử dụng:</span>
                  <div class="utilization-info">
                    <el-progress
                      :percentage="warehouse.utilization"
                      :color="getUtilizationColor(warehouse.utilization)"
                      :stroke-width="4"
                      :show-text="false"
                    />
                    <span>{{ warehouse.utilization }}%</span>
                  </div>
                </div>
                <div class="info-item">
                  <span class="info-label">Quản lý:</span>
                  <span>{{ warehouse.manager }}</span>
                </div>
                <div class="info-item full-width">
                  <span class="info-label">Địa chỉ:</span>
                  <span class="address-text">{{ warehouse.address }}</span>
                </div>
              </div>

              <template #footer>
                <div class="warehouse-actions">
                  <el-button size="small" @click.stop="editWarehouse(warehouse)">
                    <el-icon><Edit /></el-icon>
                    Sửa
                  </el-button>
                  <el-button size="small" type="primary" @click.stop="configWarehouse(warehouse)">
                    <el-icon><Setting /></el-icon>
                    Cấu hình
                  </el-button>
                </div>
              </template>
            </el-card>
          </el-col>
        </el-row>
      </div>

      <!-- Pagination -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="totalWarehouses"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- Create/Edit Dialog -->
    <el-dialog
      v-model="showCreateDialog"
      :title="editingWarehouse ? 'Sửa Kho' : 'Thêm Kho Mới'"
      width="700px"
      @close="resetForm"
    >
      <el-form
        ref="warehouseFormRef"
        :model="warehouseForm"
        :rules="formRules"
        label-width="120px"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Mã Kho" prop="code">
              <el-input v-model="warehouseForm.code" placeholder="VD: WH001" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Tên Kho" prop="name">
              <el-input v-model="warehouseForm.name" placeholder="Tên kho" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Loại Kho" prop="type">
              <el-select v-model="warehouseForm.type" placeholder="Chọn loại kho">
                <el-option label="Kho thành phẩm" value="finished_goods" />
                <el-option label="Kho nguyên liệu" value="raw_materials" />
                <el-option label="Kho phụ tùng" value="spare_parts" />
                <el-option label="Kho lạnh" value="cold_storage" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Trạng thái" prop="status">
              <el-select v-model="warehouseForm.status" placeholder="Chọn trạng thái">
                <el-option label="Hoạt động" value="active" />
                <el-option label="Tạm dừng" value="inactive" />
                <el-option label="Bảo trì" value="maintenance" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="Địa chỉ" prop="address">
          <el-input v-model="warehouseForm.address" type="textarea" :rows="2" />
        </el-form-item>

        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="Capacity (m³)" prop="capacity">
              <el-input-number
                v-model="warehouseForm.capacity"
                :min="0"
                :precision="2"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="Nhiệt độ min (°C)">
              <el-input-number
                v-model="warehouseForm.min_temperature"
                :precision="1"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="Nhiệt độ max (°C)">
              <el-input-number
                v-model="warehouseForm.max_temperature"
                :precision="1"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="Độ ẩm min (%)">
              <el-input-number
                v-model="warehouseForm.min_humidity"
                :min="0"
                :max="100"
                :precision="1"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="Độ ẩm max (%)">
              <el-input-number
                v-model="warehouseForm.max_humidity"
                :min="0"
                :max="100"
                :precision="1"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="Số tầng">
              <el-input-number
                v-model="warehouseForm.floors"
                :min="1"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="Quản lý" prop="manager">
          <el-select v-model="warehouseForm.manager" placeholder="Chọn người quản lý" filterable>
            <el-option
              v-for="manager in managers"
              :key="manager.id"
              :label="manager.name"
              :value="manager.name"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="Ghi chú">
          <el-input v-model="warehouseForm.notes" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showCreateDialog = false">Hủy</el-button>
          <el-button type="primary" @click="saveWarehouse" :loading="saving">
            {{ editingWarehouse ? 'Cập nhật' : 'Thêm mới' }}
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Plus, Download, Search, RefreshLeft, OfficeBuilding, CircleCheck,
  TakeawayBox, PieChart, List, Grid, View, Edit, Setting, Delete
} from '@element-plus/icons-vue'

// Reactive data
const loading = ref(false)
const saving = ref(false)
const searchText = ref('')
const filterStatus = ref('')
const filterType = ref('')
const viewMode = ref('table')
const currentPage = ref(1)
const pageSize = ref(20)
const showCreateDialog = ref(false)
const editingWarehouse = ref<any>(null)

// Form data
const warehouseForm = reactive({
  code: '',
  name: '',
  type: '',
  address: '',
  capacity: 0,
  min_temperature: null,
  max_temperature: null,
  min_humidity: null,
  max_humidity: null,
  floors: 1,
  status: 'active',
  manager: '',
  notes: ''
})

// Sample data
const warehouses = ref([
  {
    id: 1,
    code: 'WH001',
    name: 'Kho Thành Phẩm Hà Nội',
    type: 'finished_goods',
    address: '123 Đường ABC, Quận Cầu Giấy, Hà Nội',
    capacity: 5000,
    utilization: 78,
    status: 'active',
    manager: 'Nguyễn Văn A',
    min_temperature: 15,
    max_temperature: 25,
    min_humidity: 40,
    max_humidity: 70,
    floors: 3,
    created_at: '2024-01-15'
  },
  {
    id: 2,
    code: 'WH002',
    name: 'Kho Nguyên Liệu TP.HCM',
    type: 'raw_materials',
    address: '456 Đường DEF, Quận 7, TP.HCM',
    capacity: 8000,
    utilization: 65,
    status: 'active',
    manager: 'Trần Thị B',
    min_temperature: 10,
    max_temperature: 30,
    min_humidity: 30,
    max_humidity: 80,
    floors: 4,
    created_at: '2024-02-01'
  },
  {
    id: 3,
    code: 'WH003',
    name: 'Kho Lạnh Đà Nẵng',
    type: 'cold_storage',
    address: '789 Đường GHI, Quận Hải Châu, Đà Nẵng',
    capacity: 3000,
    utilization: 89,
    status: 'active',
    manager: 'Lê Văn C',
    min_temperature: -20,
    max_temperature: 5,
    min_humidity: 50,
    max_humidity: 90,
    floors: 2,
    created_at: '2024-01-20'
  },
  {
    id: 4,
    code: 'WH004',
    name: 'Kho Phụ Tùng Hà Nội',
    type: 'spare_parts',
    address: '321 Đường JKL, Quận Long Biên, Hà Nội',
    capacity: 2500,
    utilization: 45,
    status: 'maintenance',
    manager: 'Phạm Thị D',
    min_temperature: 20,
    max_temperature: 25,
    min_humidity: 40,
    max_humidity: 60,
    floors: 2,
    created_at: '2024-03-10'
  },
  {
    id: 5,
    code: 'WH005',
    name: 'Kho Tự Động Bình Dương',
    type: 'finished_goods',
    address: '654 Đường MNO, Thành phố Thủ Dầu Một, Bình Dương',
    capacity: 12000,
    utilization: 92,
    status: 'active',
    manager: 'Hoàng Văn E',
    min_temperature: 18,
    max_temperature: 22,
    min_humidity: 45,
    max_humidity: 65,
    floors: 5,
    created_at: '2024-01-05'
  }
])

const managers = ref([
  { id: 1, name: 'Nguyễn Văn A' },
  { id: 2, name: 'Trần Thị B' },
  { id: 3, name: 'Lê Văn C' },
  { id: 4, name: 'Phạm Thị D' },
  { id: 5, name: 'Hoàng Văn E' },
  { id: 6, name: 'Vũ Thị F' }
])

// Statistics
const statistics = computed(() => ({
  totalWarehouses: warehouses.value.length,
  activeWarehouses: warehouses.value.filter(w => w.status === 'active').length,
  totalCapacity: warehouses.value.reduce((sum, w) => sum + w.capacity, 0),
  averageUtilization: Math.round(
    warehouses.value.reduce((sum, w) => sum + w.utilization, 0) / warehouses.value.length
  )
}))

// Computed properties
const filteredWarehouses = computed(() => {
  let filtered = warehouses.value

  if (searchText.value) {
    const search = searchText.value.toLowerCase()
    filtered = filtered.filter(w =>
      w.name.toLowerCase().includes(search) ||
      w.code.toLowerCase().includes(search) ||
      w.address.toLowerCase().includes(search)
    )
  }

  if (filterStatus.value) {
    filtered = filtered.filter(w => w.status === filterStatus.value)
  }

  if (filterType.value) {
    filtered = filtered.filter(w => w.type === filterType.value)
  }

  return filtered
})

const totalWarehouses = computed(() => filteredWarehouses.value.length)

// Form validation rules
const formRules = {
  code: [
    { required: true, message: 'Vui lòng nhập mã kho', trigger: 'blur' }
  ],
  name: [
    { required: true, message: 'Vui lòng nhập tên kho', trigger: 'blur' }
  ],
  type: [
    { required: true, message: 'Vui lòng chọn loại kho', trigger: 'change' }
  ],
  address: [
    { required: true, message: 'Vui lòng nhập địa chỉ', trigger: 'blur' }
  ],
  capacity: [
    { required: true, message: 'Vui lòng nhập capacity', trigger: 'blur' },
    { type: 'number', min: 1, message: 'Capacity phải lớn hơn 0', trigger: 'blur' }
  ],
  manager: [
    { required: true, message: 'Vui lòng chọn người quản lý', trigger: 'change' }
  ]
}

// Methods
const getTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    finished_goods: 'Thành phẩm',
    raw_materials: 'Nguyên liệu',
    spare_parts: 'Phụ tùng',
    cold_storage: 'Kho lạnh'
  }
  return labels[type] || type
}

const getTypeTagType = (type: string) => {
  const types: Record<string, string> = {
    finished_goods: '',
    raw_materials: 'success',
    spare_parts: 'warning',
    cold_storage: 'info'
  }
  return types[type] || ''
}

const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    active: 'Hoạt động',
    inactive: 'Tạm dừng',
    maintenance: 'Bảo trì'
  }
  return labels[status] || status
}

const getStatusTagType = (status: string) => {
  const types: Record<string, string> = {
    active: 'success',
    inactive: 'info',
    maintenance: 'warning'
  }
  return types[status] || ''
}

const getUtilizationColor = (utilization: number) => {
  if (utilization >= 90) return '#F56C6C'
  if (utilization >= 70) return '#E6A23C'
  return '#67C23A'
}

const formatNumber = (num: number) => {
  return new Intl.NumberFormat('vi-VN').format(num)
}

const applyFilters = () => {
  currentPage.value = 1
}

const resetFilters = () => {
  searchText.value = ''
  filterStatus.value = ''
  filterType.value = ''
  currentPage.value = 1
}

const handleSort = (sort: any) => {
  console.log('Sort:', sort)
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
}

const handleCurrentChange = (page: number) => {
  currentPage.value = page
}

const viewWarehouse = (warehouse: any) => {
  ElMessage.info(`Xem chi tiết kho: ${warehouse.name}`)
}

const editWarehouse = (warehouse: any) => {
  editingWarehouse.value = warehouse
  Object.assign(warehouseForm, warehouse)
  showCreateDialog.value = true
}

const configWarehouse = (warehouse: any) => {
  ElMessage.info(`Cấu hình kho: ${warehouse.name}`)
}

const deleteWarehouse = async (warehouse: any) => {
  try {
    await ElMessageBox.confirm(
      `Bạn có chắc chắn muốn xóa kho "${warehouse.name}" không?`,
      'Xác nhận xóa',
      {
        confirmButtonText: 'Xóa',
        cancelButtonText: 'Hủy',
        type: 'warning'
      }
    )

    const index = warehouses.value.findIndex(w => w.id === warehouse.id)
    if (index > -1) {
      warehouses.value.splice(index, 1)
      ElMessage.success('Xóa kho thành công')
    }
  } catch {
    ElMessage.info('Đã hủy xóa')
  }
}

const saveWarehouse = async () => {
  const formRef = document.querySelector('el-form') as any
  if (!formRef) return

  try {
    await formRef.validate()
    saving.value = true

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))

    if (editingWarehouse.value) {
      // Update existing warehouse
      const index = warehouses.value.findIndex(w => w.id === editingWarehouse.value.id)
      if (index > -1) {
        warehouses.value[index] = { ...editingWarehouse.value, ...warehouseForm }
      }
      ElMessage.success('Cập nhật kho thành công')
    } else {
      // Add new warehouse
      const newWarehouse = {
        id: Date.now(),
        ...warehouseForm,
        utilization: 0,
        created_at: new Date().toISOString().split('T')[0]
      }
      warehouses.value.push(newWarehouse)
      ElMessage.success('Thêm kho mới thành công')
    }

    showCreateDialog.value = false
    resetForm()
  } catch (error) {
    console.error('Validation failed:', error)
  } finally {
    saving.value = false
  }
}

const resetForm = () => {
  editingWarehouse.value = null
  Object.assign(warehouseForm, {
    code: '',
    name: '',
    type: '',
    address: '',
    capacity: 0,
    min_temperature: null,
    max_temperature: null,
    min_humidity: null,
    max_humidity: null,
    floors: 1,
    status: 'active',
    manager: '',
    notes: ''
  })
}

const exportData = () => {
  ElMessage.success('Đang xuất dữ liệu...')
}

onMounted(() => {
  // Load initial data
})
</script>

<style scoped>
.warehouses-page {
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
}

.stats-cards {
  margin-bottom: 20px;
}

.stat-card {
  height: 100%;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  background: #f0f9ff;
}

.stat-details {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #606266;
}

.table-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.utilization-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.utilization-text {
  font-size: 12px;
  color: #606266;
  min-width: 35px;
}

.grid-view {
  margin-bottom: 20px;
}

.warehouse-card {
  margin-bottom: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.warehouse-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
}

.warehouse-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.warehouse-title h3 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
}

.warehouse-code {
  font-size: 12px;
  color: #909399;
}

.warehouse-info {
  margin: 16px 0;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  font-size: 14px;
}

.info-item.full-width {
  flex-direction: column;
  align-items: flex-start;
  gap: 4px;
}

.info-label {
  color: #606266;
  font-weight: 500;
}

.address-text {
  color: #303133;
  line-height: 1.4;
}

.utilization-info {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  justify-content: flex-end;
}

.warehouse-actions {
  display: flex;
  gap: 8px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .stats-cards .el-col {
    margin-bottom: 12px;
  }
}

@media (max-width: 768px) {
  .warehouses-page {
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

  .grid-view .el-col {
    span: 24;
  }

  .warehouse-actions {
    flex-direction: column;
  }
}
</style>

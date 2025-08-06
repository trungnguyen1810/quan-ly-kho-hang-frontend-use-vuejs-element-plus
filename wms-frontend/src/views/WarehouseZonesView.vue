<template>
  <div class="warehouse-zones-page">
    <!-- Header Section -->
    <div class="page-header">
      <div class="header-content">
        <div class="title-section">
          <h1 class="page-title">Quản lý Khu vực Kho</h1>
          <p class="page-description">Quản lý zones và phân vùng trong kho</p>
        </div>
        <div class="header-actions">
          <el-button type="primary" @click="showCreateDialog = true">
            <el-icon><Plus /></el-icon>
            Thêm Khu vực
          </el-button>
          <el-button @click="importZones">
            <el-icon><Upload /></el-icon>
            Import
          </el-button>
        </div>
      </div>
    </div>

    <!-- Warehouse Selector & Stats -->
    <div class="warehouse-section">
      <el-card>
        <div class="warehouse-selector">
          <div class="selector-item">
            <label>Chọn Kho:</label>
            <el-select v-model="selectedWarehouse" @change="loadZones" style="width: 200px">
              <el-option
                v-for="warehouse in warehouses"
                :key="warehouse.id"
                :label="warehouse.name"
                :value="warehouse.id"
              />
            </el-select>
          </div>
          <div class="warehouse-stats" v-if="selectedWarehouse">
            <div class="stat-item">
              <span class="stat-label">Tổng zones:</span>
              <span class="stat-value">{{ warehouseStats.totalZones }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Đang sử dụng:</span>
              <span class="stat-value">{{ warehouseStats.activeZones }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Capacity:</span>
              <span class="stat-value">{{ formatNumber(warehouseStats.totalCapacity) }} m³</span>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Filters Section -->
    <div class="filters-section">
      <el-card>
        <div class="filters-row">
          <div class="filter-item">
            <label>Tìm kiếm:</label>
            <el-input
              v-model="searchText"
              placeholder="Tên zone, mã zone..."
              style="width: 200px"
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>
          <div class="filter-item">
            <label>Loại zone:</label>
            <el-select v-model="filterType" placeholder="Chọn loại" style="width: 150px">
              <el-option label="Tất cả" value="" />
              <el-option label="Nhập hàng" value="receiving" />
              <el-option label="Lưu trữ" value="storage" />
              <el-option label="Picking" value="picking" />
              <el-option label="Đóng gói" value="packing" />
              <el-option label="Xuất hàng" value="shipping" />
              <el-option label="Kiểm tra" value="qa" />
              <el-option label="Trả hàng" value="returns" />
            </el-select>
          </div>
          <div class="filter-item">
            <label>Trạng thái:</label>
            <el-select v-model="filterStatus" placeholder="Chọn trạng thái" style="width: 120px">
              <el-option label="Tất cả" value="" />
              <el-option label="Hoạt động" value="active" />
              <el-option label="Tạm dừng" value="inactive" />
              <el-option label="Bảo trì" value="maintenance" />
            </el-select>
          </div>
          <el-button type="primary" @click="applyFilters">
            <el-icon><Search /></el-icon>
            Lọc
          </el-button>
        </div>
      </el-card>
    </div>

    <!-- Zone Layout Visualization -->
    <div class="layout-section" v-if="selectedWarehouse">
      <el-card>
        <template #header>
          <div class="card-header">
            <span>Layout Kho</span>
            <div class="layout-actions">
              <el-button size="small" @click="toggleLayoutMode">
                <el-icon><View /></el-icon>
                {{ layoutMode === '2d' ? '3D View' : '2D View' }}
              </el-button>
              <el-button size="small" @click="fullscreenLayout">
                <el-icon><FullScreen /></el-icon>
                Toàn màn hình
              </el-button>
            </div>
          </div>
        </template>

        <div class="layout-container" :class="{ 'layout-3d': layoutMode === '3d' }">
          <div class="layout-grid">
            <div
              v-for="zone in filteredZones"
              :key="zone.id"
              class="zone-item"
              :class="[
                `zone-${zone.type}`,
                `zone-${zone.status}`,
                { 'zone-selected': selectedZone?.id === zone.id }
              ]"
              :style="getZoneStyle(zone)"
              @click="selectZone(zone)"
            >
              <div class="zone-content">
                <div class="zone-header">
                  <span class="zone-code">{{ zone.code }}</span>
                  <el-tag :type="getTypeTagType(zone.type)" size="small">
                    {{ getTypeLabel(zone.type) }}
                  </el-tag>
                </div>
                <div class="zone-name">{{ zone.name }}</div>
                <div class="zone-stats">
                  <div class="zone-utilization">
                    <el-progress
                      :percentage="zone.utilization"
                      :color="getUtilizationColor(zone.utilization)"
                      :stroke-width="4"
                      :show-text="false"
                    />
                    <span class="utilization-text">{{ zone.utilization }}%</span>
                  </div>
                  <div class="zone-capacity">{{ formatNumber(zone.capacity) }} m³</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Zones Table -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>Danh sách Khu vực</span>
          <div class="table-actions">
            <el-button size="small" @click="exportZones">
              <el-icon><Download /></el-icon>
              Xuất dữ liệu
            </el-button>
          </div>
        </div>
      </template>

      <el-table
        :data="paginatedZones"
        v-loading="loading"
        height="400"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="code" label="Mã Zone" width="100" sortable />
        <el-table-column prop="name" label="Tên Zone" min-width="180" sortable />
        <el-table-column prop="type" label="Loại" width="120">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.type)" size="small">
              {{ getTypeLabel(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="capacity" label="Capacity" width="120" sortable>
          <template #default="{ row }">
            {{ formatNumber(row.capacity) }} m³
          </template>
        </el-table-column>
        <el-table-column prop="utilization" label="Sử dụng" width="140" sortable>
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
        <el-table-column prop="temperature_control" label="Kiểm soát nhiệt độ" width="150">
          <template #default="{ row }">
            <el-tag v-if="row.temperature_control" type="info" size="small">
              {{ row.min_temperature }}°C - {{ row.max_temperature }}°C
            </el-tag>
            <span v-else class="text-muted">Không</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="Trạng thái" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">
              {{ getStatusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="Thao tác" width="180" fixed="right">
          <template #default="{ row }">
            <el-button-group>
              <el-button size="small" @click="viewZone(row)">
                <el-icon><View /></el-icon>
              </el-button>
              <el-button size="small" type="primary" @click="editZone(row)">
                <el-icon><Edit /></el-icon>
              </el-button>
              <el-button size="small" type="warning" @click="configZone(row)">
                <el-icon><Setting /></el-icon>
              </el-button>
              <el-button size="small" type="danger" @click="deleteZone(row)">
                <el-icon><Delete /></el-icon>
              </el-button>
            </el-button-group>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50]"
          :total="totalZones"
          layout="total, sizes, prev, pager, next, jumper"
        />
      </div>
    </el-card>

    <!-- Zone Details Panel -->
    <el-drawer
      v-model="showZoneDetails"
      :title="selectedZone?.name || 'Chi tiết Zone'"
      size="400px"
    >
      <div v-if="selectedZone" class="zone-details">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="Mã Zone">{{ selectedZone.code }}</el-descriptions-item>
          <el-descriptions-item label="Tên Zone">{{ selectedZone.name }}</el-descriptions-item>
          <el-descriptions-item label="Loại">
            <el-tag :type="getTypeTagType(selectedZone.type)">
              {{ getTypeLabel(selectedZone.type) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="Trạng thái">
            <el-tag :type="getStatusTagType(selectedZone.status)">
              {{ getStatusLabel(selectedZone.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="Capacity">{{ formatNumber(selectedZone.capacity) }} m³</el-descriptions-item>
          <el-descriptions-item label="Sử dụng">
            <div class="utilization-display">
              <el-progress
                :percentage="selectedZone.utilization"
                :color="getUtilizationColor(selectedZone.utilization)"
              />
            </div>
          </el-descriptions-item>
          <el-descriptions-item label="Vị trí">
            Row {{ selectedZone.row }}, Col {{ selectedZone.col }}
          </el-descriptions-item>
          <el-descriptions-item label="Kích thước">
            {{ selectedZone.width }}m × {{ selectedZone.height }}m
          </el-descriptions-item>
          <el-descriptions-item label="Kiểm soát nhiệt độ">
            <el-tag v-if="selectedZone.temperature_control" type="info">
              {{ selectedZone.min_temperature }}°C - {{ selectedZone.max_temperature }}°C
            </el-tag>
            <span v-else>Không</span>
          </el-descriptions-item>
          <el-descriptions-item label="Ngày tạo">{{ selectedZone.created_at }}</el-descriptions-item>
        </el-descriptions>

        <div class="zone-actions-panel">
          <h4>Thao tác</h4>
          <el-button type="primary" @click="editZone(selectedZone)" block>
            <el-icon><Edit /></el-icon>
            Chỉnh sửa
          </el-button>
          <el-button @click="configZone(selectedZone)" block>
            <el-icon><Setting /></el-icon>
            Cấu hình
          </el-button>
          <el-button type="warning" @click="moveZone(selectedZone)" block>
            <el-icon><Rank /></el-icon>
            Di chuyển
          </el-button>
        </div>
      </div>
    </el-drawer>

    <!-- Create/Edit Dialog -->
    <el-dialog
      v-model="showCreateDialog"
      :title="editingZone ? 'Sửa Khu vực' : 'Thêm Khu vực Mới'"
      width="600px"
      @close="resetForm"
    >
      <el-form
        ref="zoneFormRef"
        :model="zoneForm"
        :rules="formRules"
        label-width="140px"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Mã Zone" prop="code">
              <el-input v-model="zoneForm.code" placeholder="VD: A01" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Tên Zone" prop="name">
              <el-input v-model="zoneForm.name" placeholder="Tên khu vực" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Loại Zone" prop="type">
              <el-select v-model="zoneForm.type" placeholder="Chọn loại">
                <el-option label="Nhập hàng" value="receiving" />
                <el-option label="Lưu trữ" value="storage" />
                <el-option label="Picking" value="picking" />
                <el-option label="Đóng gói" value="packing" />
                <el-option label="Xuất hàng" value="shipping" />
                <el-option label="Kiểm tra" value="qa" />
                <el-option label="Trả hàng" value="returns" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Trạng thái" prop="status">
              <el-select v-model="zoneForm.status" placeholder="Chọn trạng thái">
                <el-option label="Hoạt động" value="active" />
                <el-option label="Tạm dừng" value="inactive" />
                <el-option label="Bảo trì" value="maintenance" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="Vị trí Row" prop="row">
              <el-input-number v-model="zoneForm.row" :min="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="Vị trí Col" prop="col">
              <el-input-number v-model="zoneForm.col" :min="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="Capacity (m³)" prop="capacity">
              <el-input-number v-model="zoneForm.capacity" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Chiều rộng (m)">
              <el-input-number v-model="zoneForm.width" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Chiều cao (m)">
              <el-input-number v-model="zoneForm.height" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item>
          <el-checkbox v-model="zoneForm.temperature_control">Kiểm soát nhiệt độ</el-checkbox>
        </el-form-item>

        <el-row :gutter="20" v-if="zoneForm.temperature_control">
          <el-col :span="12">
            <el-form-item label="Nhiệt độ min (°C)">
              <el-input-number v-model="zoneForm.min_temperature" :precision="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Nhiệt độ max (°C)">
              <el-input-number v-model="zoneForm.max_temperature" :precision="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="Mô tả">
          <el-input v-model="zoneForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showCreateDialog = false">Hủy</el-button>
          <el-button type="primary" @click="saveZone" :loading="saving">
            {{ editingZone ? 'Cập nhật' : 'Thêm mới' }}
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Plus, Upload, Search, View, FullScreen, Download, Edit, Setting,
  Delete, Rank
} from '@element-plus/icons-vue'

// Reactive data
const loading = ref(false)
const saving = ref(false)
const searchText = ref('')
const filterType = ref('')
const filterStatus = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const selectedWarehouse = ref(1)
const selectedZone = ref<any>(null)
const showZoneDetails = ref(false)
const showCreateDialog = ref(false)
const editingZone = ref<any>(null)
const layoutMode = ref('2d')

// Sample data
const warehouses = ref([
  { id: 1, name: 'Kho Thành Phẩm Hà Nội', code: 'WH001' },
  { id: 2, name: 'Kho Nguyên Liệu TP.HCM', code: 'WH002' },
  { id: 3, name: 'Kho Lạnh Đà Nẵng', code: 'WH003' }
])

const zones = ref([
  {
    id: 1,
    warehouse_id: 1,
    code: 'A01',
    name: 'Khu vực nhập hàng A',
    type: 'receiving',
    capacity: 500,
    utilization: 75,
    status: 'active',
    row: 1,
    col: 1,
    width: 10,
    height: 8,
    temperature_control: false,
    min_temperature: null,
    max_temperature: null,
    description: 'Khu vực nhập hàng chính',
    created_at: '2024-01-15'
  },
  {
    id: 2,
    warehouse_id: 1,
    code: 'B01',
    name: 'Khu lưu trữ B1',
    type: 'storage',
    capacity: 1200,
    utilization: 88,
    status: 'active',
    row: 2,
    col: 1,
    width: 15,
    height: 12,
    temperature_control: true,
    min_temperature: 15,
    max_temperature: 25,
    description: 'Khu lưu trữ chính',
    created_at: '2024-01-15'
  },
  {
    id: 3,
    warehouse_id: 1,
    code: 'C01',
    name: 'Khu picking C1',
    type: 'picking',
    capacity: 300,
    utilization: 45,
    status: 'active',
    row: 1,
    col: 2,
    width: 8,
    height: 6,
    temperature_control: false,
    min_temperature: null,
    max_temperature: null,
    description: 'Khu vực picking nhanh',
    created_at: '2024-01-16'
  },
  {
    id: 4,
    warehouse_id: 1,
    code: 'D01',
    name: 'Khu đóng gói D1',
    type: 'packing',
    capacity: 200,
    utilization: 60,
    status: 'active',
    row: 2,
    col: 2,
    width: 6,
    height: 8,
    temperature_control: false,
    min_temperature: null,
    max_temperature: null,
    description: 'Khu vực đóng gói',
    created_at: '2024-01-16'
  },
  {
    id: 5,
    warehouse_id: 1,
    code: 'E01',
    name: 'Khu xuất hàng E1',
    type: 'shipping',
    capacity: 400,
    utilization: 30,
    status: 'active',
    row: 1,
    col: 3,
    width: 12,
    height: 6,
    temperature_control: false,
    min_temperature: null,
    max_temperature: null,
    description: 'Khu vực xuất hàng',
    created_at: '2024-01-17'
  },
  {
    id: 6,
    warehouse_id: 1,
    code: 'QA1',
    name: 'Khu kiểm tra QA1',
    type: 'qa',
    capacity: 150,
    utilization: 20,
    status: 'maintenance',
    row: 2,
    col: 3,
    width: 5,
    height: 4,
    temperature_control: true,
    min_temperature: 18,
    max_temperature: 22,
    description: 'Khu vực kiểm tra chất lượng',
    created_at: '2024-01-18'
  }
])

// Form data
const zoneForm = reactive({
  code: '',
  name: '',
  type: '',
  capacity: 0,
  row: 1,
  col: 1,
  width: 0,
  height: 0,
  status: 'active',
  temperature_control: false,
  min_temperature: null,
  max_temperature: null,
  description: ''
})

// Computed properties
const filteredZones = computed(() => {
  let filtered = zones.value.filter(z => z.warehouse_id === selectedWarehouse.value)

  if (searchText.value) {
    const search = searchText.value.toLowerCase()
    filtered = filtered.filter(z =>
      z.name.toLowerCase().includes(search) ||
      z.code.toLowerCase().includes(search)
    )
  }

  if (filterType.value) {
    filtered = filtered.filter(z => z.type === filterType.value)
  }

  if (filterStatus.value) {
    filtered = filtered.filter(z => z.status === filterStatus.value)
  }

  return filtered
})

const paginatedZones = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredZones.value.slice(start, end)
})

const totalZones = computed(() => filteredZones.value.length)

const warehouseStats = computed(() => {
  const warehouseZones = zones.value.filter(z => z.warehouse_id === selectedWarehouse.value)
  return {
    totalZones: warehouseZones.length,
    activeZones: warehouseZones.filter(z => z.status === 'active').length,
    totalCapacity: warehouseZones.reduce((sum, z) => sum + z.capacity, 0)
  }
})

// Form validation rules
const formRules = {
  code: [
    { required: true, message: 'Vui lòng nhập mã zone', trigger: 'blur' }
  ],
  name: [
    { required: true, message: 'Vui lòng nhập tên zone', trigger: 'blur' }
  ],
  type: [
    { required: true, message: 'Vui lòng chọn loại zone', trigger: 'change' }
  ],
  capacity: [
    { required: true, message: 'Vui lòng nhập capacity', trigger: 'blur' },
    { type: 'number', min: 1, message: 'Capacity phải lớn hơn 0', trigger: 'blur' }
  ]
}

// Methods
const getTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    receiving: 'Nhập hàng',
    storage: 'Lưu trữ',
    picking: 'Picking',
    packing: 'Đóng gói',
    shipping: 'Xuất hàng',
    qa: 'Kiểm tra',
    returns: 'Trả hàng'
  }
  return labels[type] || type
}

const getTypeTagType = (type: string) => {
  const types: Record<string, string> = {
    receiving: 'success',
    storage: '',
    picking: 'warning',
    packing: 'info',
    shipping: 'success',
    qa: 'danger',
    returns: 'warning'
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

const getZoneStyle = (zone: any) => {
  const baseStyle = {
    gridRow: `${zone.row} / span 1`,
    gridColumn: `${zone.col} / span 1`,
    minHeight: '120px',
    aspectRatio: `${zone.width} / ${zone.height}`
  }

  if (layoutMode.value === '3d') {
    return {
      ...baseStyle,
      transform: 'perspective(1000px) rotateX(30deg)',
      transformOrigin: 'center bottom'
    }
  }

  return baseStyle
}

const formatNumber = (num: number) => {
  return new Intl.NumberFormat('vi-VN').format(num)
}

const loadZones = () => {
  loading.value = true
  // Simulate API call
  setTimeout(() => {
    loading.value = false
  }, 500)
}

const applyFilters = () => {
  currentPage.value = 1
}

const selectZone = (zone: any) => {
  selectedZone.value = zone
  showZoneDetails.value = true
}

const toggleLayoutMode = () => {
  layoutMode.value = layoutMode.value === '2d' ? '3d' : '2d'
}

const fullscreenLayout = () => {
  ElMessage.info('Chức năng toàn màn hình đang phát triển')
}

const viewZone = (zone: any) => {
  selectedZone.value = zone
  showZoneDetails.value = true
}

const editZone = (zone: any) => {
  editingZone.value = zone
  Object.assign(zoneForm, zone)
  showCreateDialog.value = true
}

const configZone = (zone: any) => {
  ElMessage.info(`Cấu hình zone: ${zone.name}`)
}

const moveZone = (zone: any) => {
  ElMessage.info(`Di chuyển zone: ${zone.name}`)
}

const deleteZone = async (zone: any) => {
  try {
    await ElMessageBox.confirm(
      `Bạn có chắc chắn muốn xóa zone "${zone.name}" không?`,
      'Xác nhận xóa',
      {
        confirmButtonText: 'Xóa',
        cancelButtonText: 'Hủy',
        type: 'warning'
      }
    )

    const index = zones.value.findIndex(z => z.id === zone.id)
    if (index > -1) {
      zones.value.splice(index, 1)
      ElMessage.success('Xóa zone thành công')
    }
  } catch {
    ElMessage.info('Đã hủy xóa')
  }
}

const saveZone = async () => {
  try {
    saving.value = true

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))

    if (editingZone.value) {
      // Update existing zone
      const index = zones.value.findIndex(z => z.id === editingZone.value.id)
      if (index > -1) {
        zones.value[index] = {
          ...editingZone.value,
          ...zoneForm,
          warehouse_id: selectedWarehouse.value
        }
      }
      ElMessage.success('Cập nhật zone thành công')
    } else {
      // Add new zone
      const newZone = {
        id: Date.now(),
        warehouse_id: selectedWarehouse.value,
        ...zoneForm,
        utilization: 0,
        created_at: new Date().toISOString().split('T')[0]
      }
      zones.value.push(newZone)
      ElMessage.success('Thêm zone mới thành công')
    }

    showCreateDialog.value = false
    resetForm()
  } catch (error) {
    console.error('Save failed:', error)
  } finally {
    saving.value = false
  }
}

const resetForm = () => {
  editingZone.value = null
  Object.assign(zoneForm, {
    code: '',
    name: '',
    type: '',
    capacity: 0,
    row: 1,
    col: 1,
    width: 0,
    height: 0,
    status: 'active',
    temperature_control: false,
    min_temperature: null,
    max_temperature: null,
    description: ''
  })
}

const handleSelectionChange = (selection: any[]) => {
  console.log('Selected zones:', selection)
}

const importZones = () => {
  ElMessage.info('Chức năng import đang phát triển')
}

const exportZones = () => {
  ElMessage.success('Đang xuất dữ liệu zones...')
}

// Watch for warehouse changes
watch(selectedWarehouse, () => {
  loadZones()
  selectedZone.value = null
  showZoneDetails.value = false
})

onMounted(() => {
  loadZones()
})
</script>

<style scoped>
.warehouse-zones-page {
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

.warehouse-section {
  margin-bottom: 20px;
}

.warehouse-selector {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.selector-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.selector-item label {
  font-size: 14px;
  color: #606266;
  white-space: nowrap;
}

.warehouse-stats {
  display: flex;
  gap: 30px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.stat-label {
  font-size: 12px;
  color: #909399;
}

.stat-value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
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

.layout-section {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.layout-actions {
  display: flex;
  gap: 8px;
}

.layout-container {
  min-height: 400px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  overflow: auto;
}

.layout-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(3, 1fr);
  gap: 16px;
  min-height: 360px;
}

.zone-item {
  background: white;
  border: 2px solid #e4e7ed;
  border-radius: 8px;
  padding: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.zone-item:hover {
  border-color: #409EFF;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.15);
}

.zone-item.zone-selected {
  border-color: #409EFF;
  background: #ecf5ff;
}

.zone-receiving { border-left: 4px solid #67C23A; }
.zone-storage { border-left: 4px solid #409EFF; }
.zone-picking { border-left: 4px solid #E6A23C; }
.zone-packing { border-left: 4px solid #909399; }
.zone-shipping { border-left: 4px solid #67C23A; }
.zone-qa { border-left: 4px solid #F56C6C; }
.zone-returns { border-left: 4px solid #E6A23C; }

.zone-inactive { opacity: 0.6; }
.zone-maintenance { background: #fdf6ec; }

.zone-content {
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.zone-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.zone-code {
  font-weight: 600;
  color: #303133;
}

.zone-name {
  font-size: 12px;
  color: #606266;
  line-height: 1.3;
  flex: 1;
}

.zone-stats {
  margin-top: auto;
}

.zone-utilization {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 4px;
}

.utilization-text {
  font-size: 10px;
  color: #909399;
}

.zone-capacity {
  font-size: 10px;
  color: #909399;
  text-align: center;
}

.layout-3d .zone-item {
  transform-style: preserve-3d;
}

.table-card {
  margin-bottom: 20px;
}

.utilization-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.utilization-display {
  width: 100%;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.zone-details {
  padding: 0 16px;
}

.zone-actions-panel {
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid #e4e7ed;
}

.zone-actions-panel h4 {
  margin: 0 0 16px 0;
  font-size: 16px;
  color: #303133;
}

.zone-actions-panel .el-button {
  margin-bottom: 8px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.text-muted {
  color: #909399;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .layout-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .warehouse-stats {
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .warehouse-zones-page {
    padding: 12px;
  }

  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .warehouse-selector {
    flex-direction: column;
    align-items: flex-start;
  }

  .warehouse-stats {
    flex-wrap: wrap;
    gap: 16px;
  }

  .filters-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .layout-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .zone-item {
    padding: 8px;
  }

  .layout-actions {
    flex-direction: column;
  }
}
</style>

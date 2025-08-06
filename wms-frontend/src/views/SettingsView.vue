<template>
  <el-card shadow="never">
    <template #header>
      <div class="card-header">
        <span>Cấu hình hệ thống</span>
      </div>
    </template>

    <el-tabs type="border-card">
      <el-tab-pane label="Quản lý kho">
        <div class="action-bar">
          <h3>Danh sách kho</h3>
          <el-button type="primary" :icon="Plus" @click="handleAddWarehouse">Thêm kho mới</el-button>
        </div>
        <el-table :data="warehouseData" stripe highlight-current-row @current-change="handleWarehouseSelect" style="width: 100%">
          <el-table-column prop="code" label="Mã kho" width="150" />
          <el-table-column prop="name" label="Tên kho" width="250" />
          <el-table-column prop="address" label="Địa chỉ" />
          <el-table-column prop="manager" label="Người quản lý" />
          <el-table-column label="Hành động" width="180">
            <template #default="scope">
              <el-button size="small" @click="handleEditWarehouse(scope.row)">Sửa</el-button>
              <el-button size="small" type="danger" @click="handleDeleteWarehouse(scope.row.id)">Xóa</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
      <el-tab-pane label="Quản lý vị trí">
        <el-alert title="Chọn một kho từ bảng trên để xem và quản lý các khu vực (zones) và vị trí (locations) của kho đó." type="info" show-icon :closable="false" />
        <div v-if="selectedWarehouse" class="location-management">
          <h3>Khu vực thuộc: {{ selectedWarehouse.name }}</h3>
          <div class="action-bar">
            <h4>Danh sách khu vực (Zones)</h4>
            <el-button type="success" :icon="Plus" size="small" @click="handleAddZone">Thêm Zone</el-button>
          </div>
          <el-table :data="zoneData" stripe highlight-current-row @current-change="handleZoneSelect" style="width: 100%">
            <el-table-column prop="code" label="Mã Zone" />
            <el-table-column prop="name" label="Tên Zone" />
            <el-table-column prop="zone_type" label="Loại Zone" />
            <el-table-column label="Hành động" width="180">
              <template #default="scope">
                <el-button size="small" @click="handleEditZone(scope.row)">Sửa</el-button>
                <el-button size="small" type="danger" @click="handleDeleteZone(scope.row.id)">Xóa</el-button>
              </template>
            </el-table-column>
          </el-table>

          <div v-if="selectedZone" class="location-management">
            <h4>Vị trí thuộc: {{ selectedZone.name }}</h4>
             <div class="action-bar">
              <h5>Danh sách vị trí (Locations)</h5>
              <el-button type="warning" :icon="Plus" size="small" @click="handleAddLocation">Thêm Location</el-button>
            </div>
            <el-table :data="locationData" stripe style="width: 100%">
              <el-table-column prop="code" label="Mã Vị trí" />
              <el-table-column prop="location_type" label="Loại" />
              <el-table-column prop="barcode" label="Barcode" />
              <el-table-column label="Hành động" width="180">
                <template #default="scope">
                  <el-button size="small" @click="handleEditLocation(scope.row)">Sửa</el-button>
                  <el-button size="small" type="danger" @click="handleDeleteLocation(scope.row.id)">Xóa</el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </div>
      </el-tab-pane>
      <el-tab-pane label="Quản lý người dùng">
        <div class="action-bar">
          <h3>Danh sách người dùng</h3>
          <el-button type="primary" :icon="Plus" @click="handleAddUser">Thêm người dùng</el-button>
        </div>
        <el-table :data="userData" stripe style="width: 100%">
          <el-table-column prop="username" label="Tên đăng nhập" />
          <el-table-column prop="fullName" label="Họ và tên" />
          <el-table-column prop="email" label="Email" />
          <el-table-column prop="role" label="Vai trò" />
           <el-table-column label="Hành động" width="180">
            <template #default="scope">
              <el-button size="small" @click="handleEditUser(scope.row)">Sửa</el-button>
              <el-button size="small" type="danger" @click="handleDeleteUser(scope.row.id)">Xóa</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
      <el-tab-pane label="Cấu hình chung">
         <div class="placeholder">Các cấu hình hệ thống chung sẽ ở đây.</div>
      </el-tab-pane>
    </el-tabs>
  </el-card>

  <!-- Warehouse Dialog -->
  <el-dialog v-model="dialogVisible" :title="isEdit ? 'Sửa thông tin kho' : 'Tạo kho mới'" width="600px">
    <el-form :model="form" label-width="120px">
      <el-form-item label="Mã kho">
        <el-input v-model="form.code" />
      </el-form-item>
      <el-form-item label="Tên kho">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="Địa chỉ">
        <el-input v-model="form.address" type="textarea" />
      </el-form-item>
      <el-form-item label="Người quản lý">
        <el-input v-model="form.manager" />
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="dialogVisible = false">Hủy</el-button>
        <el-button type="primary" @click="handleSubmit">
          {{ isEdit ? 'Cập nhật' : 'Tạo mới' }}
        </el-button>
      </span>
    </template>
  </el-dialog>

  <!-- Zone Dialog -->
  <el-dialog v-model="zoneDialogVisible" :title="isZoneEdit ? 'Sửa khu vực' : 'Tạo khu vực mới'" width="600px">
    <el-form :model="zoneForm" label-width="120px">
      <el-form-item label="Mã Zone">
        <el-input v-model="zoneForm.code" />
      </el-form-item>
      <el-form-item label="Tên Zone">
        <el-input v-model="zoneForm.name" />
      </el-form-item>
      <el-form-item label="Loại Zone">
        <el-select v-model="zoneForm.zone_type" placeholder="Chọn loại khu vực">
          <el-option label="Receiving" value="receiving" />
          <el-option label="Storage" value="storage" />
          <el-option label="Picking" value="picking" />
          <el-option label="Shipping" value="shipping" />
          <el-option label="Quarantine" value="quarantine" />
        </el-select>
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="zoneDialogVisible = false">Hủy</el-button>
        <el-button type="primary" @click="handleZoneSubmit">
          {{ isZoneEdit ? 'Cập nhật' : 'Tạo mới' }}
        </el-button>
      </span>
    </template>
  </el-dialog>

  <!-- Location Dialog -->
  <el-dialog v-model="locationDialogVisible" :title="isLocationEdit ? 'Sửa vị trí' : 'Tạo vị trí mới'" width="600px">
    <el-form :model="locationForm" label-width="120px">
      <el-form-item label="Mã Vị trí">
        <el-input v-model="locationForm.code" />
      </el-form-item>
      <el-form-item label="Loại">
        <el-select v-model="locationForm.location_type" placeholder="Chọn loại vị trí">
          <el-option label="Rack" value="rack" />
          <el-option label="Shelf" value="shelf" />
          <el-option label="Bin" value="bin" />
          <el-option label="Floor" value="floor" />
        </el-select>
      </el-form-item>
      <el-form-item label="Barcode">
        <el-input v-model="locationForm.barcode" />
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="locationDialogVisible = false">Hủy</el-button>
        <el-button type="primary" @click="handleLocationSubmit">
          {{ isLocationEdit ? 'Cập nhật' : 'Tạo mới' }}
        </el-button>
      </span>
    </template>
  </el-dialog>

  <!-- User Dialog -->
  <el-dialog v-model="userDialogVisible" :title="isUserEdit ? 'Sửa người dùng' : 'Tạo người dùng mới'" width="600px">
    <el-form :model="userForm" label-width="120px">
      <el-form-item label="Tên đăng nhập">
        <el-input v-model="userForm.username" />
      </el-form-item>
      <el-form-item label="Họ và tên">
        <el-input v-model="userForm.fullName" />
      </el-form-item>
      <el-form-item label="Email">
        <el-input v-model="userForm.email" />
      </el-form-item>
      <el-form-item label="Vai trò">
        <el-select v-model="userForm.role" placeholder="Chọn vai trò">
          <el-option label="Super Admin" value="Super Admin" />
          <el-option label="Warehouse Manager" value="Warehouse Manager" />
          <el-option label="Inventory Staff" value="Inventory Staff" />
          <el-option label="Viewer" value="Viewer" />
        </el-select>
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="userDialogVisible = false">Hủy</el-button>
        <el-button type="primary" @click="handleUserSubmit">
          {{ isUserEdit ? 'Cập nhật' : 'Tạo mới' }}
        </el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

interface Warehouse {
  id: number;
  code: string;
  name: string;
  address: string;
  manager: string;
}

interface Zone {
  id: number;
  warehouseId: number;
  code: string;
  name: string;
  zone_type: string;
}

const dialogVisible = ref(false)
const isEdit = ref(false)

const form = reactive({
  id: 0,
  code: '',
  name: '',
  address: '',
  manager: '',
})

const warehouseData = ref([
  { id: 1, code: 'WH-HCM', name: 'Kho chính Hồ Chí Minh', address: '123 Đường ABC, Quận 1, TPHCM', manager: 'Nguyễn Văn An' },
  { id: 2, code: 'WH-HN', name: 'Kho Hà Nội', address: '456 Đường XYZ, Quận Cầu Giấy, Hà Nội', manager: 'Trần Thị Bình' },
])

const userData = ref([
  { id: 1, username: 'admin', fullName: 'Quản trị viên', email: 'admin@wms.com', role: 'Super Admin' },
  { id: 2, username: 'manager01', fullName: 'Trần Văn Quản Lý', email: 'manager01@wms.com', role: 'Warehouse Manager' },
])

const allZoneData = ref<Zone[]>([
  { id: 101, warehouseId: 1, code: 'A', name: 'Khu vực nhận hàng', zone_type: 'receiving' },
  { id: 102, warehouseId: 1, code: 'B', name: 'Khu vực lưu trữ', zone_type: 'storage' },
  { id: 201, warehouseId: 2, code: 'R', name: 'Khu vực nhận hàng', zone_type: 'receiving' },
])

const allLocationData = ref([
  { id: 1001, zoneId: 102, code: 'A-01-01', location_type: 'shelf', barcode: 'LOC-A0101' },
  { id: 1002, zoneId: 102, code: 'A-01-02', location_type: 'shelf', barcode: 'LOC-A0102' },
  { id: 2001, zoneId: 201, code: 'R-01', location_type: 'floor', barcode: 'LOC-R01' },
])

const selectedWarehouse = ref<Warehouse | null>(null)
const selectedZone = ref<Zone | null>(null)

const zoneData = computed(() => {
  const currentWarehouse = selectedWarehouse.value
  if (!currentWarehouse) return []
  return allZoneData.value.filter(zone => zone.warehouseId === currentWarehouse.id)
})

const locationData = computed(() => {
  const currentZone = selectedZone.value
  if (!currentZone) return []
  return allLocationData.value.filter(loc => loc.zoneId === currentZone.id)
})

const handleWarehouseSelect = (warehouse: Warehouse | null) => {
  selectedWarehouse.value = warehouse
  selectedZone.value = null // Reset zone selection when warehouse changes
}

const handleZoneSelect = (zone: Zone | null) => {
  selectedZone.value = zone
}

const resetForm = () => {
  form.id = 0
  form.code = ''
  form.name = ''
  form.address = ''
  form.manager = ''
}

const handleAddWarehouse = () => {
  isEdit.value = false
  resetForm()
  dialogVisible.value = true
}

const handleEditWarehouse = (row: any) => {
  isEdit.value = true
  Object.assign(form, row)
  dialogVisible.value = true
}

const handleDeleteWarehouse = (id: number) => {
  ElMessageBox.confirm('Bạn có chắc chắn muốn xóa kho này không?', 'Cảnh báo', {
    confirmButtonText: 'Xóa',
    cancelButtonText: 'Hủy',
    type: 'warning',
  }).then(() => {
    warehouseData.value = warehouseData.value.filter(item => item.id !== id)
    ElMessage({ type: 'success', message: 'Xóa thành công' })
  })
}

const handleSubmit = () => {
  if (isEdit.value) {
    const index = warehouseData.value.findIndex(item => item.id === form.id)
    if (index !== -1) {
      warehouseData.value[index] = { ...form }
    }
  } else {
    form.id = Date.now()
    warehouseData.value.unshift({ ...form })
  }
  dialogVisible.value = false
  ElMessage({ type: 'success', message: isEdit.value ? 'Cập nhật thành công' : 'Tạo mới thành công' })
}

// --- Zone CRUD ---
const zoneDialogVisible = ref(false)
const isZoneEdit = ref(false)
const zoneForm = reactive({
  id: 0,
  warehouseId: 0,
  code: '',
  name: '',
  zone_type: 'storage',
})

const resetZoneForm = () => {
  zoneForm.id = 0
  zoneForm.warehouseId = selectedWarehouse.value?.id || 0
  zoneForm.code = ''
  zoneForm.name = ''
  zoneForm.zone_type = 'storage'
}

const handleAddZone = () => {
  isZoneEdit.value = false
  resetZoneForm()
  zoneDialogVisible.value = true
}

const handleEditZone = (row: any) => {
  isZoneEdit.value = true
  Object.assign(zoneForm, row)
  zoneDialogVisible.value = true
}

const handleDeleteZone = (id: number) => {
  ElMessageBox.confirm('Bạn có chắc chắn muốn xóa khu vực này không?', 'Cảnh báo', {
    confirmButtonText: 'Xóa',
    cancelButtonText: 'Hủy',
    type: 'warning',
  }).then(() => {
    allZoneData.value = allZoneData.value.filter(item => item.id !== id)
    ElMessage({ type: 'success', message: 'Xóa thành công' })
  })
}

const handleZoneSubmit = () => {
  if (isZoneEdit.value) {
    const index = allZoneData.value.findIndex(item => item.id === zoneForm.id)
    if (index !== -1) {
      allZoneData.value[index] = { ...zoneForm }
    }
  } else {
    zoneForm.id = Date.now()
    allZoneData.value.unshift({ ...zoneForm })
  }
  zoneDialogVisible.value = false
  ElMessage({ type: 'success', message: isZoneEdit.value ? 'Cập nhật thành công' : 'Tạo mới thành công' })
}

// --- Location CRUD ---
const locationDialogVisible = ref(false)
const isLocationEdit = ref(false)
const locationForm = reactive({
  id: 0,
  zoneId: 0,
  code: '',
  location_type: 'shelf',
  barcode: '',
})

const resetLocationForm = () => {
  locationForm.id = 0
  locationForm.zoneId = selectedZone.value?.id || 0
  locationForm.code = ''
  locationForm.location_type = 'shelf'
  locationForm.barcode = ''
}

const handleAddLocation = () => {
  isLocationEdit.value = false
  resetLocationForm()
  locationDialogVisible.value = true
}

const handleEditLocation = (row: any) => {
  isLocationEdit.value = true
  Object.assign(locationForm, row)
  locationDialogVisible.value = true
}

const handleDeleteLocation = (id: number) => {
  ElMessageBox.confirm('Bạn có chắc chắn muốn xóa vị trí này không?', 'Cảnh báo', {
    confirmButtonText: 'Xóa',
    cancelButtonText: 'Hủy',
    type: 'warning',
  }).then(() => {
    allLocationData.value = allLocationData.value.filter(item => item.id !== id)
    ElMessage({ type: 'success', message: 'Xóa thành công' })
  })
}

const handleLocationSubmit = () => {
  if (isLocationEdit.value) {
    const index = allLocationData.value.findIndex(item => item.id === locationForm.id)
    if (index !== -1) {
      allLocationData.value[index] = { ...locationForm }
    }
  } else {
    locationForm.id = Date.now()
    allLocationData.value.unshift({ ...locationForm })
  }
  locationDialogVisible.value = false
  ElMessage({ type: 'success', message: isLocationEdit.value ? 'Cập nhật thành công' : 'Tạo mới thành công' })
}

// --- User CRUD ---
const userDialogVisible = ref(false)
const isUserEdit = ref(false)
const userForm = reactive({
  id: 0,
  username: '',
  fullName: '',
  email: '',
  role: 'Inventory Staff',
})

const resetUserForm = () => {
  userForm.id = 0
  userForm.username = ''
  userForm.fullName = ''
  userForm.email = ''
  userForm.role = 'Inventory Staff'
}

const handleAddUser = () => {
  isUserEdit.value = false
  resetUserForm()
  userDialogVisible.value = true
}

const handleEditUser = (row: any) => {
  isUserEdit.value = true
  Object.assign(userForm, row)
  userDialogVisible.value = true
}

const handleDeleteUser = (id: number) => {
  ElMessageBox.confirm('Bạn có chắc chắn muốn xóa người dùng này không?', 'Cảnh báo', {
    confirmButtonText: 'Xóa',
    cancelButtonText: 'Hủy',
    type: 'warning',
  }).then(() => {
    userData.value = userData.value.filter(item => item.id !== id)
    ElMessage({ type: 'success', message: 'Xóa thành công' })
  })
}

const handleUserSubmit = () => {
  if (isUserEdit.value) {
    const index = userData.value.findIndex(item => item.id === userForm.id)
    if (index !== -1) {
      userData.value[index] = { ...userForm }
    }
  } else {
    userForm.id = Date.now()
    userData.value.unshift({ ...userForm })
  }
  userDialogVisible.value = false
  ElMessage({ type: 'success', message: isUserEdit.value ? 'Cập nhật thành công' : 'Tạo mới thành công' })
}
</script>

<style scoped>
.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
.action-bar h3 {
  margin: 0;
}
.placeholder {
  padding: 20px;
  text-align: center;
  color: #909399;
}
.location-management {
  margin-top: 20px;
}
</style>

<template>
  <el-card class="inventory-container" shadow="never">
    <el-tabs v-model="activeTab" @tab-change="handleTabChange">
      <el-tab-pane label="Nhập kho" name="inbound">
        <div class="tab-content">
          <div class="action-bar">
            <h2>Danh sách phiếu nhập kho</h2>
            <el-button type="primary" :icon="Plus" @click="handleAdd">Tạo phiếu nhập</el-button>
          </div>
          <el-table :data="inboundData" stripe style="width: 100%">
            <el-table-column prop="code" label="Mã phiếu" width="180" />
            <el-table-column prop="supplier" label="Nhà cung cấp" width="220" />
            <el-table-column prop="createdDate" label="Ngày tạo" />
            <el-table-column prop="status" label="Trạng thái">
              <template #default="scope">
                <el-tag :type="getStatusType(scope.row.status)">{{ scope.row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="Hành động" width="180">
              <template #default="scope">
                <el-button size="small" @click="handleEdit(scope.row)">Sửa</el-button>
                <el-button size="small" type="danger" @click="handleDelete(scope.row.id)">Xóa</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
      <el-tab-pane label="Xuất kho" name="outbound">
        <div class="tab-content">
          <div class="action-bar">
            <h2>Danh sách phiếu xuất kho</h2>
            <el-button type="primary" :icon="Plus" @click="handleAddOutbound">Tạo phiếu xuất</el-button>
          </div>
          <el-table :data="outboundData" stripe style="width: 100%">
            <el-table-column prop="code" label="Mã phiếu" width="180" />
            <el-table-column prop="customer" label="Khách hàng" width="220" />
            <el-table-column prop="createdDate" label="Ngày tạo" />
            <el-table-column prop="status" label="Trạng thái">
              <template #default="scope">
                <el-tag :type="getStatusType(scope.row.status)">{{ scope.row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="Hành động" width="180">
              <template #default="scope">
                <el-button size="small">Sửa</el-button>
                <el-button size="small" type="danger">Xóa</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
      <el-tab-pane label="Tồn kho" name="stock">
        <div class="tab-content">
          <div class="action-bar">
            <h2>Báo cáo tồn kho</h2>
            <el-button :icon="Download">Xuất Excel</el-button>
          </div>
          <el-table :data="stockData" stripe style="width: 100%">
            <el-table-column prop="sku" label="SKU" width="180" />
            <el-table-column prop="productName" label="Tên sản phẩm" width="250" />
            <el-table-column prop="quantity" label="Số lượng tồn" />
            <el-table-column prop="location" label="Vị trí" />
            <el-table-column prop="status" label="Trạng thái">
               <template #default="scope">
                <el-tag :type="scope.row.status === 'In Stock' ? 'success' : 'warning'">{{ scope.row.status }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
      <el-tab-pane label="Chuyển kho" name="transfer">
        <div class="tab-content">
          <div class="action-bar">
            <h2>Danh sách phiếu chuyển kho</h2>
            <el-button type="primary" :icon="Plus" @click="handleAddTransfer">Tạo phiếu chuyển</el-button>
          </div>
           <el-table :data="transferData" stripe style="width: 100%">
            <el-table-column prop="code" label="Mã phiếu" width="180" />
            <el-table-column prop="from" label="Từ kho" />
            <el-table-column prop="to" label="Đến kho" />
            <el-table-column prop="createdDate" label="Ngày tạo" />
            <el-table-column prop="status" label="Trạng thái">
              <template #default="scope">
                <el-tag :type="getStatusType(scope.row.status)">{{ scope.row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="Hành động" width="180">
              <template #default="scope">
                <el-button size="small">Sửa</el-button>
                <el-button size="small" type="danger">Xóa</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- Inbound Dialog -->
    <el-dialog v-model="inboundDialogVisible" :title="isEdit ? 'Sửa phiếu nhập kho' : 'Tạo phiếu nhập kho'" width="500px">
      <el-form :model="inboundForm" label-width="120px">
        <el-form-item label="Mã phiếu">
          <el-input v-model="inboundForm.code" disabled />
        </el-form-item>
        <el-form-item label="Nhà cung cấp">
          <el-input v-model="inboundForm.supplier" />
        </el-form-item>
        <el-form-item label="Trạng thái">
          <el-select v-model="inboundForm.status" placeholder="Chọn trạng thái">
            <el-option label="Draft" value="Draft" />
            <el-option label="In Progress" value="In Progress" />
            <el-option label="Completed" value="Completed" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="inboundDialogVisible = false">Hủy</el-button>
          <el-button type="primary" @click="handleInboundSubmit">
            {{ isEdit ? 'Cập nhật' : 'Tạo mới' }}
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- Outbound Dialog -->
    <el-dialog v-model="outboundDialogVisible" title="Tạo phiếu xuất kho" width="500px">
      <el-form :model="outboundForm" label-width="120px">
        <el-form-item label="Mã phiếu">
          <el-input v-model="outboundForm.code" disabled />
        </el-form-item>
        <el-form-item label="Khách hàng">
          <el-input v-model="outboundForm.customer" />
        </el-form-item>
        <el-form-item label="Trạng thái">
           <el-select v-model="outboundForm.status" placeholder="Chọn trạng thái">
            <el-option label="Picking" value="Picking" />
            <el-option label="Shipped" value="Shipped" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="outboundDialogVisible = false">Hủy</el-button>
          <el-button type="primary" @click="handleOutboundSubmit">Tạo mới</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- Transfer Dialog -->
    <el-dialog v-model="transferDialogVisible" title="Tạo phiếu chuyển kho" width="500px">
      <el-form :model="transferForm" label-width="120px">
        <el-form-item label="Mã phiếu">
          <el-input v-model="transferForm.code" disabled />
        </el-form-item>
        <el-form-item label="Từ kho">
          <el-input v-model="transferForm.from" />
        </el-form-item>
        <el-form-item label="Đến kho">
          <el-input v-model="transferForm.to" />
        </el-form-item>
        <el-form-item label="Trạng thái">
           <el-select v-model="transferForm.status" placeholder="Chọn trạng thái">
            <el-option label="In Transit" value="In Transit" />
            <el-option label="Completed" value="Completed" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="transferDialogVisible = false">Hủy</el-button>
          <el-button type="primary" @click="handleTransferSubmit">Tạo mới</el-button>
        </span>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup lang="ts">
import { ref, watch, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Plus, Download } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()

const getTabFromRoute = () => {
  const path = route.path
  if (path.includes('inbound')) return 'inbound'
  if (path.includes('outbound')) return 'outbound'
  if (path.includes('stock')) return 'stock'
  if (path.includes('transfer')) return 'transfer'
  return 'inbound' // Default tab
}

const activeTab = ref(getTabFromRoute())

watch(route, () => {
  activeTab.value = getTabFromRoute()
})

const handleTabChange = (tabName: string) => {
  router.push(`/inventory/${tabName}`)
}

// --- Mock Data and CRUD Logic for Inbound Tab ---

const inboundDialogVisible = ref(false)
const isEdit = ref(false)
const inboundForm = reactive({
  id: 0,
  code: '',
  supplier: '',
  status: 'Draft',
  createdDate: new Date().toLocaleDateString('en-CA'),
})

const inboundData = ref([
  { id: 1, code: 'WI2408001', supplier: 'Nhà Cung Cấp A', createdDate: '2024-08-05', status: 'Completed' },
  { id: 2, code: 'WI2408002', supplier: 'Công ty TNHH B', createdDate: '2024-08-04', status: 'In Progress' },
  { id: 3, code: 'WI2408003', supplier: 'Nhà Cung Cấp C', createdDate: '2024-08-03', status: 'Draft' },
])

const outboundData = ref([
  { id: 1, code: 'WO2408001', customer: 'Khách hàng X', createdDate: '2024-08-05', status: 'Shipped' },
  { id: 2, code: 'WO2408002', customer: 'Khách hàng Y', createdDate: '2024-08-04', status: 'Picking' },
])

const stockData = ref([
  { id: 1, sku: 'SKU001', productName: 'Sản phẩm 1', quantity: 150, location: 'A-01-01', status: 'In Stock' },
  { id: 2, sku: 'SKU002', productName: 'Sản phẩm 2', quantity: 20, location: 'B-02-03', status: 'Low Stock' },
  { id: 3, sku: 'SKU003', productName: 'Sản phẩm 3', quantity: 300, location: 'A-01-02', status: 'In Stock' },
])

const transferData = ref([
  { id: 1, code: 'TF2408001', from: 'Kho Chính', to: 'Kho Phụ', createdDate: '2024-08-01', status: 'Completed' },
])

const getStatusType = (status: string) => {
  if (status === 'Completed' || status === 'Shipped') return 'success'
  if (status === 'In Progress' || status === 'Picking') return 'warning'
  return 'info'
}

const resetInboundForm = () => {
  inboundForm.id = 0
  inboundForm.code = `WI${new Date().getFullYear().toString().slice(-2)}${(new Date().getMonth() + 1).toString().padStart(2, '0')}00${inboundData.value.length + 1}`
  inboundForm.supplier = ''
  inboundForm.status = 'Draft'
  inboundForm.createdDate = new Date().toLocaleDateString('en-CA')
}

const handleAdd = () => {
  isEdit.value = false
  resetInboundForm()
  inboundDialogVisible.value = true
}

const handleEdit = (row: any) => {
  isEdit.value = true
  Object.assign(inboundForm, row)
  inboundDialogVisible.value = true
}

const handleDelete = (id: number) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn xóa phiếu nhập này không?',
    'Cảnh báo',
    {
      confirmButtonText: 'Xóa',
      cancelButtonText: 'Hủy',
      type: 'warning',
    }
  ).then(() => {
    inboundData.value = inboundData.value.filter(item => item.id !== id)
    ElMessage({
      type: 'success',
      message: 'Xóa thành công',
    })
  }).catch(() => {
    // Cancelled
  })
}

const handleInboundSubmit = () => {
  if (isEdit.value) {
    const index = inboundData.value.findIndex(item => item.id === inboundForm.id)
    if (index !== -1) {
      inboundData.value[index] = { ...inboundForm }
    }
  } else {
    inboundForm.id = Date.now() // simple id generation
    inboundData.value.unshift({ ...inboundForm })
  }
  inboundDialogVisible.value = false
  ElMessage({
    type: 'success',
    message: isEdit.value ? 'Cập nhật thành công' : 'Tạo mới thành công',
  })
}

// --- Mock Data and CRUD Logic for Outbound Tab ---

const outboundDialogVisible = ref(false)
const outboundForm = reactive({
  id: 0,
  code: '',
  customer: '',
  status: 'Picking',
  createdDate: new Date().toLocaleDateString('en-CA'),
})

const resetOutboundForm = () => {
  outboundForm.id = 0
  outboundForm.code = `WO${new Date().getFullYear().toString().slice(-2)}${(new Date().getMonth() + 1).toString().padStart(2, '0')}00${outboundData.value.length + 1}`
  outboundForm.customer = ''
  outboundForm.status = 'Picking'
  outboundForm.createdDate = new Date().toLocaleDateString('en-CA')
}

const handleAddOutbound = () => {
  resetOutboundForm()
  outboundDialogVisible.value = true
}

const handleOutboundSubmit = () => {
  outboundForm.id = Date.now()
  outboundData.value.unshift({ ...outboundForm })
  outboundDialogVisible.value = false
  ElMessage({
    type: 'success',
    message: 'Tạo mới thành công',
  })
}

// --- Mock Data and CRUD Logic for Transfer Tab ---

const transferDialogVisible = ref(false)
const transferForm = reactive({
  id: 0,
  code: '',
  from: 'Kho Chính',
  to: '',
  status: 'In Transit',
  createdDate: new Date().toLocaleDateString('en-CA'),
})

const resetTransferForm = () => {
  transferForm.id = 0
  transferForm.code = `TF${new Date().getFullYear().toString().slice(-2)}${(new Date().getMonth() + 1).toString().padStart(2, '0')}00${transferData.value.length + 1}`
  transferForm.from = 'Kho Chính'
  transferForm.to = ''
  transferForm.status = 'In Transit'
  transferForm.createdDate = new Date().toLocaleDateString('en-CA')
}

const handleAddTransfer = () => {
  resetTransferForm()
  transferDialogVisible.value = true
}

const handleTransferSubmit = () => {
  transferForm.id = Date.now()
  transferData.value.unshift({ ...transferForm })
  transferDialogVisible.value = false
  ElMessage({
    type: 'success',
    message: 'Tạo mới thành công',
  })
}

</script>

<style scoped>
.inventory-container {
  border: none;
}
.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.action-bar h2 {
  font-size: 20px;
  margin: 0;
  color: #303133;
}
.table-placeholder {
  height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
  background-color: #fafafa;
  border: 1px dashed #dcdfe6;
  border-radius: 4px;
}
</style>

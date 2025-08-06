<template>
  <el-card shadow="never">
    <div class="action-bar">
      <h2>Danh sách sản phẩm</h2>
      <el-button type="primary" :icon="Plus" @click="handleAdd">Tạo sản phẩm</el-button>
    </div>
    <el-table :data="productData" stripe style="width: 100%">
      <el-table-column prop="sku" label="SKU" width="150" />
      <el-table-column prop="name" label="Tên sản phẩm" width="250" />
      <el-table-column prop="category" label="Danh mục" />
      <el-table-column prop="brand" label="Thương hiệu" />
      <el-table-column prop="costPrice" label="Giá nhập" />
      <el-table-column prop="sellingPrice" label="Giá bán" />
      <el-table-column label="Hành động" width="180">
        <template #default="scope">
          <el-button size="small" @click="handleEdit(scope.row)">Sửa</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row.id)">Xóa</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>

  <!-- Product Dialog -->
  <el-dialog v-model="dialogVisible" :title="isEdit ? 'Sửa sản phẩm' : 'Tạo sản phẩm'" width="600px">
    <el-form :model="form" label-width="120px">
      <el-form-item label="SKU">
        <el-input v-model="form.sku" />
      </el-form-item>
      <el-form-item label="Tên sản phẩm">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="Danh mục">
        <el-input v-model="form.category" />
      </el-form-item>
      <el-form-item label="Thương hiệu">
        <el-input v-model="form.brand" />
      </el-form-item>
      <el-form-item label="Giá nhập">
        <el-input-number v-model="form.costPrice" :precision="2" :step="1000" />
      </el-form-item>
      <el-form-item label="Giá bán">
        <el-input-number v-model="form.sellingPrice" :precision="2" :step="1000" />
      </el-form-item>
      <el-form-item label="Barcode">
        <el-input v-model="form.barcode" />
      </el-form-item>
      <el-form-item label="QR Code">
        <el-input v-model="form.qrCode" />
      </el-form-item>
      <el-form-item label="Yêu cầu quản lý">
        <el-checkbox v-model="form.requiresBatch" label="Theo Lô (Batch)" />
        <el-checkbox v-model="form.requiresSerial" label="Theo Serial" />
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
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const dialogVisible = ref(false)
const isEdit = ref(false)

const form = reactive({
  id: 0,
  sku: '',
  name: '',
  category: '',
  brand: '',
  costPrice: 0,
  sellingPrice: 0,
  barcode: '',
  qrCode: '',
  requiresBatch: false,
  requiresSerial: false,
})

const productData = ref([
  { id: 1, sku: 'SKU001', name: 'Sản phẩm 1', category: 'Điện tử', brand: 'Brand A', costPrice: 100000, sellingPrice: 150000, barcode: '123456789012', qrCode: 'QR-001', requiresBatch: true, requiresSerial: false },
  { id: 2, sku: 'SKU002', name: 'Sản phẩm 2', category: 'Hàng tiêu dùng', brand: 'Brand B', costPrice: 20000, sellingPrice: 30000, barcode: '123456789013', qrCode: 'QR-002', requiresBatch: false, requiresSerial: true },
])

const resetForm = () => {
  form.id = 0
  form.sku = `SKU00${productData.value.length + 1}`
  form.name = ''
  form.category = ''
  form.brand = ''
  form.costPrice = 0
  form.sellingPrice = 0
  form.barcode = ''
  form.qrCode = ''
  form.requiresBatch = false
  form.requiresSerial = false
}

const handleAdd = () => {
  isEdit.value = false
  resetForm()
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  isEdit.value = true
  Object.assign(form, row)
  dialogVisible.value = true
}

const handleDelete = (id: number) => {
  ElMessageBox.confirm('Bạn có chắc chắn muốn xóa sản phẩm này không?', 'Cảnh báo', {
    confirmButtonText: 'Xóa',
    cancelButtonText: 'Hủy',
    type: 'warning',
  }).then(() => {
    productData.value = productData.value.filter(item => item.id !== id)
    ElMessage({ type: 'success', message: 'Xóa thành công' })
  })
}

const handleSubmit = () => {
  if (isEdit.value) {
    const index = productData.value.findIndex(item => item.id === form.id)
    if (index !== -1) {
      productData.value[index] = { ...form }
    }
  } else {
    form.id = Date.now()
    productData.value.unshift({ ...form })
  }
  dialogVisible.value = false
  ElMessage({ type: 'success', message: isEdit.value ? 'Cập nhật thành công' : 'Tạo mới thành công' })
}
</script>

<style scoped>
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
</style>

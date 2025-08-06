<template>
  <el-card shadow="never">
    <div class="action-bar">
      <h2>Danh sách nhà cung cấp</h2>
      <el-button type="primary" :icon="Plus" @click="handleAdd">Tạo nhà cung cấp</el-button>
    </div>
    <el-table :data="supplierData" stripe style="width: 100%">
      <el-table-column prop="code" label="Mã NCC" width="150" />
      <el-table-column prop="name" label="Tên nhà cung cấp" width="250" />
      <el-table-column prop="contactPerson" label="Người liên hệ" />
      <el-table-column prop="email" label="Email" />
      <el-table-column prop="phone" label="Điện thoại" />
      <el-table-column label="Hành động" width="180">
        <template #default="scope">
          <el-button size="small" @click="handleEdit(scope.row)">Sửa</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row.id)">Xóa</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>

  <!-- Supplier Dialog -->
  <el-dialog v-model="dialogVisible" :title="isEdit ? 'Sửa nhà cung cấp' : 'Tạo nhà cung cấp'" width="600px">
    <el-form :model="form" label-width="120px">
      <el-form-item label="Mã NCC">
        <el-input v-model="form.code" />
      </el-form-item>
      <el-form-item label="Tên NCC">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="Người liên hệ">
        <el-input v-model="form.contactPerson" />
      </el-form-item>
      <el-form-item label="Email">
        <el-input v-model="form.email" />
      </el-form-item>
      <el-form-item label="Điện thoại">
        <el-input v-model="form.phone" />
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
  code: '',
  name: '',
  contactPerson: '',
  email: '',
  phone: '',
})

const supplierData = ref([
  { id: 1, code: 'NCC001', name: 'Nhà Cung Cấp A', contactPerson: 'Nguyễn Văn A', email: 'a@example.com', phone: '0901234567' },
  { id: 2, code: 'NCC002', name: 'Công ty TNHH B', contactPerson: 'Trần Thị B', email: 'b@example.com', phone: '0901234568' },
  { id: 3, code: 'NCC003', name: 'Nhà Cung Cấp C', contactPerson: 'Lê Văn C', email: 'c@example.com', phone: '0901234569' },
])

const resetForm = () => {
  form.id = 0
  form.code = `NCC00${supplierData.value.length + 1}`
  form.name = ''
  form.contactPerson = ''
  form.email = ''
  form.phone = ''
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
  ElMessageBox.confirm('Bạn có chắc chắn muốn xóa nhà cung cấp này không?', 'Cảnh báo', {
    confirmButtonText: 'Xóa',
    cancelButtonText: 'Hủy',
    type: 'warning',
  }).then(() => {
    supplierData.value = supplierData.value.filter(item => item.id !== id)
    ElMessage({ type: 'success', message: 'Xóa thành công' })
  })
}

const handleSubmit = () => {
  if (isEdit.value) {
    const index = supplierData.value.findIndex(item => item.id === form.id)
    if (index !== -1) {
      supplierData.value[index] = { ...form }
    }
  } else {
    form.id = Date.now()
    supplierData.value.unshift({ ...form })
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

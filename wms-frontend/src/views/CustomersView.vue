<template>
  <el-card shadow="never">
    <div class="action-bar">
      <h2>Danh sách khách hàng</h2>
      <el-button type="primary" :icon="Plus" @click="handleAdd">Tạo khách hàng</el-button>
    </div>
    <el-table :data="customerData" stripe style="width: 100%">
      <el-table-column prop="code" label="Mã KH" width="150" />
      <el-table-column prop="name" label="Tên khách hàng" width="250" />
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

  <!-- Customer Dialog -->
  <el-dialog v-model="dialogVisible" :title="isEdit ? 'Sửa khách hàng' : 'Tạo khách hàng'" width="600px">
    <el-form :model="form" label-width="120px">
      <el-form-item label="Mã KH">
        <el-input v-model="form.code" />
      </el-form-item>
      <el-form-item label="Tên khách hàng">
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

const customerData = ref([
  { id: 1, code: 'KH001', name: 'Khách hàng X', contactPerson: 'Nguyễn Thị X', email: 'x@example.com', phone: '0987654321' },
  { id: 2, code: 'KH002', name: 'Công ty Z', contactPerson: 'Trần Văn Z', email: 'z@example.com', phone: '0987654322' },
])

const resetForm = () => {
  form.id = 0
  form.code = `KH00${customerData.value.length + 1}`
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
  ElMessageBox.confirm('Bạn có chắc chắn muốn xóa khách hàng này không?', 'Cảnh báo', {
    confirmButtonText: 'Xóa',
    cancelButtonText: 'Hủy',
    type: 'warning',
  }).then(() => {
    customerData.value = customerData.value.filter(item => item.id !== id)
    ElMessage({ type: 'success', message: 'Xóa thành công' })
  })
}

const handleSubmit = () => {
  if (isEdit.value) {
    const index = customerData.value.findIndex(item => item.id === form.id)
    if (index !== -1) {
      customerData.value[index] = { ...form }
    }
  } else {
    form.id = Date.now()
    customerData.value.unshift({ ...form })
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
